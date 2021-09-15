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

/*-----------------------------------------------------------------
 //Inheritable functions for core functionality
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./PRUF_BASIC.sol";
import "./Imports/security/ReentrancyGuard.sol";

contract ECR_CORE is BASIC {
    /**
     * @dev Sets escrow data
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _newAssetStatus - new escrow status of asset (see docs)
     * @param _escrowOwnerAddressHash - hash of escrow controller address
     * @param _timelock - timelock parameter for time controlled escrows
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
     * @dev function for setting escrow data
     * @param _idxHash - hash of asset information created by frontend inputs
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
     * @dev function for setting escrow data
     * @param _idxHash - hash of asset information created by frontend inputs
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
     * @param _idxHash - hash of asset information created by frontend inputs
     * @return escrowData struct (see interfaces for struct definitions)
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
     * @param _idxHash - hash of asset information created by frontend inputs
     * @return escrowDataExtLight struct (see interfaces for struct definitions)
     */
    function getEscrowDataLight(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtLight memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtLight memory escrowDataLight = ECR_MGR
            .retrieveEscrowDataLight(_idxHash);

        return (escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev retrieves extended escrow data
     * @param _idxHash - hash of asset information created by frontend inputs
     * @return escrowDataExtHeavy struct (see interfaces for struct definitions)
     */
    function getEscrowDataHeavy(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtHeavy memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtHeavy memory escrowDataHeavy = ECR_MGR
            .retrieveEscrowDataHeavy(_idxHash);

        return (escrowDataHeavy);
        //^^^^^^^interactions^^^^^^^^^
    }
}
