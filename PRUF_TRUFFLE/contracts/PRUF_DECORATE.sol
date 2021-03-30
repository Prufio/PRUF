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
 *  TO DO --- 
 *
 *-----------------------------------------------------------------
 * Decorates ERC721 compliant tokens with a PRUF record
 *----------------------------------------------------------------*/

// Must set up a custodyType 5 asset class for decorated assets and auth this contract type 1. Root must be private to class.
// Extended Data for ACnodes must be set to 0 <works with any ERC721>
// or set to ERC721 contract address <works only with tokens from specified contract address>

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";

//DPS:TEST WHAT COMMENTS?
contract DECORATE is
    CORE //CTS:EXAMINE COMMENTS NEED UPDATING
{
    modifier isTokenHolder(uint256 _tokenID, address _tokenContract) {
        //require that user holds token @ ID-Contract
        require(
            (IERC721(_tokenContract).ownerOf(_tokenID) == _msgSender()),
            "D:MOD-ITH: caller does not hold specified token"
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

        require(
            AC_info.custodyType == 5,
            "D:D:Asset class.custodyType != 5"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:D:Asset class extended data must be '0' or ERC721 contract address"
        );
        require(
            rec.assetClass == 0,
            "D:D:Wrapper, decoration, or record already exists"
        );

        //^^^^^^^effects^^^^^^^^^

        createRecordOnly(idxHash, _rgtHash, _assetClass, _countDownStart);
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
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "D:MS:Asset class.custodyType != 5 & record must exist"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:MS:Asset class extended data must be '0' or ERC721 contract address"
        );
        require(
            (_newAssetStatus > 49) && (rec.assetStatus > 49),
            "D:MS: cannot change status < 49"
        );
        require(
            (_newAssetStatus != 57) &&
                (_newAssetStatus != 58) &&
                (_newAssetStatus < 100),
            "D:MS: Stat Rsrvd"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "D:MS: Cannot place asset in unregistered, exported, or discarded status using modStatus"
        );
        require( //CTS:UNREACHABLE WITH CURRENT CONTRACTS. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5
            needsImport(rec.assetStatus) == 0,
            "D:MS: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set price and currency in rec.pricer rec.currency
     */
    function _setPrice(
        uint256 _tokenID,
        address _tokenContract,
        uint120 _price,
        uint8 _currency
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "D:SP:Asset class.custodyType != 5 & record must exist"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:SP:Asset class extended data must be '0' or ERC721 contract address"
        );
        require( //UNREACHABLE WITH CURRENT CONTRACTS. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5
            needsImport(rec.assetStatus) == 0,
            "D:SP: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR.setPrice(idxHash, _price, _currency);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set price and currency in rec.pricer rec.currency
     */
    function _clearPrice(uint256 _tokenID, address _tokenContract)
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "D:CP:Asset class.custodyType != 5 & record must exist"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:CP:Asset class extended data must be '0' or ERC721 contract address"
        );

        require( //CTS:UNREACHABLE WITH CURRENT CONTRACTS. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5
            needsImport(rec.assetStatus) == 0,
            "D:CP: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR.clearPrice(idxHash);
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
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "D:DC:Asset class.custodyType != 5 & record must exist"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:DC:Asset class extended data must be '0' or ERC721 contract address"
        );

        require( //CTS:UNREACHABLE WITH CURRENT CONTRACTS. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5
            needsImport(rec.assetStatus) == 0,
            "D:DC: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown - _decAmount;
        } else {
            rec.countDown = 0;
        }
        //^^^^^^^effects^^^^^^^^^

        writeRecord(idxHash, rec);
        deductServiceCosts(rec.assetClass, 7);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs1a
     */
    function _modIpfs1(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _Ipfs1a,
        bytes32 _Ipfs1b
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "D:MI1:Asset class.custodyType != 5 & record must exist"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:MI1:Asset class extended data must be '0' or ERC721 contract address"
        );

        require( //CTS:UNREACHABLE WITH CURRENT CONTRACTS. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5
            needsImport(rec.assetStatus) == 0,
            "D:MI1: Record in unregistered, exported, or discarded status"
        );

        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1a = _Ipfs1a;
        rec.Ipfs1b = _Ipfs1b;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(idxHash, rec);
        deductServiceCosts(rec.assetClass, 8);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2
     */
    function addIpfs2Note(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _Ipfs2a,
        bytes32 _Ipfs2b
        

    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "D:AI2:Asset class.custodyType != 5 & record must exist"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:AI2:Asset class extended data must be '0' or ERC721 contract address"
        );

        require( //IMPOSSIBLE TO THROW REVERTS IN REQ1 CTS:PREFERRED
            needsImport(rec.assetStatus) == 0,
            "D:AI2: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2a = _Ipfs2a;
        rec.Ipfs2b = _Ipfs2b;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(idxHash, rec);
        deductServiceCosts(rec.assetClass, 3);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Export - sets asset to status 70 (importable)
     */
    function _export(uint256 _tokenID, address _tokenContract)
        external
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "D:E:Asset class.custodyType != 5 & record must exist"
        );
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:E:Asset class extended data must be '0' or ERC721 contract address"
        );

        require(
            rec.assetStatus == 51,
            "D:E: Must be in transferrable status (51)"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        //^^^^^^^effects^^^^^^^^^

        writeRecord(idxHash, rec);
        STOR.changeAC(idxHash, AC_info.assetClassRoot); //set assetClass to the root AC of the assetClass
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev import **Record** (no confirmation required -
     * posessor is considered to be owner. sets rec.assetStatus to 52.
     */
    function _import(
        uint256 _tokenID,
        address _tokenContract,
        uint32 _newAssetClass
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);
        AC memory newAC_info = getACinfo(_newAssetClass);

        require(
            ((AC_info.custodyType == 5) || AC_info.custodyType == 3) &&
                (newAC_info.custodyType == 5),
            "D:I:Asset class.custodyType != 5 & record must exist"
        );
        require(
                (AC_info.managementType < 5),
                "D:I:Contract does not support management types > 4 or AC is locked"
        );
        require(
            ((AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0))) &&
                ((newAC_info.referenceAddress == _tokenContract) ||
                    (newAC_info.referenceAddress == address(0))),
            "D:I:Asset class extended data must be '0' or ERC721 contract address"
        );
        require(rec.assetStatus == 70, "D:I: Asset not exported");
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "D:I:Cannot change AC to new root"
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

        require( //CTS:PREFERRED: THROWS IN ONLY FUNCTION THAT CALLS createRecordOnly
            A_TKN.tokenExists(tokenId) == 0,
            "D:CRO: token is already wrapped. Must discard wrapper before decorating"
        );
        require( //CTS:PREFERRED: THROWS IN ONLY FUNCTION THAT CALLS createRecordOnly
            AC_info.custodyType == 5,
            "D:CRO:Asset class.custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
                (AC_info.managementType < 5),
                "D:CRO:Contract does not support management types > 4 or AC is locked"
        );
        if ((AC_info.managementType == 1) || (AC_info.managementType == 2)) {
            require(
                (AC_TKN.ownerOf(_assetClass) == _msgSender()),
                "D:CRO:Cannot create asset in AC mgmt type 1||2 - caller does not hold AC token"
            );
        }
        if (AC_info.managementType == 3) {
            require(
                AC_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _assetClass
                ) == 1,
                "D:CRO:Cannot create asset - caller address not authorized"
            );
        }
        if (AC_info.managementType == 4) {
            require(
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "D:CRO:Caller does not hold sufficiently trusted ID"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        STOR.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        //^^^^^^^interactions^^^^^^^^^
    }
}
