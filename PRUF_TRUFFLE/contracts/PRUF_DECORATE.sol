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
 * Decorates ERC721 compliant tokens with a PRUF record
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

    //-----------------------------------------External Functions--------------------------

    /**
     * @dev Decorates an external ERC721 with a PRüF data record 
     * @param _tokenID - tokenID of token being decorated from @_tokenContract
     * @param _tokenContract - token contract for @_tokenID
     * @param _rgtHash - hash of new rightsholder information created by frontend inputs
     * @param _assetClass - assetClass the @_tokenID will be decorated in
     * @param _countDownStart - decremental counter for an assets lifecycle
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
    {   //DPS:TEST
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(_assetClass);

        require(AC_info.custodyType == 5, "D:D:Asset class.custodyType != 5");
        require(
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:D:Asset class reference address must be '0' or ERC721 contract address"
        );
        require(
            rec.assetClass == 0,
            "D:D:Wrapper, decoration, or record already exists"
        );
        require( //DPS:TEST NEW
            (AC_info.managementType < 6),
            "ANC:IA: Contract does not support management types > 5 or AC is locked"
        );
        if (    //DPS:TEST NEW
            (AC_info.managementType == 1) ||
            (AC_info.managementType == 2) ||
            (AC_info.managementType == 5)
        ) {
            require(    //DPS:TEST NEW
                (AC_TKN.ownerOf(_assetClass) == _msgSender()),
                "ANC:IA: Cannot create asset in AC mgmt type 1||2||5 - caller does not hold AC token"
            );
        } else if (AC_info.managementType == 3) {
            require(    //DPS:TEST NEW
                AC_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _assetClass
                ) == 1,
                "ANC:IA: Cannot create asset - caller address !authorized"
            );
        } else if (AC_info.managementType == 4) {
            require(    //DPS:TEST NEW
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "ANC:IA: Caller !trusted ID holder"
            );
        }

        //^^^^^^^checks^^^^^^^^^

        createRecordOnly(idxHash, _rgtHash, _assetClass, _countDownStart);
        deductServiceCosts(_assetClass, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify Record.assetStatus 
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _newAssetStatus - new status of decorated token (see docs)
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
            (_newAssetStatus > 49) && (rec.assetStatus > 49), //Preferred
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
        require(
            needsImport(rec.assetStatus) == 0,
            "D:MS: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev set an item "for sale" by setting price and currency in rec.price rec.currency 
     * right now only type2 (PRUF tokens) currency is implemented.
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _price - desired cost of selected asset
     * @param _currency - currency in which the asset is set for sale (see docs)
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
        require( //DPS test unreachable reason does not make sense UNREACHABLE-Preferred, asset would already need to exist, which requires that this is already the case. Or import, where this also applies
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:SP:Asset class extended data must be '0' or ERC721 contract address"
        );
        require( //DPS:TEST unreachable reason does not make sense UNREACHABLE-Preferred requires root to be type5
            needsImport(rec.assetStatus) == 0,
            "D:SP: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR.setPrice(idxHash, _price, _currency);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev clear price and currency in rec.price rec.currency, making an item no longer for sale.
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
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
        require( //DPS:TEST Retest reason for unreachable does not make sense UNREACHABLE, asset would already need to exist, which requires that this is already the case. Or import, where this also applies
            (AC_info.referenceAddress == _tokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "D:CP:Asset class extended data must be '0' or ERC721 contract address"
        );

        require(
            needsImport(rec.assetStatus) == 0,
            "D:CP: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR.clearPrice(idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Decrement rec.countdown one-way counter
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _decAmount - desired amount to deduct from countDownStart of asset
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

        require( //DPS:TEST Retest reason for unreachable does not make sense
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

    /**
     * @dev Modify rec.Ipfs1a/b content adressable storage pointer
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _Ipfs1a - field for external asset data
     * @param _Ipfs1b - field for external asset data
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

        require( //DPS:TEST unreachable reason does not make sense:UNREACHABLE. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5
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

    /**
     * @dev SET rec.Ipfs2a/b (immutable) content adressable storage pointer
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _Ipfs2a - field for permanent external asset data
     * @param _Ipfs2b - field for permanent external asset data
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

    /**
     * @dev Export - sets asset to status 70 (importable)
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _exportTo - destination assetClass of decorated token
     * DPS:TEST added destination ACNODE parameter
     */
    function _exportAssetTo(uint256 _tokenID, address _tokenContract, uint32 _exportTo)
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
            require(
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
            (rec.assetStatus == 51) || (rec.assetStatus == 70), //DPS:check
            "D:E: Must be in transferrable status (51/70)"
        );
        require(
            AC_MGR.isSameRootAC(_exportTo, rec.assetClass) == 170,
            "D:E: Cannot change AC to new root"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        rec.int32temp = _exportTo; //set permitted AC for import
        //^^^^^^^effects^^^^^^^^^

        writeRecord(idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev import a decoration into a new asset class. posessor is considered to be owner. sets rec.assetStatus to 51.
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _newAssetClass - new assetClass of decorated token
     * DPS:TEST
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
        require( //DPS:TEST NEW
            _newAssetClass == rec.int32temp,
            "ANC:IA: Cannot change AC except to specified AC"
        );
        require( //DPS:TEST NEW
            (newAC_info.managementType < 6),
            "D:I: Contract does not support management types > 5 or AC is locked"
        );
        if (
            (newAC_info.managementType == 1) ||
            (newAC_info.managementType == 2) ||
            (newAC_info.managementType == 5)
        ) {
            require( //DPS:TEST NEW
                (AC_TKN.ownerOf(_newAssetClass) == _msgSender()),
                "D:I: Cannot create asset in AC mgmt type 1||2||5 - caller does not hold AC token"
            );
        } else if (newAC_info.managementType == 3) {
            require( //DPS:TEST NEW
                AC_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _newAssetClass
                ) == 1,
                "D:I: Cannot create asset - caller address !authorized"
            );
        } else if (newAC_info.managementType == 4) {
            require( //DPS:TEST NEW
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

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev create a Record in Storage @ idxHash (SETTER)
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _assetClass - assetClass the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
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
