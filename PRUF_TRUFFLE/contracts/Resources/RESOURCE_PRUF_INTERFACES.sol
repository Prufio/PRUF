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

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./RESOURCE_PRUF_STRUCTS.sol";

//---------------------------------------------------------------------------------------------------------------
/*
 * @dev Interface for STOR
 * INHERITANCE:
    import "./Imports/access/Ownable.sol";
    import "./Imports/security/Pausable.sol";
     
    import "./Imports/security/ReentrancyGuard.sol";
 */
interface STOR_Interface {
    //--------------------------------Public Functions---------------------------------//

    /**
     * @dev Authorize / Deauthorize contract NAMES permitted to make record modifications, per node
     * allows NodeTokenHolder to Authorize / Deauthorize specific contracts to work within their node
     * @param   _name -  Name of contract being authed
     * @param   _node - affected node
     * @param   _contractAuthLevel - auth level to set for thae contract, in that node
     */
    function enableContractForNode(
        string memory _name,
        uint32 _node,
        uint8 _contractAuthLevel
    ) external;

    //--------------------------------External Functions---------------------------------//

    /**
     * @dev Triggers stopped state. (pausable)
     */
    function pause() external;

    /**
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external;

    /**
     * @dev Authorize / Deauthorize ADRESSES permitted to make record modifications, per node
     * populates contract name resolution and data mappings
     * @param _contractName - String name of contract
     * @param _contractAddr - address of contract
     * @param _node - node to authorize in
     * @param _contractAuthLevel - auth level to assign
     */
    function authorizeContract(
        string calldata _contractName,
        address _contractAddr,
        uint32 _node,
        uint8 _contractAuthLevel
    ) external;

    /**
     * @dev set the default list of 11 contracts (zero index) to be applied to Noees
     * @param _contractNumber - 0-10
     * @param _name - name
     * @param _contractAuthLevel - authLevel
     */
    function addDefaultContracts(
        uint256 _contractNumber,
        string calldata _name,
        uint8 _contractAuthLevel
    ) external;

    /**
     * @dev retrieve a record from the default list of 11 contracts to be applied to Nodees
     * @param _contractNumber to look up (0-10)
     * @return the name and auth level of indexed contract
     */
    function getDefaultContract(uint256 _contractNumber)
        external
        view
        returns (DefaultContract memory);

    /**
     * @dev Set the default 11 authorized contracts
     * @param _node the Node which will be enabled for the default contracts
     */
    function enableDefaultContractsForNode(uint32 _node) external;

    /**
     * @dev Make a new record, writing to the 'database' mapping with basic initial asset data
     * calling contract must be authorized in relevant node
     * @param   _idxHash - asset ID
     * @param   _rgtHash - rightsholder id hash
     * @param _URIhash - hash of URI Suffix
     * @param   _node - node in which to create the asset
     * @param   _countDownStart - initial value for decrement-only value
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _URIhash,
        uint32 _node,
        uint32 _countDownStart
    ) external;

    /**
     * @dev Modify a record, writing to the 'database' mapping with updates to multiple fields
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * @param _newAssetStatus - New Status to set
     * @param _countDown - New countdown value (must be <= old value)
     * @param _int32temp - temp value
     * @param _incrementModCount - 0 = no 170 = yes
     * @param _incrementNumberOfTransfers - 0 = no 170 = yes
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint32 _countDown,
        uint32 _int32temp,
        uint256 _incrementModCount,
        uint256 _incrementNumberOfTransfers
    ) external;

    /**
     * @dev Change node of an asset - writes to node in the 'Record' struct of the 'database' at _idxHash
     * @param _idxHash - record asset ID
     * @param _newNode - Aseet Class to change to
     */
    function changeNode(bytes32 _idxHash, uint32 _newNode) external;

