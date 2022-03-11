/**--------------------------------------------------------PRüF0.8.7
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
 *  DAO CONTROL PANEL Interfaces
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

//---------------------------------------------------------------------------------------------------------------
/*
 * @dev Interface for Market
 * INHERITANCE:
    import "./Imports/access/Ownable.sol";
    import "./Imports/security/Pausable.sol";
    import "./Imports/security/ReentrancyGuard.sol";
 */

struct Motion {
    address proposer;
    uint32 votesFor;
    uint32 votesAgainst;
    uint32 voterCount;
    uint256 votingEpoch;
}

struct Votes {
    uint32 votes;
    uint8 yn; // yeahOrNeigh 1 = yeah
}

interface DAO_LAYER_A_Interface {
    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function DAO_hasRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function DAO_getRoleAdmin(bytes32 _role, string calldata _contract)
        external
        view
        returns (bytes32);

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
    function DAO_grantRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function DAO_revokeRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external;

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
    function DAO_renounceRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external;

    /** CTS:APPROVED not used in any current contracts, contract must be importing "./AccessControlEnumerable.sol";
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
    function DAO_getRoleMember(
        bytes32 _role,
        uint256 _index,
        string calldata _contract
    ) external view returns (address);

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function DAO_getRoleMemberCount(bytes32 _role, string calldata _contract)
        external
        view
        returns (uint256);

    /**
     * @dev Resolve contract addresses from STOR
     * @param _contract contract name to call
     */
    function DAO_resolveContractAddresses(string calldata _contract) external;

    /**
     * @dev Set address of STOR contract to interface with
     * @param _storageAddress address of PRUF_STOR
     * @param _contract contract name to call
     */
    function DAO_setStorageContract(
        address _storageAddress,
        string calldata _contract
    ) external;

    /**
     * @dev Triggers stopped state. (pausable)
     * @param _contract contract name to call
     */
    function DAO_pause(string calldata _contract) external;

    /***
     * @dev Returns to normal state. (pausable)
     * @param _contract contract name to call
     */
    function DAO_unpause(string calldata _contract) external;

    /**
     * @dev Returns true if _contract is paused, and false otherwise.
     */
    function DAO_paused(string calldata _contract) external returns (bool);

    /**
     * @dev send an ERC721 token from this contract
     * @param _tokenContract Address of foreign token contract
     * @param _to destination
     * @param _tokenID Token ID
     * @param _contract contract name to call
     */
    function DAO_ERC721Transfer(
        address _tokenContract,
        address _to,
        uint256 _tokenID,
        string calldata _contract
    ) external;

    /**
     * @dev send an ERC20 token from this contract
     * @param _tokenContract Address of foreign token contract
     * @param _to destination
     * @param _amount amount to transfer
     * @param _contract contract name to call
     */
    function DAO_ERC20Transfer(
        address _tokenContract,
        address _to,
        uint256 _amount,
        string calldata _contract
    ) external;

    //-------------------------A_TKN
    /**
     * @dev Sets the baseURI for a storage provider.
     * @param _storageProvider - storage provider number
     * @param _URI - baseURI to add
     */
    function DAO_setBaseURIforStorageType(
        uint8 _storageProvider,
        string calldata _URI
    ) external;

    /**
     * @dev !!! PERMANENTLY !!!  Kills trusted agent and payable functions
     * this will break the functionality of current payment mechanisms.
     *
     * The workaround for this is to create an allowance for pruf contracts for a single or multiple payments,
     * either ahead of time "loading up your PRUF account" or on demand with an operation. On demand will use quite a bit more gas.
     * "preloading" should be pretty gas efficient, but will add an extra step to the workflow, requiring users to have sufficient
     * PRuF "banked" in an allowance for use in the system.
     * @param _key - set to 170 to PERMENANTLY REMOVE TRUSTED AGENT CAPABILITY
     */
    function DAO_killTrustedAgent(uint256 _key) external;

    //--------------------------------------------NODE_MGR--------------------------

    /**
     * @dev Set pricing for Nodes
     * @param _newNodePrice - cost per node (18 decimals)
     * @param _newNodeBurn - burn per node (18 decimals)
     */
    function DAO_setNodePricing(uint256 _newNodePrice, uint256 _newNodeBurn)
        external;

