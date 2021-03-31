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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";

contract APP_NC is CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == _msgSender()), //_msgSender() is token holder
            "ANC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------
    /*
     * @dev Create a  newRecord with description
     */
    function newRecordWithDescription(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart,
        bytes32 _Ipfs1a,
        bytes32 _Ipfs1b
    ) external nonReentrant whenNotPaused {
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is token holder
            "ANC:NRWD: Caller !PRuF_ID holder"
        );
        //^^^^^^^Checks^^^^^^^^^

        Record memory rec;
        rec.Ipfs1a = _Ipfs1a;
        rec.Ipfs1b = _Ipfs1b;
        //^^^^^^^effects^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        writeRecordIpfs1(_idxHash, rec);
        deductServiceCosts(_assetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Create a new record
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) external nonReentrant whenNotPaused {
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is token holder
            "ANC:NR: Caller !PRuF_ID holder"
        );
        //^^^^^^^Checks^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        deductServiceCosts(_assetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Import a record into a new asset class
     */
    function importAsset(bytes32 _idxHash, uint32 _newAssetClass)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(_newAssetClass);

        require(rec.assetStatus == 70, "ANC:IA: Asset !exported");
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "ANC:IA: !Change AC to new root"
        );
        require(
                (AC_info.managementType < 5),
                "ANC:IA: Contract does not support management types > 4 or AC is locked"
        );
        if ((AC_info.managementType == 1) || (AC_info.managementType == 2)) {
            require(
                (AC_TKN.ownerOf(_newAssetClass) == _msgSender()),
                "ANC:IA: Cannot create asset in AC mgmt type 1||2 - caller does not hold AC token"
            );
        }
        if (AC_info.managementType == 3) {
            require(
                AC_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _newAssetClass
                ) == 1,
                "ANC:IA: Cannot create asset - caller address !authorized"
            );
        }
        if (AC_info.managementType == 4) {
            require(
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "ANC:IA: Caller !trusted ID holder"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 52;
        //^^^^^^^effects^^^^^^^^^

        STOR.changeAC(_idxHash, _newAssetClass);
        writeRecord(_idxHash, rec);
        deductServiceCosts(_newAssetClass, 1);
        //^^^^^^^interactions^^^^^^^^^^^^
    }

    /*
     * @dev Modify record.Ipfs2 with confirmation CTS:EXAMINE comment
     */
    function addIpfs2Note(bytes32 _idxHash, bytes32 _Ipfs2a, bytes32 _Ipfs2b)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        require( //STATE UNREACHABLE
            needsImport(rec.assetStatus) == 0,
            "ANC:I2: Record In Transferred, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2a = _Ipfs2a;
        rec.Ipfs2b = _Ipfs2b;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);
        deductServiceCosts(rec.assetClass, 3);
        //^^^^^^^interactions^^^^^^^^^
    }
}