    /**
     * @dev Set an asset to Lost Or Stolen. Allows narrow modification of status 6/12 assets, normally locked
     * @param _idxHash - record asset ID
     * @param _newAssetStatus - Status to change to
     */
    function setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /**
     * @dev Set an asset to escrow locked status (6/50/56).
     * @param _idxHash - record asset ID
     * @param _newAssetStatus - New Status to set
     */
    function setEscrow(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /**
     * @dev remove an asset from escrow status. Implicitly trusts escrowManager ECR_MGR contract
     * @param _idxHash - record asset ID
     */
    function endEscrow(bytes32 _idxHash) external;

    /**
     * @dev Modify record MutableStorage data
     * @param  _idxHash - record asset ID
     * @param  _mutableStorage1 - first half of content adressable storage location
     * @param  _mutableStorage2 - second half of content adressable storage location
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external;

    /**
     * @dev Modify NonMutableStorage data
     * @param _idxHash - record asset ID
     * @param _nonMutableStorage1 - first half of content addressable storage location
     * @param _nonMutableStorage2 - second half of content addressable storage location
     */
    function setNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external;

    /**
     * @dev return a record from the database
     * @param  _idxHash - record asset ID
     * returns a complete Record struct (see interfaces for struct definitions)
     */
    function retrieveRecord(bytes32 _idxHash)
        external
        view
        returns (Record memory);

    /**
     * @dev return a record from the database w/o rgt
     * @param _idxHash - record asset ID
     * @return rec.assetStatus,
                rec.modCount,
                rec.node,
                rec.countDown,
                rec.countDownStart,
                rec.mutableStorage1,
                rec.mutableStorage2,
                rec.nonMutableStorage1,
                rec.nonMutableStorage2,
     */
    function retrieveShortRecord(bytes32 _idxHash)
        external
        view
        returns (
            uint8,
            uint8,
            uint32,
            uint32,
            uint32,
            bytes32,
            bytes32,
            bytes32,
            bytes32,
            uint16
        );

    /**
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * @return 170 if matches, 0 if not
     */
    function verifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        view
        returns (uint256);

    /**
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder (writes an emit in blockchain for independant verification)
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * @return 170 if matches, 0 if not
     */
    function blockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint256);

    /**
     * @dev returns the address of a contract with name _name. This is for web3 implementations to find the right contract to interact with
     * example :  Frontend = ****** so web 3 first asks storage where to find frontend, then calls for frontend functions.
     * @param _name - contract name
     * @return contract address
     */
    function resolveContractAddress(string calldata _name)
        external
        view
        returns (address);

    /**
     * @dev returns the contract type of a contract with address _addr.
     * @param _addr - contract address
     * @param _node - node to look up contract type-in-class
     * @return contractType of given contract
     */
    function ContractInfoHash(address _addr, uint32 _node)
        external
        view
        returns (uint8, bytes32);
}

