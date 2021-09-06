/*--------------------------------------------------------PRüF0.8.6
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
pragma solidity ^0.8.6;
import "./RESOURCE_PRUF_STRUCTS.sol";

//------------------------------------------------------------------------------------------------
/*
 * @dev Interface for NODE_MGR
 * INHERITANCE:
    import "./PRUF_BASIC.sol";
     
 */
interface NODE_MGR_Interface {
    /*
     * @dev Transfers a name from one node to another
     * !! -------- to be used with great caution and only as a result of community governance action -----------
     * Designed to remedy brand infringement issues. This breaks decentralization and must eventually be given
     * over to some kind of governance contract.
     * Destination node must have content adressable storage Set to 0xFFF.....
     *
     */
    function transferName(
        uint32 _fromNode,
        uint32 _toNode,
        string calldata _name
    ) external;

    /*
     * @dev Modifies an node with minimal controls
     */
    function modifyNode(
        uint32 _node,
        uint32 _nodeRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        address _refAddress,
        uint8 _switches,
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

    /*
     * @dev Mints node token and creates an node. Mints to @address
     * Requires that:
     *  name is unuiqe
     *  node is not provisioned with a root (proxy for not yet registered)
     *  that ACtoken does not exist
     *  _discount 10000 = 100 percent price share , cannot exceed
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
     * @dev Burns (amount) tokens and mints a new node token to the caller address
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function purchaseNode(
        string calldata _name,
        uint32 _nodeRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external returns (uint256);

    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     */
    function addUser(
        uint32 _node,
        bytes32 _addrHash,
        uint8 _userType
    ) external;

    /*
     * @dev Modifies an node
     * Sets a new node name. Nodees cannot be moved to a new root or custody type.
     * Requires that:
     *  caller holds ACtoken
     *  name is unuiqe or same as old name
     */
    function updateNodeName(uint32 _node, string calldata _name) external;

    /*
     * @dev Modifies an node
     * Sets a new node content adressable storage Address. Nodees cannot be moved to a new root or custody type.
     * Requires that:
     *  caller holds ACtoken
     */
    function updateNodeCAS(
        uint32 _node,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external;

    /*
     * @dev Set function costs and payment address per node, in Wei
     */
    function setOperationCosts(
        uint32 _node,
        uint16 _service,
        uint256 _serviceCost,
        address _paymentAddress
    ) external;

    /*
     * @dev Modifies an node
     * Sets the immutable data on an node
     * Requires that:
     * caller holds ACtoken
     * node is managementType 255 (unconfigured)
     */
    function updateACImmutable(
        uint32 _node,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress
    ) external;

    //-------------------------------------------Read-only functions ----------------------------------------------

    /**
     * @dev get bit from .switches at specified position
     * @param _node - node associated with query
     * @param _position - bit position associated with query
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getSwitchAt(uint32 _node, uint8 _position)
        external
        returns (uint256);

    /*
     * @dev get a User Record
     */
    function getUserType(bytes32 _userHash, uint32 _node)
        external
        view
        returns (uint8);

    /*
     * @dev get the authorization status of a management type 0 = not allowed
     */
    function getManagementTypeStatus(uint8 _managementType)
        external
        view
        returns (uint8);

    /*
     * @dev get the authorization status of a storage type 0 = not allowed
     */
    function getStorageProviderStatus(uint8 _storageProvider)
        external
        view
        returns (uint8);

    /*
     * @dev get the authorization status of a custody type 0 = not allowed
     */
    function getCustodyTypeStatus(uint8 _custodyType)
        external
        view
        returns (uint8);

    /* CAN'T RETURN A STRUCT WITH A STRING WITHOUT WIERDNESS-0.8.1
     * @dev Retrieve node_data @ _node
     */
    function getExtendedNodeData(uint32 _node)
        external
        view
        returns (Node memory);

    /*
     * @dev compare the root of two Nodees
     */
    function isSameRootNode(uint32 _node1, uint32 _node2)
        external
        view
        returns (uint8);

    /*
     * @dev Retrieve Node_name @ _tokenId
     */
    function getNodeName(uint32 _tokenId) external view returns (string memory);

    /*
     * @dev Retrieve node_index @ Node_name
     */
    function resolveNode(string calldata _name) external view returns (uint32);

    /*
     * @dev return current node token index pointer
     */
    function currentNodePricingInfo() external view returns (uint256, uint256);

    /*
     * @dev Retrieve function costs per node, per service type, in Wei
     */
    function getServiceCosts(uint32 _node, uint16 _service)
        external
        view
        returns (Invoice memory);

    /**
     * @dev Retrieve PRUF_MARKET Commisiions and feed for _node
     * @param _node - node associated with query
     *
     * @return marketFees Struct for_node
     */
    function getNodeMarketFees(uint32 _node)
        external
        view
        returns (MarketFees memory);

    /*
     * @dev Retrieve Node_discount @ _node, in percent NTH share, * 100 (9000 = 90%)
     */
    function getNodeDiscount(uint32 _node) external view returns (uint32);

    /**
     * @dev get comission to charge for sales in marketplace for listing under the node's ID
     * @param _node - node to get comission
     * @return uint8 the divisor for comission charges
     */
    function getNodeComission(uint32 _node) external view returns (uint8);
}

//------------------------------------------------------------------------------------------------

/*
 * @dev Interface for STOR
 * INHERITANCE:
    import "./Imports/access/Ownable.sol";
    import "./Imports/utils/Pausable.sol";
     
    import "./Imports/utils/ReentrancyGuard.sol";
 */
interface STOR_Interface {
    /*
     * @dev Triggers stopped state. (pausable)
     */
    function pause() external;

    /*
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external;

    /*
     * @dev ASet the default 11 authorized contracts
     */
    function enableDefaultContractsForNode(uint32 _node) external;

    /*
     * @dev Authorize / Deauthorize / Authorize contract NAMES permitted to make record modifications, per Node
     * allows ACtokenHolder to auithorize or deauthorize specific contracts to work within their node
     */
    function enableContractForNode(
        string calldata _name,
        uint32 _node,
        uint8 _contractAuthLevel
    ) external;

    /*
     * @dev Make a new record, writing to the 'database' mapping with basic initial asset data
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) external;

    /*
     * @dev Modify a record, writing to the 'database' mapping with updates to multiple fields
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint32 _countDown,
        uint32 _int32temp,
        uint256 _incrementForceModCount,
        uint256 _incrementNumberOfTransfers
    ) external;

    /*
     * @dev Change node of an asset - writes to node in the 'Record' struct of the 'database' at _idxHash
     */
    function changeNode(bytes32 _idxHash, uint32 _newNode) external;

    /*
     * @dev Set an asset to stolen or lost. Allows narrow modification of status 6/12 assets, normally locked
     */
    function setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /*
     * @dev Set an asset to escrow locked status (6/50/56).
     */
    function setEscrow(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /*
     * @dev remove an asset from escrow status. Implicitly trusts escrowManager ECR_MGR contract
     */
    function endEscrow(bytes32 _idxHash) external;

    // /*
    //  * @dev Modify record sale price and currency data
    //  */
    // function setPrice(
    //     bytes32 _idxHash,
    //     uint120 _price,
    //     uint8 _currency
    // ) external;

    // /*
    //  * @dev set record sale price and currency data to zero
    //  */
    // function clearPrice(bytes32 _idxHash) external;

    /*
     * @dev Modify record mutableStorage1 data
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external;

    /*
     * @dev Write record NonMutableStorage data
     */
    function modifyNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external;

    /*
     * @dev return a record from the database, including rgt
     */
    function retrieveRecord(bytes32 _idxHash) external returns (Record memory);

    // function retrieveRecord(bytes32 _idxHash)
    //     external
    //     view
    //     returns (
    //         bytes32,
    //         uint8,
    //         uint32,
    //         uint32,
    //         uint32,
    //         bytes32,
    //         bytes32
    //     );

    /*
     * @dev return a record from the database w/o rgt
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

    /*
     * @dev return the pricing and currency data from a record
     */
    function getPriceData(bytes32 _idxHash)
        external
        view
        returns (uint120, uint8);

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     * return 170 if matches, 0 if not
     */
    function _verifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        view
        returns (uint256);

    /*
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder (writes an emit in blockchain for independant verification)
     */
    function blockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint8);

    /*
     * @dev //returns the address of a contract with name _name. This is for web3 implementations to find the right contract to interact with
     * example :  Frontend = ****** so web 3 first asks storage where to find frontend, then calls for frontend functions.
     */
    function resolveContractAddress(string calldata _name)
        external
        view
        returns (address);

    /*
     * @dev //returns the contract type of a contract with address _addr.
     */
    function ContractInfoHash(address _addr, uint32 _node)
        external
        view
        returns (uint8, bytes32);
}

//------------------------------------------------------------------------------------------------
/*
 * @dev Interface for ECR_MGR
 * INHERITANCE:
    import "./PRUF_BASIC.sol";
     
 */
interface ECR_MGR_Interface {
    /*
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     */
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock
    ) external;

    /*
     * @dev remove an asset from escrow status
     */
    function endEscrow(bytes32 _idxHash) external;

    /*
     * @dev Set data in EDL mapping
     * Must be setter contract
     * Must be in  escrow
     */
    function setEscrowDataLight(
        bytes32 _idxHash,
        escrowDataExtLight calldata _escrowDataLight
    ) external;

    /*
     * @dev Set data in EDL mapping
     * Must be setter contract
     * Must be in  escrow
     */
    function setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy calldata escrowDataHeavy
    ) external;

