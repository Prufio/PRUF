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

/**-----------------------------------------------------------------
 * FAUCET Specification V0.1
 * ü1.00 per second
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;


import "./RESOURCE_PRUF_STRUCTS.sol";
import "./RESOURCE_PRUF_INTERFACES.sol";
import "./RESOURCE_PRUF_TKN_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/security/Pausable.sol";
import "./Imports/security/ReentrancyGuard.sol";

// import "./Imports/token/ERC721/IERC721.sol";

contract FAUCET is ReentrancyGuard, AccessControl, Pausable {
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    // address internal STAKE_TKN_Address;
    // STAKE_TKN_Interface internal STAKE_TKN;

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address internal REWARDS_VAULT_Address;
    REWARDS_VAULT_Interface internal REWARDS_VAULT;

    uint256 constant seconds_in_a_day = 86400; //never set to less than 24 for tesing

    uint256 lastDrip; //last claim block.timestamp

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    // --------------------------------------Modifiers--------------------------------------------//

    // /**
    //  * @dev Verify user credentials
    //  * @param _tokenId token id to check
    //  */
    // modifier isStakeHolder(uint256 _tokenId) {
    //     require(
    //         (STAKE_TKN.ownerOf(_tokenId) == _msgSender()),
    //         "PES:MOD-ISH: caller does not hold stake token"
    //     );
    //     _;
    // }

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
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN(PRUF)
     * @param _rewardsVaultAddress address of REWARDS_VAULT
     */
    function setTokenContracts(
        address _utilAddress,
        // address _stakeAddress,
        address _rewardsVaultAddress
    ) external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _utilAddress;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        // STAKE_TKN_Address = _stakeAddress;
        // STAKE_TKN = STAKE_TKN_Interface(STAKE_TKN_Address);

        REWARDS_VAULT_Address = _rewardsVaultAddress;
        REWARDS_VAULT = REWARDS_VAULT_Interface(REWARDS_VAULT_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Transfers eligible rewards to staker, resets last payment time
     * @param _tokenId token id to claim rewards on
     */
    function drip(uint256 _tokenId)
        external
        // isStakeHolder(_tokenId)
        whenNotPaused
        nonReentrant
    {
        require(
            (block.timestamp - lastDrip) > 1, // 1 second
            "PES:CB: must wait 1s from last claim"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 reward = 1000000000000000000; // ü1.00

        lastDrip = block.timestamp; //resets interval start for next reward period
        //^^^^^^^effects^^^^^^^^^
        uint256 rewardsVaultBalance = UTIL_TKN.balanceOf(REWARDS_VAULT_Address);
        if (reward > rewardsVaultBalance) {
            reward = rewardsVaultBalance / 2; //as the rewards vault becomes empty, enforce a semi-fair FCFS distruibution favoring small holders
        }
        REWARDS_VAULT.payRewards(_tokenId, reward);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Create a newRecord with permanent description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function newRecordWithNote(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external nonReentrant whenNotPaused {
        //^^^^^^^Checks^^^^^^^^^

        Record memory rec;
        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _node, _countDownStart);
        writeNonMutableStorage(_idxHash, rec);
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
}
