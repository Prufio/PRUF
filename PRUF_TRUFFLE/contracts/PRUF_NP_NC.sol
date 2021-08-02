/**--------------------------------------------------------PRüF0.8.6
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
 *  TO DO
 *  NonCustodial protocol functions
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";

contract NP_NC is CORE {
    /**
     * @dev Verify user credentials
     * @param _idxHash idx of asset to check
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == _msgSender()), //_msgSender() is token holder
            "NPNC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Modify rgtHash (like forceModify)
     * @param _idxHash idx of asset to Modify
     * @param _newRgtHash rew rgtHash to apply
     *
     */
    function _changeRgt(bytes32 _idxHash, bytes32 _newRgtHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        require(
            isLostOrStolen(rec.assetStatus) == 0,
            "NPNC:CR: Cannot modify asset in lost or stolen status"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:CR: Cannot modify asset in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _newRgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.assetClass, 6);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev exportTo - sets asset to status 70 (importable) and defines the AC that the item can be imported into
     * @param _idxHash idx of asset to Modify
     * @param _exportTo AC target for export
     */
    //DPS:TEST
    function _exportAssetTo(bytes32 _idxHash, uint32 _exportTo)
        external
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Node memory node_info = getACinfo(rec.assetClass);

        require(
            (rec.assetStatus == 51) || (rec.assetStatus == 70), //DPS:check
            "NPNC:EXT: Must be in transferrable status (51)"
        );
        require(
            NODE_MGR.isSameRootAC(_exportTo, rec.assetClass) == 170,
            "NPNC:EXT: Cannot change AC to new root"
        );
        require(
            (node_info.managementType < 6),
            "NPNC:EXT: Contract does not support management types > 5 or AC is locked"
        );
        if ((node_info.managementType == 1) || (node_info.managementType == 5)) {
            require( //holds AC token if AC is restricted --------DPS:TEST ---- NEW
                (NODE_TKN.ownerOf(rec.assetClass) == _msgSender()),
                "NPNC:EXT: Restricted from exporting assets from this AC - does not hold ACtoken"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        rec.int32temp = _exportTo; //set permitted AC for import
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify **Record**.assetStatus with confirmation required
     * @param _idxHash idx of asset to Modify
     * @param _newAssetStatus Updated status
     */
    function _modStatus(bytes32 _idxHash, uint8 _newAssetStatus)
        public
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(
            (_newAssetStatus > 49) && (rec.assetStatus > 49),
            "NPNC:SLS: Only custodial usertype can set or change status < 50"
        );
        require(
            (_newAssetStatus != 57) &&
                (_newAssetStatus != 58) &&
                (_newAssetStatus < 100),
            "NPNC:MS: Stat Rsrvd"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "NPNC:MS: Cannot place asset in unregistered, exported, or discarded status using modStatus"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:MS: Asset is in an unregistered, exported, or discarded status."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^
        deductServiceCosts(rec.assetClass, 5);
        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation of matching rgthash required.
     * @param _idxHash idx of asset to Modify
     * @param _newAssetStatus Updated status
     */
    function _setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(
            (_newAssetStatus > 49) && (rec.assetStatus > 49),
            "NPNC:SLS: Only custodial usertype can set or change status < 50"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:SLS: Transferred,exported,or discarded asset cannot be set to lost or stolen"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setLostOrStolen(_idxHash, rec.assetStatus);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Decrement **Record**.countdown with confirmation of matching rgthash required.
     * @param _idxHash idx of asset to Modify
     * @param _decAmount Amount to decrement
     */
    function _decCounter(bytes32 _idxHash, uint32 _decAmount)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:DC: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown - _decAmount;
        } else {
            rec.countDown = 0;
        }
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.assetClass, 7);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify **Record**.Ipfs1a with confirmation of matching rgthash required.
     * @param _idxHash idx of asset to Modify
     * @param _Ipfs1a content addressable storage address part 1
     * @param _Ipfs1b content addressable storage address part 2
     */
    function _modIpfs1(
        bytes32 _idxHash,
        bytes32 _Ipfs1a,
        bytes32 _Ipfs1b
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);

        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:MI1: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1a = _Ipfs1a;
        rec.Ipfs1b = _Ipfs1b;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);
        deductServiceCosts(rec.assetClass, 8);
        //^^^^^^^interactions^^^^^^^^^
    }
}
