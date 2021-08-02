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
 * PRUF DOUBLER CONTRACT  -- requires MINTER_ROLE, (SNAPSHOT_ROLE), PAUSER_ROLE in UTIL_TKN
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract SPLIT is ReentrancyGuard, Pausable, AccessControl {
    //----------------------------ROLE DEFINITIONS
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");

    UTIL_TKN_Interface internal UTIL_TKN;

    mapping(address => uint256) internal hasSplit;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _setupRole(CONTRACT_ADMIN_ROLE, msg.sender);
        _setupRole(PAUSER_ROLE, msg.sender);
        UTIL_TKN = UTIL_TKN_Interface(
            0xa49811140E1d6f653dEc28037Be0924C811C4538
        ); // for hard coded util tkn address
    }

    //---------------------------------MODIFIERS-------------------------------//

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      is Admin
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, msg.sender),
            "SPLIT:MOD-ICA: must have CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    /**
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

    //----------------------External functions---------------------//

    /**
     * @dev doubles pruf balance at snapshotID(1)
     */
    function splitMyPruf() external whenNotPaused {
        require(
            hasSplit[msg.sender] == 0,
            "SPLIT:SMP: Caller address has already been split"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 balanceAtSnapshot = UTIL_TKN.balanceOfAt(msg.sender, 1);
        hasSplit[msg.sender] = 170; //mark caller address as having been split
        //^^^^^^^effects^^^^^^^^^

        UTIL_TKN.mint(msg.sender, balanceAtSnapshot); //mint the new tokens to caller address
        //^^^^^^^Interactions^^^^^^^^^
    }

    /**
     * @dev doubles pruf balance at snapshotID(1)
     * @param _address - address to be split
     */
    function splitPrufAtAddress(address _address) external whenNotPaused {
        require(
            hasSplit[_address] == 0,
            "SPLIT:SMPAA: Caller address has already been split"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 balanceAtSnapshot = UTIL_TKN.balanceOfAt(_address, 1);
        hasSplit[_address] = 170; //mark caller address as having been split
        //^^^^^^^effects^^^^^^^^^

        UTIL_TKN.mint(_address, balanceAtSnapshot); //mint the new tokens to caller address
        //^^^^^^^Interactions^^^^^^^^^
    }

    /**
     * @dev checks address for available split, returns balance of pruf to be split
     * @param _address - address to be checked if eligible for split
     */
    function checkMyAddress(address _address) external view returns (uint256) {
        return hasSplit[_address];
    }

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
