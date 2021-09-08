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
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _mutableStorage1 - field for external asset data
     * @param _mutableStorage2 - field for external asset data
     */
    function newRecordWithDescription(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external nonReentrant whenNotPaused {
        require(
            (ID_MGR.trustLevel(_msgSender()) > 0), //_msgSender() is ID token holder
            "ANC:NRWD: Caller !PRuF_ID holder"
        );
        //^^^^^^^Checks^^^^^^^^^

        Record memory rec;
        rec.mutableStorage1 = _mutableStorage1;
        rec.mutableStorage2 = _mutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _node, _countDownStart);
        writeMutableStorage(_idxHash, rec);
        deductServiceCosts(_node, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Create a newRecord with permanent description
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function newRecordWithNote(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external nonReentrant whenNotPaused {
        require(
            (ID_MGR.trustLevel(_msgSender()) > 0), //_msgSender() is ID token holder
            "ANC:NRWD: Caller !PRuF_ID holder"
        );
        //^^^^^^^Checks^^^^^^^^^

        Record memory rec;
        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _node, _countDownStart);
        writeNonMutableStorage(_idxHash, rec);
        deductServiceCosts(_node, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Create a newRecord
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
        require(
            (ID_MGR.trustLevel(_msgSender()) > 0), //_msgSender() is ID token holder
            "ANC:NR: Caller !PRuF_ID holder"
        );
        //^^^^^^^Checks^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _node, _countDownStart);
        deductServiceCosts(_node, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Import a record into a new node
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _newNode - node the asset will be imported into
     */
    function importAsset(bytes32 _idxHash, uint32 _newNode)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Node memory node_info =getNodeinfo(_newNode);

        require(rec.assetStatus == 70, "ANC:IA: Asset !exported");
        require(
            _newNode == rec.int32temp,
            "ANC:IA: Cannot change node except to specified node"
        );
        require( //redundant:preferred, tested and secure by commenting out req in STOR.changeNode
            NODE_MGR.isSameRootNode(_newNode, rec.node) == 170,
            "ANC:IA: Cannot change node to new root"
        );
        require( //redundant:preferred, tested and secure by commenting out req in NP_NC exportAssetTo
            (node_info.managementType < 6),
            "ANC:IA: Contract does not support management types > 5 or node is locked"
        );
        if (
            (node_info.managementType == 1) ||
            (node_info.managementType == 2) ||
            (node_info.managementType == 5)
        ) {
            require(
                (NODE_TKN.ownerOf(_newNode) == _msgSender()),
                "ANC:IA: Cannot import asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (node_info.managementType == 3) {
            require(
                NODE_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _newNode
                ) == 1,
                "ANC:IA: Cannot create asset - caller address !authorized"
            );
        } else if (node_info.managementType == 4) {
            require(
                ID_MGR.trustLevel(_msgSender()) > 10,
                "ANC:IA: Caller !trusted ID holder"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 51; //transferrable status
        //^^^^^^^effects^^^^^^^^^

        STOR.changeNode(_idxHash, _newNode);
        writeRecord(_idxHash, rec);
        deductServiceCosts(_newNode, 1);
        //^^^^^^^interactions^^^^^^^^^^^^
    }

    /**
     * @dev record NonMutableStorage data 
     * @param _idxHash - hash of asset information created by frontend inputs
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function addNonMutableNote(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        require( //STATE UNREACHABLE
            needsImport(rec.assetStatus) == 0,
            "ANC:I2: Record In Transferred, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        writeNonMutableStorage(_idxHash, rec);
        deductServiceCosts(rec.node, 3);
        //^^^^^^^interactions^^^^^^^^^
    }
}
