/**--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 * PRUF USER ID CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./RESOURCE_PRUF_STRUCTS.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
//import "./Imports/utils/ReentrancyGuard.sol";

/**
 * @dev {ERC721} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *  - token ID and URI autogeneration
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter, pauser, and contract admin
 * roles, as well as the default admin role, which will let it grant minter, pauser, and admin
 * roles to other accounts.

 struct ID {
    uint256 trustLevel; //admin only
    bytes32 URI; //caller address match
    string userName; //admin only///caller address match can set
}


 */

contract ID_MGR is Pausable, AccessControl {
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    uint256 currentIdNumber;

    mapping(address => ID) private id; // storage for extended ID data
    mapping(bytes32 => address) private addressOfIdHash; // storage for name resolution to token ID

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //----------------------Modifiers----------------------//
    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "PIDT:MOD-IA: Calling address does not belong to an admin"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has MINTER_ROLE
     */
    modifier isMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "PIDT:MOD-IM: Calling address does not belong to a minter"
        );
        _;
    }

    //----------------------EVENTS----------------------//
    event REPORT(string _msg);

    //----------------------Admin functions / isContractAdmin----------------------//

    /**
     * @dev Mint an Asset token
     * @param _recipientAddress - Address to mint token into
     * @param _trustLevel - Token ID to mint
     * @param _IdHash - URI string to atatch to token
     */
    function mintID(
        address _recipientAddress,
        uint256 _trustLevel,
        bytes32 _IdHash
    ) external isMinter whenNotPaused {
        require(
            addressOfIdHash[_IdHash] == address(0),"IM:MI: ID hash already exists. Burn old ID first."
        );
        require(
            id[_recipientAddress].IdHash == 0,"IM:MI: Adddress already has an ID. Burn old ID first."
        );
        //^^^^^^^checks^^^^^^^^^

        id[_recipientAddress].trustLevel = _trustLevel;
        id[_recipientAddress].IdHash = _IdHash;
        addressOfIdHash[_IdHash] = _recipientAddress;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Burn PRUF_ID token
     * @param _addr - address to burn ID from
     */
    function burnID(address _addr)
        external
        isMinter
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        //BURNID TODO
        delete addressOfIdHash[id[_addr].IdHash]; //remove record from IDHash registry
        delete id[_addr]; //remove record from address registry
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set new ID data fields
     * @param _addr - address to set trust level
     * @param _trustLevel - _trustLevel to set 
     */
    function setTrustLevel(address _addr, uint256 _trustLevel)
        external
        isMinter
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        id[_addr].trustLevel = _trustLevel;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev get ID data given an address to look up
     * @param _addr - address to check
     * returns ID struct (see interfaces for struct definitions)
     */
    function IdDataByAddress(address _addr) external view returns (ID memory) {
        return id[_addr];
    }

    /**
     * @dev get ID data given an IdHash to look up
     * @param _IdHash - IdHash to check
     * returns ID struct (see interfaces for struct definitions)
     */
    function IdDataByIdHash(bytes32 _IdHash) external view returns (ID memory) {
        return id[addressOfIdHash[_IdHash]];
    }

    /**
     * @dev get ID trustLevel
     * @param _addr - address to check
     * returns trust level of token id
     */
    function trustLevel(address _addr) external view returns (uint256) {
        return id[_addr].trustLevel;
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() external virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PIDT:P: ERC721PresetMinterPauserAutoId: must have pauser role to pause"
        );
        //^^^^^^^checks^^^^^^^^
        _pause();
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() external virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PIDT:UP: ERC721PresetMinterPauserAutoId: must have pauser role to unpause"
        );
        //^^^^^^^checks^^^^^^^^
        _unpause();
        //^^^^^^^interactions^^^^^^^^^
    }
}
