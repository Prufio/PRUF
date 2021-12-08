/*--------------------------------------------------------PRüF0.8.8
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
 * PRUF APP_NC
 * Application layer contract for noncustodial asset management.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";

contract APP_NC is CORE {
    //---------------------------------------Modifiers-------------------------------

    /**
     * @dev Verify user credentials
     * @param _idxHash - ID of asset token to be verified
     * Originating Address:
     *      holds asset token at idxHash
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            A_TKN.ownerOf(tokenId) == _msgSender(), //_msgSender() is token holder
            "ANC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    //---------------------------------------External Functions-------------------------------

    /**
     * @dev Create a newRecord with description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _mutableStorage1 - field for external asset data
     * @param _mutableStorage2 - field for external asset data
     * @param _URIsuffix - Hash of external CAS from URI
     */
    function newRecordWithDescription(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2,
        string calldata _URIsuffix
    ) external nonReentrant whenNotPaused {
        bytes32 idxHash = keccak256(abi.encodePacked(_idxHash, _node)); //hash idxRaw with node to get idxHash/
        //^^^^^^^Checks^^^^^^^^^

        Record memory rec;
        rec.mutableStorage1 = _mutableStorage1;
        rec.mutableStorage2 = _mutableStorage2;

        createRecord(idxHash, _rgtHash, _node, _countDownStart, _URIsuffix);
        writeMutableStorage(idxHash, rec);
        deductServiceCosts(_node, 1);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Create a newRecord with permanent description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     * @param _URIsuffix - Hash of external CAS from URI
     */
    function newRecordWithNote(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2,
        string calldata _URIsuffix
    ) external nonReentrant whenNotPaused {
        bytes32 idxHash = keccak256(abi.encodePacked(_idxHash, _node)); //hash idxRaw with node to get idxHash
        //^^^^^^^Checks^^^^^^^^^

        Record memory rec;
        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;

        createRecord(idxHash, _rgtHash, _node, _countDownStart, _URIsuffix);
        writeNonMutableStorage(idxHash, rec);
        deductServiceCosts(_node, 1);
    }

    /**
     * @dev Create a newRecord
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _URIsuffix - Hash of external CAS from URI
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        string calldata _URIsuffix
    ) external nonReentrant whenNotPaused {
        bytes32 idxHash = keccak256(abi.encodePacked(_idxHash, _node)); //hash idxRaw with node to get idxHash
        //^^^^^^^Checks^^^^^^^^^

        createRecord(idxHash, _rgtHash, _node, _countDownStart, _URIsuffix);
        deductServiceCosts(_node, 1);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev record NonMutableStorage data
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function addNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:ANMS: Record In Transferred, exported, or discarded status"
        );

        require( //caller must be nodeholder/permissioned or sw2+tokenholder and caller holds the token
            (NODE_STOR.getSwitchAt(rec.node, 2) == 1) && //sw2 is set
                (A_TKN.ownerOf(uint256(_idxHash)) == _msgSender()), //CTS:EXAMINE redundant, checks in isAuthorized
            "ANC:ANMS:User not permissioned to add NMS or does not hold asset"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;

        writeNonMutableStorage(_idxHash, rec);
        deductServiceCosts(rec.node, 3);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Update NonMutableStorage with data priovided by nodeholder
     * only works if asset is in stat201 (STOR enforces this). Conceptually,
     * nodeholder would deploy a contract to update NMS for assets. that contract would
     * hold the node or be auth100. TH would authorize the contract for their token, and
     * call the update function in that contract. The update function would set stat201, then
     * call this function to update the NMS to the new value, then unset stat201.
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function updateNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external nonReentrant whenNotPaused {
        A_TKN.isApprovedOrOwner(_msgSender(), uint256(_idxHash)); //throws if not approved (or owner)

        Record memory rec = getRecord(_idxHash);
        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:ANMN: Record In Transferred, exported, or discarded status"
        );

        require( // caller is node authorized
            (NODE_TKN.ownerOf(rec.node) == _msgSender()) || //caller holds the NT
                (NODE_STOR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    rec.node
                ) == 100), //or is auth type 100 in node
            "AT:SU:Caller !NTH or authorized(100)"
        );

        //^^^^^^^checks^^^^^^^^^

        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;

        writeNonMutableStorage(_idxHash, rec);
        deductServiceCosts(rec.node, 3);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Modify rgtHash (like forceModify)
     * @param _idxHash idx of asset to Modify
     * @param _newRgtHash rew rgtHash to apply
     */
    function changeRgt(bytes32 _idxHash, bytes32 _newRgtHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        require(
            isLostOrStolen(rec.assetStatus) == 0,
            "ANC:CR: Cannot modify asset in lost or stolen status"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:CR: Cannot modify asset in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _newRgtHash;

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.node, 6);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Modify **Record**.assetStatus with confirmation required
     * @param _idxHash idx of asset to Modify
     * @param _newAssetStatus Updated status
     */
    function modifyStatus(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(
            (_newAssetStatus > 49) && (rec.assetStatus > 49),
            "ANC:MS: Only custodial usertype can set or change status < 50"
        );
        require(
            (_newAssetStatus != 57) &&
                (_newAssetStatus != 58) &&
                (_newAssetStatus < 100),
            "ANC:MS: Status Reserved"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "ANC:MS: Cannot place asset in unregistered, exported, or discarded status using modifyStatus"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:MS: Asset is in an unregistered, exported, or discarded status."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;

        deductServiceCosts(rec.node, 5);
        writeRecord(_idxHash, rec);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation of matching rgthash required.
     * @param _idxHash idx of asset to Modify
     * @param _newAssetStatus Updated status
     */
    function setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(
            (_newAssetStatus > 49) && (rec.assetStatus > 49),
            "ANC:SLS: Only custodial usertype can set or change status < 50"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:SLS: Transferred,exported,or discarded asset cannot be set to lost or stolen"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setLostOrStolen(_idxHash, rec.assetStatus);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Decrement **Record**.countdown.
     * @param _idxHash index hash of asset to modify
     * @param _decAmount Amount to decrement
     */
    function decrementCounter(bytes32 _idxHash, uint32 _decAmount)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:DC: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown - _decAmount;
        } else {
            rec.countDown = 0;
        }

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.node, 7);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Modify **Record**.mutableStorage1 with confirmation of matching rgthash required.
     * @param _idxHash idx of asset to Modify
     * @param _mutableStorage1 content addressable storage address part 1
     * @param _mutableStorage2 content addressable storage address part 2
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);

        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:MMS: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.mutableStorage1 = _mutableStorage1;
        rec.mutableStorage2 = _mutableStorage2;

        writeMutableStorage(_idxHash, rec);
        deductServiceCosts(rec.node, 8);
        //^^^^^^^effects^^^^^^^^^
    }
}
