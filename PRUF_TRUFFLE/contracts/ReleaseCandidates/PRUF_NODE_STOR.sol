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
 * PRUF NODE_STOR
 *
 * TODO NEED IMPORTABLE MAPPING nodeTo->nodeFrom->allowed or not.
 *
 * NODE_MGR must be given NODE_ADMIN_ROLE
 * Contract for storing Node information
 *
 * For usage-level (not administrative) functions, NODE_STOR supports indirect node references
 * via the localNodeFor[] mapping. By default, nodes will have a mirror entry in localNodeFor[], so that
 * localNodeFor[node] == node.... but in the case where a node is "twinned" from another chain, 
 * querying the a foreign origin nodeID can point to the corresponding local node -IF- the entry for
 * localNodeFor[foreignNode] is set to the corresponding local nodeID.
 * 
 * the nodeDetails[] mapping contains mappings for an external token contract/ID for use at the
 * APP layer to check minting authority (for example must hold the Node token AND the foreign token
 * in order to mint new records ) There are also extra data fields to pad the struct to two words.
 *
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

contract NODE_STOR is BASIC {
    bytes32 public constant NODE_ADMIN_ROLE = keccak256("NODE_ADMIN_ROLE");
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE"); //DPS:NEW

    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    mapping(uint32 => uint32) private localNodeFor; //lookup table for child nodes from origin nodeID
    mapping(uint32 => ExtendedNodeData) private nodeDetails; //Extended Node Data

    mapping(uint32 => mapping(uint16 => Costs)) private cost; //Cost per function by Node => Costs struct (see RESOURCE_PRUF_INTERFACES for struct definitions)
    mapping(uint32 => Node) private nodeData; //node info database Node to node struct (see RESOURCE_PRUF_INTERFACES for struct definitions)
    mapping(string => uint32) private nodeId; //name to Node resolution map

    mapping(bytes32 => mapping(uint32 => uint8)) private registeredUsers; //Authorized recorder database by Node, by address hash

    mapping(uint8 => uint8) private validStorageProviders; //storageProviders -> status (enabled or disabled)
    mapping(uint8 => uint8) private validManagementTypes; //managementTypes -> status (enabled or disabled)
    mapping(uint8 => uint8) private validCustodyTypes; //custodyTypes -> status (enabled or disabled)

    constructor() {
        nodeId[""] = 4294967295; //points the blank string name to node 4294967295 to make "" owned
    }

    //--------------------------------------------Modifiers--------------------------

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has NODE_ADMIN_ROLE
     */
    modifier isNodeAdmin() {
        require(
            hasRole(NODE_ADMIN_ROLE, _msgSender()),
            "NS:MOD-INA: Must have NODE_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DAO_ROLE //DPS:NEW
     */
    modifier isDAO() {
        require(
            hasRole(DAO_ROLE, _msgSender()),
            "NS:MOD-INA: Must have DAO_ROLE"
        );
        _;
    }

    //--------------------------------------------Administrative Setters--------------------------

    /**
     * @dev Sets the valid storage type providers.
     * @param _storageProvider - uint position for storage provider
     * @param _status - uint position for custody type status
     */
    function setStorageProviders(uint8 _storageProvider, uint8 _status)
        external
        isDAO
    {
        //^^^^^^^checks^^^^^^^^^
        validStorageProviders[_storageProvider] = _status;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Sets the valid management types.
     * @param _managementType - uint position for management type
     * @param _status - uint position for custody type status
     */
    function setManagementTypes(uint8 _managementType, uint8 _status)
        external
        isDAO
    {
        //^^^^^^^checks^^^^^^^^^
        validManagementTypes[_managementType] = _status;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Sets the valid custody types.
     * @param _custodyType - uint position for custody type
     * @param _status - uint position for custody type status
     */
    function setCustodyTypes(uint8 _custodyType, uint8 _status) external isDAO {
        //^^^^^^^checks^^^^^^^^^
        validCustodyTypes[_custodyType] = _status;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * !! to be used with great caution !!
     * This potentially breaks decentralization and must eventually be given over to DAO.
     * @dev Increases (but cannot decrease) price share for a given node
     * @param _node - node in which cost share is being modified
     * @param _newDiscount - discount(1% == 100, 10000 == max)
     */
    function changeShare(
        uint32 _node,
        uint32 _newDiscount //DPS:TEST:NEW NAME
    ) external isDAO {
        require((nodeData[_node].nodeRoot != 0), "NS:IS: node !exist");
        require(_newDiscount <= 10000, "NS:IS: Discount > 100% (10000)");
        //^^^^^^^checks^^^^^^^^^

        nodeData[_node].discount = _newDiscount;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution and only as a result of community governance action -----------
     * @dev Transfers a name from one node to another
     *   -Designed to remedy brand infringement issues. This breaks decentralization and must eventually be given
     *   -over to DAO.
     * @param _fromNode - source node
     * @param _toNode - destination node
     * @param _thisName - name to be transferred
     */
    function transferName(
        uint32 _fromNode,
        uint32 _toNode,
        string calldata _thisName
    ) external isDAO {
        require(
            nodeId[_thisName] == _fromNode,
            "NS:TN: Name not in source node"
        ); //source Node_Name must match name given

        require(
            (nodeData[_toNode].CAS1 == B320xF_), //dest node must have CAS1 set to 0xFFFF.....
            "NS:TN: Destination node not prepared for name transfer"
        );
        //^^^^^^^checks^^^^^^^^^

        nodeId[_thisName] = _toNode;
        nodeData[_toNode].name = _thisName;
        nodeData[_fromNode].name = "";
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Modifies an node Node name for its exclusive namespace
     * @param _node - node being modified
     * @param _newName - updated name associated with node (unique)
     */
    function updateNodeName(uint32 _node, string calldata _newName)
        external
        whenNotPaused
        isNodeAdmin
    {
        require( //should pass if name is same as old name or name is unassigned. Should fail if name is assigned to other node
            (nodeId[_newName] == 0) || //name is unassigned
                (keccak256(abi.encodePacked(_newName)) == //name is same as old name
                    (keccak256(abi.encodePacked(nodeData[_node].name)))),
            "NS:UNN: Name already in use"
        );
        //^^^^^^^checks^^^^^^^^^

        delete nodeId[nodeData[_node].name];

        nodeId[_newName] = _node;
        nodeData[_node].name = _newName;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Modifies the name => nodeid name resolution mapping
     * @param _node - node being mapped to the name
     * @param _name - namespace being remapped
     */
    function setNodeIdForName(uint32 _node, string memory _name)
        external
        isNodeAdmin
    {
        delete nodeId[_name];
        if (
            keccak256(abi.encodePacked(_name)) !=
            keccak256(abi.encodePacked(""))
        ) {
            nodeId[_name] = _node;
        }
    }

    /**
     * !! -------- to be used with great caution -----------
     * @dev Modifies an Node with minimal controls
     * note that a node can be diasbled by setting the management type to an invalid value (or 0) //DPS:TEST
     * @param _node - node to be modified
     * @param _nodeRoot - root of node
     * @param _custodyType - custodyType of node (see docs)
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _discount - discount of node (100 == 1%, 10000 == max)
     * @param _refAddress - referance address associated with an node
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function modifyNode(
        uint32 _node,
        uint32 _nodeRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        address _refAddress,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external isDAO nonReentrant {
        Node memory _ac = nodeData[_nodeRoot];
        uint256 tokenId = uint256(_node);

        require((tokenId != 0), "NS:AMAC: Node = 0"); //sanity check inputs
        require(_discount <= 10000, "NS:AMAC: Discount > 10000 (100%)");
        require( //has valid root
            (_ac.custodyType == 3) || (_nodeRoot == _node),
            "NS:AMAC: Root !exist"
        );
        require(NODE_TKN.tokenExists(tokenId) == 170, "NS:AMAC: Node !exist");

        //^^^^^^^checks^^^^^^^^^

        nodeData[_node].nodeRoot = _nodeRoot;
        nodeData[_node].discount = _discount;
        nodeData[_node].custodyType = _custodyType;
        nodeData[_node].managementType = _managementType;
        nodeData[_node].storageProvider = _storageProvider;
        nodeData[_node].referenceAddress = _refAddress;
        nodeData[_node].CAS1 = _CAS1;
        nodeData[_node].CAS2 = _CAS2;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Administratively Deauthorize address be permitted to mint or modify records
     * @dev only useful for custody types that designate user adresses (type1...)
     * @param _node - node that user is being deauthorized in
     * @param _addrHash - hash of address to deauthorize
     * DPS:TEST:NEW
     */
    function blockUser(uint32 _node, bytes32 _addrHash) external isDAO {
        //^^^^^^^checks^^^^^^^^^

        registeredUsers[_addrHash][_node] = 0; //deauth node
        registeredUsers[_addrHash][0]--; //decrease user count
        //^^^^^^^effects^^^^^^^^^
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
    ) external whenNotPaused isNodeAdmin {
        require(
            (nodeData[_node].switches & (1 << (0))) == 0, //getSwitchAt(_node, 1) == 0
            "NS:UNC: CAS for node is locked and cannot be written"
        );
        //^^^^^^^checks^^^^^^^^^

        nodeData[_node].CAS1 = _CAS1;
        nodeData[_node].CAS2 = _CAS2;

        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Modifies node.switches bitwise (see NODE option switches in ZZ_PRUF_DOCS)
     * @param _node - node to be modified
     * @param _position - uint position of bit to be modified
     * @param _bit - switch - 1 or 0 (true or false)
     */
    function modifyNodeSwitches(
        uint32 _node,
        uint8 _position,
        uint8 _bit
    ) external isNodeAdmin nonReentrant {
        require(
            (_position > 0) && (_position < 9),
            "NS:MNS: Bit position !>0||<9"
        );
        require(_bit < 2, "NS:MNS: Bit != 1 or 0");

        //^^^^^^^checks^^^^^^^^^

        uint256 switches = nodeData[_node].switches;

        if (_bit == 1) {
            switches = switches | (1 << (_position - 1));
        }

        if (_bit == 0) {
            switches = switches & ~(1 << (_position - 1)); //make zero mask
        }

        nodeData[_node].switches = uint8(switches);
        //^^^^^^^effects^^^^^^^^^
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
    ) external whenNotPaused isNodeAdmin {
        //^^^^^^^checks^^^^^^^^^

        registeredUsers[_addrHash][_node] = _userType;

        if ((_userType != 0) && (registeredUsers[_addrHash][0] < 255)) {
            registeredUsers[_addrHash][0]++; //increase user count
        }

        if ((_userType == 0) && (registeredUsers[_addrHash][0] > 0)) {
            registeredUsers[_addrHash][0]--; //decrease user count
        }
        //^^^^^^^effects^^^^^^^^^
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
    ) external whenNotPaused isNodeAdmin {
        //^^^^^^^checks^^^^^^^^^

        cost[_node][_service].serviceCost = _serviceCost;
        cost[_node][_service].paymentAddress = _paymentAddress;
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
    ) external whenNotPaused isNodeAdmin {
        require( //_managementType is a valid type
            (validManagementTypes[_managementType] > 0),
            "NS:SNMD: managementType is invalid (0)"
        );
        require( //_storageProvider is a valid type
            (validStorageProviders[_storageProvider] > 0),
            "NS:SNMD: storageProvider is invalid (0)"
        );
        //^^^^^^^checks^^^^^^^^^

        nodeData[_node].managementType = _managementType;
        nodeData[_node].storageProvider = _storageProvider;
        nodeData[_node].referenceAddress = _refAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev extended node data setter
     * @param _node - node being setup
     * @param _exData ExtendedNodeData struct to write (see resources-structs)
     * DPS:TEST:NEW
     */
    function setExtendedNodeData(uint32 _node, ExtendedNodeData memory _exData)
        external
        isNodeAdmin
    {
        nodeDetails[_node] = _exData;
    }

    /**
     * @dev extended node data setter
     * @param _foreignNode - node from other blockcahin to point to local node
     * @param _localNode local node to point to
     * DPS:TEST:NEW
     */
    function setLocalNode(uint32 _foreignNode, uint32 _localNode)
        external
        isNodeAdmin
    {
        localNodeFor[_foreignNode] = _localNode;
    }

    /**
     * @dev extended node data setter
     * @param _foreignNode - node from other blockcahin to check for local node
     * DPS:TEST:NEW
     */
    function getLocalNode(uint32 _foreignNode) external view returns (uint32)
    {
        return localNodeFor[_foreignNode];
    }



    /**
     * @dev exttended node data getter
     * @param _node - node being queried
     * returns ExtendedNodeData struct (see resources-structs)
     * DPS:TEST:NEW
     */
    function getExtNodeData(uint32 _node)
        external
        view
        returns (ExtendedNodeData memory)
    {
        return nodeDetails[_node];
    }

    /**
     * @dev get an node Node User type for a specified address
     * @param _userHash - hash of selected user
     * @param _node - node of query
     * @return type of user @ _node (see docs)
     */
    function getUserType(bytes32 _userHash, uint32 _node)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^

        return (registeredUsers[_userHash][_node]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get the status of a specific management type
     * @param _managementType - management type associated with query (see docs)
     * @return 1 or 0 (enabled or disabled)
     */
    function getManagementTypeStatus(uint8 _managementType)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^

        return (validManagementTypes[_managementType]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get the status of a specific storage provider
     * @param _storageProvider - storage provider associated with query (see docs)
     * @return 1 or 0 (enabled or disabled)
     */
    function getStorageProviderStatus(uint8 _storageProvider)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^

        return (validStorageProviders[_storageProvider]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get the status of a specific custody type
     * @param _custodyType - custody type associated with query (see docs)
     * @return 1 or 0 (enabled or disabled)
     */
    function getCustodyTypeStatus(uint8 _custodyType)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^

        return (validCustodyTypes[_custodyType]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve extended nodeData @ _node
     * @param _node - node associated with query
     * @return nodeData (see docs)
     * supports indirect node reference via localNodeFor[node]
     */
    function getNodeData(uint32 _node) external view returns (Node memory) {
        //^^^^^^^checks^^^^^^^^^
        uint32 node = localNodeFor[_node];
        return (nodeData[node]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev verify the root of two Nodees are equal
     * @param _node1 - first node associated with query
     * @param _node2 - second node associated with query
     * @return 170 or 0 (true or false)
     * supports indirect node reference via localNodeFor[node]
     */
    function isSameRootNode(uint32 _node1, uint32 _node2)
        external
        view
        returns (uint8)
    {
        uint32 node1 = localNodeFor[_node1];
        uint32 node2 = localNodeFor[_node2];
        //^^^^^^^checks^^^^^^^^^
        if (nodeData[node1].nodeRoot == nodeData[node2].nodeRoot) {
            return uint8(170);
        } else {
            return uint8(0);
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve Node_name @ _tokenId or node
     * @param _node - tokenId associated with query
     * return name of token @ _tokenID
     * supports indirect node reference via localNodeFor[node]
     */
    function getNodeName(uint32 _node) external view returns (string memory) {
        //^^^^^^^checks^^^^^^^^^
        uint32 node = localNodeFor[_node];
        return (nodeData[node].name);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve node @ Node_name
     * @param _forThisName - name of node for nodeNumber query
     * @return node number @ _name
     */
    function resolveNode(string calldata _forThisName)
        external
        view
        returns (uint32)
    {
        //^^^^^^^checks^^^^^^^^^

        return (nodeId[_forThisName]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve function costs per Node, per service type in PRUF(18 decimals)
     * @param _node - node associated with query
     * @param _service - service number associated with query (see service types in ZZ_PRUF_DOCS)
     * @return invoice{
         rootAddress: @ _node root payment address @ _service
         rootPrice: @ _node root service cost @ _service
         NTHaddress: @ _node payment address tied @ _service
         NTHprice: @ _node service cost @ _service
         node: Node index
     }
     * supports indirect node reference via localNodeFor[node]
     */
    function getInvoice(uint32 _node, uint16 _service)
        external
        view
        returns (Invoice memory)
    {
        uint32 node = localNodeFor[_node];
        Node memory nodeInfo = nodeData[node];
        require(nodeInfo.nodeRoot != 0, "NS:GSC: node !exist");

        require(_service != 0, "NS:GSC: Service type = 0");
        //^^^^^^^checks^^^^^^^^^
        uint32 rootNode = nodeInfo.nodeRoot;

        Costs memory costs = cost[node][_service];
        Costs memory rootCosts = cost[rootNode][_service];
        Invoice memory invoice;

        invoice.rootAddress = rootCosts.paymentAddress;
        invoice.rootPrice = rootCosts.serviceCost;
        invoice.NTHaddress = costs.paymentAddress;
        invoice.NTHprice = costs.serviceCost;

        return invoice;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve service costs for _node._service
     * @param _node - node associated with query
     * @param _service - service associated with query
     * @return Costs Struct for_node
     * supports indirect node reference via localNodeFor[node]
     */
    function getPaymentData(uint32 _node, uint16 _service)
        external
        view
        returns (Costs memory)
    {
        //^^^^^^^checks^^^^^^^^^
        Costs memory paymentData;
        uint32 node = localNodeFor[_node];

        paymentData.paymentAddress = cost[node][_service].paymentAddress;
        paymentData.serviceCost = cost[node][_service].serviceCost;
        //^^^^^^^effects^^^^^^^^^

        return paymentData;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve Node_discount @ _node
     * @param _node - node associated with query
     * @return percentage of rewards distribution @ _node
     * supports indirect node reference via localNodeFor[node]
     */
    function getNodeDiscount(uint32 _node) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        uint32 node = localNodeFor[_node];

        return (nodeData[node].discount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get bit from .switches at specified position
     * @param _node - node associated with query
     * @param _position - bit position associated with query
     * @return 1 or 0 (enabled or disabled)
     * supports indirect node reference via localNodeFor[node]
     */
    function getSwitchAt(uint32 _node, uint8 _position)
        external
        view
        returns (uint256)
    {
        require(
            (_position > 0) && (_position < 9),
            "NS:GSA: bit position must be between 1 and 8"
        );
        //^^^^^^^checks^^^^^^^^^
        uint32 node = localNodeFor[_node];

        if ((nodeData[node].switches & (1 << (_position - 1))) > 0) {
            return 1;
        } else {
            return 0;
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev creates an node and its corresponding namespace and data fields
     * @param _newNodeData - creation Data for new Node
     * @param _newNode - Node to be created (unique)
     * @param _caller - function caller passed by trusted calling contract
     * sets localNodeFor[_newNode] to _newNode
     */
    function createNodeData(
        Node memory _newNodeData,
        uint32 _newNode,
        address _caller
    ) external isNodeAdmin whenNotPaused {
        Node memory _RootNodeData = nodeData[_newNodeData.nodeRoot];

        require(_newNode != 0, "NS:CN: node = 0"); //sanity check inputs
        require(
            _newNodeData.discount <= 10000,
            "NS:CN: Discount > 10000 (100%)"
        );
        require( //_ac.managementType is a valid type or explicitly unset (255)
            (validManagementTypes[_newNodeData.managementType] > 0) ||
                (_newNodeData.managementType == 255),
            "NS:CN: Management type is invalid (0)"
        );
        require( //_ac.storageProvider is a valid type or not specified (0)
            (validStorageProviders[_newNodeData.storageProvider] > 0) ||
                (_newNodeData.storageProvider == 0),
            "NS:CN: Storage Provider is invalid (0)"
        );
        require( //_ac.custodyType is a valid type or specifically unset (255)
            (validCustodyTypes[_newNodeData.custodyType] > 0) ||
                (_newNodeData.custodyType == 255),
            "NS:CN: Custody type is invalid (0)"
        );
        require( //has valid root
            (_RootNodeData.custodyType == 3) ||
                (_newNodeData.nodeRoot == _newNode),
            "NS:CN: Root !exist"
        );
        if (_RootNodeData.managementType != 0) {
            require( //holds root token if root is restricted
                (NODE_TKN.ownerOf(_newNodeData.nodeRoot) == _caller),
                "NS:CN: Restricted from creating node in this root - caller !hold root token"
            ); // DPS:TEST
        }
        require(nodeId[_newNodeData.name] == 0, "NS:CN: node name exists");
        require(
            (nodeData[_newNode].nodeRoot == 0),
            "NS:CN: node already exists"
        );
        //^^^^^^^checks^^^^^^^^^

        nodeId[_newNodeData.name] = _newNode;
        nodeData[_newNode].name = _newNodeData.name;
        nodeData[_newNode].nodeRoot = _newNodeData.nodeRoot;
        nodeData[_newNode].discount = _newNodeData.discount;
        nodeData[_newNode].custodyType = _newNodeData.custodyType;
        nodeData[_newNode].managementType = _newNodeData.managementType;
        nodeData[_newNode].switches = _RootNodeData.switches;
        nodeData[_newNode].CAS1 = _newNodeData.CAS1;
        nodeData[_newNode].CAS2 = _newNodeData.CAS2;
        localNodeFor[_newNode] = _newNode; //create default pairing for local node lookup (assumes node is native)
        //^^^^^^^effects^^^^^^^^^
    }
}
