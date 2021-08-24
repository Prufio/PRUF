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
 *  TO DO
 *  Escrow manager holds and manipultes escrow data for sattelite contracts.
 *
 *-----------------------------------------------------------------
 */
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_BASIC.sol";

contract ECR_MGR is BASIC {
    mapping(bytes32 => escrowData) private escrows;
    mapping(bytes32 => escrowDataExtLight) private EscrowDataLight;
    mapping(bytes32 => escrowDataExtHeavy) private EscrowDataHeavy;

    /**
     * Checks to see if an asset is in escrow status or not
     * @param _assetStatus - status number (see docs)
     * @return 170 or 0 (true or false)
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
    ) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            _msgSender(),
            rec.node
        );
        bytes32 controllingContractNameHash = contractInfo.nameHash;

        require(
            contractInfo.contractType == 3,
            "EM:SE: Escrow can only be set by an authorized escrow contract"
        );
        //^^^^^^^checks^^^^^^^^^
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

    /**
     * @dev remove asset from escrow
     * @param _idxHash - hash of asset information created by frontend inputs
     */
    function endEscrow(bytes32 _idxHash) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            _msgSender(),
            rec.node
        );

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

    /**
     * @dev Sets data in the Escrow Data Light mapping
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _escrowDataLight - struct of data associated with light load escrows
     */
    function setEscrowDataLight(
        bytes32 _idxHash,
        escrowDataExtLight calldata _escrowDataLight
    ) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            _msgSender(),
            rec.node
        );

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

    /**
     * @dev Sets data in the Escrow Data Heavy mapping
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param escrowDataHeavy - struct of data associated with heavy load escrows
     */
    function setEscrowDataHeavy(
        bytes32 _idxHash,
        escrowDataExtHeavy calldata escrowDataHeavy
    ) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            _msgSender(),
            rec.node
        );

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

    /**
     * @dev Permissive removal of asset from escrow status after time-out (no special qualifiers to end expired escrow)
     * @param _idxHash - hash of asset information created by frontend inputs
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
        require( // do not allow escrows with escrow.data > 199 to be ended by this function //STATE UNREACHABLE PREFERRED
            EscrowDataLight[_idxHash].escrowData < 200,
            "EM:PEE: Escrow not endable with permissiveEndEscrow"
        );
        //^^^^^^^checks^^^^^^^^^

        delete escrows[_idxHash];
        //^^^^^^^effects^^^^^^^^^

        STOR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev return escrow owner hash
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return hash of escrow owner
     */
    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        view
        returns (bytes32)
    {
        //^^^^^^^checks^^^^^^^^^

        return escrows[_idxHash].escrowOwnerAddressHash;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev return escrow data associated with an asset
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return all escrow data  @ _idxHash
     */
    function retrieveEscrowData(bytes32 _idxHash)
        external
        view
        returns (escrowData memory)
    {
        //^^^^^^^checks^^^^^^^^^

        return escrows[_idxHash];
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev return EscrowDataLight
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return EscrowDataLight struct @ _idxHash
     */
    function retrieveEscrowDataLight(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtLight memory)
    {
        //^^^^^^^checks^^^^^^^^^

        return EscrowDataLight[_idxHash];
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev return EscrowDataHeavy
     * @param _idxHash - hash of asset information created by frontend inputs
     *
     * @return EscrowDataHeavy struct @ _idxHash
     */
    function retrieveEscrowDataHeavy(bytes32 _idxHash)
        external
        view
        returns (escrowDataExtHeavy memory)
    {
        //^^^^^^^checks^^^^^^^^^

        return EscrowDataHeavy[_idxHash];
        //^^^^^^^effects^^^^^^^^^
    }
}
