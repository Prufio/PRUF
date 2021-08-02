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
 *
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";

contract APP is CORE {
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    /**
     * Checks that contract holds token
     * @param _idxHash - idxHash of asset to compare to caller for authority
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require( //require that user is authorized and token is held by contract
            (A_TKN.ownerOf(tokenId) == address(this)),
            "A:MOD-IA: APP contract !token holder"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Creates a new record  DPS:CHECK no longer sets rec.countDownStart
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) external nonReentrant whenNotPaused {
        uint8 userType = getCallingUserType(_node);

        require((userType > 0) && (userType < 10), "A:NR: User !auth in node");
        require(userType < 5, "A:NR: User !authorized to create records");
        //^^^^^^^checks^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _node, _countDownStart);
        deductServiceCosts(_node, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev import Rercord, must match export node //DPS:TEST
     * posessor is considered to be owner. sets rec.assetStatus to 0.
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _newAssetClass - node the asset will be imported into
     */
    function importAsset(bytes32 _idxHash, uint32 _newAssetClass)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash) ///contract holds token (user sent to contract)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(_newAssetClass);

        require(userType < 3, "A:IA: User !authorized to import assets");
        require((userType > 0) && (userType < 10), "A:IA: User !auth in node");
        require(
            (rec.assetStatus == 5) ||
                (rec.assetStatus == 55) ||
                (rec.assetStatus == 70),
            "A:IA: Only Transferred or exported assets can be imported"
        );
        require(
            _newAssetClass == rec.int32temp,
            "A:IA: new node must match node authorized for import"
        );
        require(
            NODE_MGR.isSameRootAC(_newAssetClass, rec.node) == 170,
            "ANC:IA: Cannot change node to new root"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.modCount = 170;
        rec.assetStatus = 0;
        //^^^^^^^effects^^^^^^^^^

        STOR.changeAC(_idxHash, _newAssetClass);
        writeRecord(_idxHash, rec);
        deductServiceCosts(_newAssetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify rec.rightsHolder
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of new rightsholder information created by frontend inputs
     */
    function forceModRecord(bytes32 _idxHash, bytes32 _rgtHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require(userType == 1, "A:FMR: User !auth in node");
        require(
            isLostOrStolen(rec.assetStatus) == 0,
            "A:FMR: Asset marked L/S"
        );
        require( //impossible to reach, APP needs to hold token
            needsImport(rec.assetStatus) == 0,
            "A:FMR: Asset needs re-imported"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.modCount = 170;
        rec.numberOfTransfers = 170;
        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.node, 6);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Transfer rights to new rightsHolder with confirmation of matching rgthash
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _newrgtHash - hash of targeted reciever information created by frontend inputs
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
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require((userType > 0) && (userType < 10), "A:TA: User not auth in node");
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
        deductServiceCosts(rec.node, 2);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify **Record** Ipfs2 with confirmation of matching rgthash
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _Ipfs2a - field for permanent external asset data
     * @param _Ipfs2b - field for permanent external asset data
     */
    function addIpfs2Note(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _Ipfs2a,
        bytes32 _Ipfs2b
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require((userType > 0) && (userType < 10), "A:I2: User not auth in node");

        require( //impossible? to reach
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
        deductServiceCosts(rec.node, 3);
        //^^^^^^^interactions^^^^^^^^^
    }
}
