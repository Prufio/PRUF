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
 * PRESALE CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/math/safeMath.sol";

contract PRESALE is ReentrancyGuard, Pausable, AccessControl {
    using SafeMath for uint256;

    //DEFINE ROLES
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant WHITELIST_ROLE = keccak256("WHITELIST_ROLE");

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address payable payment_address;

    struct whiteListedAddress {
        uint32 tokensPerEth;
        uint32 minEth;
        uint32 maxEth;
    } //parameters in eth

    mapping(address => whiteListedAddress) private whiteList;

    constructor() internal {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(WHITELIST_ROLE, _msgSender());
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
     *      is Minter
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PRuF:SSA: must have PAUSER_ROLE"
        );
        _;
    }

    //----------------------External Admin functions / onlyowner ---------------------//

    /*
     * @dev Set address of PRUF_TKN contract to interface with
     */
    function ADMIN_setTokenContract(address _address) external isAdmin {
        require(
            _address != address(0),
            "PTM:SPT: token address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _address;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set Payment addrress to send eth to
     */
    function ADMIN_setPaymentAddress(address payable _address) external isAdmin {
        require(
            _address != address(0),
            "PTM:SPA: token address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        payment_address = _address;

        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /*
     * @dev Set address of PRUF_TKN contract to interface with
     * Set default condition at address(0). Addresses not appearing on the whitelist will fall under these terms.
     */
    function whitelist(address _addr, uint32 _tokensPerEth, uint32 _minEth, uint32 _maxEth) external{
        require(
            hasRole(WHITELIST_ROLE, _msgSender()),
            "PRuF:SSA: must have WHITELIST_ROLE"
        );

        whiteListedAddress memory _whiteList;
        
        //^^^^^^^checks^^^^^^^^^

        _whiteList.tokensPerEth = _tokensPerEth; //build new whiteList entry
        _whiteList.minEth = _minEth;
        _whiteList.maxEth = _maxEth;

        whiteList[_addr] = _whiteList;  //store new whiteList entry

        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint PRUF to an addresses (ADMIN)
     */
    function ADMIN_MintPRUF(address _addr, uint256 _amount)
        external
        isAdmin
        nonReentrant
        whenNotPaused
    {
        require(
            (_amount != 0) && (_addr != address(0)),
            "PTM:MP: mint amount or address is zero"
        );
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_addr, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint PRUF to an addresses at the rate of 5000 * ETH recieved
     */
    function mintPRUF() external payable nonReentrant {
        UTIL_TKN.mint(msg.sender, msg.value.mul(5000));
    }

    /*
     * @dev withdraw to specified payment address
     */
    function withdraw() external {
        payment_address.transfer(address(this).balance);
    }

    /*
     * @dev return balance of contract
     */
    function balance() external view returns (uint256) {
        return address(this).balance;
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