//---------------------------------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------------------------------
// /*
//  * @dev Interface for NODE_MGR
//  * INHERITANCE:
//     import "../Resources/PRUF_BASIC.sol";
//  */
interface NODE_MGR_Interface {
    //--------------------------------------------Admin Related Functions--------------------------
    /**
     * @dev Set pricing for Nodes
     * @param _newNodePrice - cost per node (18 decimals)
     * @param _newNodeBurn - burn per node (18 decimals)
     */
    function setNodePricing(uint256 _newNodePrice, uint256 _newNodeBurn)
        external;

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
        );

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
    ) external;

    /**
     * @dev Burns (amount) tokens and mints a new Node token to the calling address
     * @param _name - chosen name of node
     * @param _nodeRoot - chosen root of node
     * @param _custodyType - chosen custodyType of node (see docs)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     * @param _caller caller passed from an ID_VERIFIER
     * requires that caller has ID_VERIFIER_ROLE
     */
    function purchaseNode(
        string calldata _name,
        uint32 _nodeRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2,
        address _caller
    ) external returns (uint32);

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
    ) external;

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
    ) external;

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
    ) external;

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
    ) external;

    /**
     * @dev Configure the immutable data in an Node one time
     * @param _node - node being modified
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _refAddress - address permanently tied to node
     * @param _switches - 8 switch bits
     */
    function setNonMutableData(
        uint32 _node,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress,
        uint8 _switches
    ) external;

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
    ) external;

    /**
     * @dev set an external erc721 token as ID verification (when bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function setExternalIdToken(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external;

    /**
     * @dev set an external erc721 token as ID verification (when bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function daoSetExternalId(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external;
}

//---------------------------------------------------------------------------------------------------------------

// NODE_STOR_Interface
// import "../Resources/PRUF_BASIC.sol";
// import "../Imports/security/ReentrancyGuard.sol";

interface NODE_STOR_Interface {
    //--------------------------------------------Administrative Setters--------------------------

    /**
     * @dev Sets the valid storage type providers.
     * @param _storageProvider - uint position for storage provider
     * @param _status - uint position for custody type status
     */
    function setStorageProviders(uint8 _storageProvider, uint8 _status)
        external;

    /**
     * @dev Sets the valid management types.
     * @param _managementType - uint position for management type
     * @param _status - uint position for custody type status
     */
    function setManagementTypes(uint8 _managementType, uint8 _status) external;

    /**
     * @dev Sets the valid custody types.
     * @param _custodyType - uint position for custody type
     * @param _status - uint position for custody type status
     */
    function setCustodyTypes(uint8 _custodyType, uint8 _status) external;

    /**
     * !! to be used with great caution !!
     * This potentially breaks decentralization and must eventually be given over to DAO.
     * @dev Increases (but cannot decrease) price share for a given node
     * @param _node - node in which cost share is being modified
     * @param _newDiscount - discount(1% == 100, 10000 == max)
     */
    function changeShare(uint32 _node, uint32 _newDiscount) external;

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
    ) external;

    /**
     * @dev Modifies an node Node name for its exclusive namespace
     * @param _node - node being modified
     * @param _newName - updated name associated with node (unique)
     */
    function updateNodeName(uint32 _node, string calldata _newName) external;

    /**
     * @dev Modifies the name => nodeid name resolution mapping
     * @param _node - node being mapped to the name
     * @param _name - namespace being remapped
     */
    function setNodeIdForName(uint32 _node, string memory _name) external;

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
    ) external;

    /**
     * @dev Administratively Deauthorize address be permitted to mint or modify records
     * @dev only useful for custody types that designate user adresses (type1...)
     * @param _node - node that user is being deauthorized in
     * @param _addrHash - hash of address to deauthorize
     */
    function blockUser(uint32 _node, bytes32 _addrHash) external;

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
    ) external;

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
    ) external;

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
    ) external;

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
    ) external;

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
    ) external;

    /**
     * @dev Configure the immutable data in an Node one time
     * @param _node - node being modified
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _refAddress - address permanently tied to node
     * @param _switches - 8 switch bits
     */
    function setNonMutableData(
        uint32 _node,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress,
        uint8 _switches
    ) external;

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
    ) external;

    /**
     * @dev set an external erc721 token as ID verification (when bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function setExternalIdToken(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external;

    /**
     * @dev DAO set an external erc721 token as ID verification (when bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function daoSetExternalIdToken(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external;

    /**
     * @dev unlink erc721 token as ID verification
     * @param _node - node being unlinked
     */
    function unlinkExternalId(uint32 _node) external;

    /**
     * @dev extended node data setter
     * @param _foreignNode - node from other blockcahin to point to local node
     * @param _localNode local node to point to
     */
    function setLocalNode(uint32 _foreignNode, uint32 _localNode) external;

    /**
     * @dev Set import status for foreing nodes
     * @param _thisNode - node to dis/allow importing into
     * @param _otherNode - node to be potentially imported
     * returns importability status of _thisNode=>_othernode mapping
     */
    function getImportStatus(uint32 _thisNode, uint32 _otherNode)
        external
        view
        returns (uint256);

    /**
     * @dev extended node data setter
     * @param _foreignNode - node from other blockcahin to check for local node
     */
    function getLocalNode(uint32 _foreignNode) external view returns (uint32);

    /**
     * @dev extended node data getter
     * @param _node - node being queried
     * returns ExtendedNodeData struct (see resources-structs)
     */
    function getExtendedNodeData(uint32 _node)
        external
        view
        returns (ExtendedNodeData memory);

    /**
     * @dev get an node Node User type for a specified address
     * @param _userHash - hash of selected user
     * @param _node - node of query
     * @return type of user @ _node (see docs)
     */
    function getUserType(bytes32 _userHash, uint32 _node)
        external
        view
        returns (uint8);

    /**
     * @dev get the number of adresses authorized on a node
     * @param _node - node to query
     * @return number of auth users
     */
    function getNumberOfUsers(uint32 _node) external view returns (uint256);

    /**
     * @dev get the status of a specific management type
     * @param _managementType - management type associated with query (see docs)
     * @return 1 or 0 (enabled or disabled)
     */
    function getManagementTypeStatus(uint8 _managementType)
        external
        view
        returns (uint8);

    /**
     * @dev get the status of a specific storage provider
     * @param _storageProvider - storage provider associated with query (see docs)
     * @return 1 or 0 (enabled or disabled)
     */
    function getStorageProviderStatus(uint8 _storageProvider)
        external
        view
        returns (uint8);

    /**
     * @dev get the status of a specific custody type
     * @param _custodyType - custody type associated with query (see docs)
     * @return 1 or 0 (enabled or disabled)
     */
    function getCustodyTypeStatus(uint8 _custodyType)
        external
        view
        returns (uint8);

    /**
     * @dev Retrieve extended nodeData @ _node
     * @param _node - node associated with query
     * @return nodeData (see docs)
     * supports indirect node reference via localNodeFor[node]
     */
    function getNodeData(uint32 _node) external view returns (Node memory);

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
        returns (uint8);

    /**
     * @dev Retrieve Node_name @ _tokenId or node
     * @param _node - tokenId associated with query
     * return name of token @ _tokenID
     * supports indirect node reference via localNodeFor[node]
     */
    function getNodeName(uint32 _node) external view returns (string memory);

    /**
     * @dev Retrieve node @ Node_name
     * @param _forThisName - name of node for nodeNumber query
     * @return node number @ _name
     */
    function resolveNode(string calldata _forThisName)
        external
        view
        returns (uint32);

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
        returns (Invoice memory);

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
        returns (Costs memory);

    /**
     * @dev Retrieve Node_discount @ _node
     * @param _node - node associated with query
     * @return percentage of rewards distribution @ _node
     * supports indirect node reference via localNodeFor[node]
     */
    function getNodeDiscount(uint32 _node) external view returns (uint32);

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
        returns (uint256);

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
    ) external;
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for ECR_MGR
 * INHERITANCE:
    import "../Resources/PRUF_BASIC.sol";
     
 */
