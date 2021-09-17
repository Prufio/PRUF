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
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./test_PRUF_CORE_MAL.sol";
 

contract MAL_APP is CORE_MAL {
    
    
    /*
     * @dev Verify user credentials
     * Originating Address:
     */
    // modifier isAuthorized(bytes32 _idxHash) override {
    //     uint256 tokenId = uint256(_idxHash);
    //     require(
    //         (A_TKN.ownerOf(tokenId) == APP_Address),
    //         "APP2_NC:MOD-IA: Custodial contract does not hold token"
    //     );
    //     _;
    // }

    //--------------------------------------------External Functions--------------------------

        function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) external 
    // nonReentrant whenNotPaused 
    {
        // Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(_node);
        // Node memory node_info =getNodeinfo(_node);
        // Node memory oldNode_info =getNodeinfo(rec.node);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     _node
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "A:NR: This contract not authorized for specified node"
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "A:NR: User not authorized to create records in specified node"
        // );
        // require(userType < 5, "A:NR: User not authorized to create records");
        // require(_rgtHash != 0, "A:NR: rights holder cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        //bytes32 userHash = keccak256(abi.encodePacked(_msgSender()));
        //^^^^^^^effects^^^^^^^^^

        // if (node_info.nodeRoot == oldNode_info.nodeRoot) {
            // createRecord(_idxHash, _rgtHash, _node, rec.countDownStart);
        // } else {
            createRecord(_idxHash, _rgtHash, _node, _countDownStart);
        // }
        deductServiceCosts(_node, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function modifyStatus(
        bytes32 _idxHash,
        // bytes32 _rgtHash,
        uint8 _newAssetStatus
    )
        external
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "APP2_NC:MS: This contract not authorized for specified node"
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "APP2_NC:MS: User not authorized to modify records in specified node"
        // );

        // require(
        //     isLostOrStolen(_newAssetStatus) == 0,
        //     "APP2_NC:MS: Cannot place asset in lost or stolen status using modifyStatus"
        // );
        // require(
        //     isEscrow(_newAssetStatus) == 0,
        //     "APP2_NC:MS: Cannot place asset in Escrow using modifyStatus"
        // );
        // require(
        //     needsImport(_newAssetStatus) == 0,
        //     "APP2_NC:MS: Cannot place asset in unregistered, exported, or discarded status using modifyStatus"
        // );
        // require(
        //     (_newAssetStatus < 100) &&
        //         (_newAssetStatus != 7) &&
        //         (_newAssetStatus != 57) &&
        //         (_newAssetStatus != 58),
        //     "APP2_NC:MS: Specified Status is reserved."
        // );
        // require(
        //     isEscrow(rec.assetStatus) == 0,
        //     "APP2_NC:MS: Cannot change status of asset in Escrow until escrow is expired"
        // );
        // require(
        //     needsImport(rec.assetStatus) == 0,
        //     "APP2_NC:MS: Record in unregistered, exported, or discarded status"
        // );
        // require(
        //     (rec.assetStatus > 49) || (userType < 5),
        //     "APP2_NC:MS: Only usertype < 5 can change status < 49"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "APP2_NC:MS: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation required.
     */
    function setLostOrStolen(
        bytes32 _idxHash,
        // bytes32 _rgtHash,
        uint8 _newAssetStatus
    )
        external
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "APP2_NC:SLS: This contract not authorized for specified node"
        // );
        // require(
        //     (rec.rightsHolder != 0),
        //     "APP2_NC:SLS: Record unclaimed: import required. "
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "APP2_NC:SLS: User not authorized to modify records in specified node"
        // );
        // require(
        //     isLostOrStolen(_newAssetStatus) == 170,
        //     "APP2_NC:SLS: Must set to a lost or stolen status"
        // );
        // require(
        //     (rec.assetStatus > 49) ||
        //         ((_newAssetStatus < 50) && (userType < 5)),
        //     "APP2_NC:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        // );
        // require(
        //     (rec.assetStatus != 5) && (rec.assetStatus != 55),
        //     "APP2_NC:SLS: Transferred asset cannot be set to lost or stolen after transfer."
        // );
        // require(
        //     (rec.assetStatus != 50),
        //     "APP2_NC:SLS: Asset in locked escrow cannot be set to lost or stolen"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "APP2_NC:SLS: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setLostOrStolen(_idxHash, rec.assetStatus);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function decrementCounter(
        bytes32 _idxHash,
        // bytes32 _rgtHash,
        uint32 _decAmount
    )
        external
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
        returns (uint32)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "APP2_NC:DC: This contract not authorized for specified node"
        // );

        // require(
        //     (rec.rightsHolder != 0),
        //     "APP2_NC:DC: Record unclaimed: import required. "
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "APP2_NC:DC: User not authorized to modify records in specified node"
        // );
        // require(
        //     isEscrow(rec.assetStatus) == 0,
        //     "APP2_NC:DC: Cannot modify asset in Escrow"
        // );
        // require(_decAmount > 0, "APP2_NC:DC: cannot decrement by negative number");

        // require(
        //     needsImport(rec.assetStatus) == 0,
        //     "APP2_NC:DC Record in unregistered, exported, or discarded status"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "APP2_NC:DC: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        // if (rec.countDown > _decAmount) {
        //     rec.countDown = rec.countDown - (_decAmount);
        // } else {
        //     rec.countDown = 0;
        // }
        //^^^^^^^effects^^^^^^^^^
        if (rec.countDown > _decAmount){
            rec.countDown = rec.countDown - _decAmount;
        } else {
            rec.countDown = 0;
        }
        writeRecord(_idxHash, rec);
        return (rec.countDown);
        //^^^^^^^interactions^^^^^^^^^
    }
                                                                                               //NEEDS TO BE MODIFIED IN STORAGE
    // /*
    //  * @dev Decrement **Record**.countdown with confirmation required
    //  */
    // function decrementCounterFMR(
    //     bytes32 _idxHash,
    //     bytes32 _rgtHash,
    //     uint8 _decAmount
    // )
    //     external
    //     // nonReentrant
    //     // whenNotPaused
    //     // isAuthorized(_idxHash)
    //     returns (uint8)
    // {
    //     Record memory rec = getRecord(_idxHash);
    //     // uint8 userType = getCallingUserType(rec.node);
    //     // ContractDataHash memory contractInfo = getContractInfo(
    //     //     address(this),
    //     //     rec.node
    //     // );

    //     // require(
    //     //     contractInfo.contractType > 0,
    //     //     "APP2_NC:DC: This contract not authorized for specified node"
    //     // );

    //     // require(
    //     //     (rec.rightsHolder != 0),
    //     //     "APP2_NC:DC: Record unclaimed: import required. "
    //     // );
    //     // require(
    //     //     (userType > 0) && (userType < 10),
    //     //     "APP2_NC:DC: User not authorized to modify records in specified node"
    //     // );
    //     // require(
    //     //     isEscrow(rec.assetStatus) == 0,
    //     //     "APP2_NC:DC: Cannot modify asset in Escrow"
    //     // );
    //     // require(_decAmount > 0, "APP2_NC:DC: cannot decrement by negative number");

    //     // require(
    //     //     needsImport(rec.assetStatus) == 0,
    //     //     "APP2_NC:DC Record in unregistered, exported, or discarded status"
    //     // );
    //     require(
    //         rec.rightsHolder == _rgtHash,
    //         "APP2_NC:DC: Rightsholder does not match supplied data"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     // if (rec.modCount > _decAmount) {
    //     //     rec.modCount = rec.modCount - (_decAmount);
    //     // } else {
    //     //     rec.modCount = 0;
    //     // }
    //     //^^^^^^^effects^^^^^^^^^
    //     rec.modCount = rec.modCount - (_decAmount);
    //     writeRecord(_idxHash, rec);
    //     return (rec.modCount);
    //     //^^^^^^^interactions^^^^^^^^^
    // }
                                                                                               //NEEDS TO BE MODIFIED IN STORAGE
    // function decrementCounterTXFR(
    //     bytes32 _idxHash,
    //     bytes32 _rgtHash,
    //     uint16 _decAmount
    // )
    //     external
    //     // nonReentrant
    //     // whenNotPaused
    //     // isAuthorized(_idxHash)
    //     returns (uint16)
    // {
    //     Record memory rec = getRecord(_idxHash);
    //     // uint8 userType = getCallingUserType(rec.node);
    //     // ContractDataHash memory contractInfo = getContractInfo(
    //     //     address(this),
    //     //     rec.node
    //     // );

    //     // require(
    //     //     contractInfo.contractType > 0,
    //     //     "APP2_NC:DC: This contract not authorized for specified node"
    //     // );

    //     // require(
    //     //     (rec.rightsHolder != 0),
    //     //     "APP2_NC:DC: Record unclaimed: import required. "
    //     // );
    //     // require(
    //     //     (userType > 0) && (userType < 10),
    //     //     "APP2_NC:DC: User not authorized to modify records in specified node"
    //     // );
    //     // require(
    //     //     isEscrow(rec.assetStatus) == 0,
    //     //     "APP2_NC:DC: Cannot modify asset in Escrow"
    //     // );
    //     // require(_decAmount > 0, "APP2_NC:DC: cannot decrement by negative number");

    //     // require(
    //     //     needsImport(rec.assetStatus) == 0,
    //     //     "APP2_NC:DC Record in unregistered, exported, or discarded status"
    //     // );
    //     require(
    //         rec.rightsHolder == _rgtHash,
    //         "APP2_NC:DC: Rightsholder does not match supplied data"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     // if (rec.numberOfTransfers > _decAmount) {
    //     //     rec.numberOfTransfers = rec.numberOfTransfers - (_decAmount);
    //     // } else {
    //     //     rec.numberOfTransfers = 0;
    //     // }
    //     //^^^^^^^effects^^^^^^^^^
    //     rec.numberOfTransfers = rec.numberOfTransfers - (_decAmount);
    //     writeRecord(_idxHash, rec);
    //     return (rec.numberOfTransfers);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    /*
     * @dev Modify **Record**.mutableStorage1 with confirmation
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    )
        external
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "APP2_NC:MI1: This contract not authorized for specified node"
        // );
        // require(
        //     (rec.rightsHolder != 0),
        //     "APP2_NC:MI1: Record unclaimed: import required."
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "APP2_NC:MI1: User not authorized to modify records in specified node"
        // );
        // require(rec.mutableStorage1 != _content adressable storageHash, "APP2_NC:MI1: New data same as old");

        // require(
        //     isEscrow(rec.assetStatus) == 0,
        //    "APP2_NC:MI1: Cannot modify asset in Escrow"
        // );
        // require(
        //     needsImport(rec.assetStatus) == 0,
        //     "APP2_NC:MI1: Record in unregistered, exported, or discarded status"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "APP2_NC:MI1: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        rec.mutableStorage1 = _mutableStorage1;
        rec.mutableStorage2 = _mutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        writeMutableStorage(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.NonMutableStorage with confirmation
     */
    function addNonMutableNote(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    )
        external
        
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "A:I2: This contract not authorized for specified node"
        // );
        // require(
        //     (rec.rightsHolder != 0),
        //     "A:I2: Record unclaimed: import required. "
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "A:I2: User not authorized to modify records in specified node"
        // );
        // require(
        //     isLostOrStolen(rec.assetStatus) == 0,
        //     "A:FMR: Asset marked lost or stolen"
        // );
        // require(
        //     isEscrow(rec.assetStatus) == 0,
        //     "A:FMR: Asset in escrow"
        // );
        // require(
        //     needsImport(rec.assetStatus) == 0,
        //     "A:FMR: Asset needs re-imported"
        // );
        // require(
        //     rec.nonMutableStorage1 == 0,
        //     "A:I2: nonMutableStorage1 has data already. Overwrite not permitted"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "A:I2: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        rec.nonMutableStorage1 = _nonMutableStorage1;
        rec.nonMutableStorage2 = _nonMutableStorage2;
        //^^^^^^^effects^^^^^^^^^

        writeNonMutableStorage(_idxHash, rec);

        deductServiceCosts(rec.node, 3);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     *     @dev Export FROM Custodial:
     */
    function changeNode(bytes32 _idxHash, uint32 newNode)
        external
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );
        // Node memory node_info =getNodeinfo(rec.node);

        // require(
        //     contractInfo.contractType > 0,
        //     "A:MS: This contract not authorized for specified node"
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "A:EA: User not authorized to modify records in specified node"
        // );
        // require( // require transferrable (51) status
        //     rec.assetStatus == 51,
        //     "A:EA: Asset status must be 51 to export"
        // );
        // //^^^^^^^checks^^^^^^^^^

        // if (rec.numberOfTransfers < 65335) {
        //     rec.numberOfTransfers++;
        // }
        // rec.assetStatus = 70; // Set status to 70 (exported)
        //^^^^^^^effects^^^^^^^^^

        // APP.transferAssetToken(_addr, _idxHash);
        // writeRecord(_idxHash, rec);
        STOR.changeNode(_idxHash, newNode);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    function setEscrow(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external 
    // nonReentrant whenNotPaused 
    {
        // Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        uint256 escrowTime = block.timestamp + _escrowTime;
        uint8 newEscrowStatus;
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );

        // require(                                                                   //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:SE: This contract not authorized for specified node"
        // );
        // require((rec.node != 0), "E:SE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:SE: User not authorized to modify records in specified node"
        // );
        // require(
        //     (escrowTime >= block.timestamp),
        //     "E:SE: Escrow must be set to a time in the future"
        // );
        // require(
        //     (rec.assetStatus != 3) &&
        //         (rec.assetStatus != 4) &&
        //         (rec.assetStatus != 53) &&
        //         (rec.assetStatus != 54) &&
        //         (rec.assetStatus != 5) &&
        //         (rec.assetStatus != 55),
        //     "E:SE: Transferred, lost, or stolen status cannot be set to escrow."
        // );
        // require(
        //     (rec.assetStatus != 6) &&
        //         (rec.assetStatus != 50) &&
        //         (rec.assetStatus != 56),
        //     "E:SE: Asset already in escrow status."
        // );
        // require(
        //     (userType < 5) || (( userType > 4) && ( userType < 10) && (_escrowStatus > 49)),
        //     "E:SE: Non supervisored agents must set escrow status within scope."
        // );
        // require(
        //     (_escrowStatus == 6) ||
        //         (_escrowStatus == 50) ||
        //         (_escrowStatus == 56),
        //     "E:SE: Must specify an valid escrow status"
        // );
        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        ECR_MGR.setEscrow(
            _idxHash,
            newEscrowStatus,
            _escrowOwnerHash,
            escrowTime
        );
        //^^^^^^^interactions^^^^^^^^^
    }


        function setEscrowStor(
        bytes32 _idxHash,
        uint8 _escrowStatus
    ) external 
    // nonReentrant whenNotPaused isAuthorized(_idxHash) 
    {
        // Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.node);
        // uint256 escrowTime = block.timestamp + _escrowTime;
        // uint8 newEscrowStatus;
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );

        // require(                                                                   //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:SE: This contract not authorized for specified node"
        // );
        // require((rec.node != 0), "E:SE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:SE: User not authorized to modify records in specified node"
        // );
        // require(
        //     (escrowTime >= block.timestamp),
        //     "E:SE: Escrow must be set to a time in the future"
        // );
        // require(
        //     (rec.assetStatus != 3) &&
        //         (rec.assetStatus != 4) &&
        //         (rec.assetStatus != 53) &&
        //         (rec.assetStatus != 54) &&
        //         (rec.assetStatus != 5) &&
        //         (rec.assetStatus != 55),
        //     "E:SE: Transferred, lost, or stolen status cannot be set to escrow."
        // );
        // require(
        //     (rec.assetStatus != 6) &&
        //         (rec.assetStatus != 50) &&
        //         (rec.assetStatus != 56),
        //     "E:SE: Asset already in escrow status."
        // );
        // require(
        //     (userType < 5) || (( userType > 4) && ( userType < 10) && (_escrowStatus > 49)),
        //     "E:SE: Non supervisored agents must set escrow status within scope."
        // );
        // require(
        //     (_escrowStatus == 6) ||
        //         (_escrowStatus == 50) ||
        //         (_escrowStatus == 56),
        //     "E:SE: Must specify an valid escrow status"
        // );
        //^^^^^^^checks^^^^^^^^^

        // newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setEscrow(
            _idxHash,
            _escrowStatus
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev takes asset out of excrow status if time period has resolved || is escrow issuer
     */
    function endEscrow(bytes32 _idxHash)
        external
        // nonReentrant
        // isAuthorized(_idxHash)
    {
        // Record memory rec = getRecord(_idxHash);
        // escrowData memory escrow = getEscrowData(_idxHash);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );
        // uint8 userType = getCallingUserType(rec.node);
        // bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        // require(                                                                 //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:EE: This contract not authorized for specified node"
        // );

        // require((rec.node != 0), "E:EE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:EE: User not authorized to modify records in specified node"
        // );
        // require(
        //     (rec.assetStatus == 6) ||
        //         (rec.assetStatus == 50) ||
        //         (rec.assetStatus == 56),
        //     "E:EE- record must be in escrow status"
        // );
        // require(
        //     ((rec.assetStatus > 49) || (userType < 5)),
        //     "E:EE: Usertype less than 5 required to end this escrow"
        // );
        // require(
        //     (escrow.timelock < block.timestamp) ||
        //         (keccak256(abi.encodePacked(_msgSender())) == ownerHash),
        //     "E:EE: Escrow period not ended and caller is not escrow owner"
        // );
        //^^^^^^^checks^^^^^^^^^

        ECR_MGR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }


    function endEscrowStor(bytes32 _idxHash)
        external
        // nonReentrant
        // isAuthorized(_idxHash)
    {
        // Record memory rec = getRecord(_idxHash);
        // escrowData memory escrow = getEscrowData(_idxHash);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.node
        // );
        // uint8 userType = getCallingUserType(rec.node);
        // bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        // require(                                                                 //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:EE: This contract not authorized for specified node"
        // );

        // require((rec.node != 0), "E:EE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:EE: User not authorized to modify records in specified node"
        // );
        // require(
        //     (rec.assetStatus == 6) ||
        //         (rec.assetStatus == 50) ||
        //         (rec.assetStatus == 56),
        //     "E:EE- record must be in escrow status"
        // );
        // require(
        //     ((rec.assetStatus > 49) || (userType < 5)),
        //     "E:EE: Usertype less than 5 required to end this escrow"
        // );
        // require(
        //     (escrow.timelock < block.timestamp) ||
        //         (keccak256(abi.encodePacked(_msgSender())) == ownerHash),
        //     "E:EE: Escrow period not ended and caller is not escrow owner"
        // );
        //^^^^^^^checks^^^^^^^^^

        STOR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function retrieveRecordStor(bytes32 _idxHash)
        external
    {
        STOR.retrieveRecord(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }


        /**
     * @dev Safely burns a token and sets the corresponding RGT to zero in storage.
     */
    function discard(uint256 tokenId) external nonReentrant {
        bytes32 _idxHash = bytes32(tokenId);
        //Record memory rec = getRecord(_idxHash);
        
        // require(                 
        //     _isApprovedOrOwner(_msgSender(), tokenId),
        //     "AT:D:transfer caller is not owner nor approved"
        // );
        // require(//REDUNDANT---will throw in RCLR.discard()
        //     (rec.assetStatus == 59),
        //     "AT:D:Asset must be in status 59 (discardable) to be discarded"
        // );
// 
        //^^^^^^^checks^^^^^^^^^
        RCLR.discard(_idxHash, _msgSender());
        //^^^^^^^interactions^^^^^^^^^
    }

    // function _setPrice(
    //     bytes32 _idxHash,
    //     uint120 _price,
    //     uint8 _currency
    //     // uint256 _setForSale // if 170 then change to transferrable
    // ) external nonReentrant 
    // // whenNotPaused isAuthorized(_idxHash) 
    // {
    //     // Record memory rec = getRecord(_idxHash);

    //     // require(
    //     //     needsImport(rec.assetStatus) == 0,
    //     //     "E:SP Record in unregistered, exported, or discarded status"
    //     // );
    //     // require((rec.assetStatus > 49) || (_setForSale != 170) , "E:SP Asset Status < 50");
    //     // require(isEscrow(rec.assetStatus) == 0, "E:SP Record is in escrow");

    //     // require(
    //     //     _currency == 2,
    //     //     "E:SP: Price must be in PRUF tokens for this contract"
    //     // );
    //     //^^^^^^^checks^^^^^^^^^
    //     // if (_setForSale == 170){
    //     //     rec.assetStatus = 51;
    //     //     writeRecord(_idxHash, rec);
    //     // }

    //     STOR.setPrice(_idxHash, _price, _currency);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    // /*
    //  * @dev set price and currency in rec.pricer rec.currency
    //  */
    // function _clearPrice(bytes32 _idxHash)
    //     external
    //     nonReentrant
    //     // whenNotPaused
    //     // isAuthorized(_idxHash)
    // {
    //     // Record memory rec = getRecord(_idxHash);

    //     // require(
    //     //     needsImport(rec.assetStatus) == 0,
    //     //     "E:DC Record in unregistered, exported, or discarded status"
    //     // );
    //     // require(isEscrow(rec.assetStatus) == 0, "E:SP Record is in escrow");
    //     //^^^^^^^checks^^^^^^^^^

    //     STOR.clearPrice(_idxHash);
    //     //^^^^^^^interactions^^^^^^^^^
    // }
    
}
