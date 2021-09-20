/*--------------------------------------------------------PRüF0.8.7
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
 * CTS:EXAMINE description of contract
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";

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
            "A:MOD-IA: Custodial contract does not hold token"
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
     * @dev import Rercord, must match export node
     * posessor is considered to be owner. sets rec.assetStatus to 0.
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _newNode - node the asset will be imported into
     */
    function importAsset(bytes32 _idxHash, uint32 _newNode)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash) ///contract holds token (user sent to contract)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(_newNode);

        require(userType < 3, "A:IA: User !authorized to import assets");
        require((userType > 0) && (userType < 10), "A:IA: User !auth in node");
        require(
            (rec.assetStatus == 5) ||
                (rec.assetStatus == 55) ||
                (rec.assetStatus == 70),
            "A:IA: Only Transferred or exported assets can be imported"
        );
        require(
            _newNode == rec.int32temp,
            "A:IA: new node must match node authorized for import"
        );
        require(
            NODE_MGR.isSameRootNode(_newNode, rec.node) == 170,
            "ANC:IA: Cannot change node to new root"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.modCount = 170;
        rec.assetStatus = 0;
        //^^^^^^^effects^^^^^^^^^

        STOR.changeNode(_idxHash, _newNode);
        writeRecord(_idxHash, rec);
        deductServiceCosts(_newNode, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify rec.rightsHolder
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of new rightsholder information created by frontend inputs
     */
    function forceModifyRecord(bytes32 _idxHash, bytes32 _rgtHash)
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
        require( //impossible to reach with current contracts, APP needs to hold token
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
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require(
            (userType > 0) && (userType < 10),
            "A:TA: User not auth in node"
        );
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
     * @dev Modify **Record** NonMutableStorage with confirmation of matching rgthash
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function addNonMutableNote(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require(
            (userType > 0) && (userType < 10),
            "A:I2: User not auth in node"
        );

        require( //impossible to reach with current contracts, APP needs to hold token
            needsImport(rec.assetStatus) == 0,
            "A:I2: Asset needs re-imported"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "A:I2: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        writeNonMutableStorage(_idxHash, rec);
        deductServiceCosts(rec.node, 3);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Transfer any specified assetToken from contract
     * @param _to - address to send to
     * @param _idxHash - asset index
     */
    function transferAssetToken(address _to, bytes32 _idxHash)
        external
        nonReentrant
    {
        require(
            hasRole(ASSET_TXFR_ROLE, _msgSender()),
            "B:TX:Must have ASSET_TXFR_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 tokenId = uint256(_idxHash);

        A_TKN.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify **Record**.assetStatus with confirmation of matching rgthash required
     * @param _idxHash asset to moidify
     * @param _rgtHash rgthash to match in front end
     * @param _newAssetStatus updated status
     */
    function modifyStatus(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require(
            (userType > 0) && (userType < 10),
            "APP:MS: User !auth in node"
        );
        require(
            (_newAssetStatus != 7) &&
                (_newAssetStatus != 57) &&
                (_newAssetStatus != 58) &&
                (_newAssetStatus < 100),
            "APP:MS: Stat Rsrvd"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "APP:MS: Cannot place asset in unregistered, exported, or discarded status using modifyStatus"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "APP:MS: Record in unregistered, exported, or discarded status"
        );
        require(
            (rec.assetStatus > 49) || (userType < 5),
            "APP:MS: Only usertype < 5 can change status < 49"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "APP:MS: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation of matching rgthash required
     * @param _idxHash asset to moidify
     * @param _rgtHash rgthash to match in front end
     * @param _newAssetStatus updated status
     */
    function setLostOrStolen(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);
        require(
            (userType > 0) && (userType < 10),
            "APP:SLS: User !auth in node"
        );
        require(
            (rec.assetStatus > 49) ||
                ((_newAssetStatus < 50) && (userType < 5)),
            "APP:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "APP:SLS: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setLostOrStolen(_idxHash, rec.assetStatus);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Decrement **Record**.countdown with confirmation of matching rgthash required
     * @param _idxHash asset to moidify
     * @param _rgtHash rgthash to match in front end
     * @param _decAmount amount to decrement
     */
    function decrementCounter(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _decAmount
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require(
            (userType > 0) && (userType < 10),
            "APP:DC: User !auth in node"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "APP:DC Record in unregistered, exported, or discarded status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "APP:DC: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown - _decAmount;
        } else {
            rec.countDown = 0;
        }
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.node, 7);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify rec.MutableStorage field with rghHash confirmation
     * @param _idxHash idx of asset to Modify
     * @param _rgtHash rgthash to match in front end
     * @param _mutableStorage1 content adressable storage adress part 1
     * @param _mutableStorage2 content adressable storage adress part 2
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);
        require(
            (userType > 0) && (userType < 10),
            "APP:MMS: User !auth in node"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "APP:MMS: Record in unregistered, exported, or discarded status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "APP:MMS: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.mutableStorage1 = _mutableStorage1;
        rec.mutableStorage2 = _mutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        writeMutableStorage(_idxHash, rec);
        deductServiceCosts(rec.node, 8);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Export FROM Custodial - sets asset to status 70 (importable) for export
     * @dev exportTo - sets asset to status 70 (importable) and defines the node that the item can be imported into
     * @param _idxHash idx of asset to Modify
     * @param _exportTo node target for export
     * @param _addr adress to send asset to
     * @param _rgtHash rgthash to match in front end
     */
    function exportAssetTo(
        bytes32 _idxHash,
        uint32 _exportTo,
        address _addr,
        bytes32 _rgtHash
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);

        require(
            (userType > 0) && (userType < 10),
            "APP:EA: user not auth in node"
        );
        require( // require transferrable (51) status
            (rec.assetStatus == 51) || (rec.assetStatus == 70),
            "APP:EA: Asset status must be 51 to export"
        );
        require(
            NODE_MGR.isSameRootNode(_exportTo, rec.node) == 170,
            "A:EA: Cannot export node to new root"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "APP:EA: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        rec.int32temp = _exportTo;
        //^^^^^^^effects^^^^^^^^^

        A_TKN.safeTransferFrom(address(this), _addr, uint256(_idxHash));
        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }
}
