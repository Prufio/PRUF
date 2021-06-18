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
 * flesh out functions , Create misc front end functions for different stake minimums, times, and rewards. These call newStake.
 *-----------------------------------------------------------------
 *-----------------------------------------------------------------
 * Early Access Staking Specification V0.1
 * EO Staking is a straght time-return staking model, based on Tokenized stakes.
 * Each "stake" is a staking "contract" with the following params:
 * amount  - Amount of stake
 * interval - maturity interval of stake - also time to first maturity at formation
 * startTime - Last Cycle - stake begin time or last paid time
 * endTime - end of the current cycle (may be in the past in the case of post-maturity stakes)
 * bonus - incentive paid per cycle
 *
 * ----Behavior-----
 *
 * 1: Create the stake - Stake NFT is issued to the creator. A unuiqe stake is formed with the face value, bonus, start time, and interval chosen. (becomes tokenHolder)
 * 2: payment can be taken at any time - will be the full amount or the fraction of the bonus amount (tokenholder)
 * 3: At any time after the end of the stake, the stake can be broken. Breaking the stake pays all tokens and bonus to the stakeHolder, and destroys the stake token. (tokenholder)
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/token/ERC721/IERC721.sol";
import "./Imports/token/ERC721/IERC721Receiver.sol";

contract EO_STAKING is
    ReentrancyGuard,
    AccessControl,
    IERC721Receiver,
    Pausable
{
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ASSET_TXFR_ROLE = keccak256("ASSET_TXFR_ROLE");

    address internal STAKE_VAULT_Address;
    STAKE_VAULT_Interface internal STAKE_VAULT;

    address internal REWARDS_VAULT_Address;
    REWARDS_VAULT_Interface internal REWARDS_VAULT;

    address internal STAKE_TKN_Address;
    STAKE_TKN_Interface internal STAKE_TKN;

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    uint256 currentStake;

    mapping(uint256 => Stake) private stake; // stake data

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    // --------------------------------------Modifiers--------------------------------------------//

    /**
     * @dev Verify user credentials
     * @param _tokenId token id to check
     */
    modifier isStakeHolder(uint256 _tokenId) {
        require(
            (STAKE_TKN.ownerOf(_tokenId) == _msgSender()),
            "PES:MOD-ISH: caller does not hold stake token"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      Has Role
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "PES:MOD-ICA Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PES:MOD-IP:Calling address is not pauser"
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
            "PES:TET:Must have ASSET_TXFR_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        IERC721(_ERC721Contract).safeTransferFrom(address(this), _to, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set address of contracts to interface with
     * @param _stakeAddress address of STAKE_TKN
     * @param _stakeVaultAddress address of STAKE_VAULT
     * @param _rewardsVaultAddress address of REWARDS_VAULT
     */
    function Admin_setTokenContracts(
        address _utilAddress,
        address _stakeAddress,
        address _stakeVaultAddress,
        address _rewardsVaultAddress
    ) external virtual isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _utilAddress;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        STAKE_TKN_Address = _stakeAddress;
        STAKE_TKN = STAKE_TKN_Interface(STAKE_TKN_Address);

        STAKE_VAULT_Address = _stakeVaultAddress;
        STAKE_VAULT = STAKE_VAULT_Interface(STAKE_VAULT_Address);

        REWARDS_VAULT_Address = _rewardsVaultAddress;
        REWARDS_VAULT = REWARDS_VAULT_Interface(REWARDS_VAULT_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /**
    takeBonus (tokenId) #require be tokenHolder , (now - starttime) > 24 hours #public
    calls eligibleRewards to get payAmount
    sets startTime = now

    tokensLeft = rewardsVault.tokensInFund
    if payAmount > tokensLeft payAmount = tokensLeft

    calls rewardsVault.payRewards (tokenID,payAmount) 
    */

    /**
     * @dev Verify user credentials
     * @param _tokenId token id to check
     */
    function takeBonus(uint256 _tokenId) public isStakeHolder(_tokenId) {}

    /**
    breakStake (tokenId) #require be tokenHolder , now > (mintTime + interval)  //must wait 24 hours since last takeBonus call or will throw in takeBonus #public
    calls takeBonus (tokenId)
    calls stakeVault.releaseStake(tokenId)
    burn (tokenId)

    */
    /**
     * @dev Verify user credentials
     * @param _tokenId token id to check
     */
    function breakStake(uint256 _tokenId) public isStakeHolder(_tokenId) {}


    /**
     * @dev Verify user credentials
     * @param _tokenId token id to check
     */
    function eligibleRewards(uint256 _tokenId) public returns (uint256) {
        Stake memory thisStake = stake[_tokenId];
        uint256 availableRewards = UTIL_TKN.balanceOf(REWARDS_VAULT_Address);
        uint256 elapsedMicroIntervals =
            (((block.timestamp - thisStake.startTime) * 1000000) /
                thisStake.interval); //microIntervals since stake start or last payout
        uint256 reward = (elapsedMicroIntervals * thisStake.bonus) / 1000000;

        if (reward > availableRewards) {
            reward = availableRewards;
        }

        return (reward);
    }

    /**
     * @dev Return Stake info
     * @param _tokenId Stake ID to return
     */
    function stakeInfo(uint256 _tokenId)
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            stake[_tokenId].stakedAmount,
            stake[_tokenId].mintTime,
            stake[_tokenId].startTime,
            stake[_tokenId].interval,
            stake[_tokenId].bonus
        );
    }

    /**
    struct Stake {
    uint256 stakedAmount; //tokens in stake
    uint256 mintTime; //blocktime of creation
    uint256 startTime; //blocktime of creation or most recent payout
    uint256 interval; //staking interval in seconds
    uint256 bonus; //bonus tokens earned per interval
    } */

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

    /**
     * @dev Create a new stake
     * @param _amount stake token amount
     * @param _interval stake maturity interval, in seconds
     * @param _bonus bonus tokens paid, per _interval
     */
    function newStake(
        uint256 _amount,
        uint256 _interval,
        uint256 _bonus
    ) private {
        require(
            _interval > 172800, // 2 days in seconds
            "PES:NS: Stake <= 172800 sec"
        );

        require(
            _amount > 999999999999999999999, //1000 pruf
            "PES:NS: Staked amount < 1000"
        );
        //^^^^^^^checks^^^^^^^^^

        currentStake++;
        Stake memory thisStake;
        thisStake.stakedAmount = _amount;
        thisStake.mintTime = block.timestamp;
        thisStake.startTime = thisStake.mintTime;
        thisStake.interval = _interval;
        thisStake.bonus = _bonus;

        stake[currentStake] = thisStake;
        //^^^^^^^effects^^^^^^^^^

        STAKE_TKN.mintStakeToken(_msgSender(), currentStake);
        STAKE_VAULT.takeStake(currentStake, _amount);
        //^^^^^^^interactions^^^^^^^^^
    }
}
