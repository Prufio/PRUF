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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";

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
            "B:MOD-IP:Calling address is not DAO"
        );
        _;
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
        //^^^^^^^effects^^^^^^^^^
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
        //^^^^^^^effects^^^^^^^^^
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
