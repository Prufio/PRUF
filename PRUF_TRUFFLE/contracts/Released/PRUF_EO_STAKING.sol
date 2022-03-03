/*--------------------------------------------------------PRüF0.8.7
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

/**-----------------------------------------------------------------
 * Early Access Staking Specification V0.2
 * EO Staking is a straght time-return staking model, based on Tokenized stakes.
 * Each "stake" is a staking "contract" with the following params:
 * amount  - Amount of stake
 * interval - maturity interval of stake - also time to first maturity at formation
 * startTime - Last Cycle - stake begin time or last paid time
 * endTime - end of the current cycle (may be in the past in the case of post-maturity stakes)
 * bonusPercentag - incentive paid per cycle
 *
 * ----Behavior-----
 *
 * 1: Create the stake - Stake NFT is issued to the creator. A unuiqe stake is formed with the face value, bonusPercentag, start time, maximum, and interval chosen. (becomes tokenHolder)
 * 2: payment can be taken at any time - will be the full amount or the fraction of the bonusPercentag amount (tokenholder)
 * 3: At any time after the end of the stake, the stake can be broken. Breaking the stake pays all tokens and bonusPercentag to the stakeHolder, and destroys the stake token. (tokenholder)
 * 4: the stake can be added to, up to its allowed maximum.
 *
 * ----To terminate staking rewards and to ensure fair distributions----
 * 1: Deactivate all stakeTiers by setting the stakeTier.maximum to 0
 * 2: Set endOfStaking to calculated fair distribution deadline by externally iterating all active stakes and calculating the last second for fair distribution based on balance of REWARDS_VAULT.
 * NOTE: if no external action is taken, final rewards will be distributed in a semi-fair first-come first-served basis favoring smaller balance stakes.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/RESOURCE_PRUF_INTERFACES.sol";
import "../Resources/RESOURCE_PRUF_TKN_INTERFACES.sol";
import "../Imports/access/AccessControl.sol";
import "../Imports/security/Pausable.sol";
import "../Imports/security/ReentrancyGuard.sol";
import "../Imports/token/ERC721/IERC721.sol";

contract EO_STAKING is ReentrancyGuard, AccessControl, Pausable {
    struct StakingTier {
        uint256 minimum; //Minimum stake for this tier
        uint256 maximum; //Maximum stake for this tier
        uint256 interval; //staking interval, in dayUnits
        uint256 bonusPercentage; //bonusPercentage in tenths of a percent
    }

    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address internal STAKE_VAULT_Address;
    STAKE_VAULT_Interface internal STAKE_VAULT;

    address internal STAKE_TKN_Address;
    STAKE_TKN_Interface internal STAKE_TKN;

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address internal REWARDS_VAULT_Address;
    REWARDS_VAULT_Interface internal REWARDS_VAULT;

    uint256 currentStake;
    uint256 constant seconds_in_a_day = 86400; //never set to less than 24 for tesing
    uint256 endOfStaking = block.timestamp + (seconds_in_a_day * 36500); //100 years in the future

    uint256 minUpgradeInterval = seconds_in_a_day / 24; //1 hour, based on seconds_in_a_day
 
    mapping(uint256 => Stake) private stake; // stake data
    mapping(uint256 => StakingTier) private stakeTier; //stake tier parameters

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
     *      Has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "PES:MOD-ICA Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      Has PAUSER_ROLE
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PES:MOD-IP:Calling address !pauser"
        );
        _;
    }

    //--------------------------------------External functions--------------------------------------------//

    /**
     * @dev Setter for setting fractions of a day for minimum interval
     * @param _minUpgradeInterval in seconds
     */
    function setMinimumPeriod(uint256 _minUpgradeInterval) external isContractAdmin {
        require(
            _minUpgradeInterval <= (seconds_in_a_day / 24),
            "ES:SMP:Cannot set minimum period to less than 1 hour"
        );
        minUpgradeInterval = _minUpgradeInterval;
    }

    /**
     * @dev Kill switch for staking reward earning
     * @param _delay delay in seconds to end stake earning
     */
    function endStaking(uint256 _delay) external isContractAdmin {
        endOfStaking = block.timestamp + _delay;
    }

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN(PRUF)
     * @param _stakeAddress address of STAKE_TKN
     * @param _stakeVaultAddress address of STAKE_VAULT
     * @param _rewardsVaultAddress address of REWARDS_VAULT
     */
    function setTokenContracts(
        address _utilAddress,
        address _stakeAddress,
        address _stakeVaultAddress,
        address _rewardsVaultAddress
    ) external isContractAdmin {
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

    /**
     * @dev Set stake tier parameters
     * @param _stakeTier Staking level to set
     * @param _min Minumum stake
     * @param _max Maximum stake
     * @param _interval staking interval, in dayUnits - set to the number of days that the stake and reward interval will be based on.
     * @param _bonusPercentage bonusPercentage in tenths of a percent: 15 = 1.5% or 15/1000 per interval. Calculated to a fixed amount of tokens in the actual stake
     */
    function setStakeLevels(
        uint256 _stakeTier,
        uint256 _min,
        uint256 _max,
        uint256 _interval,
        uint256 _bonusPercentage
    ) external isContractAdmin {
        require(
            _interval >= 2,
            "PES:SSL: minumum allowable time for stake is 2 days"
        );
        require(
            _min > 99999999999999999999, //100 pruf
            "PES:SSL: Stake tier minimum amount < 100 not allowed"
        );

        //^^^^^^^checks^^^^^^^^^
        stakeTier[_stakeTier].minimum = _min;
        stakeTier[_stakeTier].maximum = _max; //set to zero to disable new stkes in this tier
        stakeTier[_stakeTier].interval = _interval;
        stakeTier[_stakeTier].bonusPercentage = _bonusPercentage;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Create a new stake
     * @param _amount amount of tokens to stake
     * @param _stakeTier staking tier
     */
    function stakeMyTokens(uint256 _amount, uint256 _stakeTier) external {
        StakingTier memory thisStakeTier = stakeTier[_stakeTier];
        require(thisStakeTier.maximum > 0, "PES:SMT: Inactive Staking tier");
        require(
            _amount <= thisStakeTier.maximum,
            "PES:SMT: Stake above maximum for this tier."
        );
        require(
            _amount >= thisStakeTier.minimum,
            "PES:SMT: Stake below minumum for this tier."
        );

        newStake(_amount, _stakeTier);
    }

    /**
     * @dev Transfers eligible rewards to staker, resets last payment time, adds _amount tokens to holders stake
     * @param _tokenId token id to modify stake
     */
    function increaseMyStake(uint256 _tokenId, uint256 _amount)
        external
        isStakeHolder(_tokenId)
        whenNotPaused
        nonReentrant
    {
        Stake memory thisStake = stake[_tokenId];

        require(
            endOfStaking > block.timestamp,
            "PES:IMS: New stakes cannot be created."
        );
        require(
            (block.timestamp - thisStake.startTime) > minUpgradeInterval, //DPS:TEST:NEW
            "PES:IMS: must wait more time from creation/last claim"
        );
        require(
            (_amount + thisStake.stakedAmount) <= thisStake.maximum,
            "PES:IMS: amount will raise stake above maximum."
        );
        uint256 reward = eligibleRewards(_tokenId); //gets reward for current reward period, prior to any changes
        require(
            (UTIL_TKN.balanceOf(_msgSender()) + reward) >= _amount,
            "PES:IMS:Insufficient Funds at stakeHolder address to match stake increase"
        );

        //^^^^^^^checks^^^^^^^^^
        thisStake.stakedAmount = thisStake.stakedAmount + _amount; //increases staked amount by stake increase _amount
        thisStake.mintTime = block.timestamp; //Starts mint time of stake over
        thisStake.startTime = thisStake.mintTime; //Starts reward start time over
        //thisStake.interval, .maximum, and .bonusPercentage are unchanged

        stake[_tokenId] = thisStake; //write the updated stake parameters to the stake map

        //^^^^^^^effects^^^^^^^^^
        uint256 rewardsVaultBalance = UTIL_TKN.balanceOf(REWARDS_VAULT_Address);
        if (reward > rewardsVaultBalance) {
            reward = rewardsVaultBalance / 2; //as the rewards vault becomes empty, enforce a semi-fair FCFS distruibution favoring small holders
        }

        REWARDS_VAULT.payRewards(_tokenId, reward); //get all rewards due first.

        STAKE_VAULT.takeStake(_tokenId, _amount); //move _amount tokens from token holder account to stake_vault
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Transfers eligible rewards to staker, resets last payment time
     * @param _tokenId token id to claim rewards on
     */
    function claimBonus(uint256 _tokenId)
        external
        isStakeHolder(_tokenId)
        whenNotPaused
        nonReentrant
    {
        Stake memory thisStake = stake[_tokenId];

        require(
            (block.timestamp - thisStake.startTime) > seconds_in_a_day, // 1 day in seconds
            "PES:CB: must wait 24h from creation/last claim"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 reward = eligibleRewards(_tokenId); //gets reward for current reward period

        stake[_tokenId].startTime = block.timestamp; //resets interval start for next reward period
        //^^^^^^^effects^^^^^^^^^
        uint256 rewardsVaultBalance = UTIL_TKN.balanceOf(REWARDS_VAULT_Address);
        if (reward > rewardsVaultBalance) {
            reward = rewardsVaultBalance / 2; //as the rewards vault becomes empty, enforce a semi-fair FCFS distruibution favoring small holders
        }
        REWARDS_VAULT.payRewards(_tokenId, reward);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Burns stake, transfers eligible rewards and staked tokens to staker
     * @param _tokenId stake key token id
     */
    function breakStake(uint256 _tokenId)
        external
        isStakeHolder(_tokenId)
        whenNotPaused
        nonReentrant
    {
        Stake memory thisStake = stake[_tokenId];

        require(
            block.timestamp >
                (thisStake.mintTime + (thisStake.interval * seconds_in_a_day)),
            "PES:BS: must wait until stake period has elapsed"
        );
        require(
            (block.timestamp - thisStake.startTime) > seconds_in_a_day, // 1 day in seconds
            "PES:BS: must wait 24h from last claim"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 reward = eligibleRewards(_tokenId);
        //^^^^^^^effects^^^^^^^^^

        uint256 rewardsVaultBalance = UTIL_TKN.balanceOf(REWARDS_VAULT_Address);
        if (reward > rewardsVaultBalance) {
            reward = rewardsVaultBalance / 2; //as the rewards vault becomes empty, enforce a semi-fair first-come first-serve distruibution favoring small holders
        }

        REWARDS_VAULT.payRewards(_tokenId, reward);
        STAKE_VAULT.releaseStake(_tokenId);
        STAKE_TKN.burnStakeToken(_tokenId);
        delete stake[_tokenId];
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Pauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     */
    function pause() external isPauser {
        _pause();
    }

    /**
     * @dev Unpauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     */
    function unpause() external isPauser {
        _unpause();
    }

    /**
     * @dev Check eligible rewards amount for a stake, for verification
     * @param _tokenId token id to check
     * @return reward and microIntervals
     */
    function checkEligibleRewards(uint256 _tokenId)
        external
        view
        returns (uint256, uint256)
    {
        Stake memory thisStake = stake[_tokenId];
        uint256 timeNow;

        if (block.timestamp > endOfStaking) {
            timeNow = endOfStaking;
        } else {
            timeNow = block.timestamp;
        }
        
        uint256 bonusPerInterval = (thisStake.stakedAmount *
            thisStake.bonusPercentage) / 1000;

        uint256 elapsedMicroIntervals = (((timeNow - thisStake.startTime) *
            1000000) / (thisStake.interval * seconds_in_a_day)); //microIntervals since stake start or last payout

        uint256 reward = (elapsedMicroIntervals * bonusPerInterval) / 1000000;

        return (reward, elapsedMicroIntervals); //reward amount and millionths of a reward period that have passed
    }

    /**
     * @dev Returns info of given stake key tokenId
     * @param _tokenId Stake ID to return
     * @return Stake struct, see Interfaces.sol
     */
    function stakeInfo(uint256 _tokenId)
        external
        view
        returns (
            uint256,
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
            stake[_tokenId].bonusPercentage,
            stake[_tokenId].maximum
        );
    }

    /**
     * @dev Return specific stakeTier specification
     * @param _stakeTier stake level to inspect
     * @return StakingTier @ given index, see declaration in beginning of contract
     */
    function getStakeLevel(uint256 _stakeTier)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            stakeTier[_stakeTier].minimum,
            stakeTier[_stakeTier].maximum,
            stakeTier[_stakeTier].interval,
            stakeTier[_stakeTier].bonusPercentage
        );
    }

    //--------------------------------------------------------------------------------------Internal/Private functions

    /**
     * @dev Check eligible rewards amount for a stake
     * @param _tokenId token id to check
     * @return eligible rewards @ given staking key ID
     */
    function eligibleRewards(uint256 _tokenId) internal view returns (uint256) {
        Stake memory thisStake = stake[_tokenId];
        uint256 timeNow;

        if (block.timestamp > endOfStaking) {
            timeNow = endOfStaking;
        } else {
            timeNow = block.timestamp;
        }

        uint256 bonusPerInterval = (thisStake.stakedAmount *
            thisStake.bonusPercentage) / 1000;
        uint256 elapsedMicroIntervals = (((timeNow - thisStake.startTime) *
            1000000) / (thisStake.interval * seconds_in_a_day)); //microIntervals since stake start or last payout

        uint256 reward = (elapsedMicroIntervals * bonusPerInterval) / 1000000;

        return (reward);
    }

    /**
     * @dev Create a new stake
     * @param _amount stake token amount
     * @param _tier stake tier to stake in
     */
    function newStake(uint256 _amount, uint256 _tier)
        private
        nonReentrant
        whenNotPaused
    {
        StakingTier memory thisStakeTier = stakeTier[_tier];
        require(
            thisStakeTier.interval >= 2, // 2 days in seconds unreachable? throws in setStakeLevels
            "PES:NS: Interval <= 2"
        );
        //^^^^^^^checks^^^^^^^^^

        currentStake++;
        Stake memory thisStake;

        thisStake.stakedAmount = _amount;
        thisStake.mintTime = block.timestamp;
        thisStake.startTime = thisStake.mintTime;
        thisStake.interval = thisStakeTier.interval;
        thisStake.bonusPercentage = thisStakeTier.bonusPercentage;
        thisStake.maximum = thisStakeTier.maximum;

        stake[currentStake] = thisStake;
        //^^^^^^^effects^^^^^^^^^

        STAKE_TKN.mintStakeToken(_msgSender(), currentStake);
        STAKE_VAULT.takeStake(currentStake, _amount);
        //^^^^^^^interactions^^^^^^^^^
    }
}
