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
 * DAO THUNK LAYER - (ONE OF MANY)
 * //DPS:TEST MAJOR REVISIONS - added calls to DAO
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Resources/RESOURCE_PRUF_EXT_INTERFACES.sol";
import "../Resources/RESOURCE_PRUF_DAO_INTERFACES.sol";

contract DAO_LAYER_BASIC is BASIC {
    address internal DAO_STOR_Address;
    DAO_STOR_Interface internal DAO_STOR;

    address internal CLOCK_Address;
    CLOCK_Interface internal CLOCK;

    /**
     * @dev Resolve contract addresses from STOR
     */
    function resolveContractAddresses()
        external
        override
        nonReentrant
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^

        // NODE_TKN_Address = STOR.resolveContractAddress("NODE_TKN");
        // NODE_TKN = NODE_TKN_Interface(NODE_TKN_Address);

        // NODE_MGR_Address = STOR.resolveContractAddress("NODE_MGR");
        // NODE_MGR = NODE_MGR_Interface(NODE_MGR_Address);

        // NODE_STOR_Address = STOR.resolveContractAddress("NODE_STOR");
        // NODE_STOR = NODE_STOR_Interface(NODE_STOR_Address);

        // UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        // UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        // A_TKN_Address = STOR.resolveContractAddress("A_TKN");
        // A_TKN = A_TKN_Interface(A_TKN_Address);

        // ECR_MGR_Address = STOR.resolveContractAddress("ECR_MGR");
        // ECR_MGR = ECR_MGR_Interface(ECR_MGR_Address);

        // APP_Address = STOR.resolveContractAddress("APP");
        // APP = APP_Interface(APP_Address);

        // RCLR_Address = STOR.resolveContractAddress("RCLR");
        // RCLR = RCLR_Interface(RCLR_Address);

        // APP_NC_Address = STOR.resolveContractAddress("APP_NC");
        // APP_NC = APP_NC_Interface(APP_NC_Address);

        DAO_STOR_Address = STOR.resolveContractAddress("DAO_STOR");
        DAO_STOR = DAO_STOR_Interface(DAO_STOR_Address);

        CLOCK_Address = STOR.resolveContractAddress("CLOCK");
        CLOCK = CLOCK_Interface(CLOCK_Address);
    }

    //---------------------------------------------DAO SETTING FUNCTIONS

    /**
     * @dev Default param setter
     * @param _quorum new value for minimum required voters to create a quorum
     */
    function DAO_setQuorum(uint32 _quorum) external nonReentrant {
        verifySig(abi.encodePacked("DAO_setQuorum", address(this), _quorum));

        //^^^^^^^checks^^^^^^^^^

        DAO_STOR.setQuorum(_quorum);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Default param setter
     * @param _passingMargin new value for minimum required passing margin for votes, in whole percents
     */
    function DAO_setPassingMargin(uint32 _passingMargin) external nonReentrant {
        verifySig(
            abi.encodePacked("DAO_setQuorum", address(this), _passingMargin)
        );

        //^^^^^^^checks^^^^^^^^^

        DAO_STOR.setPassingMargin(_passingMargin);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Default param setter
     * @param _max new value for maximum votees per node
     */
    function DAO_setMaxVote(uint32 _max) external nonReentrant {
        verifySig(abi.encodePacked("DAO_setQuorum", address(this), _max));

        //^^^^^^^checks^^^^^^^^^

        DAO_STOR.setMaxVote(_max);
        //^^^^^^^effects^^^^^^^^^
    }

    //---------------------------------------------EPOCH CLOCK FUNCTIONS

    /**
     * @dev Set storage contract to interface with
     * @param _epochSeconds - New period for EPOCHS in seconds
     */
    function DAO_setNewEpochInterval(uint256 _epochSeconds)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_setNodeStorageContract",
                address(this),
                _epochSeconds
            )
        );

        //^^^^^^^checks^^^^^^^^^

        CLOCK.setNewEpochInterval(_epochSeconds);
        //^^^^^^^Interactions^^^^^^^^^
    }

    //-----------------------------------------------Functions shared by many contracts through inheritance

    /**
     * @dev Returns `true` if `account` has been granted `role`. //CTS:EXAMINE does this need to be dao controlled?
     */
    function DAO_hasRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external view returns (bool) {
        return (
            BASIC_Interface(resolveName(_contract)).hasRole(_role, _account)
        );
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and //CTS:EXAMINE does this need to be dao controlled?
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function DAO_getRoleAdmin(bytes32 _role, string calldata _contract)
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
     //DPS:TEST ALL ROLE MANIPULATORS TO MAKE SURE THEY WORK. CRITICAL.
     * - this contract must have ``role``'s admin role.
     */
    function DAO_grantRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_grantRole",
                address(this),
                _role,
                _account,
                _contract
            )
        );

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).grantRole(_role, _account);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     //DPS:TEST ALL ROLE MANIPULATORS TO MAKE SURE THEY WORK. CRITICAL.
     * - this contract must have ``role``'s admin role.
     */
    function DAO_revokeRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_revokeRole",
                address(this),
                _role,
                _account,
                _contract
            )
        );

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).revokeRole(_role, _account);
        //^^^^^^^interactions^^^^^^^^^
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
     //DPS:TEST ALL ROLE MANIPULATORS TO MAKE SURE THEY WORK. CRITICAL.
     */
    function DAO_renounceRole(
        bytes32 _role,
        address _account,
        string calldata _contract
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_renounceRole",
                address(this),
                _role,
                _account,
                _contract
            )
        );

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).renounceRole(_role, _account);
        //^^^^^^^interactions^^^^^^^^^
    }

    /** //CTS:EXAMINE does this need to be dao controlled?
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
    ) external view returns (address) {
        return (
            BASIC_Interface(resolveName(_contract)).getRoleMember(_role, _index)
        );
    }

    /** //CTS:EXAMINE does this need to be dao controlled?
     * @dev Returns the number of accounts that have `role`. Can be used
     * together with {getRoleMember} to enumerate all bearers of a role.
     */
    function DAO_getRoleMemberCount(bytes32 _role, string calldata _contract)
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
    function DAO_resolveContractAddresses(string calldata _contract)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_resolveContractAddresses",
                address(this),
                _contract
            )
        );

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).resolveContractAddresses();
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set address of STOR contract to interface with
     * @param _storageAddress address of PRUF_STOR
     * @param _contract contract name to call
     */
    function DAO_setStorageContract(
        address _storageAddress,
        string calldata _contract
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_setStorageContract",
                address(this),
                _storageAddress,
                _contract
            )
        );

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).setStorageContract(
            _storageAddress
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Triggers stopped state. (pausable)
     * @param _contract contract name to call
     */
    function DAO_pause(string calldata _contract) external nonReentrant {
        verifySig(abi.encodePacked("DAO_pause", address(this), _contract));

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).pause();
        //^^^^^^^interactions^^^^^^^^^
    }

    /***
     * @dev Returns to normal state. (pausable)
     * @param _contract contract name to call
     */
    function DAO_unpause(string calldata _contract) external nonReentrant {
        verifySig(abi.encodePacked("DAO_unpause", address(this), _contract));

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).unpause();
        //^^^^^^^interactions^^^^^^^^^
    }

    /** //CTS:EXAMINE does this need to be dao controlled?
     * {revokeRole}.
     * @dev Returns true if _contract is paused, and false otherwise.
     */
    function DAO_paused(string calldata _contract) external returns (bool) {
        return (BASIC_Interface(resolveName(_contract)).paused());
    }

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
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_ERC721Transfer",
                address(this),
                _tokenContract,
                _to,
                _tokenID,
                _contract
            )
        );

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).ERC721Transfer(
            _tokenContract,
            _to,
            _tokenID
        );
        //^^^^^^^interactions^^^^^^^^^
    }

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
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_ERC20Transfer",
                address(this),
                _tokenContract,
                _to,
                _amount,
                _contract
            )
        );

        //^^^^^^^checks^^^^^^^^^

        BASIC_Interface(resolveName(_contract)).ERC20Transfer(
            _tokenContract,
            _to,
            _amount
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------INTERNAL FUNCTIONS

    /**
     * @dev Makes signature hash and verifies against DAO_STOR
     * @param _sigArray signature of call to approve
     */
    function verifySig(bytes memory _sigArray) internal {
        DAO_STOR.verifyResolution(
            keccak256(
                abi.encodePacked(keccak256(_sigArray), CLOCK.thisEpoch())
            ),
            _msgSender()
        );
    }

    /**
     * @dev name resolver
     * @param _name name to resolve
     * returns address of (contract name)
     */
    function resolveName(string calldata _name) public view returns (address) {
        return STOR.resolveContractAddress(_name);
        //^^^^^^^interactions^^^^^^^^^
    }
}
