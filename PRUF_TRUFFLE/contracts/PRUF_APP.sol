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
 *
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";

contract APP is CORE {
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    modifier isAuthorized(bytes32 _idxHash) override {
        //require that user is authorized and token is held by contract
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == address(this)),
            "A:MOD-IA: APP contract !token holder"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Wrapper for newRecord
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) external nonReentrant whenNotPaused {
        uint8 userType = getCallingUserType(_assetClass);

        require((userType > 0) && (userType < 10), "A:NR: User not auth in AC");
        require(userType < 5, "A:NR: User not authorized to create records");
        //^^^^^^^checks^^^^^^^^^

        //^^^^^^^effects^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        deductServiceCosts(_assetClass, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev import **Record** (no confirmation required -
     * posessor is considered to be owner. sets rec.assetStatus to 0.
     */
    function importAsset(
        bytes32 _idxHash,
        bytes32 _newRgtHash,
        uint32 _newAssetClass
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash) //contract holds token (user sent to contract)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(_newAssetClass);

        require(userType < 3, "A:IA: User not authorized to import assets");
        require((userType > 0) && (userType < 10), "A:IA: User not auth in AC");
        require(
            (rec.assetStatus == 5) ||
                (rec.assetStatus == 55) ||
                (rec.assetStatus == 70),
            "A:IA: Only Transferred or exported assets can be imported"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.forceModCount = 170;
        rec.assetStatus = 0;
        rec.rightsHolder = _newRgtHash;
        //^^^^^^^effects^^^^^^^^^

        STOR.changeAC(_idxHash, _newAssetClass);
        writeRecord(_idxHash, rec);
        deductServiceCosts(_newAssetClass, 1);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.rightsHolder without confirmation required
     */
    function forceModRecord(bytes32 _idxHash, bytes32 _rgtHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);

        require(userType == 1, "A:FMR: User not auth in AC");
        require(
            isLostOrStolen(rec.assetStatus) == 0,
            "A:FMR: Asset marked L/S"
        );
        require( //IMPOSSIBLE TO THROW REVERTS IN REQ1 CTS:PREFERRED
            needsImport(rec.assetStatus) == 0,
            "A:FMR: Asset needs re-imported"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.forceModCount = 170;
        rec.numberOfTransfers = 170;
        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.assetClass, 6);

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Transfer Rights to new rightsHolder with confirmation
     */
    function transferAsset(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _newrgtHash
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);

        require((userType > 0) && (userType < 10), "A:TA: User not auth in AC");
        require(
            (rec.assetStatus > 49) || (userType < 5),
            "A:TA:Only usertype < 5 can change status < 50"
        );
        require(
            (rec.assetStatus == 1) || (rec.assetStatus == 51),
            "A:TA:Asset status != transferrable"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "A:TA:Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.numberOfTransfers = 170;

        if (_newrgtHash == 0x0) {
            //set to transferred status
            rec.assetStatus = 5;
            _newrgtHash = B320xF_;
        }

        rec.rightsHolder = _newrgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductServiceCosts(rec.assetClass, 2);

        return (170);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     */
    function addIpfs2Note(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _Ipfs2a,
        bytes32 _Ipfs2b
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);

        require((userType > 0) && (userType < 10), "A:I2: User not auth in AC");

        require( //IMPOSSIBLE TO THROW REVERTS IN REQ1 CTS:PREFERRED
            needsImport(rec.assetStatus) == 0,
            "A:I2: Asset needs re-imported"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "A:I2: Rightsholder does not match supplied data"
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
