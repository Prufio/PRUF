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
 *---------------------------------------------------------------



PRUF_EO_STAKING contract:

Data structures: 
stakes (amount, mintTime, startTime, interval, bonus)
map "stake" tokenID -> stakes 

Create misc front end functions for different stake minimums, times, and rewards. These call newStake.

#this will be an internal function with external front ends made with various specs and minimums to form the stake offering variations

*/

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
     * @dev Set address of STOR contract to interface with
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     */
    function Admin_setTokenContracts(
        address _utilAddress,
        address _stakeAddress
    ) external virtual isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN = UTIL_TKN_Interface(_utilAddress);
        STAKE_TKN = STAKE_TKN_Interface(_stakeAddress);
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
    function takeBonus (uint256 _tokenId) isStakeHolder(_tokenId) public {}

    /**
    breakStake (tokenId) #require be tokenHolder , now > (mintTime + interval)  //must wait 24 hours since last takeBonus call or will throw in takeBonus #public
    calls takeBonus (tokenId)
    calls stakeVault.releaseStake(tokenId)
    burn (tokenId)

    */
    function breakStake (uint256 _tokenId) isStakeHolder(_tokenId) public {}

    /**
    eligibleRewards (tokenId) #view
    elapsed_micro-intervals = ( ( ( now-starttime ) * 1,000,000 )  / interval ) 

            #if the collection perieod exceeds 1,000,000 intervals, there will be losses, 
            #the fund will be exhausted so no problem of perpetuity overflowing the time calculations

    rewards = (micro-intervals * bonus) / 1,000,000  
    returns rewards
    
    */
    function eligibleRewards (uint256 _tokenId) view public {}

    /**
    stakeInfo(tokenId) #view
    returns stake[tokenId] #maybe broken out into individual vars
    */
    function stakeInfo (uint256 _tokenId) view public {}


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

    /**
    newStake(amount, interval, endTime, bonus) #private 
    stakeNumber ++
    Mints a token to caller address with tokenId = stakeNumber

    calls stakeVault.takeStake (stakeNumber, amount)

    records stake[stakeNumber].amount, mintTime = now, starttime = now, interval, bonus
    */
    function newStake(uint256 _amount, uint256 _interval, uint256 _endTime, uint256 _bonus) private {}
}
