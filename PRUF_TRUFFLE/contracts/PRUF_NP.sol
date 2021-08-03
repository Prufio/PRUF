/**--------------------------------------------------------PRüF0.8.6
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
 *  Custodial Protocol Functions
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";

contract NP is CORE {
    /**
     * @dev Verify user credentials
     * @param _idxHash asset to check that caller holds token
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

        require((userType > 0) && (userType < 10), "NP:MS: User !auth in node");
        require(
            (_newAssetStatus != 7) &&
                (_newAssetStatus != 57) &&
                (_newAssetStatus != 58) &&
                (_newAssetStatus < 100),
            "NP:MS: Stat Rsrvd"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "NP:MS: Cannot place asset in unregistered, exported, or discarded status using modifyStatus"
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
        require((userType > 0) && (userType < 10), "NP:SLS: User !auth in node");
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

        require((userType > 0) && (userType < 10), "NP:DC: User !auth in node");
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
        require((userType > 0) && (userType < 10), "NP:MI1: User !auth in node");
        require(
            needsImport(rec.assetStatus) == 0,
            "NP:MI1: Record in unregistered, exported, or discarded status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:MI1: Rightsholder does not match supplied data"
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
            "NP:EA: user not auth in node"
        );
        require( // require transferrable (51) status
            (rec.assetStatus == 51) || (rec.assetStatus == 70),
            "NP:EA: Asset status must be 51 to export"
        );
        require(
            NODE_MGR.isSameRootNode(_exportTo, rec.node) == 170,
            "A:IA: Cannot export node to new root"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:MI1: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)
        rec.int32temp = _exportTo;
        //^^^^^^^effects^^^^^^^^^

        APP.transferAssetToken(_addr, _idxHash);
        writeRecord(_idxHash, rec);
    }
}
