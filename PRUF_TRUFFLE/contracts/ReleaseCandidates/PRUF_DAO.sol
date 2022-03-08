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
    uint256 quorum = 1;
    uint256 passingPercentage = 60;
    uint256 maximumVote = 100000; //max vote in whole PRUF staked (future implementation)

    uint256 votingPeriod = 10 minutes; //test params
    uint256 confirmationPeriod = 2 minutes; //test params

    //uint256 votingPeriod = 10 days;
    //uint256 confirmationPeriod = 2 days;
    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    bytes32 public constant DAO_ADMIN_ROLE = keccak256("DAO_ADMIN_ROLE");
    bytes32 public constant DAO_LAYER_ROLE = keccak256("DAO_LAYER_ROLE");

    mapping(bytes32 => Motion) private motions;

    event REPORT(bytes32 _motion, string _msg);
    event VOTE(bytes32 _motion, uint256 _vote, string _msg);

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
     * @dev Crates an new Motion in the motions map
     * Originating Address:
     *      holds > .9_ pruf
     * @param _motion the hash of the referring contract address, function name, and parmaeters
     */
    function createMotion(bytes32 _motion) external {
        require(
            ((motions[_motion].status != 1) && (motions[_motion].status != 2)),
            "DAO:CM:Motion exists - wait for or finalize motion in progress"
        ); // Motion must not be currently proposed or approved
        require(
            UTIL_TKN.balanceOf(_msgSender()) > 99999999999999999, // 1 PRUF MINIMUM REQUIRED TO CREATE A MOTION
            "DAO:CM:Proposer must hold =>1 PRUF"
        );
        //^^^^^^^checks^^^^^^^^^

        delete motions[_motion]; //clear any existing data // CTS:EXAMINE should this exist?? I dont see a case where a motions status is 0 || > 2

        motions[_motion].proposer = _msgSender();
        motions[_motion].status = 1; //put motion in proposed status
        motions[_motion].proposalTime = block.timestamp;
        emit REPORT(_motion, "Motion Created");
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Admin voting : to be depricated ---------CAUTION:CENTRALIZATION RISK
     * @param _motion the motion hash to be voted on
     * @param _vote // 0 = neigh, int =
     */
    function adminVote(bytes32 _motion, uint256 _vote) external isDAOadmin {
        require(
            motions[_motion].status == 1,
            "DAO:AV:Motion not in 'proposed' status"
        );
        require(
            block.timestamp <= motions[_motion].proposalTime + votingPeriod,
            "DAO:AV:Voting window closed"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 vote = _vote;
        if (vote > maximumVote) {
            vote = maximumVote;
        }

        motions[_motion].voterCount++;
        motions[_motion].votes = motions[_motion].votes + vote;
        //^^^^^^^effects^^^^^^^^^

        emit VOTE(_motion, vote, "Vote Recorded");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Finalizes / tallys votes for a mation
     * @param _motion the motion hash to be finalized
     * also clears any expired or failed motions
     */
    function finalizeVoting(bytes32 _motion) external {
        if (
            block.timestamp >=
            motions[_motion].proposalTime + votingPeriod + confirmationPeriod
        ) {
            delete motions[_motion];
            emit REPORT(_motion, "Motion Expired");
            //^^^^^^^checks^^^^^^^^^
        } else {
            tallyVotes(_motion);
        }
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Throws if a resolution is not approved. clears the motion if successful
     * @param _motion the motion hash to check
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function verifyResolution(bytes32 _motion, address _caller) external isDAOlayer {
        require(
            motions[_motion].status == 2,
            "DAO:VR:specified proposal is not approved"
        );
        require(
            (motions[_motion].proposer == _caller) || (NODE_TKN.balanceOf(_caller) > 0),
            "DAO:VR:Caller not authorized to execute resolution"
        );

        //^^^^^^^checks^^^^^^^^^

        delete motions[_motion];
        //^^^^^^^effects^^^^^^^^^
    }

    /** CTS:EXAMINE is this supposed to be named getMotionStatus? seems to get the whole struct
     * @dev Getter for motions
     * @param _motion the motion hash to get
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getMotionStatus(bytes32 _motion)
        external
        view
        returns (Motion memory)
    {
        return motions[_motion];
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------INTERNAL FUNCTIONS

    /**
     * @dev Veriifies quorum and checks pass/fail for votes;
     * deletes failed motions
     * @param _motion the motion hash to tally
     */
    function tallyVotes(bytes32 _motion) internal {
        require(
            block.timestamp > motions[_motion].proposalTime + votingPeriod,
            "DAO:TV:Voting still open, cannot finalize"
        );
        //^^^^^^^checks^^^^^^^^^

        Motion memory thisMotion = motions[_motion];

        if (thisMotion.voterCount > quorum) {
            uint256 votePercent = ((thisMotion.votes * 100) /
                thisMotion.voterCount);
            if (votePercent >= passingPercentage) {
                motions[_motion].status = 2;
                emit REPORT(_motion, "Passed");
            } else {
                delete motions[_motion];
                emit REPORT(_motion, "Failed");
            }
        } else {
            delete motions[_motion];
            emit REPORT(_motion, "Quorum not met.");
        }
        //^^^^^^^effects^^^^^^^^^
    }
}
