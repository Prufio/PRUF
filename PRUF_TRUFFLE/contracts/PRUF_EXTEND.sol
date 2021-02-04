/*--------------------------------------------------------PRuF0.7.1
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
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract EXTEND is CORE {
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    modifier isAuthorized(bytes32 _idxHash) override {
        //require that user is authorized and token is held by contract
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == address(this)),
            "A:MOD-IA: APP contract does not hold token"
        );
        _;
    }

    modifier isTokenHolder(uint256 _tokenID, address _tokenContract) {
        //require that user holds token @ ID-Contract
        require(
            (IERC721(_tokenContract).ownerOf(_tokenID) == _msgSender()),
            "A:MOD-IA: caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Wrapper for newRecord
     */
    function decorate721(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        //require((userType > 0) && (userType < 10), "A:NR: User not auth in AC");
        //require(userType < 5, "A:NR: User not authorized to create records");
        //^^^^^^^checks^^^^^^^^^

        //bytes32 userHash = keccak256(abi.encodePacked(_msgSender()));
        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) {
            createRecordOnly(
                idxHash,
                _rgtHash,
                _assetClass,
                rec.countDownStart
            );
        } else {
            createRecordOnly(idxHash, _rgtHash, _assetClass, _countDownStart);
        }
        deductServiceCosts(_assetClass, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.assetStatus 
     */
    function _modStatus(
        uint256 _tokenID,
        address _tokenContract,
        uint8 _newAssetStatus
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
        returns (uint8)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);

        require(
            (_newAssetStatus != 7) &&
                (_newAssetStatus != 57) &&
                (_newAssetStatus != 58) &&
                (_newAssetStatus < 100),
            "E:MS: Stat Rsrvd"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "E:MS: Cannot place asset in unregistered, exported, or discarded status using modStatus"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "E:MS: Record in unregistered, exported, or discarded status"
        );
        require(
            (rec.assetStatus > 49),
            "E:MS: cannot change status < 49"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }


    /*
     * @dev Decrement **Record**.countdown
     */
    function _decCounter(
        uint256 _tokenID,
        address _tokenContract,
        uint32 _decAmount
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
        returns (uint32)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);

        require(
            needsImport(rec.assetStatus) == 0,
            "E:DC Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown - _decAmount;
        } else {
            rec.countDown = 0;
        }
        //^^^^^^^effects^^^^^^^^^

        writeRecord(idxHash, rec);
        deductServiceCosts(rec.assetClass, 7); //------------------------------DPS:TEST--NEW
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs1
     */
    function _modIpfs1(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _IpfsHash
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
        returns (bytes32)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        require(
            needsImport(rec.assetStatus) == 0,
            "E:MI1: Record in unregistered, exported, or discarded status"
        );

        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(idxHash, rec);
        deductServiceCosts(rec.assetClass, 8); //------------------------------DPS:TEST--NEW
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev import **Record** (no confirmation required -
     * posessor is considered to be owner. sets rec.assetStatus to 0.
     */
    function importAsset(
        uint256 _tokenID,
        address _tokenContract,
        uint32 _newAssetClass
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
        returns (uint8)
    {
         bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);

        require(rec.assetStatus == 70, "ANC:IA: Asset not exported");
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "ANC:IA:Cannot change AC to new root"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 52;
        //^^^^^^^effects^^^^^^^^^

        STOR.changeAC(idxHash, _newAssetClass);
        writeRecord(idxHash, rec);
        deductServiceCosts(_newAssetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2
     */
    function addIpfs2Note(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _IpfsHash
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
        returns (bytes32)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);

        require((userType > 0) && (userType < 10), "E:I2: User not auth in AC");

        require( //IMPOSSIBLE TO THROW REVERTS IN REQ1 CTS:PREFERRED
            needsImport(rec.assetStatus) == 0,
            "E:I2:  Record in unregistered, exported, or discarded status"
        );

        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(idxHash, rec);

        deductServiceCosts(rec.assetClass, 3);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev create a Record in Storage @ idxHash (SETTER)
     */
    function createRecordOnly(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) internal {
        uint256 tokenId = uint256(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "E:CRO: token has a wrapper. Must discard wrapper before decorating"
        );

        require(
            AC_info.custodyType == 5,
            "E:CRO:Asset class.custodyType must be 5 (wrapped/decorated erc721)"
        );

        // if (AC_info.custodyType == 1) {
        //     A_TKN.mintAssetToken(address(this), tokenId, "pruf.io");
        // }

        // if ((AC_info.custodyType == 2) || (AC_info.custodyType == 4)) {
        //     A_TKN.mintAssetToken(_msgSender(), tokenId, "pruf.io");
        // }

        STOR.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
    }
}
