/*--------------------------------------------------------PRüF0.8.8
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
 * PRUF NODE_MGR
 * Contract for minting new nodes using manual verification
 *
 * STATEMENT OF TERMS OF SERVICE (TOS):
 * User agrees not to intentionally claim any namespace that is a recognized or registered brand name, trade mark,
 * or other Intellectual property not belonging to the user, and agrees to voluntarily remove any name or brand found to be
 * infringing from any record that the user controls, within 30 days of notification. If notification is not possible or
 * there is no response to notification, the user agrees that the name record may be changed without their permission or cooperation.
 * Use of this software constitutes consent to the terms above.
 -----------------------------------------------------------------*/

 //MUST BE GIVEN ID_VERIFIER_ROLE IN NODE_MGR

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_BASIC.sol";
import "../Imports/security/ReentrancyGuard.sol";

contract BUILDER is BASIC {

    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");

    constructor() {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
    }

    //--------------------------------------------Modifiers--------------------------

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has NODE_MINTER_ROLE
     */
    modifier isNodeMinter() {
        require(
            hasRole(NODE_MINTER_ROLE, _msgSender()),
            "NM:MOD-INM: Must have NODE_MINTER_ROLE"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Burns (amount) tokens and mints a new Node token to the calling address
     * @param _name - chosen name of node
     * @param _nodeRoot - chosen root of node
     * @param _custodyType - chosen custodyType of node (see docs)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function purchaseNode(
        string calldata _name,
        uint32 _nodeRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2,
        address _mintNodeFor
    ) external nonReentrant isNodeMinter returns (uint256) {

        //^^^^^^^checks^^^^^^^^^

        //^^^^^^^effects^^^^^^^^^

        uint256 mintedNode = NODE_MGR.purchaseNode(_name,_nodeRoot,_custodyType,_CAS1,_CAS2,_mintNodeFor);

        return mintedNode;
        //^^^^^^^interactions^^^^^^^^^
    }

}
