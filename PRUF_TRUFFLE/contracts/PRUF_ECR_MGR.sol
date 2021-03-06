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
 *  break escrow down into smaller mappings
 *
 *-----------------------------------------------------------------
 */
// CTS:EXAMINE provide a description of ECR_MGR
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_BASIC.sol";

contract ECR_MGR is BASIC {
    mapping(bytes32 => escrowData) private escrows;
    mapping(bytes32 => escrowDataExtLight) private EscrowDataLight;
    mapping(bytes32 => escrowDataExtHeavy) private EscrowDataHeavy;

    /*
    * // CTS:EXAMINE comment
    * // CTS:EXAMINE param
    * // CTS:EXAMINE return
    */
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

    /*
    * // CTS:EXAMINE comment
    * // CTS:EXAMINE param
    * // CTS:EXAMINE return
    */
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
     * // CTS:EXAMINE param
     * // CTS:EXAMINE param
     * // CTS:EXAMINE param
     * // CTS:EXAMINE param
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
        //Should never be neccessary:
        // delete escrows[_idxHash];
        // delete EscrowDataLight[_idxHash];
        // delete EscrowDataHeavy[_idxHash];

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
     * // CTS:EXAMINE param
     */
    function endEscrow(bytes32 _idxHash) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo =
            getContractInfo(_msgSender(), rec.assetClass);

        require(
            isEscrow(rec.assetStatus) == 170,
            "EM:EE: Asset !in escrow status"
        );
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:EE: Only contract with same name as setter can end escrow"
        );

        //^^^^^^^checks^^^^^^^^^

        delete escrows[_idxHash];
        delete EscrowDataLight[_idxHash];
        delete EscrowDataHeavy[_idxHash];
        //^^^^^^^effects^^^^^^^^^

        STOR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set data in EDL mapping
     * // CTS:EXAMINE param
     * // CTS:EXAMINE param
     * // CTS:EXAMINE add req section
     * Must be setter contract
     * Must be in escrow
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
            "EM:SEDL: Asset !in escrow status"
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
     * @dev Set data in EDH mapping
     * // CTS:EXAMINE param
     * // CTS:EXAMINE param
     * // CTS:EXAMINE add req section
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

        EscrowDataHeavy[_idxHash] = escrowDataHeavy; //set in EDH map
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Permissive removal of asset from escrow status after time-out
     * // CTS:EXAMINE param
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
        require( // do not allow escrows with escrow.data > 199 to be ended by this function //STATE UNREACHABLE CTS:PREFERRED
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
     * // CTS:EXAMINE param
     * // CTS:EXAMINE returns
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
     * // CTS:EXAMINE param
     * // CTS:EXAMINE returns
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
     * // CTS:EXAMINE param
     * // CTS:EXAMINE returns
     */
    function retrieveEscrowDataLight(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtLight memory)
    {
        return EscrowDataLight[_idxHash];
    }

    /*
     * @dev return EscrowDataHeavy @ IDX
     * // CTS:EXAMINE param
     * // CTS:EXAMINE returns
     */
    function retrieveEscrowDataHeavy(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtHeavy memory)
    {
        return EscrowDataHeavy[_idxHash];
    }
}
