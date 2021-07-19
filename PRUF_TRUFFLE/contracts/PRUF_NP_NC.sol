/*--------------------------------------------------------PRüF0.8.0
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

 //CTS:EXAMINE quick explainer for the contract

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";

contract NP_NC is CORE {

    /*
     * @dev Verify user credentials
     * //CTS:EXAMINE param
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

    /*
     * @dev Modify rgtHash (like forceModify)
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE returns
     * //CTS:EXAMINE create req section
     * must be tokenholder or A_TKN
     *
     */
    function _changeRgt(bytes32 _idxHash, bytes32 _newRgtHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (bytes32)
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

        return _idxHash;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Export - sets asset to status 70 (importable) //CTS:EXAMINE we should maybe describe this better
     * //CTS:EXAMINE param
     */
    function _exportNC(bytes32 _idxHash)
        external
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            rec.assetStatus == 51,
            "NPNC:EX: Must be in transferrable status (51)"
        );
        require(
            (AC_info.managementType < 6),
            "NPNC:EX: Contract does not support management types > 5 or AC is locked"
        );
        if ((AC_info.managementType == 1) || (AC_info.managementType == 5)) {
            require( //holds AC token if AC is restricted --------DPS TEST ---- NEW
                (AC_TKN.ownerOf(rec.assetClass) == _msgSender()),
                "NPNC:EX: Restricted from exporting assets from this AC - does not hold ACtoken"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        //STOR.changeAC(_idxHash, AC_info.assetClassRoot); //set assetClass to the root AC of the assetClass //CTS:EXAMINE untested dont delete
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev exportTo - sets asset to status 70 (importable) //CTS:EXAMINE we should maybe describe this better
     * //CTS:EXAMINE param
     */
    function _exportTo(bytes32 _idxHash, uint32 _newAssetClass)
        external
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            rec.assetStatus == 51,
            "NPNC:EX: Must be in transferrable status (51)"
        );
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "NPNC:EX: Cannot change AC to new root"
        );
        require(
            (AC_info.managementType < 6),
            "NPNC:EX: Contract does not support management types > 5 or AC is locked"
        );
        if ((AC_info.managementType == 1) || (AC_info.managementType == 5)) {
            require( //holds AC token if AC is restricted --------DPS TEST ---- NEW
                (AC_TKN.ownerOf(rec.assetClass) == _msgSender()),
                "NPNC:EX: Restricted from exporting assets from this AC - does not hold ACtoken"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        //STOR.changeAC(_idxHash, AC_info.assetClassRoot); //set assetClass to the root AC of the assetClass //CTS:EXAMINE untested dont delete
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE returns
     */
    function _modStatus(bytes32 _idxHash, uint8 _newAssetStatus)
        public
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
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

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation required. //CTS:EXAMINE confirmation?
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE returns
     */
    function _setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
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

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required //CTS:EXAMINE confirmation?
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE returns
     */
    function _decCounter(bytes32 _idxHash, uint32 _decAmount)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint32)
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
        return (rec.countDown);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs1a with confirmation //CTS:EXAMINE confirmation?
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE returns
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
