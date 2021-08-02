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
    mapping(uint32 => mapping(uint16 => Costs)) private cost; // Cost per function by node => Costs struct (see PRUF_INTERFACES for struct definitions)
    mapping(uint32 => Node) private node_data; // node info database node to node struct (see PRUF_INTERFACES for struct definitions)
    mapping(string => uint32) private node_index; //name to node resolution map
    mapping(bytes32 => mapping(uint32 => uint8)) private registeredUsers; // Authorized recorder database by node, by address hash
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
            "ACM:MOD-INM: Must have NODE_MINTER_ROLE"
        );
        _;
    }

    /**
     * @dev Verify caller holds ACtoken of passed node
     * @param _node - node in which caller is queried for ownership
     */
    modifier isACtokenHolderOfClass(uint32 _node) {
        require(
            (NODE_TKN.ownerOf(_node) == _msgSender()),
            "ACM:MOD-IACTHoC: _msgSender() not authorized in node"
        );
        _;
    }

    //--------------------------------------------ADMIN only Functions--------------------------

    /**
     * @dev Set pricing for Nodes
     * @param newACprice - cost per node (18 decimals)
     */
    function adminSetACpricing(uint256 newACprice) external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        node_price = newACprice;
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
    function adminIncreaseShare(uint32 _node, uint32 _newDiscount)
        external
        isContractAdmin
    {
        require(
            (node_data[_node].assetClassRoot != 0),
            "ACM:AIS: node !exist"
        );
        require(
            _newDiscount >= node_data[_node].discount,
            "ACM:AIS: New share < old share"
        );
        require(_newDiscount <= 10000, "ACM:AIS: Discount > 100% (10000)");
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
    function adminSetStorageProviders(uint8 _storageProvider, uint8 _status)
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
    function adminSetManagementTypes(uint8 _managementType, uint8 _status)
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
    function adminSetCustodyTypes(uint8 _custodyType, uint8 _status)
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
     * @param _assetClassSource - source node
     * @param _assetClassDest - destination node
     * @param _name - name to be transferred
     */
    function transferName(
        uint32 _assetClassSource,
        uint32 _assetClassDest,
        string calldata _name
    ) external isContractAdmin {
        require(
            node_index[_name] == _assetClassSource,
            "ACM:TN: Name not in source node"
        ); //source AC_Name must match name given

        require(
            (node_data[_assetClassDest].CAS1 == B320xF_), //dest node must have CAS1 set to 0xFFFF.....
            "ACM:TN: Destination node not prepared for name transfer"
        );
        //^^^^^^^checks^^^^^^^^^

        node_index[_name] = _assetClassDest;
        node_data[_assetClassDest].name = _name;
        node_data[_assetClassSource].name = "";
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution -----------
     * @dev Modifies an node with minimal controls
     * @param _node - node to be modified
     * @param _assetClassRoot - root of node
     * @param _custodyType - custodyType of node (see docs)
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _discount - discount of node (100 == 1%, 10000 == max)
     * @param _refAddress - referance address associated with an node
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function adminModAssetClass(
        uint32 _node,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        address _refAddress,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external isContractAdmin nonReentrant {
        Node memory _ac = node_data[_assetClassRoot];
        uint256 tokenId = uint256(_node);

        require((tokenId != 0), "ACM:AMAC: node = 0"); //sanity check inputs
        require(_discount <= 10000, "ACM:AMAC: Discount > 10000 (100%)");
        require( //has valid root
            (_ac.custodyType == 3) || (_assetClassRoot == _node),
            "ACM:AMAC: Root !exist"
        );
        require(NODE_TKN.tokenExists(tokenId) == 170, "ACM:AMAC: ACtoken !exist");

        //^^^^^^^checks^^^^^^^^^

        node_data[_node].assetClassRoot = _assetClassRoot;
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
    function adminModAssetClassSwitches(
        uint32 _node,
        uint8 _position,
        uint8 _bit
    ) external isContractAdmin nonReentrant {
        require(
            (_position > 0) && (_position < 9),
            "ACM:AMACS: Bit position !>0||<9"
        );
        require(_bit < 2, "ACM:AMACS: Bit != 1 or 0");

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
     * @dev Mints node token and creates an node.
     * @param _node - node to be created (unique)
     * @param _name - name to be configured to node (unique)
     * @param _assetClassRoot - root of node
     * @param _custodyType - custodyType of new node (see docs)
     * @param _managementType - managementType of new node (see docs)
     * @param _storageProvider - storageProvider of new node (see docs)
     * @param _discount - discount of node (100 == 1%, 10000 == max)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     * @param _recipientAddress - address to recieve node
     */
    function createAssetClass(
        uint32 _node,
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        bytes32 _CAS1,
        bytes32 _CAS2,
        address _recipientAddress
    ) external isNodeMinter nonReentrant {
        //^^^^^^^checks^^^^^^^^^

        Node memory _AC;
        _AC.name = _name;
        _AC.assetClassRoot = _assetClassRoot;
        _AC.custodyType = _custodyType;
        _AC.managementType = _managementType;
        _AC.storageProvider = _storageProvider;
        _AC.discount = _discount;
        _AC.CAS1 = _CAS1;
        _AC.CAS2 = _CAS2;

        _createAssetClass(_AC, _node, _recipientAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Burns (amount) tokens and mints a new node token to the calling address
     * @param _name - chosen name of node
     * @param _assetClassRoot - chosen root of node
     * @param _custodyType - chosen custodyType of node (see docs)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function purchaseNode(
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external nonReentrant returns (uint256) {
        require(
            nodeTokenIndex < 4294000000,
            "ACM:PACN: Only 4294000000 node tokens allowed"
        );
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1),
            "ACM:PACN: Caller !valid PRuF_ID holder"
        );
        //^^^^^^^checks^^^^^^^^^

        nodeTokenIndex++;

        address rootPaymentAddress = cost[_assetClassRoot][1].paymentAddress; //payment for upgrade goes to root node payment address specified for service (1)

        //mint an node token to _msgSender(), at tokenID nodeTokenIndex, with URI = root asset Class #

        UTIL_TKN.trustedAgentBurn(_msgSender(), node_price / 2);
        UTIL_TKN.trustedAgentTransfer(
            _msgSender(),
            rootPaymentAddress,
            node_price - (node_price / 2)
        ); //burning 50% so we have tokens to incentivise outreach performance
        Node memory _AC;
        _AC.name = _name;
        _AC.assetClassRoot = _assetClassRoot;
        _AC.custodyType = _custodyType;
        _AC.managementType = 255; //creates nodes at managementType 255 = not yet usable(disabled),
        _AC.storageProvider = 0; //creates nodes at storageType 0 = not yet usable(disabled),
        _AC.discount = startingDiscount;
        _AC.CAS1 = _CAS1;
        _AC.CAS2 = _CAS2;

        _createAssetClass(_AC, uint32(nodeTokenIndex), _msgSender());

        //Set the default 11 authorized contracts
        if (_custodyType == 2) {
            STOR.enableDefaultContractsForAC(uint32(nodeTokenIndex));
        }

        return nodeTokenIndex; //returns node # of minted token
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
    ) external whenNotPaused isACtokenHolderOfClass(_node) {
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
    function updateACname(uint32 _node, string calldata _name)
        external
        whenNotPaused
        isACtokenHolderOfClass(_node)
    {
        require( //should pass if name is same as old name or name is unassigned. Should fail if name is assigned to other node
            (node_index[_name] == 0) || //name is unassigned
                (keccak256(abi.encodePacked(_name)) == //name is same as old name
                    (keccak256(abi.encodePacked(node_data[_node].name)))),
            "ACM:UACN: Name already in use or is same as the previous"
        );
        //^^^^^^^checks^^^^^^^^^

        delete node_index[node_data[_node].name];

        node_index[_name] = _node;
        node_data[_node].name = _name;
        //^^^^^^^effects^^^^^^^^^
    }

    /** CTS:EXAMINE Need 2 IPFS fields
     * @dev Modifies an node Node IPFS data pointer
     * @param _node - node being modified
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function updateNodeCAS(
        uint32 _node,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external whenNotPaused isACtokenHolderOfClass(_node) {
        require(
            getSwitchAt(_node, 1) == 0,
            "ACM:UNC: CAS for node is locked and cannot be written"
        );
        //^^^^^^^checks^^^^^^^^^
        node_data[_node].CAS1 = _CAS1;
        node_data[_node].CAS2 = _CAS2;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Set function costs and payment address per node, in PRUF(18 decimals)
     * @param _node - node to set service costs
     * @param _service - service type being modified (see service types in ZZ_PRUF_DOCS)
     * @param _serviceCost - 18 decimal fee in PRUF associated with specified service
     * @param _paymentAddress - address to have _serviceCost paid to
     */
    function ACTH_setCosts(
        uint32 _node,
        uint16 _service,
        uint256 _serviceCost,
        address _paymentAddress
    ) external whenNotPaused isACtokenHolderOfClass(_node) {
        //^^^^^^^checks^^^^^^^^^

        cost[_node][_service].serviceCost = _serviceCost;
        cost[_node][_service].paymentAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------Functions dealing with immutable data ---------------------------------------------

    /**
     * @dev Configure the immutable data in an node one time
     * @param _node - node being modified
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _refAddress - address permanently tied to node
     */
    function updateACImmutable(
        uint32 _node,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress
    ) external whenNotPaused isACtokenHolderOfClass(_node) {
        require(
            node_data[_node].managementType == 255,
            "ACM:UACI: Immutable node data already set"
        );
        require(
            _managementType != 255,
            "ACM:UACI: managementType = 255(Unconfigured)"
        );
        require( //_managementType is a valid type
            (validManagementTypes[_managementType] > 0),
            "ACM:UACI: managementType is invalid (0)"
        );
        require( //_storageProvider is a valid type
            (validStorageProviders[_storageProvider] > 0),
            "ACM:UACI: storageProvider is invalid (0)"
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
    function getNode_data(uint32 _node)
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
            node_data[_node].assetClassRoot,
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
    function getExtAC_data(uint32 _node)
        external
        view
        returns (Node memory)
    {
        //^^^^^^^checks^^^^^^^^^
        return (node_data[_node]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev verify the root of two asset classes are equal
     * @param _assetClass1 - first node associated with query
     * @param _assetClass2 - second node associated with query
     *
     * @return 170 or 0 (true or false)
     */
    function isSameRootAC(uint32 _assetClass1, uint32 _assetClass2)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        if (
            node_data[_assetClass1].assetClassRoot ==
            node_data[_assetClass2].assetClassRoot
        ) {
            return uint8(170);
        } else {
            return uint8(0);
        }
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve AC_name @ _tokenId or node
     * @param node - tokenId associated with query
     *
     * @return name of token @ _tokenID
     */
    function getNode_name(uint32 node)
        external
        view
        returns (string memory)
    {
        //^^^^^^^checks^^^^^^^^^

        return (node_data[node].name);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve node @ AC_name
     * @param _name - name of node for assetClassNumber query
     *
     * @return node number @ _name
     */
    function resolveAssetClass(string calldata _name)
        external
        view
        returns (uint32)
    {
        //^^^^^^^checks^^^^^^^^^
        return (node_index[_name]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev return current node token index and price
     *
     * @return {
         nodeTokenIndex: current token number
         AC_price: current price per node
     }
     */
    function currentACpricingInfo() external view returns (uint256, uint256) {
        //^^^^^^^checks^^^^^^^^^
        return (nodeTokenIndex, node_price);
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------functions for payment calculations----------------------------------------------

    /**
     * @dev Retrieve function costs per node, per service type in PRUF(18 decimals)
     * @param _node - node associated with query
     * @param _service - service number associated with query (see service types in ZZ_PRUF_DOCS)
     *
     * @return invoice{
         rootAddress: @ _node root payment address @ _service
         rootPrice: @ _node root service cost @ _service
         ACTHaddress: @ _node payment address tied @ _service
         ACTHprice: @ _node service cost @ _service
         node: _node
     }
     */
    function getServiceCosts(uint32 _node, uint16 _service)
        external
        view
        returns (Invoice memory)
    {
        Node memory node_info = node_data[_node];
        require(node_info.assetClassRoot != 0, "ACM:GSC: node !exist");

        require(_service != 0, "ACM:GSC: Service type = 0");
        //^^^^^^^checks^^^^^^^^^
        uint32 rootAssetClass = node_info.assetClassRoot;

        Costs memory costs = cost[_node][_service];
        Costs memory rootCosts = cost[rootAssetClass][_service];
        Invoice memory invoice;

        invoice.rootAddress = rootCosts.paymentAddress;
        invoice.rootPrice = rootCosts.serviceCost;
        invoice.ACTHaddress = costs.paymentAddress;
        invoice.ACTHprice = costs.serviceCost;
        invoice.node = _node;

        return invoice;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve AC_discount @ _node
     * @param _node - node associated with query
     *
     * @return percentage of rewards distribution @ _node
     */
    function getNode_discount(uint32 _node) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        return (node_data[_node].discount);
        //^^^^^^^interactions^^^^^^^^^
    }

    //-------------------------------------------INTERNAL / PRIVATE functions ----------------------------------------------

    /**
     * @dev creates an node and its corresponding namespace and data fields
     * @param _AC - creation Data for new Node
     * @param _node - Node to be created (unique)
     * @param _recipientAddress - address to recieve Node
     */
    function _createAssetClass(
        Node memory _AC,
        uint32 _node,
        address _recipientAddress
    ) private whenNotPaused {
        Node memory _RootNodeData = node_data[_AC.assetClassRoot];
        uint256 tokenId = uint256(_node);

        require(tokenId != 0, "ACM:CAC: node = 0"); //sanity check inputs
        require(_AC.discount <= 10000, "ACM:CAC: Discount > 10000 (100%)");
        require( //_ac.managementType is a valid type or explicitly unset (255)
            (validManagementTypes[_AC.managementType] > 0) ||
                (_AC.managementType == 255),
            "ACM:CAC: Management type is invalid (0)"
        );
        require( //_ac.storageProvider is a valid type or not specified (0)
            (validStorageProviders[_AC.storageProvider] > 0) ||
                (_AC.storageProvider == 0),
            "ACM:CAC: Storage Provider is invalid (0)"
        );
        require( //_ac.custodyType is a valid type or specifically unset (255)
            (validCustodyTypes[_AC.custodyType] > 0) ||
                (_AC.custodyType == 255),
            "ACM:CAC: Custody type is invalid (0)"
        );
        require( //has valid root
            (_RootNodeData.custodyType == 3) ||
                (_AC.assetClassRoot == _node),
            "ACM:CAC: Root !exist"
        );
        if (_RootNodeData.managementType != 0) {
            require( //holds root token if root is restricted
                (NODE_TKN.ownerOf(_AC.assetClassRoot) == _msgSender()),
                "ACM:CAC: Restricted from creating node in this root - caller !hold root token"
            );
        }
        require(node_index[_AC.name] == 0, "ACM:CAC: node name exists");
        require(
            (node_data[_node].assetClassRoot == 0),
            "ACM:CAC: node already exists"
        );
        //^^^^^^^checks^^^^^^^^^

        node_index[_AC.name] = _node;
        node_data[_node].name = _AC.name;
        node_data[_node].assetClassRoot = _AC.assetClassRoot;
        node_data[_node].discount = _AC.discount;
        node_data[_node].custodyType = _AC.custodyType;
        node_data[_node].managementType = _AC.managementType;
        node_data[_node].switches = _RootNodeData.switches;
        node_data[_node].CAS1 = _AC.CAS1;
        node_data[_node].CAS2 = _AC.CAS2;
        //^^^^^^^effects^^^^^^^^^

        NODE_TKN.mintACToken(
            _recipientAddress,
            tokenId,
            "pruf.io/assetClassToken"
        );
        //^^^^^^^interactions^^^^^^^^^
    }
}