    //--------------------------------------------NODE_STOR--------------------------

    /**
     * @dev Sets the valid storage type providers.
     * @param _storageProvider - uint position for storage provider
     * @param _status - uint position for custody type status
     */
    function DAO_setStorageProviders(uint8 _storageProvider, uint8 _status)
        external;

    /**
     * @dev Sets the valid management types.
     * @param _managementType - uint position for management type
     * @param _status - uint position for custody type status
     */
    function DAO_setManagementTypes(uint8 _managementType, uint8 _status)
        external;

    /**
     * @dev Sets the valid custody types.
     * @param _custodyType - uint position for custody type
     * @param _status - uint position for custody type status
     */
    function DAO_setCustodyTypes(uint8 _custodyType, uint8 _status) external;

    /**
     * !! to be used with great caution !!
     * This potentially breaks decentralization and must eventually be given over to DAO.
     * @dev Increases (but cannot decrease) price share for a given node
     * @param _node - node in which cost share is being modified
     * @param _newDiscount - discount(1% == 100, 10000 == max)
     */
    function DAO_changeShare(uint32 _node, uint32 _newDiscount) external;

    /**
     * !! -------- to be used with great caution and only as a result of community governance action -----------
     * @dev Transfers a name from one node to another
     *   -Designed to remedy brand infringement issues. This breaks decentralization and must eventually be given
     *   -over to DAO.
     * @param _fromNode - source node
     * @param _toNode - destination node
     * @param _thisName - name to be transferred
     */
    function DAO_transferName(
        uint32 _fromNode,
        uint32 _toNode,
        string calldata _thisName
    ) external;

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
    function DAO_modifyNode(
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
    function DAO_blockUser(uint32 _node, bytes32 _addrHash) external;

    /**
     * @dev DAO set an external erc721 token as ID verification (when bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function DAO_setExternalId(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external;

    //---------------------------------STOR

    /**
     * @dev Authorize / Deauthorize ADRESSES permitted to make record modifications, per node
     * populates contract name resolution and data mappings
     * @param _contractName - String name of contract
     * @param _contractAddr - address of contract
     * @param _node - node to authorize in
     * @param _contractAuthLevel - auth level to assign
     */
    function DAO_authorizeContract(
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
    function DAO_addDefaultContracts(
        uint256 _contractNumber,
        string calldata _name,
        uint8 _contractAuthLevel
    ) external;

    //---------------------------------NODE_TKN

    /**
     * @dev Set storage contract to interface with
     * @param _nodeStorageAddress - Node storage contract address
     */
    function DAO_setNodeStorageContract(address _nodeStorageAddress) external;

    //---------------------------------UD_721

    /**
     * @dev Set address of STOR contract to interface with
     * @param _erc721Address address of token contract to interface with
     * @param _UD_721ContractAddress address of UD_721 contract
     */
    function DAO_setUnstoppableDomainsTokenContract(
        address _erc721Address,
        address _UD_721ContractAddress
    ) external;

    //---------------------------------EO_STAKING

    /**
     * @dev Setter for setting fractions of a day for minimum interval
     * @param _minUpgradeInterval in seconds
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_setMinimumPeriod(
        uint256 _minUpgradeInterval,
        address _EO_STAKING_Address
    ) external;

    /**
     * @dev Kill switch for staking reward earning
     * @param _delay delay in seconds to end stake earning
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_endStaking(uint256 _delay, address _EO_STAKING_Address)
        external;

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN(PRUF)
     * @param _stakeAddress address of STAKE_TKN
     * @param _stakeVaultAddress address of STAKE_VAULT
     * @param _rewardsVaultAddress address of REWARDS_VAULT
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_setTokenContractsEO(
        address _utilAddress,
        address _stakeAddress,
        address _stakeVaultAddress,
        address _rewardsVaultAddress,
        address _EO_STAKING_Address
    ) external;

    /**
     * @dev Set stake tier parameters
     * @param _stakeTier Staking level to set
     * @param _min Minumum stake
     * @param _max Maximum stake
     * @param _interval staking interval, in dayUnits - set to the number of days that the stake and reward interval will be based on.
     * @param _bonusPercentage bonusPercentage in tenths of a percent: 15 = 1.5% or 15/1000 per interval. Calculated to a fixed amount of tokens in the actual stake
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_setStakeLevels(
        uint256 _stakeTier,
        uint256 _min,
        uint256 _max,
        uint256 _interval,
        uint256 _bonusPercentage,
        address _EO_STAKING_Address
    ) external;

    //---------------------------------REWARDS_VAULT and STAKE_VAULT //DPS:TEST works for both?

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     * @param vaultContractAddress address of REWARDS_VAULT or STAKE_VAULT contract
     */
    function DAO_setTokenContracts(
        address _utilAddress,
        address _stakeAddress,
        address vaultContractAddress
    ) external;

    /**
     * @dev name resolver
     * @param _name name to resolve
     * returns address of (contract name)
     */
    function resolveName(string calldata _name) external returns (address);
}

interface DAO_CORE_Interface {

    /**
     * @dev Default param setter
     * @param _quorum new value for minimum required voters to create a quorum
     */
    function setQuorum(uint32 _quorum) external;

    /**
     * @dev Default param setter
     * @param _passingMargin new value for minimum required passing margin for votes, in whole percents
     */
    function setPassingMargin(uint32 _passingMargin) external;

    /**
     * @dev Default param setter
     * @param _max new value for maximum votees per node
     */
    function setMaxVote(uint32 _max) external;

    /**
     * @dev Resolve contract addresses from STOR
     */
    function resolveContractAddresses() external;

     /**
     * @dev Crates an new Motion in the motions map
     * @param _motion the hash of the referring contract address, function name, and parmaeters
     * @param _proposer //proposing address
     */
    function adminCreateMotion(bytes32 _motion, address _proposer) external returns (bytes32);
    

    /**
     * @dev DAO admin will be given to a trusted contract that allows nodes to cast their delegated votes---------CAUTION:CENTRALIZATION RISK
     * @param _motion // propsed action
     * @param _node // node doing the voting
     * @param _votes //# of votes
     * @param _yn // yeah (1) or neigh (0)
     * @param _voter //voting address
     */
    function adminVote(
        bytes32 _motion, //propsed action
        uint32 _node, //node doing the voting
        uint32 _votes, //# of votes
        uint8 _yn, // yeah (1) or neigh (0)
        address _voter //voting address
    ) external;

    /**
     * @dev Admin veto for incrementel transfer of power to the DAO---------CAUTION:CENTRALIZATION RISK
     * @param _motion // propsed action
     */
    function adminVeto(
        bytes32 _motion // propsed action
    ) external;
    
    /**
     * @dev Throws if a resolution is not approved. clears the motion if successful
     * @param _motion the motion hash to check
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function verifyResolution(bytes32 _motion, address _caller) external;

    /**
     * @dev Getter for motions
     * @param _motionIndex the index of the motion hash to get
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getMotionDataByIndex(uint256 _motionIndex)
        external
        view
        returns (Motion memory);

    /**
     * @dev Getter for motions
     * @param _motion the motion hash to get
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getMotionData(bytes32 _motion)
        external
        view
        returns (Motion memory);

    /**
     * @dev Getter for node voting participation
     * @param _epoch the epoch to check
     * @param _node the node to get voting activity for
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getNodeActivityByEpoch(uint256 _epoch, uint32 _node)
        external
        view
        returns (uint256);

    /**
     * @dev Getter for vote history, by motion and node
     * @param _motion the epoch to check
     * @param _node the node to get voting activity for
     * to be called by DAO_LAYER contracts as a check prior to executing functions
     */
    function getNodeVotingHistory(bytes32 _motion, uint32 _node)
        external
        view
        returns (Votes memory);
}


interface CLOCK_Interface {
    /**
     * @dev gets the current epoch
     */
    function thisEpoch() external view returns (uint256);

    /**
     * @dev gets the current epoch elapsed time
     */
    function thisEpochElapsedTime() external view returns (uint256);

    /**
     * @dev gets the current epochSeconds calue
     */
    function getEpochSeconds() external view returns (uint256);

    /**
     * @dev Sets a new epoch interval
     * @param _epochSeconds new epoch period to set
     * caller must be DAO_LAYER
     */
    function setNewEpochInterval(uint256 _epochSeconds) external;
}



