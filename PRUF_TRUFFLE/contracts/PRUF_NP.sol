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
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";

contract NP is CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == APP_Address),
            "NP:MOD-IA: Custodial contract does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function _modStatus(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);

        require(
            (userType > 0) && (userType < 10),
            "NP:MS: User not auth in AC"
        );
        require(
            (_newAssetStatus != 7) &&
            (_newAssetStatus != 57) &&
            (_newAssetStatus != 58) &&
            (_newAssetStatus < 100),
            "NP:MS: Stat Rsrvd"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "NP:MS: Cannot place asset in unregistered, exported, or discarded status using modStatus"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NP:MS: Record in unregistered, exported, or discarded status"
        );
        require(
            (rec.assetStatus > 49) || (userType < 5),
            "NP:MS: Only usertype < 5 can change status < 49"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:MS: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation required.
     */
    function _setLostOrStolen(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);
        require(
            (userType > 0) && (userType < 10),
            "NP:SLS: user not auth in AC"
        );
        require(
            (rec.assetStatus > 49) ||
                ((_newAssetStatus < 50) && (userType < 5)),
            "NP:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:SLS: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setStolenOrLost(_idxHash, rec.assetStatus);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function _decCounter(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _decAmount
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint32)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);

        require(
            (userType > 0) && (userType < 10),
            "NP:DC: user not auth in AC"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NP:DC Record in unregistered, exported, or discarded status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:DC: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown - _decAmount;
        } else {
            rec.countDown = 0;
        }
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        return (rec.countDown);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs1 with confirmation
     */
    function _modIpfs1(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);
        require(
            (userType > 0) && (userType < 10),
            "NP:MI1: user not auth in AC"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NP:MI1: Record in unregistered, exported, or discarded status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:MI1: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     *     @dev Export FROM Custodial:
     */
    function exportAsset(bytes32 _idxHash, address _addr)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            (userType > 0) && (userType < 10),
            "NP:EA: user not auth in AC"
        );
        require( // require transferrable (51) status
            rec.assetStatus == 51,
            "NP:EA: Asset status must be 51 to export"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        //^^^^^^^effects^^^^^^^^^

        APP.transferAssetToken(_addr, _idxHash);
        writeRecord(_idxHash, rec);
        STOR.changeAC(_idxHash, AC_info.assetClassRoot);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }
}
