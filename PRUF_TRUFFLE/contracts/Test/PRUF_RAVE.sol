/*--------------------------------------------------------PRüF0.9.0
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
pragma solidity 0.8.7;

import "../Resources/PRUF_BASIC.sol";
import "../Imports/security/ReentrancyGuard.sol";

contract RAVE is BASIC {
    constructor() {
        //THIS CONTRACT LAUNCHES PAUSED BY DEFAULT JUST IN CASE YOU ARE AN IDIOT
        // _pause();
    }

    /**
     * @dev Verify caller holds Nodetoken
     * @param _node - node for which caller is queried for ownership
     */
    modifier isNodeHolder(uint32 _node) {
        require(
            (NODE_TKN.ownerOf(_node) == _msgSender()),
            "RAVE:MOD-INH: _msgSender() does not hold node token"
        );
        _;
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

    /**
     * @dev Authorize / Deauthorize users for an address be permitted to make record modifications
     * @dev only useful for custody types that designate user adresses (type1...)
     * @param _node - node that user is being authorized in
     * @param _addrHash - hash of address belonging to user being authorized
     * @param _userType - authority level for user (see docs)
     */
    function addUser(
        uint32 _node,
        bytes32 _addrHash,
        uint8 _userType
    ) external whenNotPaused isNodeHolder(_node) {
        //^^^^^^^checks^^^^^^^^^

        NODE_MGR.addUser(_node, _addrHash, _userType);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set import status for foreign nodes
     * @param _thisNode - node to dis/allow importing into
     * @param _otherNode - node to be imported
     * @param _newStatus - importability status (0=not importable, 1=importable >1 =????)
     */
    function updateImportStatus(
        uint32 _thisNode,
        uint32 _otherNode,
        uint256 _newStatus
    ) external whenNotPaused isNodeHolder(_thisNode) {
        NODE_MGR.updateImportStatus(_thisNode, _otherNode, _newStatus);
    }

    /**
     * @dev Modifies an node Node content adressable storage data pointer
     * @param _node - node being modified
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function updateNodeCAS(
        uint32 _node,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external whenNotPaused isNodeHolder(_node) {
        //^^^^^^^checks^^^^^^^^^

        NODE_MGR.updateNodeCAS(_node, _CAS1, _CAS2);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set function costs and payment address per Node, in PRUF(18 decimals)
     * @param _node - node to set service costs
     * @param _service - service type being modified (see service types in ZZ_PRUF_DOCS)
     * @param _serviceCost - 18 decimal fee in PRUF associated with specified service
     * @param _paymentAddress - address to have _serviceCost paid to
     */
    function setOperationCosts(
        uint32 _node,
        uint16 _service,
        uint256 _serviceCost,
        address _paymentAddress
    ) external whenNotPaused isNodeHolder(_node) {
        //^^^^^^^checks^^^^^^^^^

        NODE_MGR.setOperationCosts(
            _node,
            _service,
            _serviceCost,
            _paymentAddress
        );
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Configure the immutable data in an Node one time
     * @param _node - node being modified
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _refAddress - address permanently tied to node
     */
    function setNonMutableData(
        uint32 _node,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress,
        uint8 _switches
    ) external whenNotPaused isNodeHolder(_node) {
        NODE_MGR.setNonMutableData(
            _node,
            _managementType,
            _storageProvider,
            _refAddress,
            _switches
        );
    }

    /**
     * @dev extended node data setter
     * @param _node - node being configured
     * @param _u8a ExtendedNodeData
     * @param _u8b ExtendedNodeData
     * @param _u16c ExtendedNodeData
     * @param _u32d ExtendedNodeData
     * @param _u32e ExtendedNodeData
     */
    function setExtendedNodeData(
        uint32 _node,
        uint8 _u8a,
        uint8 _u8b,
        uint16 _u16c,
        uint32 _u32d,
        uint32 _u32e
    ) external whenNotPaused isNodeHolder(_node) {
        NODE_MGR.setExtendedNodeData(_node, _u8a, _u8b, _u16c, _u32d, _u32e);
    }
}
