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

/**-----------------------------------------------------------------
 * DAO Specification V0.01
 * //DPS:TEST NEW CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Resources/RESOURCE_PRUF_EXT_INTERFACES.sol";

contract DAO is BASIC {
    bytes32 public constant DAO_ADMIN_ROLE = keccak256("DAO_ADMIN_ROLE");

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DAO_ROLE
     */
    modifier isDAOadmin() {
        require(
            hasRole(DAO_ADMIN_ROLE, _msgSender()),
            "DAO:MOD-IP:Calling address is not DAO"
        );
        _;
    }

    //   interface IAccessControl {

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function DAOhasRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external view returns (bool) {
        return (
            BASIC_Interface(resolveName(_contract)).hasRole(_role, _account)
        );
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function DAOgetRoleAdmin(bytes32 _role, string calldata _contract)
        external
        view
        returns (bytes32)
    {
        return (BASIC_Interface(resolveName(_contract)).getRoleAdmin(_role));
    }

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
    function DAOgrantRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).grantRole(_role, _account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function DAOrevokeRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).revokeRole(_role, _account);
    }

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
    function DAOrenounceRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).renounceRole(_role, _account);
    }

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
    function DAOgetRoleMember(
        bytes32 _role,
        uint256 _index,
        string calldata _contract
    ) external view returns (address) {
        return (
            BASIC_Interface(resolveName(_contract)).getRoleMember(_role, _index)
        );
    }

    /**
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function DAOgetRoleMemberCount(bytes32 _role, string calldata _contract)
        external
        view
        returns (uint256)
    {
        return (
            BASIC_Interface(resolveName(_contract)).getRoleMemberCount(_role)
        );
    }

    /**
     * @dev Resolve contract addresses from STOR
     * @param _contract contract name to call
     */
    function DAOresolveContractAddresses(string calldata _contract)
        external
        isDAOadmin
    {
        BASIC_Interface(resolveName(_contract)).resolveContractAddresses();
    }

    /**
     * @dev Set address of STOR contract to interface with
     * @param _storageAddress address of PRUF_STOR
     * @param _contract contract name to call
     */
    function DAOsetStorageContract(
        address _storageAddress,
        string calldata _contract
    ) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).setStorageContract(
            _storageAddress
        );
    }

    /***
     * @dev Triggers stopped state. (pausable)
     * @param _contract contract name to call
     */
    function DAOpause(string calldata _contract) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).pause();
    }

    /***
     * @dev Returns to normal state. (pausable)
     * @param _contract contract name to call
     */
    function DAOunpause(string calldata _contract) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).unpause();
    }

    /**
     * @dev Returns true if _contract is paused, and false otherwise.
     */
    function DAOpaused(string calldata _contract) external returns (bool) {
        return (BASIC_Interface(resolveName(_contract)).paused());
    }

    /**
     * @dev send an ERC721 token from this contract
     * @param _tokenContract Address of foreign token contract
     * @param _to destination
     * @param _tokenID Token ID
     * @param _contract contract name to call
     */
    function DAOERC721Transfer(
        address _tokenContract,
        address _to,
        uint256 _tokenID,
        string calldata _contract
    ) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).ERC721Transfer(
            _tokenContract,
            _to,
            _tokenID
        );
    }

    /**
     * @dev send an ERC20 token from this contract
     * @param _tokenContract Address of foreign token contract
     * @param _to destination
     * @param _amount amount to transfer
     * @param _contract contract name to call
     */
    function DAOERC20Transfer(
        address _tokenContract,
        address _to,
        uint256 _amount,
        string calldata _contract
    ) external isDAOadmin {
        BASIC_Interface(resolveName(_contract)).ERC20Transfer(
            _tokenContract,
            _to,
            _amount
        );
    }

    //-------------------------A_TKN
    /**
     * @dev Sets the baseURI for a storage provider.
     * @param _storageProvider - storage provider number
     * @param _URI - baseURI to add
     */
    function setBaseURIforStorageType(
        uint8 _storageProvider,
        string calldata _URI
    ) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        A_TKN.setBaseURIforStorageType(_storageProvider, _URI);
        //^^^^^^^interactions^^^^^^^^^
    }

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
    function killTrustedAgent(uint256 _key) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        A_TKN.killTrustedAgent(_key);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------NODE_MGR--------------------------

    /**
     * @dev Set pricing for Nodes
     * @param _newNodePrice - cost per node (18 decimals)
     * @param _newNodeBurn - burn per node (18 decimals)
     */
    function setNodePricing(uint256 _newNodePrice, uint256 _newNodeBurn)
        external
        isDAOadmin
    {
        NODE_MGR.setNodePricing(_newNodePrice, _newNodeBurn);
    }

    //--------------------------------------------NODE_STOR--------------------------

    /**
     * @dev Sets the valid storage type providers.
     * @param _storageProvider - uint position for storage provider
     * @param _status - uint position for custody type status
     */
    function setStorageProviders(uint8 _storageProvider, uint8 _status)
        external
        isDAOadmin
    {
        //^^^^^^^checks^^^^^^^^^
        NODE_STOR.setStorageProviders(_storageProvider, _status);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Sets the valid management types.
     * @param _managementType - uint position for management type
     * @param _status - uint position for custody type status
     */
    function setManagementTypes(uint8 _managementType, uint8 _status)
        external
        isDAOadmin
    {
        //^^^^^^^checks^^^^^^^^^
        NODE_STOR.setManagementTypes(_managementType, _status);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Sets the valid custody types.
     * @param _custodyType - uint position for custody type
     * @param _status - uint position for custody type status
     */
    function setCustodyTypes(uint8 _custodyType, uint8 _status)
        external
        isDAOadmin
    {
        //^^^^^^^checks^^^^^^^^^
        NODE_STOR.setCustodyTypes(_custodyType, _status);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * !! to be used with great caution !!
     * This potentially breaks decentralization and must eventually be given over to DAO.
     * @dev Increases (but cannot decrease) price share for a given node
     * @param _node - node in which cost share is being modified
     * @param _newDiscount - discount(1% == 100, 10000 == max)
     */
    function changeShare(uint32 _node, uint32 _newDiscount)
        external
        isDAOadmin
    {
        //^^^^^^^checks^^^^^^^^^
        NODE_STOR.changeShare(_node, _newDiscount);
        //^^^^^^^interactions^^^^^^^^^
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
    ) external isDAOadmin {
        NODE_STOR.transferName(_fromNode, _toNode, _thisName);
        //^^^^^^^interactions^^^^^^^^^
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
    ) external isDAOadmin {
        NODE_STOR.modifyNode(
            _node,
            _nodeRoot,
            _custodyType,
            _managementType,
            _storageProvider,
            _discount,
            _refAddress,
            _CAS1,
            _CAS2
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Administratively Deauthorize address be permitted to mint or modify records
     * @dev only useful for custody types that designate user adresses (type1...)
     * @param _node - node that user is being deauthorized in
     * @param _addrHash - hash of address to deauthorize
     */
    function blockUser(uint32 _node, bytes32 _addrHash) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        NODE_STOR.blockUser(_node, _addrHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev DAO set an external erc721 token as ID verification (when bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function daoSetExternalId(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external isDAOadmin {
        NODE_STOR.daoSetExternalIdToken(_node, _tokenContractAddress, _tokenId);
    }

    //---------------------------------STOR

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
    ) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        STOR.authorizeContract(
            _contractName,
            _contractAddr,
            _node,
            _contractAuthLevel
        );
        //^^^^^^^interactions^^^^^^^^^
    }

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
    ) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        STOR.addDefaultContracts(_contractNumber, _name, _contractAuthLevel);
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------NODE_TKN

    /**
     * @dev Set storage contract to interface with
     * @param _nodeStorageAddress - Node storage contract address
     */
    function setNodeStorageContract(address _nodeStorageAddress)
        external
        isDAOadmin
    {
        //^^^^^^^checks^^^^^^^^^
        NODE_TKN.setNodeStorageContract(_nodeStorageAddress);
        //^^^^^^^Interactions^^^^^^^^^
    }

    //---------------------------------UD_721

    /**
     * @dev Set address of STOR contract to interface with
     * @param _erc721Address address of token contract to interface with
     * @param _UD_721ContractAddress address of UD_721 contract
     */
    function setUnstoppableDomainsTokenContract(
        address _erc721Address,
        address _UD_721ContractAddress
    ) external virtual isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        UD_721_Interface(_UD_721ContractAddress)
            .setUnstoppableDomainsTokenContract(_erc721Address);
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------EO_STAKING

    /**
     * @dev Setter for setting fractions of a day for minimum interval
     * @param _minUpgradeInterval in seconds
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function setMinimumPeriod(
        uint256 _minUpgradeInterval,
        address _EO_STAKING_Address
    ) external isDAOadmin {
        EO_STAKING_Interface(_EO_STAKING_Address).setMinimumPeriod(
            _minUpgradeInterval
        );
    }

    /**
     * @dev Kill switch for staking reward earning
     * @param _delay delay in seconds to end stake earning
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function endStaking(uint256 _delay, address _EO_STAKING_Address)
        external
        isDAOadmin
    {
        EO_STAKING_Interface(_EO_STAKING_Address).endStaking(_delay);
    }

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN(PRUF)
     * @param _stakeAddress address of STAKE_TKN
     * @param _stakeVaultAddress address of STAKE_VAULT
     * @param _rewardsVaultAddress address of REWARDS_VAULT
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function setTokenContracts(
        address _utilAddress,
        address _stakeAddress,
        address _stakeVaultAddress,
        address _rewardsVaultAddress,
        address _EO_STAKING_Address
    ) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^

        EO_STAKING_Interface(_EO_STAKING_Address).setTokenContracts(
            _utilAddress,
            _stakeAddress,
            _stakeVaultAddress,
            _rewardsVaultAddress
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set stake tier parameters
     * @param _stakeTier Staking level to set
     * @param _min Minumum stake
     * @param _max Maximum stake
     * @param _interval staking interval, in dayUnits - set to the number of days that the stake and reward interval will be based on.
     * @param _bonusPercentage bonusPercentage in tenths of a percent: 15 = 1.5% or 15/1000 per interval. Calculated to a fixed amount of tokens in the actual stake
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function setStakeLevels(
        uint256 _stakeTier,
        uint256 _min,
        uint256 _max,
        uint256 _interval,
        uint256 _bonusPercentage,
        address _EO_STAKING_Address
    ) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        EO_STAKING_Interface(_EO_STAKING_Address).setStakeLevels(
            _stakeTier,
            _min,
            _max,
            _interval,
            _bonusPercentage
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------REWARDS_VAULT and STAKE_VAULT //DPS:TEST works for both?

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     * @param vaultContractAddress address of REWARDS_VAULT or STAKE_VAULT contract
     */
    function setTokenContracts(
        address _utilAddress,
        address _stakeAddress,
        address vaultContractAddress
    ) external isDAOadmin {
        //^^^^^^^checks^^^^^^^^^
        REWARDS_VAULT_Interface(vaultContractAddress).setTokenContracts(
            _utilAddress,
            _stakeAddress
        );

        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------INTERNAL FUNCTIONS

    /**
     * @dev name resolver
     * @param _name name to resolve
     * returns address of (contract name)
     */
    function resolveName(string calldata _name)
        internal
        view
        returns (address)
    {
        return STOR.resolveContractAddress(_name);
    }
}
