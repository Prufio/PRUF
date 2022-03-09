/*--------------------------------------------------------PRüF0.8.7
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 * DAO Specification V0.01
 * //DPS:TEST NEW CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Resources/RESOURCE_PRUF_DAO_INTERFACES.sol";

contract DAO is BASIC {
    //SET THESE UNDER DAO CONTROL
    uint32 quorum = 1;
    uint32 passingMargin = 60; //in percent
    uint32 maximumVote = 100000; //max vote in whole PRUF staked (future implementation)

    uint256 currentProposal;

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    bytes32 public constant DAO_ADMIN_ROLE = keccak256("DAO_ADMIN_ROLE");
    bytes32 public constant DAO_LAYER_ROLE = keccak256("DAO_LAYER_ROLE");

    address internal CLOCK_Address;
    CLOCK_Interface internal CLOCK;

    mapping(bytes32 => Motion) private motions; //proposalSignature => Proposal data -- proposal record
    mapping(bytes32 => mapping(uint32 => Votes)) private nodeVoteHistory; //proposalSignature => NodeId => vote -- node voting history by proposal
    mapping(uint256 => mapping(uint32 => uint32)) private votingActivity; //epoch => voterNodeId => votingOccurences -- node voting participation by epoch
    mapping(uint256 => bytes32) private proposals; //index =>  proposals, enumerable
    mapping(bytes32 => mapping(address => uint8)) private yesVoters; //addresses that voted yes

    event REPORT(bytes32 _motion, string _msg);
    event VOTE(bytes32 _motion, uint32 _vote, uint8 _yn, string _msg);

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DAO_ROLE
     */
    modifier isDAOadmin() {
        require(
            hasRole(DAO_ADMIN_ROLE, _msgSender()),
            "DAO:MOD-IDA:Calling address is not DAO admin"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DAO_ROLE
     */
    modifier isDAOlayer() {
        require(
            hasRole(DAO_LAYER_ROLE, _msgSender()),
            "DAO:MOD-IDL:Calling address is not DAO layer contract"
        );
        _;
    }

    /**
     * @dev Resolve contract addresses from STOR
     */
    function resolveContractAddresses()
        external
        override
        nonReentrant
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^

        NODE_TKN_Address = STOR.resolveContractAddress("NODE_TKN");
        NODE_TKN = NODE_TKN_Interface(NODE_TKN_Address);

        CLOCK_Address = STOR.resolveContractAddress("CLOCK");
        CLOCK = CLOCK_Interface(CLOCK_Address);
    }

    /**
     * @dev Crates an new Motion in the motions map
     * Originating Address:
     *      holds > .9_ pruf
     * @param _motion the hash of the referring contract address, function name, and parmaeters
     */
    function createMotion(bytes32 _motion) external returns (bytes32) {
        bytes32 motion = keccak256(
            abi.encodePacked(_motion, (CLOCK.thisEpoch() + 2))
        );
        require(
            motions[motion].votesFor == 0,
            "DAO:CM:Motion exists - wait for or finalize motion in progress"
        ); // Motion must not be currently proposed or approved

        require(
            UTIL_TKN.balanceOf(_msgSender()) > 99999999999999999, // 1 PRUF MINIMUM REQUIRED TO CREATE A MOTION
            "DAO:CM:Proposer must hold =>1 PRUF"
        );
        //^^^^^^^checks^^^^^^^^^

        motions[motion].proposer = _msgSender();
        motions[motion].votesFor = 1; //put motion in proposed status
        motions[motion].votesAgainst = 1; //put motion in proposed status
        motions[motion].voterCount = 0;
        motions[motion].votingEpoch = CLOCK.thisEpoch() + 1; //voting will start in one epoch

        proposals[currentProposal] = motion;
        currentProposal++;

        emit REPORT(motion, "Motion Created");
        return (motion);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Admin voting : to be depricated ---------CAUTION:CENTRALIZATION RISK
     * @param _motion // propsed action
     * @param _node // node doing the voting
     * @param _votes //# of votes
     * @param _yn // yeah (1) or neigh (0)
     */
    function adminVote(
        bytes32 _motion, // propsed action
        uint32 _node, // node doing the voting
        uint32 _votes, //# of votes
        uint8 _yn // yeah (1) or neigh (0)
    ) external isDAOadmin {
        require(
            motions[_motion].votesFor != 0,
            "DAO:AV:Motion not in 'proposed' status"
        );
        require(
            CLOCK.thisEpoch() == (motions[_motion].votingEpoch),
            "DAO:AV:Voting window not open"
        );
        require(
            nodeVoteHistory[_motion][_node].votes == 0,
            "DAO:AV:Node has already cast a vote on this motion"
        );
        //^^^^^^^checks^^^^^^^^^

        uint32 votes = _votes;
        if (votes > maximumVote) {
            votes = maximumVote;
        }

        motions[_motion].voterCount++; //increment count of voters participating

        if (_yn == 1) {
            motions[_motion].votesFor = motions[_motion].votesFor + votes;
        } else {
            motions[_motion].votesAgainst =
                motions[_motion].votesAgainst +
                votes;
        }

        //^^^^^^^effects^^^^^^^^^
        recordVotingEvent(_motion, _node, _votes, _yn);

        emit VOTE(_motion, votes, _yn, "Vote Recorded");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Throws if a resolution is not approved. clears the motion if successful
     * @param _motion the motion hash to check
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function verifyResolution(bytes32 _motion, address _caller)
        external
        isDAOlayer
    {
        Motion memory thisMotion = motions[_motion];

        require(
            CLOCK.thisEpoch() == thisMotion.votingEpoch + 1,
            "DAO:VR:proposal is not valid in this epoch"
        );

        require(
            thisMotion.proposer != address(0),
            "DAO:VR:resolution has already been exercised"
        );

        require(
            thisMotion.votesFor > thisMotion.votesAgainst,
            "DAO:VR:specified proposal was rejected by majority"
        );

        require(
            thisMotion.voterCount >= quorum,
            "DAO:VR:specified proposal failed to gain a quorum"
        );

        require(
            ((uint256(thisMotion.votesFor) * 10) /
                (uint256(thisMotion.votesFor) +
                    uint256(thisMotion.votesAgainst))) >= passingMargin,
            "DAO:VR:specified proposal failed to gain required majority margin"
        );

        require(
            (thisMotion.proposer == _caller) ||
                (yesVoters[_motion][_caller] == 1),
            "DAO:VR:Caller not authorized to execute resolution"
        );

        motions[_motion].proposer = address(0); //mark as exercised
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Getter for motions
     * @param _motionIndex the index of the motion hash to get
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getMotionDataByIndex(uint256 _motionIndex)
        external
        view
        returns (Motion memory)
    {
        bytes32 proposal = proposals[_motionIndex];
        return motions[proposal];
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Getter for motions
     * @param _motion the motion hash to get
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getMotionData(bytes32 _motion)
        external
        view
        returns (Motion memory)
    {
        return motions[_motion];
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Getter for node voting participation
     * @param _epoch the epoch to check
     * @param _node the node to get voting activity for
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getNodeActivityByEpoch(uint256 _epoch, uint32 _node)
        external
        view
        returns (uint256)
    {
        return (uint256(votingActivity[_epoch][_node]));
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Getter for vote history, by motion and node
     * @param _motion the epoch to check
     * @param _node the node to get voting activity for
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getNodeVotingHistory(bytes32 _motion, uint32 _node)
        public
        view
        returns (Votes memory)
    {
        return (nodeVoteHistory[_motion][_node]);
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------INTERNAL FUNCTIONS

    /**
     * @dev Records data relevant for a voting event for vote history;
     * @param _proposal proposal signature
     * @param _node node casting the votes
     * @param _votes votes cast
     * @param _yn for or against
     */
    function recordVotingEvent(
        bytes32 _proposal,
        uint32 _node,
        uint32 _votes,
        uint8 _yn
    ) internal {
        nodeVoteHistory[_proposal][_node].votes = _votes;
        nodeVoteHistory[_proposal][_node].yn = _yn;
        yesVoters[_proposal][_msgSender()] = _yn;
        votingActivity[CLOCK.thisEpoch()][_node]++;
    }
}