interface ECR_MGR_Interface {
    /**
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _newAssetStatus - new escrow status of asset (see docs)
     * @param _escrowOwnerAddressHash - hash of escrow controller address
     * @param _timelock - timelock parameter for time controlled escrows
     */
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock
    ) external;

    /**
     * @dev remove asset from escrow
     * @param _idxHash - hash of asset information created by frontend inputs
     */
    function endEscrow(bytes32 _idxHash) external;

    /**
     * @dev Sets data in the Escrow Data Light mapping
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _escrowDataLight - struct of data associated with light load escrows
     */
    function setEscrowDataLight(
        bytes32 _idxHash,
        escrowDataExtLight calldata _escrowDataLight
    ) external;

    /**
     * @dev Sets data in the Escrow Data Heavy mapping
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param escrowDataHeavy - struct of data associated with heavy load escrows
     */
    function setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy calldata escrowDataHeavy
    ) external;

    /**
     * @dev Permissive removal of asset from escrow status after time-out (no special qualifiers to end expired escrow)
     * @param _idxHash - hash of asset information created by frontend inputs
     */
    function permissiveEndEscrow(bytes32 _idxHash) external;

    /**
     * @dev return escrow owner hash
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return hash of escrow owner
     */
    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        view
        returns (bytes32);

    /**
     * @dev return escrow data associated with an asset
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return all escrow data  @ _idxHash
     */
    function retrieveEscrowData(bytes32 _idxHash)
        external
        view
        returns (escrowData memory);

    /**
     * @dev return EscrowDataLight
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return EscrowDataLight struct @ _idxHash
     */
    function retrieveEscrowDataLight(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtLight memory);

    /**
     * @dev return EscrowDataHeavy
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return EscrowDataHeavy struct @ _idxHash
     */
    function retrieveEscrowDataHeavy(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtHeavy memory);
}

//---------------------------------------------------------------------------------------------------------------

// /**
//  * @dev Interface for ID_MGR
//  * INHERITANCE:
// // import "./RESOURCE_PRUF_STRUCTS.sol";
// // import "./Imports/access/AccessControl.sol";
// // import "./Imports/security/Pausable.sol";
// */
// interface ID_MGR_Interface {
//     /**
//      * @dev Mint an Asset token
//      * @param _recipientAddress - Address to mint token into
//      * @param _trustLevel - Token ID to mint
//      * @param _IdHash - URI string to atatch to token
//      */
//     function mintID(
//         address _recipientAddress,
//         uint256 _trustLevel,
//         bytes32 _IdHash
//     ) external;

//     /**
//      * @dev Burn PRUF_ID token
//      * @param _addr - address to burn ID from
//      */
//     function burnID(address _addr) external;

//     /**
//      * @dev Set new ID data fields
//      * @param _addr - address to set trust level
//      * @param _trustLevel - _trustLevel to set
//      */
//     function setTrustLevel(address _addr, uint256 _trustLevel) external;

//     /**
//      * @dev get ID data given an address to look up
//      * @param _addr - address to check
//      * @return ID struct (see interfaces for struct definitions)
//      */
//     function IdDataByAddress(address _addr)
//         external
//         view
//         returns (PRUFID memory);

//     /**
//      * @dev get ID data given an IdHash to look up
//      * @param _IdHash - IdHash to check
//      * @return ID struct (see interfaces for struct definitions)
//      */
//     function IdDataByIdHash(bytes32 _IdHash)
//         external
//         view
//         returns (PRUFID memory);

//     /**
//      * @dev get ID trustLevel
//      * @param _addr - address to check
//      * @return trust level of token id
//      */
//     function trustLevel(address _addr) external view returns (uint256);

//     /**
//      * @dev Pauses all token transfers.
//      *
//      * See {ERC721Pausable} and {Pausable-_pause}.
//      *
//      * Requirements:
//      *
//      * - the caller must have the `PAUSER_ROLE`.
//      */
//     function pause() external;

