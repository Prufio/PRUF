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
 *
 * Contract for minting and managing Nodes
 *
 * STATEMENT OF TERMS OF SERVICE (TOS):
 * User agrees not to intentionally claim any namespace that is a recognized or registered brand name, trade mark,
 * or other Intellectual property not belonging to the user, and agrees to voluntarily remove any name or brand found to be
 * infringing from any record that the user controls, within 30 days of notification. If notification is not possible or
 * there is no response to notification, the user agrees that the name record may be changed without their permission or cooperation.
 * Use of this software constitutes consent to the terms above.
 -----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_BASIC.sol";
import "../Imports/security/ReentrancyGuard.sol";

contract NODE_MGR is BASIC {
    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");
    uint256 private nodeTokenIndex = 1000000; //Starting index for purchased node tokens
    uint256 public node_price = 200000 ether;
    uint32 private constant startingDiscount = 9500; //Purchased nodes start with 95% profit share

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

    /**
     * @dev Verify caller holds Nodetoken of passed node
     * @param _node - node in which caller is queried for ownership
     */
    modifier isNodeHolder(uint32 _node) {
        require(
            (NODE_TKN.ownerOf(_node) == _msgSender()),
            "NM:MOD-INH: _msgSender() not authorized in Node"
        );
        _;
    }

    //--------------------------------------------Admin Related Functions--------------------------
    /**
     * @dev Set pricing for Nodes
     * @param newNodePrice - cost per node (18 decimals)
     */
    function setNodePricing(uint256 newNodePrice) external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        node_price = newNodePrice;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("node pricing Changed!"); //report access to internal parameter
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev return current node token index and price
     * @return {
         nodeTokenIndex: current token number
         Node_price: current price per node
     }
     */
    function currentNodePricingInfo() external view returns (uint256, uint256) {
        //^^^^^^^checks^^^^^^^^^

        return (nodeTokenIndex, node_price);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Mints Node token and creates an node.
     * @param _node - node to be created (unique)
     * @param _name - name to be configured to node (unique)
     * @param _nodeRoot - root of node
     * @param _custodyType - custodyType of new node (see docs)
     * @param _managementType - managementType of new node (see docs)
     * @param _storageProvider - storageProvider of new node (see docs)
     * @param _discount - discount of node (100 == 1%, 10000 == max)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     * @param _recipientAddress - address to recieve node
     */
    function createNode(
        uint32 _node,
        string calldata _name,
        uint32 _nodeRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        bytes32 _CAS1,
        bytes32 _CAS2,
        address _recipientAddress
    ) external isNodeMinter nonReentrant {
        //^^^^^^^checks^^^^^^^^^

        Node memory _newNode;
        _newNode.name = _name;
        _newNode.nodeRoot = _nodeRoot;
        _newNode.custodyType = _custodyType;
        _newNode.managementType = _managementType;
        _newNode.storageProvider = _storageProvider;
        _newNode.discount = _discount;
        _newNode.CAS1 = _CAS1;
        _newNode.CAS2 = _CAS2;

        _createNode(_newNode, _node, _recipientAddress);
        //^^^^^^^effects^^^^^^^^^
    }

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
        bytes32 _CAS2
    ) external nonReentrant returns (uint256) {
        require(
            nodeTokenIndex < 4294000000,
            "NM:PN: Only 4294000000 node tokens allowed"
        );
        require(
            (ID_MGR.trustLevel(_msgSender()) > 0),
            "NM:PN: Caller !valid PRuF_ID holder"
        );
        //^^^^^^^checks^^^^^^^^^

        nodeTokenIndex++;
        Costs memory paymentData = NODE_STOR.getServicePaymentData(
            _nodeRoot,
            1
        );

        address rootPaymentAddress = paymentData.paymentAddress; //payment for upgrade goes to root node payment address specified for service (1)

        //mint an Node token to _msgSender(), at tokenID nodeTokenIndex, with URI = root Node

        Node memory ThisNode;
        ThisNode.name = _name;
        ThisNode.nodeRoot = _nodeRoot;
        ThisNode.custodyType = _custodyType;
        ThisNode.managementType = 255; //creates nodes at managementType 255 = not yet usable(disabled),
        ThisNode.storageProvider = 0; //creates nodes at storageType 0 = not yet usable(disabled),
        ThisNode.discount = startingDiscount;
        ThisNode.CAS1 = _CAS1;
        ThisNode.CAS2 = _CAS2;
        //^^^^^^^effects^^^^^^^^^

        UTIL_TKN.trustedAgentBurn(_msgSender(), node_price / 2);
        UTIL_TKN.trustedAgentTransfer(
            _msgSender(),
            rootPaymentAddress,
            node_price - (node_price / 2)
        ); //burning 50% so we have tokens to incentivise outreach performance

        _createNode(ThisNode, uint32(nodeTokenIndex), _msgSender());

        //Set the default 11 authorized contracts
        if (_custodyType == 2) {
            STOR.enableDefaultContractsForNode(uint32(nodeTokenIndex));
        }

        return nodeTokenIndex; //returns Node # of minted token
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

        NODE_STOR.addUser(_node, _addrHash, _userType);
        //^^^^^^^interactions^^^^^^^^^
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
        require(
            NODE_STOR.getSwitchAt(_node, 1) == 0,
            "NM:UNC: CAS for node is locked and cannot be written"
        );
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.updateNodeCAS(_node, _CAS1, _CAS2);
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

        NODE_STOR.setOperationCosts(
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
        address _refAddress
    ) external whenNotPaused isNodeHolder(_node) {
        Node memory thisNode = NODE_STOR.getNodeData(_node);

        require(
            thisNode.managementType == 255,
            "NM:SNMD: Immutable node data already set"
        );
        require(
            _managementType != 255,
            "NM:SNMD: managementType = 255(Unconfigured)"
        );

        NODE_STOR.setNonMutableData(
            _node,
            _managementType,
            _storageProvider,
            _refAddress
        );
    }

    //-------------------------------------------Private functions ----------------------------------------------

    /**
     * @dev creates an node and its corresponding namespace and data fields
     * @param _newNodeData - creation Data for new Node
     * @param _newNode - Node to be created (unique)
     * @param _recipientAddress - address to recieve Node
     */
    function _createNode(
        Node memory _newNodeData,
        uint32 _newNode,
        address _recipientAddress
    ) private whenNotPaused {
        uint256 tokenId = uint256(_newNode);

        NODE_STOR.createNodeData(_newNodeData, _newNode, _msgSender());
        NODE_TKN.mintNodeToken(_recipientAddress, tokenId, "pruf.io/nodeToken");
        //^^^^^^^interactions^^^^^^^^^
    }

}