    /*
     * @dev Permissive removal of asset from escrow status after time-out
     */
    function permissiveEndEscrow(bytes32 _idxHash) external;

    /*
     * @dev return escrow OwnerHash
     */
    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        returns (bytes32 hashOfEscrowOwnerAdress);

    /*
     * @dev return escrow data @ IDX
     */
    function retrieveEscrowData(bytes32 _idxHash)
        external
        returns (escrowData memory);

    /*
     * @dev return EscrowDataLight @ IDX
     */
    function retrieveEscrowDataLight(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtLight memory);

    /*
     * @dev return EscrowDataHeavy @ IDX
     */
    function retrieveEscrowDataHeavy(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtHeavy memory);
}

//------------------------------------------------------------------------------------------------
/*
 * @dev Interface for RCLR
 * INHERITANCE:
    import "./PRUF_ECR_CORE.sol";
    import "./PRUF_CORE.sol";
 */
interface RCLR_Interface {
    function discard(bytes32 _idxHash, address _sender) external;

    function recycle(bytes32 _idxHash) external;
}

//------------------------------------------------------------------------------------------------
/*
 * @dev Interface for APP
 * INHERITANCE:
    import "./PRUF_CORE.sol";
 */
interface APP_Interface {
    function transferAssetToken(address _to, bytes32 _idxHash) external;
}

