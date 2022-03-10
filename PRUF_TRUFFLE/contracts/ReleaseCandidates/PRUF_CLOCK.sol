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
 * DAO Specification V0.02
 * //DPS:TEST NEW CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_CORE.sol";

contract CLOCK is BASIC {

    uint256 epochSeconds; //period of epochs, in seconds
    uint256 epochsOriginTime; //current epoch count starts at this time
    uint256 baseEpochs; // epochs past as of epochStartTime

    uint256 constant minEpochSeconds = 1; //DPS:CHECK CAUTION TESTING VALUE
    // uint256 constant minEpochSeconds = 3600; //1 hour

    //^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

    bytes32 public constant DAO_LAYER_ROLE = keccak256("DAO_LAYER_ROLE");

    event REPORT(string _msg, uint256 _seconds, uint256 _epoch);

    constructor() {
        epochSeconds = 9; //DPS:CHECK CAUTION TESTING VALUE
        //epochSeconds = 1 weeks;
        epochsOriginTime = block.timestamp;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has DAO_ROLE
     */
    modifier isDAOlayer() {
        require(
            hasRole(DAO_LAYER_ROLE, _msgSender()),
            "DAO:MOD-IDL:Calling address is not DAO layer contract"
        );
        _;
    }

    /**
     * @dev gets the current epoch
     */
    function thisEpoch() public view returns (uint256) {
        //^^^^^^^checks^^^^^^^^^
        return (baseEpochs +
            ((block.timestamp - epochsOriginTime) / epochSeconds));
        //^^^^^^^interactions^^^^^^^^
    }

    /**
     * @dev gets the current epoch elapsed time
     */
    function thisEpochElapsedTime() public view returns (uint256) {
        //^^^^^^^checks^^^^^^^^^
        return (block.timestamp -
            ((thisEpoch() * epochSeconds) + epochsOriginTime));
        //^^^^^^^interactions^^^^^^^^
    }

    /**
     * @dev gets the current epochSeconds calue
     */
    function getEpochSeconds() external view returns (uint256) {
        //^^^^^^^checks^^^^^^^^^
        return (epochSeconds);
        //^^^^^^^interactions^^^^^^^^
    }

    /**
     * @dev Sets a new epoch interval
     * @param _epochSeconds new epoch period to set
     * caller must be DAO_LAYER
     */
    function setNewEpochInterval(uint256 _epochSeconds) external isDAOlayer {
        require(
            _epochSeconds >= minEpochSeconds,
            "CLOCK:DSC:proposed epoch interval cannot be less than minEpochSeconds"
        );
        require(
            thisEpochElapsedTime() < _epochSeconds,
            "CLOCK:DSC:current epoch time elapsed cannot be more that proposed epoch interval"
        );
        //^^^^^^^checks^^^^^^^^^
        baseEpochs = thisEpoch();
        epochsOriginTime = block.timestamp;
        epochSeconds = _epochSeconds;
        emit REPORT(
            "PRUF_CLOCK: Epoch period set to",
            _epochSeconds,
            baseEpochs
        );
        //^^^^^^^effects^^^^^^^^^
    }
}

