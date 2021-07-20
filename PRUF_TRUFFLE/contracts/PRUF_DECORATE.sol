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
 * Decorates ERC721 compliant tokens with a PRUF record CTS:EXAMINE better explanation
 *----------------------------------------------------------------*/

// Must set up a custodyType 5 asset class for decorated assets and auth this contract type 1. Root must be private to class.
// Extended Data for ACnodes must be set to 0 <works with any ERC721>
// or set to ERC721 contract address <works only with tokens from specified contract address>

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract DECORATE is CORE {

    /**
     * @dev Verify user credentials
     * @param _tokenID - tokenID of token @_tokenContract caller is trying to interact with
     * @param _tokenContract - token contract used to query _tokenID for owner identity
     * Originating Address:
     *   require that user holds token @ _tokencontract
     */
    modifier isTokenHolder(uint256 _tokenID, address _tokenContract) {
        require(
            (IERC721(_tokenContract).ownerOf(_tokenID) == _msgSender()),
            "D:MOD-ITH: caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Decorates an external ERC721 with PRüF data
     * @param _tokenID
     * @param
     * @param
     * @param
     * @param
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

        require(AC_info.custodyType == 5, "D:D:Asset class.custodyType != 5");
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
            (_newAssetStatus > 49) && (rec.assetStatus > 49), //CTS:EXAMINE I think this functionality is inevitably non-custodial, so only need to check for newAssetStatus. Should never be otherwise
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
        require( //CTS:UNREACHABLE WITH CURRENT CONTRACTS. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5 //CTS:EXAMINE can roots even be custody type classified?
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
     * @dev set price and currency in rec.price rec.currency //CTS:EXAMINE less technical, describe theres only usecase for type2 currency
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
        require(
            needsImport(rec.assetStatus) == 0,
            "D:SP: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR.setPrice(idxHash, _price, _currency);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set price and currency in rec.price rec.currency //CTS:EXAMINE less technical
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
            (AC_info.managementType < 6),
            "C:CR:Contract does not support management types > 5 or AC is locked"
        );
        if ((AC_info.custodyType != 1) && (AC_info.managementType == 5)) {
            require(
                (AC_TKN.ownerOf(rec.assetClass) == _msgSender()),
                "C:WIPFS1: Caller must hold ACnode (management type 5)"
            );
        }
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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

        require(
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
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
            (AC_info.managementType < 6),
            "C:CR:Contract does not support management types > 5 or AC is locked"
        );
        if ((AC_info.managementType == 1) || (AC_info.managementType == 5)) {
            require( //caller holds AC token if AC is restricted --------DPS TEST ---- NEW
                (AC_TKN.ownerOf(rec.assetClass) == _msgSender()),
                "D:E: Restricted from exporting assets from this AC - does not hold ACtoken"
            );
        }
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
     * posessor is considered to be owner. sets rec.assetStatus to 51.
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE this one needs a req section
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
            (AC_info.custodyType == 5) && (newAC_info.custodyType == 5), //only allow import of other wrappers
            "D:I:Asset class.custodyType != 5 & record must exist"
        );
        require(
            ((AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0))) &&
                ((newAC_info.referenceAddress == _tokenContract) ||
                    (newAC_info.referenceAddress == address(0))),
            "D:I:Asset class extended data must be '0' or ERC721 contract address" //if AC has a contract erc721address specified, it must match
        );
        require(rec.assetStatus == 70, "D:I: Asset not exported");
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "D:I:Cannot change AC to new root"
        );
        require(
            (newAC_info.managementType < 6),
            "D:I: Contract does not support management types > 5 or AC is locked"
        );
        if (
            (newAC_info.managementType == 1) ||
            (newAC_info.managementType == 2) ||
            (newAC_info.managementType == 5)
        ) {
            require(
                (AC_TKN.ownerOf(_newAssetClass) == _msgSender()),
                "D:I: Cannot create asset in AC mgmt type 1||2||5 - caller does not hold AC token"
            );
        } else if (newAC_info.managementType == 3) {
            require(
                AC_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _newAssetClass
                ) == 1,
                "D:I: Cannot create asset - caller address !authorized"
            );
        } else if (newAC_info.managementType == 4) {
            require(
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "D:I: Caller !trusted ID holder"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 51;
        //^^^^^^^effects^^^^^^^^^

        STOR.changeAC(idxHash, _newAssetClass);
        writeRecord(idxHash, rec);
        deductServiceCosts(_newAssetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev create a Record in Storage @ idxHash (SETTER)
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE this one needs a req section
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
            "D:CRO: token is already wrapped. Must discard wrapper before decorating"
        );
        require(
            AC_info.custodyType == 5,
            "D:CRO:Asset class.custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
            (AC_info.managementType < 5),
            "D:CRO:Contract does not support management types > 5 or AC is locked"
        );
        if (
            (AC_info.managementType == 1) ||
            (AC_info.managementType == 2) ||
            (AC_info.managementType == 5)
        ) {
            require(
                (AC_TKN.ownerOf(_assetClass) == _msgSender()),
                "D:CRO:Cannot create asset in AC mgmt type 1||2||5 - caller does not hold AC token"
            );
        } else if (AC_info.managementType == 3) {
            require(
                AC_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _assetClass
                ) == 1,
                "D:CRO:Cannot create asset - caller address not authorized"
            );
        } else if (AC_info.managementType == 4) {
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
