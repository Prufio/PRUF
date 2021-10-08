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
 * Contract for minting and managing node Nodes
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
    bytes32 public constant NODE_ADMIN_ROLE = keccak256("NODE_ADMIN_ROLE");
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    uint256 private nodeTokenIndex = 1000000; //Starting index for purchased node tokens
    uint256 public node_price = 200000 ether;
    uint32 private constant startingDiscount = 9500; //Purchased nodes start with 95% profit share
    mapping(uint32 => mapping(uint16 => Costs)) private cost; //Cost per function by Node => Costs struct (see RESOURCE_PRUF_INTERFACES for struct definitions)
    mapping(uint32 => Node) private nodeData; //node info database Node to node struct (see RESOURCE_PRUF_INTERFACES for struct definitions)
    mapping(string => uint32) private nodeId; //name to Node resolution map
    mapping(bytes32 => mapping(uint32 => uint8)) private registeredUsers; //Authorized recorder database by Node, by address hash
    mapping(uint8 => uint8) private validStorageProviders; //storageProviders -> status (enabled or disabled)
    mapping(uint8 => uint8) private validManagementTypes; //managementTypes -> status (enabled or disabled)
    mapping(uint8 => uint8) private validCustodyTypes; //custodyTypes -> status (enabled or disabled)

    constructor() {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
        nodeId[""] = 4294967295; //points the blank string name to node 4294967295 to make "" owned
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
     * @dev Verify user credentials
     * Originating Address:
     *      has NODE_ADMIN_ROLE
     */
    modifier isNodeAdmin() {
        require(
            hasRole(NODE_ADMIN_ROLE, _msgSender()),
            "NM:MOD-INA: Must have NODE_ADMIN_ROLE"
        );
        _;
    }


    //--------------------------------------------Administrative Setters--------------------------

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
     * @param _thisName - name to be transferred
     */
    function transferName(
        uint32 _fromNode,
        uint32 _toNode,
        string calldata _thisName
    ) external isNodeAdmin {
        require(
            nodeId[_thisName] == _fromNode,
            "NM:TN: Name not in source node"
        ); //source Node_Name must match name given

        require(
            (nodeData[_toNode].CAS1 == B320xF_), //dest node must have CAS1 set to 0xFFFF.....
            "NM:TN: Destination node not prepared for name transfer"
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
            "NM:UNN: Name already in use"
        );
        //^^^^^^^checks^^^^^^^^^

        delete nodeId[nodeData[_node].name];

        nodeId[_newName] = _node;
        nodeData[_node].name = _newName;
        //^^^^^^^effects^^^^^^^^^
    }

    function setNodeData(uint32 _node, Node memory _thisNodeData)
        external
        isNodeAdmin
    {
        Node memory rootData = nodeData[_thisNodeData.nodeRoot];

        require((_node != 0), "NM:AMAC: Node = 0"); //sanity check inputs
        require(
            _thisNodeData.discount <= 10000,
            "NM:AMAC: Discount > 10000 (100%)"
        );
        require( //has valid root
            (rootData.custodyType == 3) || (_thisNodeData.nodeRoot == _node),
            "NM:AMAC: Root !exist"
        );

        require( //should pass if name is same as old name or name is unassigned. Should fail if name is assigned to other node
            (nodeId[_thisNodeData.name] == 0) || //name is unassigned
                (keccak256(abi.encodePacked(_thisNodeData.name)) == //name is same as old name
                    (keccak256(abi.encodePacked(nodeData[_node].name)))),
            "NM:UNN: name is changed or not unset."
        );

        nodeData[_node] = _thisNodeData;
    }

    function setNodeId(uint32 _node, string memory _name) external isNodeAdmin {
        delete nodeId[_name];
        if (
            keccak256(abi.encodePacked(_name)) !=
            keccak256(abi.encodePacked(""))
        ) {
            nodeId[_name] = _node;
        }
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
            "NM:MNS: Bit position !>0||<9"
        );
        require(_bit < 2, "NM:MNS: Bit != 1 or 0");

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
            registeredUsers[_addrHash][0]++;
        }

        if ((_userType == 0) && (registeredUsers[_addrHash][0] > 0)) {
            registeredUsers[_addrHash][0]--;
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
     */
    function getExtendedNodeData(uint32 _node)
        external
        view
        returns (Node memory)
    {
        //^^^^^^^checks^^^^^^^^^

        return (nodeData[_node]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev verify the root of two Nodees are equal
     * @param _node1 - first node associated with query
     * @param _node2 - second node associated with query
     * @return 170 or 0 (true or false)
     */
    function isSameRootNode(uint32 _node1, uint32 _node2)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        if (nodeData[_node1].nodeRoot == nodeData[_node2].nodeRoot) {
            return uint8(170);
        } else {
            return uint8(0);
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve Node_name @ _tokenId or node
     * @param node - tokenId associated with query
     * @return name of token @ _tokenID
     */
    function getNodeName(uint32 node) external view returns (string memory) {
        //^^^^^^^checks^^^^^^^^^

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
     */
    function getInvoice(uint32 _node, uint16 _service)
        external
        view
        returns (Invoice memory)
    {
        Node memory node_info = nodeData[_node];
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

        return invoice;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve service costs for _node._service
     * @param _node - node associated with query
     * @param _service - service associated with query
     * @return Costs Struct for_node
     */
    function getServicePaymentData(uint32 _node, uint16 _service)
        external
        view
        returns (Costs memory)
    {
        //^^^^^^^checks^^^^^^^^^
        Costs memory ServicePaymentData;

        ServicePaymentData.paymentAddress = cost[_node][_service]
            .paymentAddress;
        ServicePaymentData.serviceCost = cost[_node][_service].serviceCost;
        //^^^^^^^effects^^^^^^^^^

        return ServicePaymentData;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Retrieve Node_discount @ _node
     * @param _node - node associated with query
     * @return percentage of rewards distribution @ _node
     */
    function getNodeDiscount(uint32 _node) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^

        return (nodeData[_node].discount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get bit from .switches at specified position
     * @param _node - node associated with query
     * @param _position - bit position associated with query
     * @return 1 or 0 (enabled or disabled)
     */
    function getSwitchAt(uint32 _node, uint8 _position)
        external
        view
        returns (uint256)
    {
        require(
            (_position > 0) && (_position < 9),
            "NM:GSA: bit position must be between 1 and 8"
        );
        //^^^^^^^checks^^^^^^^^^

        if ((nodeData[_node].switches & (1 << (_position - 1))) > 0) {
            return 1;
        } else {
            return 0;
        }
        //^^^^^^^interactions^^^^^^^^^
    }
}
