/*-----------------------------------------------------------V0.7.0
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
 *  break escrow down into smaller mappings
 *
 *-----------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_BASIC.sol";
import "./Imports/math/Safemath.sol";

contract ECR_MGR is BASIC {
    using SafeMath for uint256;

    struct escrowData { //3 slots
        bytes32 controllingContractNameHash; //hash of the name of the controlling escrow contract
        bytes32 escrowOwnerAddressHash; //hash of an address designated as an executor for the escrow contract
        uint256 timelock;
    }

    struct escrowDataExtLight {  //1 slot
        uint8 escrowData;
        uint8 u8_1;
        uint8 u8_2;
        uint8 u8_3;
        uint16 u16_1;
        uint16 u16_2;
        uint32 u32_1;
        address addr_1;
    }

    struct escrowDataExtHeavy { // 5 slots
        uint32  u32_2;
        uint32  u32_3;
        uint32  u32_4;
        address addr_2;
        bytes32 b32_1;
        bytes32 b32_2;
        uint256 u256_1;
        uint256 u256_2;
    }

    mapping(bytes32 => escrowData) private escrows;
    mapping(bytes32 => escrowDataExtLight) private EscrowDataLight;
    mapping(bytes32 => escrowDataExtHeavy) private EscrowDataHeavy;

    function isLostOrStolen(uint8 _assetStatus) private pure returns (uint8) {
        if (
            (_assetStatus != 3) &&
            (_assetStatus != 4) &&
            (_assetStatus != 53) &&
            (_assetStatus != 54)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    function isEscrow(uint8 _assetStatus) private pure returns (uint8) {
        if (
            (_assetStatus != 6) &&
            (_assetStatus != 50) &&
            (_assetStatus != 56) &&
            (_assetStatus != 60)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    /*
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     */
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock
    ) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            msg.sender,
            rec.assetClass
        );
        bytes32 controllingContractNameHash = contractInfo.nameHash;

        require(
            contractInfo.contractType == 3,
            "EM:SE: Escrow can only be set by an authorized escrow contract"
        );
        //^^^^^^^checks^^^^^^^^^
        delete escrows[_idxHash];

        escrows[_idxHash]
            .controllingContractNameHash = controllingContractNameHash;
        escrows[_idxHash].escrowOwnerAddressHash = _escrowOwnerAddressHash;
        escrows[_idxHash].timelock = _timelock;
        //^^^^^^^effects^^^^^^^^^

        STOR.setEscrow(_idxHash, _newAssetStatus);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status
     */
    function endEscrow(bytes32 _idxHash) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            msg.sender,
            rec.assetClass
        );

        require(
            isEscrow(rec.assetStatus) == 170,
            "EM:EE:Asset not in escrow status"
        );
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:EE:Only contract with same name as setter can end escrow"
        );

        //^^^^^^^checks^^^^^^^^^

        delete escrows[_idxHash];
        //^^^^^^^effects^^^^^^^^^

        STOR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set data in EDL mapping
     * Must be setter contract
     * Must be in  escrow
     */
    function setEscrowDataLight(
        bytes32 _idxHash,
        uint8 _escrowData,
        uint8 _u8_1,
        uint8 _u8_2,
        uint8 _u8_3,
        uint16 _u16_1,
        uint16 _u16_2,
        uint32 _u32_1,
        address _addr_1) 
        external nonReentrant whenNotPaused {

        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            msg.sender,
            rec.assetClass
        );

        require(
            isEscrow(rec.assetStatus) == 170,
            "EM:SEDL:Asset not in escrow status"
        );
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:SEDL:Only contract with same name as setter can modify escrow data"
        );
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtLight memory escrowDataLight;

        escrowDataLight.escrowData = _escrowData;
        escrowDataLight.u8_1 = _u8_1;
        escrowDataLight.u8_2 = _u8_2;
        escrowDataLight.u8_3 = _u8_3;
        escrowDataLight.u16_1 = _u16_1;
        escrowDataLight.u16_2 = _u16_2;
        escrowDataLight.u32_1 = _u32_1;
        escrowDataLight.addr_1 = _addr_1;

        EscrowDataLight[_idxHash] = escrowDataLight; //set in EDL map
        //^^^^^^^effects^^^^^^^^^
    }


    /*
     * @dev Set data in EDL mapping
     * Must be setter contract
     * Must be in  escrow
     */
    function setEscrowDataHeavy(
        bytes32 _idxHash,
        uint32 _u32_2,
        uint32 _u32_3,
        uint32 _u32_4,
        address _addr_2,
        bytes32 _b32_1,
        bytes32 _b32_2,
        uint256 _u256_1,
        uint256 _u256_2) 
        external nonReentrant whenNotPaused {

        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            msg.sender,
            rec.assetClass
        );

        require(
            isEscrow(rec.assetStatus) == 170,
            "EM:SEDL:Asset not in escrow status"
        );
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:SEDL:Only contract with same name as setter can modify escrow data"
        );
        //^^^^^^^checks^^^^^^^^^

        escrowDataExtHeavy memory escrowDataHeavy;
            escrowDataHeavy.u32_2 = _u32_2;
            escrowDataHeavy.u32_3 = _u32_3;
            escrowDataHeavy.u32_4 = _u32_4;
            escrowDataHeavy.addr_2 = _addr_2;
            escrowDataHeavy.b32_1 = _b32_1;
            escrowDataHeavy.b32_2 = _b32_2;
            escrowDataHeavy.u256_1 = _u256_1;
            escrowDataHeavy.u256_2 = _u256_2;

        EscrowDataHeavy[_idxHash] = escrowDataHeavy; //set in EDL map
        //^^^^^^^effects^^^^^^^^^
    }



    /*
     * @dev Permissive removal of asset from escrow status after time-out
     */
    function permissiveEndEscrow(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
    {
        require(
            escrows[_idxHash].timelock < block.timestamp,
            "EM:PEE:Escrow not expired"
        );
        require( // do not allow escrows with escrow.data > 199 to be ended by this function     //STATE UNREACHABLE CTS:PREFERRED
            EscrowDataLight[_idxHash].escrowData < 200,
            "EM:PEE:Escrow not endable with permissiveEndEscrow"
        );
        //^^^^^^^checks^^^^^^^^^

        delete escrows[_idxHash];
        //^^^^^^^effects^^^^^^^^^

        STOR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev return escrow OwnerHash
     */
    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        view
        returns (bytes32)
    {
        return escrows[_idxHash].escrowOwnerAddressHash;
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev return escrow data @ IDX
     */
    function retrieveEscrowData(bytes32 _idxHash)
        external
        view
        returns (
            bytes32,
            bytes32,
            uint256
        )
    {
        escrowData memory escrow = escrows[_idxHash];
        return (
            escrow.controllingContractNameHash,
            escrow.escrowOwnerAddressHash,
            escrow.timelock
        );
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev return EscrowDataLight @ IDX
     */
    function retrieveEscrowDataLight(bytes32 _idxHash)
        external
        view
        returns (
            uint8,
            uint8,
            uint8,
            uint8,
            uint16,
            uint16,
            uint32,
            address
            )
    {
        escrowDataExtLight memory escrowDataLight = EscrowDataLight[_idxHash];

        return (
            escrowDataLight.escrowData,
            escrowDataLight.u8_1,
            escrowDataLight.u8_2,
            escrowDataLight.u8_3,
            escrowDataLight.u16_1,
            escrowDataLight.u16_2,
            escrowDataLight.u32_1,
            escrowDataLight.addr_1
        );
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev return EscrowDataHeavy @ IDX
     */
    function retrieveEscrowDataHeavy(bytes32 _idxHash)
        external
        view
        returns (
            uint32,
            uint32,
            uint32,
            address,
            bytes32,
            bytes32,
            uint256,
            uint256
            )
    {
        escrowDataExtHeavy memory escrowDataHeavy = EscrowDataHeavy[_idxHash];
        return (
            escrowDataHeavy.u32_2,
            escrowDataHeavy.u32_3,
            escrowDataHeavy.u32_4,
            escrowDataHeavy.addr_2,
            escrowDataHeavy.b32_1,
            escrowDataHeavy.b32_2,
            escrowDataHeavy.u256_1,
            escrowDataHeavy.u256_2
        );
        //^^^^^^^checks/interactions^^^^^^^^^
    }
}
