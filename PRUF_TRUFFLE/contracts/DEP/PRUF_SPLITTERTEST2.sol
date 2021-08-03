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
 *  make so that you can call a split on a remote address (not onlyowner)
 *
 *-----------------------------------------------------------------
 * PRUF DOUBLER CONTRACT  -- requires MINTER_ROLE, (SNAPSHOT_ROLE), PAUSER_ROLE in UTIL_TKN
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract SPLITTEST2 is ReentrancyGuard, Pausable, AccessControl {
    //----------------------------ROLE DEFINITIONS
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    mapping(address => uint256) internal hasSplit;

    uint256 internal snapshotID; //this version of the contract will only work on the first snapshot and cannot be changed

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CONTRACT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        // UTIL_TKN = UTIL_TKN_Interface(
        //     0xa49811140E1d6f653dEc28037Be0924C811C4538 //DPS:CHECK drake you will have to change this to test?
        // ); // for hard coded util tkn address
    }

    //------------------------------------------------------------------------MODIFIERS

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Admin
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, msg.sender),
            "SPLIT:MOD-IA: must have CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Pauser
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, msg.sender),
            "SPLIT:MOD-IP: must have PAUSER_ROLE"
        );
        _;
    }

    //----------------------External Admin functions---------------------//

    /*
     * @dev Set address of PRUF_TKN contract to interface with
     * TESTING: ALL REQUIRES, ACCESS ROLE
     */
    function setTokenContract(address _address) external isContractAdmin {
        require(
            _address != address(0) && UTIL_TKN_Address == address(0),
            "SPLIT:ASTC: Token contract address = zero or address already set"
        );
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _address;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set snapshot ID
     * TESTING: ALL REQUIRES, ACCESS ROLE
     */
    function setSnapshotID(uint256 _snapshot) external isContractAdmin {
    // ^^^^^^^checks^^^^^^^^^

    snapshotID = _snapshot;
    // ^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev pause the contract, renounce pauser role, take a snapshot,
     * TESTING: ALL REQUIRES, ACCESS ROLE
     */
    function takeSnapshot() external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^
        // UTIL_TKN.pause();
        // renounceRole(PAUSER_ROLE, address(this));
        snapshotID = UTIL_TKN.takeSnapshot();
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev doubles pruf balance at snapshot snapshotID
     * TESTING: ALL REQUIRES, ACCESS ROLE, PAUSABLE
     */
    function splitMyPruf() external whenNotPaused {
        require(
            hasSplit[msg.sender] == 0,
            "SPLIT:SMP: Caller address has already been split"
        );
        uint256 balanceAtSnapshot =
            //UTIL_TKN.balanceOfAt(msg.sender, snapshotID);
            UTIL_TKN.balanceOfAt(msg.sender, 1);

        balanceAtSnapshot = balanceAtSnapshot;
        //^^^^^^^checks^^^^^^^^^
        hasSplit[msg.sender] = 170; //mark caller address as having been split
        //^^^^^^^effects^^^^^^^^^

        UTIL_TKN.mint(msg.sender, balanceAtSnapshot); //mint the new tokens to caller address
        //^^^^^^^Interactions^^^^^^^^^
    }

    /*
     * @dev checks address for available split, returns balance of pruf to be split
     * TESTING: ALL REQUIRES, ACCESS ROLE, PAUSABLE
     */
    function checkMyAddress(address _address) external returns (uint256) {
        require(
            hasSplit[_address] == 0,
            "SPLIT:CMA: Caller address has already been split"
        );
        //^^^^^^^checks^^^^^^^^^
        //return UTIL_TKN.balanceOfAt(msg.sender, snapshotID);
        return UTIL_TKN.balanceOfAt(_address, 1);
        //^^^^^^^Interactions^^^^^^^^^
    }

    /*
     * @dev Getter for util_tkn address
     * TESTING: ALL REQUIRES, ACCESS ROLE, PAUSABLE
     */
    // function getTokenAddress() external view returns (address) {
    //     //^^^^^^^checks^^^^^^^^^
    //     return UTIL_TKN_Address;
    //     //^^^^^^^Interactions^^^^^^^^^
    // }

    /**
     * @dev Pauses pausable functions.
     * See {ERC20Pausable} and {Pausable-_pause}.
     * Requirements:
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual isPauser {
        //^^^^^^^checks^^^^^^^^^
        _pause();
        //^^^^^^^effects^^^^^^^^
    }

    /**
     * @dev Unpauses all pausable functions.
     * See {ERC20Pausable} and {Pausable-_unpause}.
     * Requirements:
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual isPauser {
        //^^^^^^^checks^^^^^^^^^
        _unpause();
        //^^^^^^^effects^^^^^^^^
    }
}
