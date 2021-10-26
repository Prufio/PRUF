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
 * PRUF PRUF_RAVE
 * Simple identity provider for minting new nodes and pruf like a Sheik.
 * DO NOT LAUNCH THIS CONTRACT ON MAINNET LOL 
 *
 * CONTRACT MUST BE GIVEN ID_PROVIDER_ROLE IN NODE_MGR and MINTER_ROLE in UTIL_TKN
 -----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_BASIC.sol";
import "../Imports/security/ReentrancyGuard.sol";

contract RAVE is BASIC {
    constructor() {
        //THIS CONTRACT LAUNCHES PAUSED BY DEFAULT JUST IN CASE YOU ARE AN IDIOT
        _pause();
    }

    function bumpMe() external nonReentrant whenNotPaused {
        UTIL_TKN.mint(_msgSender(), 10000000000000000000000);
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
    ) external nonReentrant whenNotPaused returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        uint256 mintedNode = NODE_MGR.purchaseNode(
            _name,
            _nodeRoot,
            _custodyType,
            _CAS1,
            _CAS2,
            _mintNodeFor
        );

        return mintedNode;
        //^^^^^^^interactions^^^^^^^^^
    }
}
