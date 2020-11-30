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
 *  TO DO
 *
 *-----------------------------------------------------------------
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/math/safeMath.sol";

contract AIR_MINTER is ReentrancyGuard, AccessControl, Pausable {

    //DEFINE ROLES
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    uint256 amount;

    constructor() internal {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    //------------------------------------------------------------------------MODIFIERS
    
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Admin
     */
    modifier isAdmin() {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:SSA: must have DEFAULT_ADMIN_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is Minter
     */
    modifier isMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "PRuF:SSA: must have MINTER_ROLE"
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
            hasRole(PAUSER_ROLE, _msgSender()),
            "PRuF:SSA: must have PAUSER_ROLE"
        );
        _;
    }

    //----------------------External Admin functions / isAdmin ---------------------//
    

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setTokenContract(address _address)
        external
        virtual
        isAdmin

    {
        require(
            _address != address(0),
            "AM:SSC: token address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _address;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set airdrop amount
     */
    function OO_setAirdropAmount(uint256 _amount) external isAdmin {
        require(_amount != 0, "AM:SAA: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        amount = _amount;
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint14(
        address _a,
        address _b,
        address _c,
        address _d,
        address _e,
        address _f,
        address _g,
        address _h,
        address _i,
        address _j,
        address _k,
        address _l,
        address _m,
        address _n
    ) external isMinter nonReentrant whenNotPaused {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        UTIL_TKN.mint(_d, amount);
        UTIL_TKN.mint(_e, amount);
        UTIL_TKN.mint(_f, amount);
        UTIL_TKN.mint(_g, amount);
        UTIL_TKN.mint(_h, amount);
        UTIL_TKN.mint(_i, amount);
        UTIL_TKN.mint(_j, amount);
        UTIL_TKN.mint(_k, amount);
        UTIL_TKN.mint(_l, amount);
        UTIL_TKN.mint(_m, amount);
        UTIL_TKN.mint(_n, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint10(
        address _a,
        address _b,
        address _c,
        address _d,
        address _e,
        address _f,
        address _g,
        address _h,
        address _i,
        address _j
    ) external isMinter nonReentrant whenNotPaused {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        UTIL_TKN.mint(_d, amount);
        UTIL_TKN.mint(_e, amount);
        UTIL_TKN.mint(_f, amount);
        UTIL_TKN.mint(_g, amount);
        UTIL_TKN.mint(_h, amount);
        UTIL_TKN.mint(_i, amount);
        UTIL_TKN.mint(_j, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint5(
        address _a,
        address _b,
        address _c,
        address _d,
        address _e
    ) external isAdmin nonReentrant whenNotPaused {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        UTIL_TKN.mint(_d, amount);
        UTIL_TKN.mint(_e, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint3(
        address _a,
        address _b,
        address _c
    ) external isMinter nonReentrant whenNotPaused {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        UTIL_TKN.mint(_c, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint2(address _a, address _b) external isMinter nonReentrant whenNotPaused {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        UTIL_TKN.mint(_b, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a set amount to a list of addresses
     */
    function OO_bulkMint1(address _a) external isMinter nonReentrant whenNotPaused {
        require(amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_a, amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Triggers stopped state. (pausable)
     *
     */
    function OO_pause() external isPauser {
        _pause();
    }

    /**
     * @dev Returns to normal state. (pausable)
     */
    function OO_unpause() external isPauser {
        _unpause();
    }

    //--------------------------------------------------------------------------------------INTERNAL functions
}
