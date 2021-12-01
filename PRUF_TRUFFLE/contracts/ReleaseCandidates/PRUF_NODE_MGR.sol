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
 ** IMPORTANT Local (child) node behaviours overwrite parent nodes; **
 ** DPS:CHECK VERIFY THAT THIS IS ENFORCED  local nodes should only be mapped if their nonmutable attributes match those of their parent. **
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
    uint256 private nodeTokenIndex = 1000000; //Starting index for purchased node tokens
    uint256 public node_price = 100000 ether;
    uint256 private node_burn = 100000 ether;
    uint32 private constant startingDiscount = 9500; //Purchased nodes start with 95% profit share

    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");
    bytes32 public constant ID_VERIFIER_ROLE = keccak256("ID_VERIFIER_ROLE");

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
     * @dev Verify user credentials
     * Originating Address:
     *      has ID_PROVIDER_ROLE
     */
    modifier isIdVerifier() {
        require(
            hasRole(ID_VERIFIER_ROLE, _msgSender()),
            "NM:MOD-INM: Must have ID_VERIFIER_ROLE"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Set pricing for Nodes
     * @param _newNodePrice - cost per node (18 decimals)
     * @param _newNodeBurn - burn per node (18 decimals)
     */
    function setNodePricing(uint256 _newNodePrice, uint256 _newNodeBurn)
        external
        isDAO
    {
        require(
            _newNodePrice <= _newNodeBurn,
            "NM:SNP:node burn must be => node price"
        ); //Enforce 50% + node cost burning
        //^^^^^^^checks^^^^^^^^^

        node_price = _newNodePrice;
        node_burn = _newNodeBurn;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("node pricing changed!"); //report access to internal parameter
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev return current node token index and price
     * @return {
         nodeTokenIndex: current token number
         node_price: current price per node
         node_burn: burn per node
     }
     */
    function currentNodePricingInfo()
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        //^^^^^^^checks^^^^^^^^^

        return (nodeTokenIndex, node_price, node_burn);
        //^^^^^^^interactions^^^^^^^^^
    }

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

        _createNode(_newNode, _node, _recipientAddress, _msgSender());
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
        bytes32 _CAS2,
        address _caller
    ) external nonReentrant whenNotPaused isIdVerifier returns (uint256) {
        require(
            nodeTokenIndex < 4294000000,
            "NM:PN: Only 4294000000 node tokens allowed"
        );
        require(
            (_custodyType != 3) && (_custodyType != 0),
            "NM:PN: custody type cannot be 0||3 "
        );

        //^^^^^^^checks^^^^^^^^^

        nodeTokenIndex++;
        Costs memory paymentData = NODE_STOR.getPaymentData(_nodeRoot, 1);

        address rootPaymentAddress = paymentData.paymentAddress; //payment for upgrade goes to root node payment address specified for service (1)

        //mint an Node token to _mintToAddress, at tokenID nodeTokenIndex, with URI = root Node

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

        UTIL_TKN.trustedAgentBurn(_caller, node_burn);
        UTIL_TKN.trustedAgentTransfer(_caller, rootPaymentAddress, node_price); //burning 50%+ so we have tokens to incentivise outreach performance

        _createNode(ThisNode, uint32(nodeTokenIndex), _caller, _caller);

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
    ) external whenNotPaused isIdVerifier {
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.addUser(_node, _addrHash, _userType);
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
    ) external whenNotPaused isIdVerifier {
        NODE_STOR.updateImportStatus(_thisNode, _otherNode, _newStatus);
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
    ) external whenNotPaused isIdVerifier {
        Node memory thisNode = NODE_STOR.getNodeData(_node);
        require(
            (NODE_STOR.getSwitchAt(_node, 1) == 0) ||
                (thisNode.CAS1 & thisNode.CAS2 == 0),
            "NM:UNC: CAS for node is set and cannot be written"
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
    ) external whenNotPaused isIdVerifier {
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
        address _refAddress,
        uint8 _switches
    ) external whenNotPaused isIdVerifier {
        Node memory thisNode = NODE_STOR.getNodeData(_node);
        ExtendedNodeData memory thisNodeExtData = NODE_STOR.getExtendedNodeData(
            _node
        );

        require(
            thisNode.managementType == 255,
            "NM:SNMD: Immutable node data already set"
        );
        require(
            _managementType != 255,
            "NM:SNMD: managementType = 255(Unconfigured)"
        );

        if (thisNode.custodyType != 3) {
            //CTS:EXAMINE
            require(
                _managementType != 0,
                "NM:SNMD: managementType cannot = 0 unless root"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.setNonMutableData(
            _node,
            _managementType,
            _storageProvider,
            _refAddress,
            _switches
        );

        //if extended data shows a verifying token id, set switch 6 to one
        if (thisNodeExtData.idProviderTokenId != 0) {
            NODE_STOR.modifyNodeSwitches(_node, 6, 1);
        }
        //^^^^^^^interactions^^^^^^^^^
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
    ) external whenNotPaused isIdVerifier {
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.setExtendedNodeData(_node, _u8a, _u8b, _u16c, _u32d, _u32e);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev external erc721 token as ID configurator (bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function setExternalIdToken(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external whenNotPaused isIdVerifier {
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.setExternalIdToken(_node, _tokenContractAddress, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
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
        address _recipientAddress,
        address _caller
    ) private whenNotPaused {
        //^^^^^^^checks^^^^^^^^^

        uint256 tokenId = uint256(_newNode);

        NODE_STOR.createNodeData(_newNodeData, _newNode, _caller);
        NODE_TKN.mintNodeToken(_recipientAddress, tokenId, "pruf.io/nodeToken");
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get bit from uint8 at specified position (1-8)
     * @param _byte - node associated with query
     * @param _position - bit position associated with query
     * @return 1 or 0 (enabled or disabled)
     * supports indirect node reference via localNodeFor[node]
     */
    function getBitAt(uint8 _byte, uint8 _position)
        internal
        pure
        returns (uint256)
    {
        require(
            (_position > 0) && (_position < 9),
            "NS:GSA: bit position must be between 1 and 8"
        );
        //^^^^^^^checks^^^^^^^^^

        if ((_byte & (1 << (_position - 1))) > 0) {
            return 1;
        } else {
            return 0;
        }
        //^^^^^^^interactions^^^^^^^^^
    }
}
