/**--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 * Contract for minting and managing node Nodes
 *
 * STATEMENT OF TERMS OF SERVICE (TOS):
 * User agrees not to intentionally claim any namespace that is a recognized or registered brand name, trade mark,
 * or other Intellectual property not belonging to the user, and agrees to voluntarily remove any name or brand found to be
 * infringing from any record that the user controls, within 30 days of notification. If notification is not possible or
 * there is no response to notification, the user agrees that the name record may be changed without their permission or cooperation.
 * Use of this software constitutes consent to the terms above.
 *-----------------------------------------------------------------
 */

/**-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_BASIC.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract NODE_MGR is BASIC {
    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    uint256 private nodeTokenIndex = 1000000; //Starting index for purchased node tokens
    uint256 public node_price = 200000 ether;
    uint32 private constant startingDiscount = 9500; // Purchased nodes start with 95% profit share
    mapping(uint32 => mapping(uint16 => Costs)) private cost; // Cost per function by Node => Costs struct (see PRUF_INTERFACES for struct definitions)
    mapping(uint32 => Node) private node_data; // node info database Node to node struct (see PRUF_INTERFACES for struct definitions)
    mapping(string => uint32) private node_index; //name to Node resolution map
    mapping(bytes32 => mapping(uint32 => uint8)) private registeredUsers; // Authorized recorder database by Node, by address hash
    mapping(uint8 => uint8) private validStorageProviders; //storageProvider -> status (enabled or disabled)
    mapping(uint8 => uint8) private validManagementTypes; //managementTypes -> status (enabled or disabled)
    mapping(uint8 => uint8) private validCustodyTypes; //managementTypes -> status (enabled or disabled)

    constructor() {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
        node_index[""] = 4294967295; //points the blank string name to node 4294967295 to make "" owned
    }

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
            (A_TKN.ownerOf(_node) == _msgSender()),
            "NM:MOD-INTHoC: _msgSender() not authorized in Node"
        );
        _;
    }

    //--------------------------------------------ADMIN only Functions--------------------------

    /**
     * @dev Set pricing for Nodes
     * @param newNodePrice - cost per node (18 decimals)
     */
    function setNodePricing(uint256 newNodePrice) external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        node_price = newNodePrice;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("node pricing Changed!"); //report access to internal parameter (KEEP THIS)
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * !! to be used with great caution !!
     * This potentially breaks decentralization and must eventually be given over to some kind of governance contract.
     * @dev Increases (but cannot decrease) price share for a given node
     * @param _node - node in which cost share is being modified
     * @param _newDiscount - discount(1% == 100, 10000 == max)
     */
    function increaseShare(uint32 _node, uint32 _newDiscount)
        external
        isContractAdmin
    {
        require((node_data[_node].nodeRoot != 0), "NM:AIS: node !exist");
        require(
            _newDiscount >= node_data[_node].discount,
            "NM:AIS: New share < old share"
        );
        require(_newDiscount <= 10000, "NM:AIS: Discount > 100% (10000)");
        //^^^^^^^checks^^^^^^^^^

        node_data[_node].discount = _newDiscount;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     *
     * @dev Sets the valid storage type providers.
     * @param _storageProvider - uint position for storage provider
     * @param _status - uint position for custody type status
     */
    function setStorageProviders(uint8 _storageProvider, uint8 _status)
        external
        isContractAdmin
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
        isContractAdmin
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
    function setCustodyTypes(uint8 _custodyType, uint8 _status)
        external
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^
        validCustodyTypes[_custodyType] = _status;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution and only as a result of community governance action -----------
     * @dev Transfers a name from one node to another
     *   -Designed to remedy brand infringement issues. This breaks decentralization and must eventually be given
     *   -over to some kind of governance contract.
     * @param _fromNode - source node
     * @param _toNode - destination node
     * @param _name - name to be transferred
     */
    function transferName(
        uint32 _fromNode,
        uint32 _toNode,
        string calldata _name
    ) external isContractAdmin {
        require(
            node_index[_name] == _fromNode,
            "NM:TN: Name not in source node"
        ); //source Node_Name must match name given

        require(
            (node_data[_toNode].CAS1 == B320xF_), //dest node must have CAS1 set to 0xFFFF.....
            "NM:TN: Destination node not prepared for name transfer"
        );
        //^^^^^^^checks^^^^^^^^^

        node_index[_name] = _toNode;
        node_data[_toNode].name = _name;
        node_data[_fromNode].name = "";
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution -----------
     * @dev Modifies an Node with minimal controls
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
    ) external isContractAdmin nonReentrant {
        Node memory _ac = node_data[_nodeRoot];
        uint256 tokenId = uint256(_node);

        require((tokenId != 0), "NM:AMAC: Node = 0"); //sanity check inputs
        require(_discount <= 10000, "NM:AMAC: Discount > 10000 (100%)");
        require( //has valid root
            (_ac.custodyType == 3) || (_nodeRoot == _node),
            "NM:AMAC: Root !exist"
        );
        require(A_TKN.tokenExists(tokenId) == 170, "NM:AMAC: Node !exist");

        //^^^^^^^checks^^^^^^^^^

        node_data[_node].nodeRoot = _nodeRoot;
        node_data[_node].discount = _discount;
        node_data[_node].custodyType = _custodyType;
        node_data[_node].managementType = _managementType;
        node_data[_node].storageProvider = _storageProvider;
        node_data[_node].referenceAddress = _refAddress;
        node_data[_node].CAS1 = _CAS1;
        node_data[_node].CAS2 = _CAS2;
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
    ) external isContractAdmin nonReentrant {
        require(
            (_position > 0) && (_position < 9),
            "NM:AMACS: Bit position !>0||<9"
        );
        require(_bit < 2, "NM:AMACS: Bit != 1 or 0");

        //^^^^^^^checks^^^^^^^^^

        uint256 switches = node_data[_node].switches;

        if (_bit == 1) {
            switches = switches | (1 << (_position - 1));
        }

        if (_bit == 0) {
            switches = switches & ~(1 << (_position - 1)); //make zero mask
        }

        node_data[_node].switches = uint8(switches);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------------NODEMINTER only Functions--------------------------

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
        bytes32 _CAS2
    ) external nonReentrant returns (uint256) {
        require(
            nodeTokenIndex < 4294000000,
            "NM:PACN: Only 4294000000 node tokens allowed"
        );
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1),
            "NM:PACN: Caller !valid PRuF_ID holder"
        );
        //^^^^^^^checks^^^^^^^^^

        nodeTokenIndex++;

        address rootPaymentAddress = cost[_nodeRoot][1].paymentAddress; //payment for upgrade goes to root node payment address specified for service (1)

        //mint an Node token to _msgSender(), at tokenID nodeTokenIndex, with URI = root Node #

        UTIL_TKN.trustedAgentBurn(_msgSender(), node_price / 2);
        UTIL_TKN.trustedAgentTransfer(
            _msgSender(),
            rootPaymentAddress,
            node_price - (node_price / 2)
        ); //burning 50% so we have tokens to incentivise outreach performance
        Node memory _node;
        _node.name = _name;
        _node.nodeRoot = _nodeRoot;
        _node.custodyType = _custodyType;
        _node.managementType = 255; //creates nodes at managementType 255 = not yet usable(disabled),
        _node.storageProvider = 0; //creates nodes at storageType 0 = not yet usable(disabled),
        _node.discount = startingDiscount;
        _node.CAS1 = _CAS1;
        _node.CAS2 = _CAS2;

        _createNode(_node, uint32(nodeTokenIndex), _msgSender());

        //Set the default 11 authorized contracts
        if (_custodyType == 2) {
            STOR.enableDefaultContractsForAC(uint32(nodeTokenIndex));
        }

        return nodeTokenIndex; //returns Node # of minted token
        //^^^^^^^effects/interactions^^^^^^^^^
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

        registeredUsers[_addrHash][_node] = _userType;

        if ((_userType != 0) && (registeredUsers[_addrHash][0] < 255)) {
            registeredUsers[_addrHash][0]++;
        }

        if ((_userType == 0) && (registeredUsers[_addrHash][0] > 0)) {
            registeredUsers[_addrHash][0]--;
        }

        //^^^^^^^effects^^^^^^^^^
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modifies an node Node name for its exclusive namespace
     * @param _node - node being modified
     * @param _name - updated name associated with node (unique)
     */
    function updateNodeName(uint32 _node, string calldata _name)
        external
        whenNotPaused
        isNodeHolder(_node)
    {
        require( //should pass if name is same as old name or name is unassigned. Should fail if name is assigned to other node
            (node_index[_name] == 0) || //name is unassigned
                (keccak256(abi.encodePacked(_name)) == //name is same as old name
                    (keccak256(abi.encodePacked(node_data[_node].name)))),
            "NM:UACN: Name already in use or is same as the previous"
        );
        //^^^^^^^checks^^^^^^^^^

        delete node_index[node_data[_node].name];

        node_index[_name] = _node;
        node_data[_node].name = _name;
        //^^^^^^^effects^^^^^^^^^
    }

    /**Î
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
            getSwitchAt(_node, 1) == 0,
            "NM:UNC: CAS for node is locked and cannot be written"
        );
        //^^^^^^^checks^^^^^^^^^
        node_data[_node].CAS1 = _CAS1;
        node_data[_node].CAS2 = _CAS2;
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
    ) external whenNotPaused isNodeHolder(_node) {
        //^^^^^^^checks^^^^^^^^^

        cost[_node][_service].serviceCost = _serviceCost;
        cost[_node][_service].paymentAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------Functions dealing with immutable data ---------------------------------------------

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
        require(
            node_data[_node].managementType == 255,
            "NM:UACI: Immutable node data already set"
        );
        require(
            _managementType != 255,
            "NM:UACI: managementType = 255(Unconfigured)"
        );
        require( //_managementType is a valid type
            (validManagementTypes[_managementType] > 0),
            "NM:UACI: managementType is invalid (0)"
        );
        require( //_storageProvider is a valid type
            (validStorageProviders[_storageProvider] > 0),
            "NM:UACI: storageProvider is invalid (0)"
        );
        //^^^^^^^checks^^^^^^^^^

        node_data[_node].managementType = _managementType;
        node_data[_node].storageProvider = _storageProvider;
        node_data[_node].referenceAddress = _refAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------Read-only functions ----------------------------------------------

    /**
     * @dev get bit from .switches at specified position
     * @param _node - node associated with query
     * @param _position - bit position associated with query
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getSwitchAt(uint32 _node, uint8 _position)
        public
        view
        returns (uint256)
    {
        require(
            (_position > 0) && (_position < 9),
            "AM:GSA: bit position must be between 1 and 8"
        );
        //^^^^^^^checks^^^^^^^^^

        if ((node_data[_node].switches & (1 << (_position - 1))) > 0) {
            return 1;
        } else {
            return 0;
        }
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get an node Node User type for a specified address
     * @param _userHash - hash of selected user
     * @param _node - node of query
     *
     * @return type of user @ _node (see docs)
     */
    function getUserType(bytes32 _userHash, uint32 _node)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (registeredUsers[_userHash][_node]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get the status of a specific management type
     * @param _managementType - management type associated with query (see docs)
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getManagementTypeStatus(uint8 _managementType)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (validManagementTypes[_managementType]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get the status of a specific storage provider
     * @param _storageProvider - storage provider associated with query (see docs)
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getStorageProviderStatus(uint8 _storageProvider)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (validStorageProviders[_storageProvider]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get the status of a specific custody type
     * @param _custodyType - custody type associated with query (see docs)
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getCustodyTypeStatus(uint8 _custodyType)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (validCustodyTypes[_custodyType]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve node_data @ _node
     * @param _node - node associated with query
     * DPS:THIS FUNCTION REMAINS FOR EXTERNAL TESTING ACCESS. try using getExtAcData, it should be depricated prior to production.
     */
    function getNodeData(uint32 _node)
        external
        view
        returns (
            uint32,
            uint8,
            uint8,
            uint32,
            address
        )
    {
        //^^^^^^^checks^^^^^^^^^
        return (
            node_data[_node].nodeRoot,
            node_data[_node].custodyType,
            node_data[_node].managementType,
            node_data[_node].discount,
            node_data[_node].referenceAddress
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve extended node_data @ _node
     * @param _node - node associated with query
     *
     * @return node_data (see docs)
     */
    function getExtendedNodeData(uint32 _node)
        external
        view
        returns (Node memory)
    {
        //^^^^^^^checks^^^^^^^^^
        return (node_data[_node]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev verify the root of two Nodees are equal
     * @param _node1 - first node associated with query
     * @param _node2 - second node associated with query
     *
     * @return 170 or 0 (true or false)
     */
    function isSameRootNode(uint32 _node1, uint32 _node2)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        if (node_data[_node1].nodeRoot == node_data[_node2].nodeRoot) {
            return uint8(170);
        } else {
            return uint8(0);
        }
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve Node_name @ _tokenId or node
     * @param node - tokenId associated with query
     *
     * @return name of token @ _tokenID
     */
    function getNodeName(uint32 node) external view returns (string memory) {
        //^^^^^^^checks^^^^^^^^^

        return (node_data[node].name);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve node @ Node_name
     * @param _name - name of node for nodeNumber query
     *
     * @return node number @ _name
     */
    function resolveNode(string calldata _name) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        return (node_index[_name]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev return current node token index and price
     *
     * @return {
         nodeTokenIndex: current token number
         Node_price: current price per node
     }
     */
    function currentNodePricingInfo() external view returns (uint256, uint256) {
        //^^^^^^^checks^^^^^^^^^
        return (nodeTokenIndex, node_price);
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------functions for payment calculations----------------------------------------------

    /**
     * @dev Retrieve function costs per Node, per service type in PRUF(18 decimals)
     * @param _node - node associated with query
     * @param _service - service number associated with query (see service types in ZZ_PRUF_DOCS)
     *
     * @return invoice{
         rootAddress: @ _node root payment address @ _service
         rootPrice: @ _node root service cost @ _service
         NTHaddress: @ _node payment address tied @ _service
         NTHprice: @ _node service cost @ _service
         node: Node index
     }
     */
    function getServiceCosts(uint32 _node, uint16 _service)
        external
        view
        returns (Invoice memory)
    {
        Node memory node_info = node_data[_node];
        require(node_info.nodeRoot != 0, "NM:GSC: node !exist");

        require(_service != 0, "NM:GSC: Service type = 0");
        //^^^^^^^checks^^^^^^^^^
        uint32 rootNode = node_info.nodeRoot;

        Costs memory costs = cost[_node][_service];
        Costs memory rootCosts = cost[rootNode][_service];
        Invoice memory invoice;

        invoice.rootAddress = rootCosts.paymentAddress;
        invoice.rootPrice = rootCosts.serviceCost;
        invoice.NTHaddress = costs.paymentAddress;
        invoice.NTHprice = costs.serviceCost;
        invoice.node = _node;

        return invoice;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve Node_discount @ _node
     * @param _node - node associated with query
     *
     * @return percentage of rewards distribution @ _node
     */
    function getNodeDiscount(uint32 _node) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        return (node_data[_node].discount);
        //^^^^^^^interactions^^^^^^^^^
    }

    //-------------------------------------------INTERNAL / PRIVATE functions ----------------------------------------------

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
        Node memory _RootNodeData = node_data[_newNodeData.nodeRoot];
        uint256 tokenId = uint256(_newNode);

        require(tokenId != 0, "NM:CN: node = 0"); //sanity check inputs
        require(
            _newNodeData.discount <= 10000,
            "NM:CN: Discount > 10000 (100%)"
        );
        require( //_ac.managementType is a valid type or explicitly unset (255)
            (validManagementTypes[_newNodeData.managementType] > 0) ||
                (_newNodeData.managementType == 255),
            "NM:CN: Management type is invalid (0)"
        );
        require( //_ac.storageProvider is a valid type or not specified (0)
            (validStorageProviders[_newNodeData.storageProvider] > 0) ||
                (_newNodeData.storageProvider == 0),
            "NM:CN: Storage Provider is invalid (0)"
        );
        require( //_ac.custodyType is a valid type or specifically unset (255)
            (validCustodyTypes[_newNodeData.custodyType] > 0) ||
                (_newNodeData.custodyType == 255),
            "NM:CN: Custody type is invalid (0)"
        );
        require( //has valid root
            (_RootNodeData.custodyType == 3) ||
                (_newNodeData.nodeRoot == _newNode),
            "NM:CN: Root !exist"
        );
        if (_RootNodeData.managementType != 0) {
            require( //holds root token if root is restricted
                (A_TKN.ownerOf(_newNodeData.nodeRoot) == _msgSender()),
                "NM:CN: Restricted from creating node in this root - caller !hold root token"
            );
        }
        require(node_index[_newNodeData.name] == 0, "NM:CN: node name exists");
        require(
            (node_data[_newNode].nodeRoot == 0),
            "NM:CN: node already exists"
        );
        //^^^^^^^checks^^^^^^^^^

        node_index[_newNodeData.name] = _newNode;
        node_data[_newNode].name = _newNodeData.name;
        node_data[_newNode].nodeRoot = _newNodeData.nodeRoot;
        node_data[_newNode].discount = _newNodeData.discount;
        node_data[_newNode].custodyType = _newNodeData.custodyType;
        node_data[_newNode].managementType = _newNodeData.managementType;
        node_data[_newNode].switches = _RootNodeData.switches;
        node_data[_newNode].CAS1 = _newNodeData.CAS1;
        node_data[_newNode].CAS2 = _newNodeData.CAS2;
        //^^^^^^^effects^^^^^^^^^

        A_TKN.mintNodeToken(_recipientAddress, tokenId, "pruf.io/nodeToken");
        STOR.enableDefaultContractsForAC(_newNode);
        STOR.newRecord(bytes32(tokenId), 0x0000000000000000000000000000000000000000000000000000000000000001, _newNode, 4294967295);
        //^^^^^^^interactions^^^^^^^^^
    }
}
