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
 * FAUCET Specification V0.1
 * ü1.00 per second
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";

contract FAUCET is CORE {
    address internal REWARDS_VAULT_Address;
    REWARDS_VAULT_Interface internal REWARDS_VAULT;

    uint256 constant seconds_in_a_day = 86400; //never set to less than 24 for tesing

    uint256 droplet = 10000000000000000000; // ü5.00

    uint256 interval = 900; //limit interval in seconds
    uint256 maxPerInterval = 110000000000000000000; //Max PRUF delivered per interval
    uint256 tokensThisInterval = 0; //Tokens claimed this interval
    uint256 lastStream; //last claim block.timestamp

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
     * @dev Setter for setting faucet output amount
     * @param _droplet in seconds
     */
    function setFaucetAmount(uint256 _droplet) external isContractAdmin {
        require(
            droplet <= 1000000000000000000000, //cannot exceed ü1000
            "ES:SFA:Cannot set to more than 100"
        );
        droplet = _droplet;
    }

    /**
     * @dev Setter for reset interval
     * @param _interval in seconds
     */
    function setInterval(uint256 _interval) external isContractAdmin {
        require(
            _interval >= 30, //at least 30 seconds
            "ES:SMP:Cannot set minimum period to less than 30 seconds"
        );
        interval = _interval;
    }

    /**
     * @dev Setter for max tokens per interval
     * @param _maxPerInterval in seconds
     */
    function setMaxPerInterval(uint256 _maxPerInterval)
        external
        isContractAdmin
    {
        require(
            _maxPerInterval <= 10000000000000000000000, //No more than 10K
            "ES:SMP:Cannot set minimum period to less than 30 seconds"
        );
        maxPerInterval = _maxPerInterval;
    }

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

        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Transfers eligible rewards to staker, resets last payment time
     * @param _seed token id to claim rewards on
     */

    //CTS:EXAMINE--WARNING IN COMPILING, FUNCTION COMMENTED OUT FOR TESTING

    // function drip(bytes32 _seed) external whenNotPaused nonReentrant {
    //     if (block.timestamp - lastStream > interval) {
    //         tokensThisInterval = 0;
    //         lastStream = block.timestamp;
    //     }
    //     require(
    //         tokensThisInterval < maxPerInterval,
    //         "PES:CB: Stream Depleted. Wait until next interval"
    //     );

    //     uint256 faucetBalance = UTIL_TKN.balanceOf(address(this));

    //     //^^^^^^^checks^^^^^^^^^

    //     if (droplet > faucetBalance) {
    //         droplet = faucetBalance / 2; //as the faucet becomes empty, enforce a tapering distribution
    //     }

    //     //^^^^^^^effects^^^^^^^^^

    //     UTIL_TKN.transfer(_msgSender(), droplet); //deliver the goods
    //     tokensThisInterval = tokensThisInterval + droplet;
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    // bytes32 _idxHash,
    // bytes32 _rgtHash,
    // uint32 _node,
    // uint32 _countDownStart,
    // bytes32 _nonMutableStorage1,
    // bytes32 _nonMutableStorage2

    //APP_NC.newRecordWithNote(_idxHash, _rgtHash, _node, _countDownStart, _nonMutableStorage1, _nonMutableStorage2);
}
