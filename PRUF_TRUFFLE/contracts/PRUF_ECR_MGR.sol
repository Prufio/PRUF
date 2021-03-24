/*--------------------------------------------------------PRüF0.8.0
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
pragma solidity ^0.8.0;

import "./PRUF_BASIC.sol";

contract ECR_MGR is BASIC {
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
        ContractDataHash memory contractInfo =
            getContractInfo(_msgSender(), rec.assetClass);
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
        ContractDataHash memory contractInfo =
            getContractInfo(_msgSender(), rec.assetClass);

        require(
            isEscrow(rec.assetStatus) == 170,
            "EM:EE: Asset not in escrow status"
        );
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:EE: Only contract with same name as setter can end escrow"
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
        escrowDataExtLight calldata _escrowDataLight
    ) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo =
            getContractInfo(_msgSender(), rec.assetClass);

        require(
            isEscrow(rec.assetStatus) == 170,
            "EM:SEDL: Asset not in escrow status"
        );
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:SEDL: Only contract with same name as setter can modify escrow data"
        );
        //^^^^^^^checks^^^^^^^^^

        EscrowDataLight[_idxHash] = _escrowDataLight; //set in EDL map
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set data in EDL mapping
     * Must be setter contract
     * Must be in  escrow
     */
    function setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy calldata escrowDataHeavy
    ) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo =
            getContractInfo(_msgSender(), rec.assetClass);

        require(
            isEscrow(rec.assetStatus) == 170,
            "EM:SEDL: Asset not in escrow status"
        );
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:SEDL: Only contract with same name as setter can modify escrow data"
        );
        //^^^^^^^checks^^^^^^^^^

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
            "EM:PEE: Escrow not expired"
        );
        require( // do not allow escrows with escrow.data > 199 to be ended by this function     //STATE UNREACHABLE CTS:PREFERRED
            EscrowDataLight[_idxHash].escrowData < 200,
            "EM:PEE: Escrow not endable with permissiveEndEscrow"
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
        returns (escrowData memory)
    {
        return escrows[_idxHash];
    }

    /*
     * @dev return EscrowDataLight @ IDX
     */
    function retrieveEscrowDataLight(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtLight memory)
    {
        return EscrowDataLight[_idxHash];
    }

    function retrieveEscrowDataHeavy(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtHeavy memory)
    {
        return EscrowDataHeavy[_idxHash];
    }
}
