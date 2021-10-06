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

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./RESOURCE_PRUF_STRUCTS.sol";

//------------------------------------------------------------------------------------------------

interface temp {
    
    /**
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _newAssetStatus - new escrow status of asset (see docs)
     * @param _escrowOwnerAddressHash - hash of escrow controller address
     * @param _timelock - timelock parameter for time controlled escrows
     */
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock
    ) external;

    /**
     * @dev remove asset from escrow
     * @param _idxHash - hash of asset information created by frontend inputs
     */
    function endEscrow(bytes32 _idxHash) external;

    /**
     * @dev Sets data in the Escrow Data Light mapping
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _escrowDataLight - struct of data associated with light load escrows
     */
    function setEscrowDataLight(
        bytes32 _idxHash,
        escrowDataExtLight calldata _escrowDataLight
    ) external;

    /**
     * @dev Sets data in the Escrow Data Heavy mapping
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param escrowDataHeavy - struct of data associated with heavy load escrows
     */
    function setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy calldata escrowDataHeavy
    ) external;

    /**
     * @dev Permissive removal of asset from escrow status after time-out (no special qualifiers to end expired escrow)
     * @param _idxHash - hash of asset information created by frontend inputs
     */
    function permissiveEndEscrow(bytes32 _idxHash)
        external;
    /**
     * @dev return escrow owner hash
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return hash of escrow owner
     */
    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        returns (bytes32);

    /**
     * @dev return escrow data associated with an asset
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return all escrow data  @ _idxHash
     */
    function retrieveEscrowData(bytes32 _idxHash)
        external
        returns (escrowData memory);

    /**
     * @dev return EscrowDataLight
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return EscrowDataLight struct @ _idxHash
     */
    function retrieveEscrowDataLight(bytes32 _idxHash)
        external
        returns (escrowDataExtLight memory);

    /**
     * @dev return EscrowDataHeavy
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return EscrowDataHeavy struct @ _idxHash
     */
    function retrieveEscrowDataHeavy(bytes32 _idxHash)
        external
        returns (escrowDataExtHeavy memory);
}