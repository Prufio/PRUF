/*--------------------------------------------------------PRuF0.7.1
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

/*-----------------------------------------------------------------
 *  TO DO  ------------------------------------DPS:TEST--NEW
 *  make so that you can call a split on a remote address (not onlyowner)
 *
 *-----------------------------------------------------------------
 * PRUF DOUBLER CONTRACT  -- requires MINTER_ROLE, SNAPSHOT_ROLE, PAUSER_ROLE in UTIL_TKN
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/math/SafeMath.sol";

contract SPLIT is ReentrancyGuard, Pausable, AccessControl {
    using SafeMath for uint256;

    //----------------------------ROLE DFINITIONS
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    mapping(address => uint256) private hasSplit;

    uint256 public snapshotID;

    //uint256 public multiplier = 1;

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CONTRACT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
    }

    //------------------------------------------------------------------------MODIFIERS

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Admin
     */
    modifier isAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, msg.sender),
            "PD:MOD: must have CONTRACT_ADMIN_ROLE"
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
            "PD:MOD: must have PAUSER_ROLE"
        );
        _;
    }

    //----------------------External Admin functions---------------------//

    /*
     * @dev Set address of PRUF_TKN contract to interface with
     * TESTING: ALL REQUIRES, ACCESS ROLE
     */
    function ADMIN_setTokenContract(address _address) external isAdmin {
        require(
            _address != address(0),
            "PD:STC: token contract address cannot be zero"
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
    // function ADMIN_setSnapshotID(uint256 _snapshot) external isAdmin {
        //^^^^^^^checks^^^^^^^^^

        // snapshotID = _snapshot;
        //^^^^^^^effects^^^^^^^^^
    // }

    // /*
    //  * @dev Set pruf doulble multiplier
    //  * TESTING: ALL REQUIRES, ACCESS ROLE
    //  */
    // function ADMIN_setMultiplier(uint256 _mult) external isAdmin {
    //     //^^^^^^^checks^^^^^^^^^
    //     multiplier = _mult;
    //     //^^^^^^^effects^^^^^^^^^
    // }

    /*
     * @dev pause the contract, renounce pauser role, take a snapshot,
     * TESTING: ALL REQUIRES, ACCESS ROLE
     */
    function ADMIN_takeSnapshot() external isAdmin {
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
            "PD:DMP: Caller address has already been split"
        );
        uint256 balanceAtSnapshot =
            UTIL_TKN.balanceOfAt(msg.sender, snapshotID);

        balanceAtSnapshot = balanceAtSnapshot + (balanceAtSnapshot.div(10)); //add 10%
        //^^^^^^^checks^^^^^^^^^
        hasSplit[msg.sender] = 170; //mark as done for caller address

        UTIL_TKN.mint(msg.sender, balanceAtSnapshot); //mint the new tokens to caller address
        //UTIL_TKN.mint(msg.sender, balanceAtSnapshot.mul(multiplier));
        //^^^^^^^Interactions^^^^^^^^^
    }

    /*
     * @dev checks address for available split, returns balance of pruf to be split
     * TESTING: ALL REQUIRES, ACCESS ROLE, PAUSABLE
     */
    function checkMyAddress() external returns (uint256) {
        require(
            hasSplit[msg.sender] == 0,
            "PD:CMA: Caller address has already been split"
        );
        //^^^^^^^checks^^^^^^^^^
        return UTIL_TKN.balanceOfAt(msg.sender, snapshotID);
        //^^^^^^^Interactions^^^^^^^^^
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual isPauser {
        //^^^^^^^checks^^^^^^^^^
        _pause();
        //^^^^^^^effects^^^^^^^^
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual isPauser {
        //^^^^^^^checks^^^^^^^^^
        _unpause();
        //^^^^^^^effects^^^^^^^^
    }
}
