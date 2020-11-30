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
        uint32 minTokens; 
        uint32 maxTokens; 
    } 

    struct whiteListedAddress256 {
        uint256 tokensPerEth;
        uint256 minTokens; 
        uint256 maxTokens; 
    }

    mapping(address => whiteListedAddress) private whiteList;

    constructor() public {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(WHITELIST_ROLE, _msgSender());
        whiteList[address (0)].tokensPerEth = 100000; //100,000 tokens per ETH default
        whiteList[address (0)].minTokens = 10000; // 0.1 eth minimum default (10,000 tokens)
        whiteList[address (0)].maxTokens = 100000000; //1,000 eth max default (100,000,000 tokens)
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

    event REPORT(address addr, uint256 amount);

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
    function whitelist(address _addr, uint32 _tokensPerEth, uint32 _minTokens, uint32 _maxTokens) external {
        require(
            hasRole(WHITELIST_ROLE, _msgSender()),
            "PRuF:SSA: must have WHITELIST_ROLE"
        );

        whiteListedAddress memory _whiteList;
        
        //^^^^^^^checks^^^^^^^^^

        _whiteList.tokensPerEth = _tokensPerEth; //build new whiteList entry
        _whiteList.minTokens = _minTokens;
        _whiteList.maxTokens = _maxTokens;

        whiteList[_addr] = _whiteList;  //store new whiteList entry

        //^^^^^^^effects^^^^^^^^^
    }

    function checkWhitelist(address _addr) external view returns (uint256, uint256, uint256, uint256){ //min tokens, max tokens, tokens per eth, ETH (wei) to buy maxtokens

        whiteListedAddress memory _whiteList = whiteList[_addr];

        if (_whiteList.tokensPerEth == 0) {
            _whiteList = whiteList[address(0)];
        }

        uint256 maxEth = uint256(_whiteList.maxTokens).div(uint256(_whiteList.tokensPerEth));
        
        return (_whiteList.minTokens, _whiteList.maxTokens, _whiteList.tokensPerEth, maxEth);
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

        whiteListedAddress256 memory _whiteList256;
        whiteListedAddress memory _whiteList = whiteList[msg.sender];

        if (_whiteList.tokensPerEth == 0) {
            _whiteList = whiteList[address(0)];
        }
        
        uint256 amountToMint = msg.value.mul(_whiteList.tokensPerEth);

        require(
            (amountToMint != 0),
            "PTM:MP: mint amount is zero"
        );
        require(
            (amountToMint >= _whiteList.minTokens),
            "PTM:MP: Insufficient ETH to meet minimum purchase"
        );
        require(
            (amountToMint <= _whiteList.maxTokens),
            "PTM:MP: Purchase request exceeds allowed purchase amount"
        );

        _whiteList256.tokensPerEth =  uint256(_whiteList.tokensPerEth);
        _whiteList256.minTokens =  uint256(_whiteList.minTokens);
        _whiteList256.maxTokens =  uint256(_whiteList.maxTokens);

        _whiteList256.maxTokens = _whiteList256.maxTokens.sub(amountToMint); //reduce allotment by the amount to be minted

        require(
            (_whiteList256.maxTokens < 4294967295),  //---this should never be able to happen.
            "PTM:MP: Something broke - uint32 out of range"
        );

        _whiteList.maxTokens = uint32(_whiteList256.maxTokens); //store the updated number of tokens that can be minted to the account
        
        UTIL_TKN.mint(msg.sender, amountToMint);

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
    function pause() external isPauser {
        _pause();
    }

    /**
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external isPauser {
        _unpause();
    }

    //--------------------------------------------------------------------------------------INTERNAL functions
}
