/*-----------------------------------------------------------V0.6.8
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_BASIC.sol";
import "./PRUF_INTERFACES.sol";
import "./Imports/PullPayment.sol";
import "./Imports/ReentrancyGuard.sol";

contract ECR_CORE is BASIC {
    using SafeMath for uint256;

    struct escrowData {
        bytes32 controllingContractNameHash; //hash of the name of the controlling escrow contract
        bytes32 escrowOwnerAddressHash; //hash of an address designated as an executor for the escrow contract
        uint256 timelock;
    }

    struct escrowDataExtLight {
        //1 slot
        uint8 escrowData;
        uint8 u8_1;
        uint8 u8_2;
        uint8 u8_3;
        uint16 u16_1;
        uint16 u16_2;
        uint32 u32_1;
        address addr_1;
    }

    struct escrowDataExtHeavy {
        // 5 slots
        uint32 u32_2;
        uint32 u32_3;
        uint32 u32_4;
        address addr_2;
        bytes32 b32_1;
        bytes32 b32_2;
        uint256 u256_1;
        uint256 u256_2;
    }

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

    function _setEscrowDataLight(
        bytes32 _idxHash,
        escrowDataExtLight memory escrowDataLight
    ) internal whenNotPaused {
        ECR_MGR.setEscrowDataLight(
            _idxHash,
            escrowDataLight.escrowData,
            escrowDataLight.u8_1,
            escrowDataLight.u8_2,
            escrowDataLight.u8_3,
            escrowDataLight.u16_1,
            escrowDataLight.u16_2,
            escrowDataLight.u32_1,
            escrowDataLight.addr_1
        );
        //^^^^^^^effects^^^^^^^^^
    }

    function _setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy memory escrowDataHeavy
    ) internal whenNotPaused {
        ECR_MGR.setEscrowDataHeavy(
            _idxHash,
            escrowDataHeavy.u32_2,
            escrowDataHeavy.u32_3,
            escrowDataHeavy.u32_4,
            escrowDataHeavy.addr_2,
            escrowDataHeavy.b32_1,
            escrowDataHeavy.b32_2,
            escrowDataHeavy.u256_1,
            escrowDataHeavy.u256_2
        );
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev retrieves escrow data and returns escrow struct
     */
    function getEscrowData(bytes32 _idxHash)
        internal
        returns (escrowData memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowData memory escrow;
        //^^^^^^^effects^^^^^^^^^

        (
            escrow.controllingContractNameHash,
            escrow.escrowOwnerAddressHash,
            escrow.timelock
        ) = ECR_MGR.retrieveEscrowData(_idxHash);

        return (escrow);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves extended escrow data and returns escrowDataExtLight struct
     */
    function getEscrowDataLight(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtLight memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtLight memory escrowDataLight;
        //^^^^^^^effects^^^^^^^^^

        (
            escrowDataLight.escrowData,
            escrowDataLight.u8_1,
            escrowDataLight.u8_2,
            escrowDataLight.u8_3,
            escrowDataLight.u16_1,
            escrowDataLight.u16_2,
            escrowDataLight.u32_1,
            escrowDataLight.addr_1
        ) = ECR_MGR.retrieveEscrowDataLight(_idxHash);

        return (escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves extended escrow data and returns escrowDataExtHeavy struct
     */
    function getEscrowDataHeavy(bytes32 _idxHash)
        internal
        view
        returns (escrowDataExtHeavy memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtHeavy memory escrowDataHeavy;
        //^^^^^^^effects^^^^^^^^^

        (
            escrowDataHeavy.u32_2,
            escrowDataHeavy.u32_3,
            escrowDataHeavy.u32_4,
            escrowDataHeavy.addr_2,
            escrowDataHeavy.b32_1,
            escrowDataHeavy.b32_2,
            escrowDataHeavy.u256_1,
            escrowDataHeavy.u256_2
        ) = ECR_MGR.retrieveEscrowDataHeavy(_idxHash);

        return (escrowDataHeavy);
        //^^^^^^^interactions^^^^^^^^^
    }
}
