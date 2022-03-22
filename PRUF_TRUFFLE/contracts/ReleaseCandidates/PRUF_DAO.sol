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
 * DAO FRONT END
 * //DPS:TEST NEW CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Resources/RESOURCE_PRUF_DAO_INTERFACES.sol";

contract DAO is BASIC {
    bytes32 public constant DAO_VETO_ROLE = keccak256("DAO_VETO_ROLE");

    address internal DAO_STOR_Address;
    DAO_STOR_Interface internal DAO_STOR;

    event REPORT(bytes32 _motion, string _msg);

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

        UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        DAO_STOR_Address = STOR.resolveContractAddress("DAO_STOR");
        DAO_STOR = DAO_STOR_Interface(DAO_STOR_Address);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Crates an new Motion in DAO_STOR
     * Originating Address:
     *      holds > .9_ pruf
     * @param _motion the hash of the referring contract address, function name, and parmaeters
     */
    function createMotion(bytes32 _motion) external returns (bytes32) {
        require(
            UTIL_TKN.balanceOf(_msgSender()) > 99999999999999999, // 1 PRUF MINIMUM REQUIRED TO CREATE A MOTION
            "DAO:CM:Proposer must hold =>1 PRUF"
        );
        //^^^^^^^checks^^^^^^^^^

        return DAO_STOR.adminCreateMotion(_motion, _msgSender());
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Admin veto for incrementel transfer of power to the DAO---------CAUTION:CENTRALIZATION RISK
     * @param _motion // propsed action
     */
    function veto(
        bytes32 _motion // propsed action
    ) external {
        require(
            hasRole(DAO_VETO_ROLE, _msgSender()),
            "DAO:VETO:Calling address does not have VETO_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        DAO_STOR.adminVeto(_motion);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * Placeholder voting until node staking becomes complete.
     * The final version contract will query the staked amount to calculate voting power.
     * @dev Node voting
     * @param _motion // propsed action
     * @param _node // node doing the voting
     * @param _yn // yeah (1) or neigh (0)
     */
    function vote(
        bytes32 _motion, // propsed action
        uint32 _node, // node doing the voting
        uint8 _yn // yeah (1) or neigh (0)
    ) external {
        require(
            NODE_TKN.ownerOf(_node) == _msgSender(),
            "DAO:VOTE:Voter does not hold specified Node"
        );
        //^^^^^^^checks^^^^^^^^^

        DAO_STOR.adminVote(_motion, _node, 1000, _yn, _msgSender()); // Votes with 1000 votes for each node
        //^^^^^^^interactions^^^^^^^^^
    }
}