//     /**
//      * @dev Unpauses all token transfers.
//      *
//      * See {ERC721Pausable} and {Pausable-_unpause}.
//      *
//      * Requirements:
//      *
//      * - the caller must have the `PAUSER_ROLE`.
//      */
//     function unpause() external;
// }

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for RCLR
 * INHERITANCE:
    import "../Resources/PRUF_ECR_CORE.sol";
    import "../Resources/PRUF_CORE.sol";
 */
interface RCLR_Interface {
    /**
     * @dev discards item -- caller is assetToken contract
     * @param _idxHash asset ID
     * @param _sender discarder
     * Caller Must have DISCARD_ROLE
     */
    function discard(bytes32 _idxHash, address _sender) external;

    /**
     * @dev reutilize a recycled asset
     * maybe describe the reqs in this one, back us up on the security
     * @param _idxHash asset ID
     * @param _rgtHash rights holder hash to set
     */
    function recycle(bytes32 _idxHash, bytes32 _rgtHash) external;
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for APP
 * INHERITANCE:
    import "../Resources/PRUF_CORE.sol";
 */
interface APP_Interface {
    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Creates a new record
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _URIsuffix URI
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        string memory _URIsuffix
    ) external;

    // /** //import & export have been slated for reevaluation
    //  * @dev import Rercord, must match export node
    //  * posessor is considered to be owner. sets rec.assetStatus to 0.
    //  * @param _idxHash - hash of asset information created by frontend inputs
    //  * @param _newNode - node the asset will be imported into
    //  */
    // function importAsset(bytes32 _idxHash, uint32 _newNode) external;

    /**
     * @dev Modify rec.rightsHolder
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of new rightsholder information created by frontend inputs
     */
    function forceModifyRecord(bytes32 _idxHash, bytes32 _rgtHash) external;

    /**
     * @dev Transfer rights to new rightsHolder with confirmation of matching rgthash
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _newrgtHash - hash of targeted reciever information created by frontend inputs
     */
    function transferAsset(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _newrgtHash
    ) external;

    /**
     * @dev Modify **Record** NonMutableStorage with confirmation of matching rgthash
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function addNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external;

    /**
     * @dev Transfer any specified assetToken from contract
     * @param _to - address to send to
     * @param _idxHash - asset index
     */
    function transferAssetToken(address _to, bytes32 _idxHash) external;

    /**
     * @dev Modify **Record**.assetStatus with confirmation of matching rgthash required
     * @param _idxHash asset to moidify
     * @param _rgtHash rgthash to match in front end
     * @param _newAssetStatus updated status
     */
    function modifyStatus(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    ) external;

    /**
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation of matching rgthash required
     * @param _idxHash asset to moidify
     * @param _rgtHash rgthash to match in front end
     * @param _newAssetStatus updated status
     */
    function setLostOrStolen(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    ) external;

    /**
     * @dev Decrement **Record**.countdown with confirmation of matching rgthash required
     * @param _idxHash asset to moidify
     * @param _rgtHash rgthash to match in front end
     * @param _decAmount amount to decrement
     */
    function decrementCounter(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _decAmount
    ) external;

    /**
     * @dev Modify rec.MutableStorage field with rghHash confirmation
     * @param _idxHash idx of asset to Modify
     * @param _rgtHash rgthash to match in front end
     * @param _mutableStorage1 content adressable storage adress part 1
     * @param _mutableStorage2 content adressable storage adress part 2
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external;

    //     /** //import & export have been slated for reevaluation
    //      * @dev Export FROM Custodial - sets asset to status 70 (importable) for export
    //      * @dev exportTo - sets asset to status 70 (importable) and defines the node that the item can be imported into
    //      * @param _idxHash idx of asset to Modify
    //      * @param _exportTo node target for export
    //      * @param _addr adress to send asset to
    //      * @param _rgtHash rgthash to match in front end
    //      */
    //     function exportAssetTo(
    //         bytes32 _idxHash,
    //         uint32 _exportTo,
    //         address _addr,
    //         bytes32 _rgtHash
    //     ) external;
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for APP_NC
 * INHERITANCE:
    import "../Resources/PRUF_CORE.sol";
 */
interface APP_NC_Interface {
    //---------------------------------------External Functions-------------------------------

    /**
     * @dev Create a newRecord with description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _mutableStorage1 - field for external asset data
     * @param _mutableStorage2 - field for external asset data
     * @param _URIsuffix - tokenURI
     */
    function newRecordWithDescription(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2,
        string memory _URIsuffix
    ) external;

