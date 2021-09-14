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

import "./PRUF_CORE.sol";


contract FAUCET is CORE {

    address internal REWARDS_VAULT_Address;
    REWARDS_VAULT_Interface internal REWARDS_VAULT;

    uint256 constant seconds_in_a_day = 86400; //never set to less than 24 for tesing

    uint256 lastDrip; //last claim block.timestamp

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


    //--------------------------------------External functions--------------------------------------------//


    /**
     * @dev Resolve Contract Addresses from STOR
     */
    function resolveContractAddresses()
        external
        override
        nonReentrant
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^

    
        REWARDS_VAULT_Address = STOR.resolveContractAddress("REWARDS_VAULT");
        REWARDS_VAULT = REWARDS_VAULT_Interface(REWARDS_VAULT_Address);

        UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        APP_NC_Address = STOR.resolveContractAddress("APP_NC");
        APP_NC = APP_NC_Interface(APP_NC_Address);

        ID_MGR_Address = STOR.resolveContractAddress("ID_MGR");
        ID_MGR = ID_MGR_Interface(ID_MGR_Address);

        // NODE_TKN_Address = STOR.resolveContractAddress("NODE_TKN");
        // NODE_TKN = NODE_TKN_Interface(NODE_TKN_Address);

        // NODE_MGR_Address = STOR.resolveContractAddress("NODE_MGR");
        // NODE_MGR = NODE_MGR_Interface(NODE_MGR_Address);

        // A_TKN_Address = STOR.resolveContractAddress("A_TKN");
        // A_TKN = A_TKN_Interface(A_TKN_Address);

        // ID_MGR_Address = STOR.resolveContractAddress("ID_MGR");
        // ID_MGR = ID_MGR_Interface(ID_MGR_Address);

        // ECR_MGR_Address = STOR.resolveContractAddress("ECR_MGR");
        // ECR_MGR = ECR_MGR_Interface(ECR_MGR_Address);

        // APP_Address = STOR.resolveContractAddress("APP");
        // APP = APP_Interface(APP_Address);

        // RCLR_Address = STOR.resolveContractAddress("RCLR");
        // RCLR = RCLR_Interface(RCLR_Address);

        // APP2_Address = STOR.resolveContractAddress("APP2");

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


    // bytes32 _idxHash,
    // bytes32 _rgtHash,
    // uint32 _node,
    // uint32 _countDownStart,
    // bytes32 _nonMutableStorage1,
    // bytes32 _nonMutableStorage2

    //APP_NC.newRecordWithNote(_idxHash, _rgtHash, _node, _countDownStart, _nonMutableStorage1, _nonMutableStorage2);

}
