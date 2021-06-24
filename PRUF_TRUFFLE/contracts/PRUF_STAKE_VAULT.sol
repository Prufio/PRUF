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
 *PRUF stakeVault holds stakes that were placed into its care.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/token/ERC721/IERC721.sol";
import "./Imports/token/ERC721/IERC721Receiver.sol";

contract STAKE_VAULT is
    ReentrancyGuard,
    AccessControl,
    IERC721Receiver,
    Pausable
{
    mapping(uint256 => uint256) private stake; // holds the stake parameters for each stake tokenId

    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant STAKE_ADMIN_ROLE = keccak256("STAKE_ADMIN_ROLE");
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

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      Has role
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "B:MOD:-IADM Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    modifier isStakeAdmin() {
        require(
            hasRole(STAKE_ADMIN_ROLE, _msgSender()),
            "B:MOD:-IADM Caller !STAKE_ADMIN_ROLE"
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
    function transferERC721Token(
        address _to,
        uint256 _tokenId,
        address _ERC721Contract
    ) external virtual nonReentrant {
        require(
            hasRole(ASSET_TXFR_ROLE, _msgSender()),
            "B:TX:Must have ASSET_TXFR_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        IERC721(_ERC721Contract).safeTransferFrom(address(this), _to, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     */
    function Admin_setTokenContracts(
        address _utilAddress,
        address _stakeAddress
    ) external virtual isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _utilAddress;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        STAKE_TKN_Address = _stakeAddress;
        STAKE_TKN = STAKE_TKN_Interface(STAKE_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /**
     * @dev moves (amount)tokens from holder of(tokenID) into itself using trustedAgentTransfer, records the amount in stake map
     * @param _tokenId token to get stake for
     * @param _amount amount of stake to pull
     */
    function takeStake(uint256 _tokenId, uint256 _amount)
        external
        isStakeAdmin
        nonReentrant
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        address staker = STAKE_TKN.ownerOf(_tokenId);
        //^^^^^^^effects^^^^^^^^^

        UTIL_TKN.trustedAgentTransfer(staker, address(this), _amount);
        stake[_tokenId] = _amount;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev sends stakedAmount[tokenId] tokens to ownerOf(tokenId). updates the stake map
     * @param _tokenId token to get stake for
     */
    function releaseStake(uint256 _tokenId)
        external
        isStakeAdmin
        nonReentrant
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        address staker = STAKE_TKN.ownerOf(_tokenId);
        uint256 amount = stake[_tokenId];
        delete stake[_tokenId];
        //^^^^^^^effects^^^^^^^^^

        UTIL_TKN.transfer(staker, amount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Returns the amount of tokens staked on (tokenId)
     * @param _tokenId token to check
     */
    function stakeOfToken(uint256 _tokenId) external view returns (uint256) {
        return stake[_tokenId];
        //^^^^^^^interactions^^^^^^^^^
    }

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