//------------------------------------------------------------------------------------------------
/*
 * @dev Interface for APP_NC
 * INHERITANCE:
    import "./PRUF_CORE.sol";
 */
interface APP_NC_Interface {
    function transferAssetToken(address _to, bytes32 _idxHash) external;
}

/*
 * @dev Interface for EO_STAKING
 * INHERITANCE:
    import "./Imports/access/AccessControl.sol";
    import "./Imports/utils/Pausable.sol";
    import "./Imports/utils/ReentrancyGuard.sol";
    import "./Imports/token/ERC721/IERC721.sol";
    import "./Imports/token/ERC721/IERC721Receiver.sol";
 */
interface EO_STAKING_Interface {
    function claimBonus(uint256 _tokenId) external;

    function breakStake(uint256 _tokenId) external;

    function eligibleRewards(uint256 _tokenId)
        external
        returns (uint256 rewards);

    function stakeInfo(uint256 _tokenId)
        external
        returns (
            uint256 stakedAmount,
            uint256 mintTime,
            uint256 startTime,
            uint256 interval,
            uint256 bonusPercentage,
            uint256 maximum
        );
}

/*
 * @dev Interface for STAKE_VAULT
 * INHERITANCE:
    import "./Imports/access/AccessControl.sol";
    import "./Imports/utils/Pausable.sol";
    import "./Imports/utils/ReentrancyGuard.sol";
    import "./Imports/token/ERC721/IERC721.sol";
    import "./Imports/token/ERC721/IERC721Receiver.sol";
 */
interface STAKE_VAULT_Interface {
    function takeStake(uint256 _tokenID, uint256 _amount) external;

    //function releaseStake(address _addr, uint256 _tokenID) external;
    function releaseStake(uint256 _tokenID) external;

    function stakeOfToken(uint256 _tokenID) external returns (uint256 stake);
}

/*
 * @dev Interface for REWARDS_VAULT
 * INHERITANCE:
    import "./Imports/access/AccessControl.sol";
    import "./Imports/utils/Pausable.sol";
    import "./Imports/utils/ReentrancyGuard.sol";
    import "./Imports/token/ERC721/IERC721.sol";
    import "./Imports/token/ERC721/IERC721Receiver.sol";
 */
interface REWARDS_VAULT_Interface {
    function payRewards(uint256 _tokenId, uint256 _amount) external;
}