    /**
     * @dev Create a newRecord with permanent description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     * @param _URIsuffix - tokenURI
     */
    function newRecordWithNote(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2,
        string memory _URIsuffix
    ) external;

    /**
     * @dev Create a newRecord
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _URIsuffix - tokenURI
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        string memory _URIsuffix
    ) external;

    // /** //import & export have been slated for reevaluation
    //  * @dev exportTo - sets asset to status 70 (importable) and defines the node that the item can be imported into
    //  * @param _idxHash idx of asset to Modify
    //  * @param _exportTo node target for export
    //  */
    // function exportAssetTo(bytes32 _idxHash, uint32 _exportTo) external;

    // /** //import & export have been slated for reevaluation
    //  * @dev Import a record into a new node
    //  * @param _idxHash - hash of asset information created by frontend inputs
    //  * @param _newNode - node the asset will be imported into
    //  */
    // function importAsset(bytes32 _idxHash, uint32 _newNode) external;

    /**
     * @dev record NonMutableStorage data
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function addNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external;

    /**
     * @dev record NonMutableStorage data
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function updateNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external;

    /**
     * @dev Modify rgtHash (like forceModify)
     * @param _idxHash idx of asset to Modify
     * @param _newRgtHash rew rgtHash to apply
     */
    function changeRgt(bytes32 _idxHash, bytes32 _newRgtHash) external;

