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
 *  TO DO
 *---------------------------------------------------------------*/


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";

contract APP_NC is CORE {

    /**
     * @dev Verify user credentials
     * @param _idxHash - ID of asset token to be verified
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

    //---------------------------------------External Functions-------------------------------

    /**
     * @dev Create a newRecord with description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _assetClass - assetClass the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _Ipfs1a - field for external asset data
     * @param _Ipfs1b - field for external asset data
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
            (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is ID token holder
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

    /**
     * @dev Create a newRecord with permanent description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _assetClass - assetClass the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _Ipfs2a - field for permanent external asset data
     * @param _Ipfs2b - field for permanent external asset data
     */
    function newRecordWithNote(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart,
        bytes32 _Ipfs2a,
        bytes32 _Ipfs2b
    ) external nonReentrant whenNotPaused {
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is ID token holder
            "ANC:NRWD: Caller !PRuF_ID holder"
        );
        //^^^^^^^Checks^^^^^^^^^

        Record memory rec;
        rec.Ipfs2a = _Ipfs2a;
        rec.Ipfs2b = _Ipfs2b;
        //^^^^^^^effects^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        writeRecordIpfs2(_idxHash, rec);
        deductServiceCosts(_assetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Create a newRecord
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _assetClass - assetClass the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) external nonReentrant whenNotPaused {
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is ID token holder
            "ANC:NR: Caller !PRuF_ID holder"
        );
        //^^^^^^^Checks^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        deductServiceCosts(_assetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /** DPS TEST-NEW FUNCTIONALITY
     * @dev Import a record into a new asset class
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _newAssetClass - assetClass the asset will be imported into
     */
    function importAsset(bytes32 _idxHash, uint32 _newAssetClass)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Node memory node_info = getACinfo(_newAssetClass);

        require(rec.assetStatus == 70, "ANC:IA: Asset !exported");
        require( //DPS:TEST NEW
            _newAssetClass == rec.int32temp,
            "ANC:IA: Cannot change node except to specified node"
        );
        require( 
            NODE_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "ANC:IA: Cannot change node to new root"
        );
        require(
            (node_info.managementType < 6),
            "ANC:IA: Contract does not support management types > 5 or node is locked"
        );
        if (
            (node_info.managementType == 1) ||
            (node_info.managementType == 2) ||
            (node_info.managementType == 5)
        ) {
            require(
                (NODE_TKN.ownerOf(_newAssetClass) == _msgSender()),
                "ANC:IA: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (node_info.managementType == 3) {
            require(
                NODE_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _newAssetClass
                ) == 1,
                "ANC:IA: Cannot create asset - caller address !authorized"
            );
        } else if (node_info.managementType == 4) {
            require(
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "ANC:IA: Caller !trusted ID holder"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 51; //transferrable status
        //^^^^^^^effects^^^^^^^^^

        STOR.changeAC(_idxHash, _newAssetClass);
        writeRecord(_idxHash, rec);
        deductServiceCosts(_newAssetClass, 1);
        //^^^^^^^interactions^^^^^^^^^^^^
    }

    /**
     * @dev record IPFS2 data 
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _Ipfs2a - field for permanent external asset data
     * @param _Ipfs2b - field for permanent external asset data
     */
    function addIpfs2Note(
        bytes32 _idxHash,
        bytes32 _Ipfs2a,
        bytes32 _Ipfs2b
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
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
