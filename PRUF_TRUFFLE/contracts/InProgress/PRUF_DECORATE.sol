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
 * Decorates ERC721 compliant tokens with a PRUF record
 *----------------------------------------------------------------*/


// Must set up a custodyType 5 node for decorated assets and auth this contract type 1. Root must be private to class.
// Extended Data for nodes must be set to 0 <works with any ERC721>
// or set to ERC721 contract address <works only with tokens from specified contract address>

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Imports/token/ERC721/IERC721.sol";

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
     * @param _node - node the @_tokenID will be decorated in
     * @param _countDownStart - decremental counter for an assets lifecycle
     */
    function decorate721(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {   //DPS:TEST
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        Node memory nodeInfo =getNodeinfo(_node);

        require(nodeInfo.custodyType == 5, "D:D:Node.custodyType != 5");
        require(
            (nodeInfo.referenceAddress == _tokenContract) ||
                (nodeInfo.referenceAddress == address(0)),
            "D:D:Node reference address must be '0' or ERC721 contract address"
        );
        require(
            rec.node == 0,
            "D:D:Wrapper, decoration, or record already exists"
        );
        require( //DPS:TEST NEW
            (nodeInfo.managementType < 6),
            "ANC:IA: Contract does not support management types > 5 or node is locked"
        );
        if (    //DPS:TEST NEW
            (nodeInfo.managementType == 1) ||
            (nodeInfo.managementType == 2) ||
            (nodeInfo.managementType == 5)
        ) {
            require(    //DPS:TEST NEW
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "ANC:IA: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (nodeInfo.managementType == 3) {
            require(    //DPS:TEST NEW
                NODE_STOR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "ANC:IA: Cannot create asset - caller address !authorized"
            );
        } else if (nodeInfo.managementType == 4) {
            require(    //DPS:TEST NEW
                ID_MGR.trustLevel(_msgSender()) > 10,
                "ANC:IA: Caller !trusted ID holder"
            );
        }

        //^^^^^^^checks^^^^^^^^^

        createRecordOnly(idxHash, _rgtHash, _node, _countDownStart);
        deductServiceCosts(_node, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify Record.assetStatus 
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _newAssetStatus - new status of decorated token (see docs)
     */
    function modifyStatus(
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
        Node memory nodeInfo =getNodeinfo(rec.node);

        require(
            nodeInfo.custodyType == 5,
            "D:MS:Node.custodyType != 5 & record must exist"
        );
        require(
            (nodeInfo.referenceAddress == _tokenContract) ||
                (nodeInfo.referenceAddress == address(0)),
            "D:MS:Node extended data must be '0' or ERC721 contract address"
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
            "D:MS: Cannot place asset in unregistered, exported, or discarded status using modifyStatus"
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
     * @dev Decrement rec.countdown one-way counter
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _decAmount - desired amount to deduct from countDownStart of asset
     */
    function decrementCounter(
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
        Node memory nodeInfo =getNodeinfo(rec.node);

        require(
            nodeInfo.custodyType == 5,
            "D:DC:Node.custodyType != 5 & record must exist"
        );
        require(
            (nodeInfo.referenceAddress == _tokenContract) ||
                (nodeInfo.referenceAddress == address(0)),
            "D:DC:Node extended data must be '0' or ERC721 contract address"
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
        deductServiceCosts(rec.node, 7);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modify rec.mutableStorage1/b content adressable storage pointer
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _mutableStorage1 - field for external asset data
     * @param _mutableStorage2 - field for external asset data
     */
    function modifyMutableStorage(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        Node memory nodeInfo =getNodeinfo(rec.node);

        require(
            nodeInfo.custodyType == 5,
            "D:MI1:Node.custodyType != 5 & record must exist"
        );
        require(
            (nodeInfo.managementType < 6),
            "C:CR:Contract does not support management types > 5 or node is locked"
        );
        if ((nodeInfo.custodyType != 1) && (nodeInfo.managementType == 5)) {
            require(
                (NODE_TKN.ownerOf(rec.node) == _msgSender()),
                "C:WRMS: Caller must hold node (management type 5)"
            );
        }
        require(
            (nodeInfo.referenceAddress == _tokenContract) ||
                (nodeInfo.referenceAddress == address(0)),
            "D:MI1:Node extended data must be '0' or ERC721 contract address"
        );

        require( //DPS:TEST unreachable reason does not make sense:UNREACHABLE. WOULD REQUIRE ROOT CLASSES TO BE CUSTODY TYPE 5
            needsImport(rec.assetStatus) == 0,
            "D:MI1: Record in unregistered, exported, or discarded status"
        );

        //^^^^^^^checks^^^^^^^^^

        rec.mutableStorage1 = _mutableStorage1;
        rec.mutableStorage2 = _mutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        writeMutableStorage(idxHash, rec);
        deductServiceCosts(rec.node, 8);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev SET rec.nonMutableStorage1/b (immutable) content adressable storage pointer
     * @param _tokenID - tokenID of assets token @_tokenContract
     * @param _tokenContract - token contract of _tokenID
     * @param _nonMutableStorage1 - field for permanent external asset data
     * @param _nonMutableStorage2 - field for permanent external asset data
     */
    function addNonMutableStorage(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        Node memory nodeInfo =getNodeinfo(rec.node);

        require(
            nodeInfo.custodyType == 5,
            "D:AI2:Node.custodyType != 5 & record must exist"
        );
        require(
            (nodeInfo.referenceAddress == _tokenContract) ||
                (nodeInfo.referenceAddress == address(0)),
            "D:AI2:Node extended data must be '0' or ERC721 contract address"
        );

        require(
            needsImport(rec.assetStatus) == 0,
            "D:AI2: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        writeNonMutableStorage(idxHash, rec);
        deductServiceCosts(rec.node, 3);
        //^^^^^^^interactions^^^^^^^^^
    }

    // /** //import & export have been slated for reevaluation
    //  * @dev Export - sets asset to status 70 (importable)
    //  * @param _tokenID - tokenID of assets token @_tokenContract
    //  * @param _tokenContract - token contract of _tokenID
    //  * @param _exportTo - destination node of decorated token
    //  * DPS:TEST added destination node parameter
    //  */
    // function exportAssetTo(uint256 _tokenID, address _tokenContract, uint32 _exportTo)
    //     external
    //     whenNotPaused
    //     isTokenHolder(_tokenID, _tokenContract)
    // {   
    //     bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
    //     Record memory rec = getRecord(idxHash);
    //     Node memory nodeInfo =getNodeinfo(rec.node);

    //     require(
    //         nodeInfo.custodyType == 5,
    //         "D:E:Node.custodyType != 5 & record must exist"
    //     );
    //     require(
    //         (nodeInfo.managementType < 6),
    //         "C:CR:Contract does not support management types > 5 or node is locked"
    //     );
    //     if ((nodeInfo.managementType == 1) || (nodeInfo.managementType == 5)) {
    //         require(
    //             (NODE_TKN.ownerOf(rec.node) == _msgSender()),
    //             "D:E: Restricted from exporting assets from this node - does not hold NodeToken"
    //         );
    //     }
    //     require(
    //         (nodeInfo.referenceAddress == _tokenContract) ||
    //             (nodeInfo.referenceAddress == address(0)),
    //         "D:E:Node extended data must be '0' or ERC721 contract address"
    //     );

    //     require(
    //         (rec.assetStatus == 51) || (rec.assetStatus == 70), //DPS:check
    //         "D:E: Must be in transferrable status (51/70)"
    //     );
    //     require(
    //         NODE_STOR.isSameRootNode(_exportTo, rec.node) == 170,
    //         "D:E: Cannot change node to new root"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     rec.assetStatus = 70; // Set status to 70 (exported)
    //     rec.int32temp = _exportTo; //set permitted node for import
    //     //^^^^^^^effects^^^^^^^^^

    //     writeRecord(idxHash, rec);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    // /** //import & export have been slated for reevaluation
    //  * @dev import a decoration into a new node. posessor is considered to be owner. sets rec.assetStatus to 51.
    //  * @param _tokenID - tokenID of assets token @_tokenContract
    //  * @param _tokenContract - token contract of _tokenID
    //  * @param _newNode - new node of decorated token
    //  */
    // function importAsset(
    //     uint256 _tokenID,
    //     address _tokenContract,
    //     uint32 _newNode
    // )
    //     external
    //     nonReentrant
    //     whenNotPaused
    //     isTokenHolder(_tokenID, _tokenContract)
    // {
    //     bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
    //     Record memory rec = getRecord(idxHash);
    //     Node memory nodeInfo =getNodeinfo(rec.node);
    //     Node memory newNodeInfo =getNodeinfo(_newNode);

    //     require(
    //         (nodeInfo.custodyType == 5) && (newNodeInfo.custodyType == 5), //only allow import of other wrappers
    //         "D:I:Node.custodyType != 5 & record must exist"
    //     );
    //     require(
    //         ((nodeInfo.referenceAddress == _tokenContract) ||
    //             (nodeInfo.referenceAddress == address(0))) &&
    //             ((newNodeInfo.referenceAddress == _tokenContract) ||
    //                 (newNodeInfo.referenceAddress == address(0))),
    //         "D:I:Node extended data must be '0' or ERC721 contract address" //if node has a contract erc721address specified, it must match
    //     );
    //     require(rec.assetStatus == 70, "D:I: Asset not exported");
    //     require(
    //         NODE_STOR.isSameRootNode(_newNode, rec.node) == 170,
    //         "D:I:Cannot change node to new root"
    //     );
    //     require( //DPS:TEST NEW
    //         _newNode == rec.int32temp,
    //         "ANC:IA: Cannot change node except to specified node"
    //     );
    //     require( //DPS:TEST NEW
    //         (newNodeInfo.managementType < 6),
    //         "D:I: Contract does not support management types > 5 or node is locked"
    //     );
    //     if (
    //         (newNodeInfo.managementType == 1) ||
    //         (newNodeInfo.managementType == 2) ||
    //         (newNodeInfo.managementType == 5)
    //     ) {
    //         require( //DPS:TEST NEW
    //             (NODE_TKN.ownerOf(_newNode) == _msgSender()),
    //             "D:I: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
    //         );
    //     } else if (newNodeInfo.managementType == 3) {
    //         require( //DPS:TEST NEW
    //             NODE_STOR.getUserType(
    //                 keccak256(abi.encodePacked(_msgSender())),
    //                 _newNode
    //             ) == 1,
    //             "D:I: Cannot create asset - caller address !authorized"
    //         );
    //     } else if (newNodeInfo.managementType == 4) {
    //         require( //DPS:TEST NEW
    //             ID_MGR.trustLevel(_msgSender()) > 10,
    //             "D:I: Caller !trusted ID holder"
    //         );
    //     }
    //     //^^^^^^^checks^^^^^^^^^

    //     rec.assetStatus = 51;
    //     //^^^^^^^effects^^^^^^^^^

    //     STOR.changeNode(idxHash, _newNode);
    //     writeRecord(idxHash, rec);
    //     deductServiceCosts(_newNode, 1);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev create a Record in Storage @ idxHash (SETTER)
     * @param _idxRaw - hash of asset information created by frontend inputs
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     */
    function createRecordOnly(
        bytes32 _idxRaw,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) internal {
        bytes32 idxHash = keccak256(abi.encodePacked(_idxRaw, _node)); //hash idxRaw with node to get idxHash DPS:TEST
        uint256 tokenId = uint256(idxHash);
        Node memory nodeInfo =getNodeinfo(_node);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "D:CRO: token is already wrapped. Must discard wrapper before decorating"
        );
        require(
            nodeInfo.custodyType == 5,
            "D:CRO:Node.custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
            (nodeInfo.managementType < 5),
            "D:CRO:Contract does not support management types > 5 or node is locked"
        );
        if (
            (nodeInfo.managementType == 1) ||
            (nodeInfo.managementType == 2) ||
            (nodeInfo.managementType == 5)
        ) {
            require(
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "D:CRO:Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (nodeInfo.managementType == 3) {
            require(
                NODE_STOR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "D:CRO:Cannot create asset - caller address not authorized"
            );
        } else if (nodeInfo.managementType == 4) {
            require(
                ID_MGR.trustLevel(_msgSender()) > 10,
                "D:CRO:Caller does not hold sufficiently trusted ID"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        STOR.newRecord(idxHash, _rgtHash, _node, _countDownStart);
        //^^^^^^^interactions^^^^^^^^^
    }
}