    /**
     * @dev Modify **Record**.assetStatus with confirmation required
     * @param _idxHash idx of asset to Modify
     * @param _newAssetStatus Updated status
     */
    function modifyStatus(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /**
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation of matching rgthash required.
     * @param _idxHash idx of asset to Modify
     * @param _newAssetStatus Updated status
     */
    function setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /**
     * @dev Decrement **Record**.countdown.
     * @param _idxHash index hash of asset to modify
     * @param _decAmount Amount to decrement
     */
    function decrementCounter(bytes32 _idxHash, uint32 _decAmount) external;

    /**
     * @dev Modify **Record**.mutableStorage1 with confirmation of matching rgthash required.
     * @param _idxHash idx of asset to Modify
     * @param _mutableStorage1 content addressable storage address part 1
     * @param _mutableStorage2 content addressable storage address part 2
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external;
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for EO_STAKING
 * INHERITANCE:
    import "./Imports/access/AccessControl.sol";
    import "./Imports/security/Pausable.sol";
    import "./Imports/security/ReentrancyGuard.sol";
    import "./Imports/token/ERC721/IERC721.sol";
    import "./Imports/token/ERC721/IERC721Receiver.sol";
 */
interface EO_STAKING_Interface {
    //--------------------------------------External functions--------------------------------------------//

    /**
     * @dev Setter for setting fractions of a day for minimum interval
     * @param _minUpgradeInterval in seconds
     */
    function setMinimumPeriod(uint256 _minUpgradeInterval) external;

    /**
     * @dev Kill switch for staking reward earning
     * @param _delay delay in seconds to end stake earning
     */
    function endStaking(uint256 _delay) external;

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN(PRUF)
     * @param _stakeAddress address of STAKE_TKN
     * @param _stakeVaultAddress address of STAKE_VAULT
     * @param _rewardsVaultAddress address of REWARDS_VAULT
     */
    function setTokenContracts(
        address _utilAddress,
        address _stakeAddress,
        address _stakeVaultAddress,
        address _rewardsVaultAddress
    ) external;

    /**
     * @dev Set stake tier parameters
     * @param _stakeTier Staking level to set
     * @param _min Minumum stake
     * @param _max Maximum stake
     * @param _interval staking interval, in dayUnits - set to the number of days that the stake and reward interval will be based on.
     * @param _bonusPercentage bonusPercentage in tenths of a percent: 15 = 1.5% or 15/1000 per interval. Calculated to a fixed amount of tokens in the actual stake
     */
    function setStakeLevels(
        uint256 _stakeTier,
        uint256 _min,
        uint256 _max,
        uint256 _interval,
        uint256 _bonusPercentage
    ) external;

    /**
     * @dev Create a new stake
     * @param _amount amount of tokens to stake
     * @param _stakeTier staking tier
     */
    function stakeMyTokens(uint256 _amount, uint256 _stakeTier) external;

    /**
     * @dev Transfers eligible rewards to staker, resets last payment time, adds _amount tokens to holders stake
     * @param _tokenId token id to modify stake
     */
    function increaseMyStake(uint256 _tokenId, uint256 _amount) external;

    /**
     * @dev Transfers eligible rewards to staker, resets last payment time
     * @param _tokenId token id to claim rewards on
     */
    function claimBonus(uint256 _tokenId) external;

    /**
     * @dev Burns stake, transfers eligible rewards and staked tokens to staker
     * @param _tokenId stake key token id
     */
    function breakStake(uint256 _tokenId) external;

    /**
     * @dev Pauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     */
    function pause() external;

    /**
     * @dev Unpauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     */
    function unpause() external;

    /**
     * @dev Check eligible rewards amount for a stake, for verification
     * @param _tokenId token id to check
     * @return reward and microIntervals
     */
    function checkEligibleRewards(uint256 _tokenId)
        external
        view
        returns (uint256, uint256);

    /**
     * @dev Returns info of given stake key tokenId
     * @param _tokenId Stake ID to return
     * @return Stake struct, see Interfaces.sol
     */
    function stakeInfo(uint256 _tokenId)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    /**
     * @dev Return specific stakeTier specification
     * @param _stakeTier stake level to inspect
     * @return StakingTier @ given index, see declaration in beginning of contract
     */
    function getStakeLevel(uint256 _stakeTier)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        );
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for STAKE_VAULT
 * INHERITANCE:
    import "./Imports/access/AccessControl.sol";
    import "./Imports/security/Pausable.sol";
    import "./Imports/security/ReentrancyGuard.sol";
    import "./Imports/token/ERC721/IERC721.sol";
    import "./Imports/token/ERC721/IERC721Receiver.sol";
 */
interface STAKE_VAULT_Interface {
    //-----------External Admin functions / isContractAdmin-----------//

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN contract
     * @param _stakeAddress address of STAKE_TKN contract
     */
    function setTokenContracts(address _utilAddress, address _stakeAddress)
        external;

    //-------------------------External functions-----------------------//

    /**
     * @dev moves tokens(amount) from holder(tokenID) into itself using trustedAgentTransfer, records the amount in stake map
     * @param _tokenId stake token to take stake for
     * @param _amount amount of stake to pull
     */
    function takeStake(uint256 _tokenId, uint256 _amount) external;

    /**
     * @dev sends stakedAmount[tokenId] tokens to ownerOf(tokenId), updates the stake map.
     * @param _tokenId stake token to release stake for
     */
    function releaseStake(uint256 _tokenId) external;

    /**
     * @dev Returns the amount of tokens staked on (tokenId)
     * @param _tokenId token to check
     * @return Stake of _tokenId
     */
    function stakeOfToken(uint256 _tokenId) external view returns (uint256);

    /**
     * @dev Pauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     */
    function pause() external;

    /**
     * @dev Unpauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     */
    function unpause() external;
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for REWARDS_VAULT
 * INHERITANCE:
    import "./Imports/access/AccessControl.sol";
    import "./Imports/security/Pausable.sol";
    import "./Imports/security/ReentrancyGuard.sol";
    import "./Imports/token/ERC721/IERC721.sol";
    import "./Imports/token/ERC721/IERC721Receiver.sol";
 */
interface REWARDS_VAULT_Interface {
    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     */
    function setTokenContracts(address _utilAddress, address _stakeAddress)
        external;

    /**
     * @dev Sends (amount) pruf to ownerOf(tokenId)
     * @param _tokenId - stake key token ID
     * @param _amount - amount to pay to owner of (tokenId)
     */
    function payRewards(uint256 _tokenId, uint256 _amount) external;

    /**
     * @dev Pauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     */
    function pause() external;

    /**
     * @dev Unpauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     */
    function unpause() external;
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for UD_721
 * INHERITANCE:
    import "../Resources/PRUF_BASIC.sol";
    import "../Imports/security/ReentrancyGuard.sol";
 */
interface UD_721_Interface {
    /**
     * @dev Set address of STOR contract to interface with
     * @param _erc721Address address of token contract to interface with
     */
    function setUnstoppableDomainsTokenContract(address _erc721Address)
        external;

    /**
     * @dev Burns (amount) tokens and mints a new Node token to the calling address
     * @param _domain - chosen domain of node
     * @param _tld - chosen tld of node
     * @param _nodeRoot - chosen root of node
     * @param _custodyType - chosen custodyType of node (see docs)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function purchaseNode(
        string calldata _domain,
        string calldata _tld,
        uint32 _nodeRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external returns (uint256);

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
    ) external;

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
    ) external;

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
    ) external;

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
    ) external;

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
    ) external;

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
    ) external;

    function getTokenIdFromDomain(string memory _domain, string memory _tld)
        external
        returns (uint256);
}

//---------------------------------------------------------------------------------------------------------------

/*
 * @dev Interface for BASIC
 * INHERITANCE:
    import "../Resources/RESOURCE_PRUF_INTERFACES.sol";
    import "../Resources/RESOURCE_PRUF_TKN_INTERFACES.sol";
    import "../Imports/access/AccessControl.sol";
    import "../Imports/security/Pausable.sol";
    import "../Imports/security/ReentrancyGuard.sol";
    import "../Imports/token/ERC721/IERC721Receiver.sol";
    import "../Resources/IERC721_URI.sol";
    import "../Imports/token/ERC20/IERC20.sol";
 */
interface BASIC_Interface {
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account)
        external
        view
        returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;

    /**
     * @dev Returns one of the accounts that have `role`. `index` must be a
     * value between 0 and {getRoleMemberCount}, non-inclusive.
     *
     * Role bearers are not sorted in any particular way, and their ordering may
     * change at any point.
     *
     * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
     * you perform all queries on the same block. See the following
     * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
     * for more information.
     */
    function getRoleMember(bytes32 role, uint256 index)
        external
        view
        returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function getRoleMemberCount(bytes32 role) external view returns (uint256);

    /**
     * @dev Resolve contract addresses from STOR
     */
    function resolveContractAddresses() external;

    /**
     * @dev Set address of STOR contract to interface with
     * @param _storageAddress address of PRUF_STOR
     */
    function setStorageContract(address _storageAddress) external;

    /***
     * @dev Triggers stopped state. (pausable)
     */
    function pause() external;

    /***
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external;

    /**
     * @dev Returns true if the contract is paused, and false otherwise.
     */
    function paused() external returns (bool);

    /**
     * @dev send an ERC721 token from this contract
     * @param _tokenContract Address of foreign token contract
     * @param _to destination
     * @param _tokenID Token ID
     */
    function ERC721Transfer(
        address _tokenContract,
        address _to,
        uint256 _tokenID
    ) external;

    /**
     * @dev send an ERC20 token from this contract
     * @param _tokenContract Address of foreign token contract
     * @param _to destination
     * @param _amount amount to transfer
     */
    function ERC20Transfer(
        address _tokenContract,
        address _to,
        uint256 _amount
    ) external;
}

//---------------------------------------------------------------------------------------------------------------

// /**
//  * @dev External interface of AccessControl declared to support ERC165 detection.
//  */
// interface IAccessControl {
//     /**
//      * @dev Returns `true` if `account` has been granted `role`.
//      */
//     function hasRole(bytes32 role, address account)
//         external
//         view
//         returns (bool);

//     /**
//      * @dev Returns the admin role that controls `role`. See {grantRole} and
//      * {revokeRole}.
//      *
//      * To change a role's admin, use {AccessControl-_setRoleAdmin}.
//      */
//     function getRoleAdmin(bytes32 role) external view returns (bytes32);

//     /**
//      * @dev Grants `role` to `account`.
//      *
//      * If `account` had not been already granted `role`, emits a {RoleGranted}
//      * event.
//      *
//      * Requirements:
//      *
//      * - the caller must have ``role``'s admin role.
//      */
//     function grantRole(bytes32 role, address account) external;

//     /**
//      * @dev Revokes `role` from `account`.
//      *
//      * If `account` had been granted `role`, emits a {RoleRevoked} event.
//      *
//      * Requirements:
//      *
//      * - the caller must have ``role``'s admin role.
//      */
//     function revokeRole(bytes32 role, address account) external;

//     /**
//      * @dev Revokes `role` from the calling account.
//      *
//      * Roles are often managed via {grantRole} and {revokeRole}: this function's
//      * purpose is to provide a mechanism for accounts to lose their privileges
//      * if they are compromised (such as when a trusted device is misplaced).
//      *
//      * If the calling account had been granted `role`, emits a {RoleRevoked}
//      * event.
//      *
//      * Requirements:
//      *
//      * - the caller must be `account`.
//      */
//     function renounceRole(bytes32 role, address account) external;

//     /**
//      * @dev Returns one of the accounts that have `role`. `index` must be a
//      * value between 0 and {getRoleMemberCount}, non-inclusive.
//      *
//      * Role bearers are not sorted in any particular way, and their ordering may
//      * change at any point.
//      *
//      * WARNING: When using {getRoleMember} and {getRoleMemberCount}, make sure
//      * you perform all queries on the same block. See the following
//      * https://forum.openzeppelin.com/t/iterating-over-elements-on-enumerableset-in-openzeppelin-contracts/2296[forum post]
//      * for more information.
//      */
//     function getRoleMember(bytes32 role, uint256 index)
//         external
//         view
//         returns (address);

//     /**
//      * @dev Returns the number of accounts that have `role`. Can be used
//      * together with {getRoleMember} to enumerate all bearers of a role.
//      */
//     function getRoleMemberCount(bytes32 role) external view returns (uint256);
//}
