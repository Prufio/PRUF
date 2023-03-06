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
 * DAO STATEFULNESS, ARCHIVAL STORAGE, AND INVIOLATE LOGIC
 * //DPS:TEST NEW CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Resources/RESOURCE_PRUF_DAO_INTERFACES.sol";

contract DAO_STOR is BASIC {
    //SET THESE UNDER DAO CONTROL
    uint32 public quorum = 5;
    uint32 public passingMargin = 60; //in percent
    uint32 public maximumVote = 100000; //max vote in whole PRUF staked (future implementation)

    uint256 currentMotion;

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    bytes32 public constant DAO_ADMIN_ROLE = keccak256("DAO_ADMIN_ROLE");
    bytes32 public constant DAO_LAYER_ROLE = keccak256("DAO_LAYER_ROLE");

    address internal CLOCK_Address;
    CLOCK_Interface internal CLOCK;

    mapping(bytes32 => Motion) private motions; //motionSignature => motion data -- motion record
    mapping(bytes32 => mapping(uint32 => Votes)) private nodeVoteHistory; //motionSignature => NodeId => vote -- node voting history by motion
    mapping(uint256 => mapping(uint32 => uint32)) private votingActivity; //epoch => voterNodeId => votingOccurences -- node voting participation by epoch
    mapping(uint256 => bytes32) private indexedMotions; //index =>  motions enumerated
    mapping(bytes32 => mapping(address => uint8)) private yesVoters; //addresses that voted yes

    event REPORT(bytes32 _motion, string _msg);
    event VOTE(bytes32 _motion, uint32 _vote, uint8 _yn, string _msg);

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DAO_ADMIN_ROLE
     */
    modifier isDAOadmin() {
        require(
            hasRole(DAO_ADMIN_ROLE, _msgSender()),
            "DAO_STOR:MOD-IDA:Calling address is not DAO admin"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DAO_LAYER_ROLE
     */
    modifier isDAOlayer() {
        require(
            hasRole(DAO_LAYER_ROLE, _msgSender()),
            "DAO_STOR:MOD-IDL:Calling address is not DAO layer contract"
        );
        _;
    }

    /**
     * @dev Default param setter
     * @param _quorum new value for minimum required voters to create a quorum
     */
    function setQuorum(uint32 _quorum) external isDAOlayer {
        uint256 mintedNodes;

        (mintedNodes, , ) = NODE_MGR.currentNodePricingInfo();
        mintedNodes = mintedNodes - 1000000; //nodes minted inside ecosystem start at ID 1000000

        require(
            _quorum < ((mintedNodes / 20) + 10), 
            "DAO_STOR:SQ:proposed Quorum > 5% (+10) of the indigenous node population"
        );
        //^^^^^^^checks^^^^^^^^^

        quorum = _quorum;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Default param setter
     * @param _passingMargin new value for minimum required passing margin for votes, in whole percents
     */
    function setPassingMargin(uint32 _passingMargin) external isDAOlayer {
        require(
            (_passingMargin > 50) && (_passingMargin < 71), 
            "DAO_STOR:SPM:Passing margin must be 51-70"
        );
        //^^^^^^^checks^^^^^^^^^

        passingMargin = _passingMargin;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Default param setter
     * @param _max new value for maximum votes per node
     */
    function setMaxVote(uint32 _max) external isDAOlayer {
        require(
            (_max < 100000000) && (_max <= (maximumVote * 2)),
            "DAO_STOR:SMV:Maximum vote cannot be more than 100 million or more than twice the previous value"
        );
        //^^^^^^^checks^^^^^^^^^

        maximumVote = _max;
        //^^^^^^^effects^^^^^^^^^
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

        NODE_MGR_Address = STOR.resolveContractAddress("NODE_MGR");
        NODE_MGR = NODE_MGR_Interface(NODE_MGR_Address);

        CLOCK_Address = STOR.resolveContractAddress("CLOCK");
        CLOCK = CLOCK_Interface(CLOCK_Address);

        UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Crates an new Motion in the motions map
     * Originating Address:
     *      holds > .9_ pruf
     * @param _motion the hash of the referring contract address, function name, and parmaeters
     * @param _proposer proposing address
     */
    function adminCreateMotion(bytes32 _motion, address _proposer)
        external
        isDAOadmin
        returns (bytes32)
    {
        bytes32 motion = keccak256(
            abi.encode(_motion, (CLOCK.thisEpoch() + 2))
        );
        require(
            motions[motion].votesFor == 0,
            "DAO_STOR:CM:Motion exists - wait for or finalize motion in progress"
        ); // Motion must not be currently proposed or approved

        //^^^^^^^checks^^^^^^^^^

        motions[motion].proposer = _proposer;
        motions[motion].votesFor = 1; //put motion in proposed status...1 vote for and against
        motions[motion].votesAgainst = 1; //put motion in proposed status...1 vote for and against
        motions[motion].voterCount = 0; //initialize JIC is a repeat
        motions[motion].votingEpoch = CLOCK.thisEpoch() + 1; //voting can start in one epoch

        indexedMotions[currentMotion] = motion; //set enumaratable
        currentMotion++; //increment enumeration for next motion
        //^^^^^^^effects^^^^^^^^^

        emit REPORT(motion, "Motion Created");
        return (motion); //return the finished signature hash of the motion
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Admin veto for incrementel transfer of power to the DAO---------CAUTION:CENTRALIZATION RISK
     * @param _motion // propsed action to veto
     */
    function adminVeto(bytes32 _motion) external isDAOadmin {
        require(
            motions[_motion].votesFor != 0,
            "DAO_STOR:veto:Motion not in 'proposed' status"
        );
        //^^^^^^^checks^^^^^^^^^

        motions[_motion].votesFor = 0;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT(_motion, "Vetoed");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev DAO admin will be given to a trusted contract that allows nodes to cast their delegated votes---------CAUTION:CENTRALIZATION RISK
     * @param _motion // propsed action
     * @param _node // node doing the voting
     * @param _votes //# of votes
     * @param _yn // yeah (1) or neigh (0)
     * @param _voter //voting address
     */
    function adminVote(
        bytes32 _motion, // propsed action
        uint32 _node, // node doing the voting
        uint32 _votes, //# of votes
        uint8 _yn, // yeah (1) or neigh (0)
        address _voter //voting address
    ) external isDAOadmin {
        require(
            motions[_motion].votesFor != 0,
            "DAO_STOR:vote:Motion not in 'proposed' status"
        );
        require(
            CLOCK.thisEpoch() == (motions[_motion].votingEpoch),
            "DAO_STOR:vote:Voting window not open"
        );
        require(
            nodeVoteHistory[_motion][_node].votes == 0,
            "DAO_STOR:vote:Node has already cast a vote on this motion"
        );
        require(
            (_yn == 0) || (_yn == 1),
            "DAO_STOR:vote:vote type must be 1 or 0 only"
        );
        //^^^^^^^checks^^^^^^^^^

        uint32 votes = _votes;
        if (votes > maximumVote) {
            votes = maximumVote;
        } // truncate votes cast to maximumVote

        motions[_motion].voterCount++; //increment counter of participating voters

        if (_yn == 1) {
            //cast votes for
            motions[_motion].votesFor = motions[_motion].votesFor + votes;
        } else {
            //cast votes against
            motions[_motion].votesAgainst =
                motions[_motion].votesAgainst +
                votes;
        }

        //store voting metrics
        nodeVoteHistory[_motion][_node].votes = _votes;
        nodeVoteHistory[_motion][_node].yn = _yn;
        yesVoters[_motion][_voter] = _yn;
        votingActivity[CLOCK.thisEpoch()][_node]++;
        //^^^^^^^effects^^^^^^^^^

        emit VOTE(_motion, votes, _yn, "Vote Recorded");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Throws if a resolution is not approved. clears the motion if successful, returning control to the calling contract
     * @param _motion the motion hash to check
     * @param _caller original calling address
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function verifyResolution(bytes32 _motion, address _caller)
        external
        isDAOlayer
    {
        Motion memory thisMotion = motions[_motion];

        require(
            CLOCK.thisEpoch() == thisMotion.votingEpoch + 1,
            "DAO_STOR:VR:motion is not valid in this epoch"
        );

        require(
            thisMotion.proposer != address(0),
            "DAO_STOR:VR:resolution has already been exercised or does not exist"
        );

        require(
            thisMotion.votesFor > thisMotion.votesAgainst,
            "DAO_STOR:VR:specified motion was rejected by majority"
        );

        require(
            thisMotion.voterCount >= quorum,
            "DAO_STOR:VR:specified motion failed to gain a quorum"
        );

        require(
            ((uint256(thisMotion.votesFor) * 100) /
                (uint256(thisMotion.votesFor) +
                    uint256(thisMotion.votesAgainst))) >= passingMargin,
            "DAO_STOR:VR:specified motion failed to gain required majority margin"
        );

        require(
            (thisMotion.proposer == _caller) ||
                (yesVoters[_motion][_caller] == 1),
            "DAO_STOR:VR:Caller not authorized to execute resolution"
        );
        //^^^^^^^checks^^^^^^^^^

        motions[_motion].proposer = address(0); //mark as motion as exercised (cannot be reused)
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Getter for motions
     * @param _motionIndex the index of the motion hash to get
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getMotionByIndex(uint256 _motionIndex)
        external
        view
        returns (bytes32)
    {
        //^^^^^^^checks^^^^^^^^^

        return (indexedMotions[_motionIndex]);
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
        returns (
            address,
            uint32,
            uint32,
            uint32,
            uint256
        )
    {
        //^^^^^^^checks^^^^^^^^^

        Motion memory motion = motions[_motion];
        return (
            motion.proposer,
            motion.votesFor,
            motion.votesAgainst,
            motion.voterCount,
            motion.votingEpoch
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Getter for motions
     * @param _motion the motion hash to get
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getMotionDataStruct(bytes32 _motion)
        external
        view
        returns (Motion memory)
    {
        //^^^^^^^checks^^^^^^^^^

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
        //^^^^^^^checks^^^^^^^^^

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
        //^^^^^^^checks^^^^^^^^^
        return (nodeVoteHistory[_motion][_node]);
        //^^^^^^^interactions^^^^^^^^^
    }
}