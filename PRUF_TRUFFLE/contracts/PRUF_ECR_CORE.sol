/*--------------------------------------------------------PRüF0.8.0
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

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

 //CTS:EXAMINE quick explainer for the contract

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_BASIC.sol";
//import "./PRUF_INTERFACES.sol"; // CTS:EXAMINE remove
import "./Imports/utils/ReentrancyGuard.sol";

contract ECR_CORE is BASIC {
    
    /**
     * Escrow Data Setter
     * @param _idxHash - Asset ID
     * @param _newAssetStatus - Escrow status to set
     * @param _escrowOwnerAddressHash - Hash of escrow controller address
     * @param _timelock - Timelock parameter for time controlled escrows
     */
    function _setEscrowData(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock
    ) internal whenNotPaused {
        ECR_MGR.setEscrow(
            _idxHash,
            _newAssetStatus,
            _escrowOwnerAddressHash,
            _timelock
        );
    }

    /**
     * Escrow DataLight Setter
     * @param _idxHash - Asset ID
     * @param _escrowDataLight - escrowDataExtLight struct (see interfaces for struct definitions)
     */
    function _setEscrowDataLight(
        bytes32 _idxHash,
        escrowDataExtLight memory _escrowDataLight
    ) internal whenNotPaused {
        ECR_MGR.setEscrowDataLight(_idxHash, _escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * Escrow DataHeavy Setter
     * @param _idxHash - Asset ID
     * @param _escrowDataHeavy - escrowDataExtHeavy struct (see interfaces for struct definitions)
     */
    function _setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy memory _escrowDataHeavy
    ) internal whenNotPaused {
        ECR_MGR.setEscrowDataHeavy(_idxHash, _escrowDataHeavy);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev retrieves escrow data
     * @param _idxHash - Asset ID
     * returns escrowData struct (see interfaces for struct definitions)
     */
    function getEscrowData(bytes32 _idxHash)
        internal
        returns (escrowData memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowData memory escrow = ECR_MGR.retrieveEscrowData(_idxHash);

        return (escrow);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev retrieves extended escrow data
     * @param _idxHash - Asset ID
     * returns escrowDataExtLight struct (see interfaces for struct definitions)
     */
    function getEscrowDataLight(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtLight memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtLight memory escrowDataLight =
            ECR_MGR.retrieveEscrowDataLight(_idxHash);

        return (escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev retrieves extended escrow data
     * @param _idxHash - Asset ID
     * returns escrowDataExtHeavy struct (see interfaces for struct definitions)
     */
    function getEscrowDataHeavy(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtHeavy memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtHeavy memory escrowDataHeavy =
            ECR_MGR.retrieveEscrowDataHeavy(_idxHash);

        return (escrowDataHeavy);
        //^^^^^^^interactions^^^^^^^^^
    }
}
