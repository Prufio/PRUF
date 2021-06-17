/*--------------------------------------------------------PRüF0.8.0
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/
         
/**-----------------------------------------------------------------
*  TO DO
*
* IMPORTANT!!! EXTERNAL OR PUBLIC FUNCTIONS WITHOUTSTRICT PERMISSIONING NEED 
* TO BE CLOSELY EXAMINED IN THIS CONTRACT AS THEY WILL BE INHERITED NEARLY GLOBALLY
*-----------------------------------------------------------------
*-----------------------------------------------------------------
*PRUF basic provides core data structures and functionality to PRUF contracts.
*Features include contract name resolution, and getters for records, users, and asset class information.
*---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/token/ERC721/IERC721.sol";
import "./Imports/token/ERC721/IERC721Receiver.sol";

contract R_VAULT is
    ReentrancyGuard,
    AccessControl,
    IERC721Receiver,
    Pausable
{
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ASSET_TXFR_ROLE = keccak256("ASSET_TXFR_ROLE");

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address internal STAKE_TKN_Address;
    STAKE_TKN_Interface internal STAKE_TKN;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    // --------------------------------------Modifiers--------------------------------------------//


    /*
     * @dev Verify user credentials
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * Originating Address:
     *   require that user holds token @ ID-Contract
     */
    modifier isStakeHolder(uint256 _tokenID) {
        require(
            (STAKE_TKN.ownerOf(_tokenID) == _msgSender()),
            "D:MOD-ITH: caller does not hold stake token"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      is contract admin
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "B:MOD:-IADM Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "B:MOD-IP:Calling address is not pauser"
        );
        _;
    }

    //----------------------External Admin functions / isContractAdmin----------------------//

    /**
     * @dev Transfer any specified ERC721 Token from contract
     * @param _to - address to send to
     * @param _tokenId - token ID
     * @param _ERC721Contract - token contract address
     */
    function transferERC721Token(address _to, uint256 _tokenId, address _ERC721Contract)
        external
        virtual
        nonReentrant
    {
        require( 
            hasRole(ASSET_TXFR_ROLE, _msgSender()),
            "B:TX:Must have ASSET_TXFR_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        IERC721(_ERC721Contract).safeTransferFrom(address(this), _to, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }


    /**
     * @dev Set address of STOR contract to interface with 
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     */
    function Admin_setTokenContracts(address _utilAddress, address _stakeAddress)
        external
        virtual
        isContractAdmin 
    {
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN = UTIL_TKN_Interface(_utilAddress);
        STAKE_TKN = STAKE_TKN_Interface(_stakeAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//
    /**
     * @dev Compliance for erc721 reciever
     * See OZ documentation 
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        //^^^^^^^checks^^^^^^^^^
        return this.onERC721Received.selector;
        //^^^^^^^interactions^^^^^^^^^
    }

    /***
     * @dev Triggers stopped state. (pausable)
     *
     */
    function pause() external isPauser {
        _pause();
    }

    /***
     * @dev Returns to normal state. (pausable)
     */

    function unpause() external isPauser {
        _unpause();
    }

    //--------------------------------------------------------------------------------------INTERNAL functions





}
