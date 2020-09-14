/*-----------------------------------------------------------V0.7.0
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
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE_MAL.sol";

contract MAL_APP is CORE_MAL {
    
    /*
     * @dev Verify user credentials
     * Originating Address:
     */
    // modifier isAuthorized(bytes32 _idxHash) override {
    //     uint256 tokenId = uint256(_idxHash);
    //     require(
    //         (A_TKN.ownerOf(tokenId) == APP_Address),
    //         "NP:MOD-IA: Custodial contract does not hold token"
    //     );
    //     _;
    // }

    //--------------------------------------------External Functions--------------------------

        function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) external payable 
    // nonReentrant whenNotPaused 
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(_assetClass);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     _assetClass
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "A:NR: This contract not authorized for specified AC"
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "A:NR: User not authorized to create records in specified asset class"
        // );
        // require(userType < 5, "A:NR: User not authorized to create records");
        // require(_rgtHash != 0, "A:NR: rights holder cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        //bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) {
            createRecord(_idxHash, _rgtHash, _assetClass, rec.countDownStart);
        } else {
            createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        }
        deductServiceCosts(_assetClass, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function _modStatus(
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
        // uint8 userType = getCallingUserType(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "NP:MS: This contract not authorized for specified AC"
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "NP:MS: User not authorized to modify records in specified asset class"
        // );

        // require(
        //     isLostOrStolen(_newAssetStatus) == 0,
        //     "NP:MS: Cannot place asset in lost or stolen status using modStatus"
        // );
        // require(
        //     isEscrow(_newAssetStatus) == 0,
        //     "NP:MS: Cannot place asset in Escrow using modStatus"
        // );
        // require(
        //     needsImport(_newAssetStatus) == 0,
        //     "NP:MS: Cannot place asset in unregistered, exported, or discarded status using modStatus"
        // );
        // require(
        //     (_newAssetStatus < 100) &&
        //         (_newAssetStatus != 7) &&
        //         (_newAssetStatus != 57) &&
        //         (_newAssetStatus != 58),
        //     "NP:MS: Specified Status is reserved."
        // );
        // require(
        //     isEscrow(rec.assetStatus) == 0,
        //     "NP:MS: Cannot change status of asset in Escrow until escrow is expired"
        // );
        // require(
        //     needsImport(rec.assetStatus) == 0,
        //     "NP:MS: Record in unregistered, exported, or discarded status"
        // );
        // require(
        //     (rec.assetStatus > 49) || (userType < 5),
        //     "NP:MS: Only usertype < 5 can change status < 49"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "NP:MS: Rightsholder does not match supplied data"
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
    function _setLostOrStolen(
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
        // uint8 userType = getCallingUserType(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "NP:SLS: This contract not authorized for specified AC"
        // );
        // require(
        //     (rec.rightsHolder != 0),
        //     "NP:SLS: Record unclaimed: import required. "
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "NP:SLS: User not authorized to modify records in specified asset class"
        // );
        // require(
        //     isLostOrStolen(_newAssetStatus) == 170,
        //     "NP:SLS: Must set to a lost or stolen status"
        // );
        // require(
        //     (rec.assetStatus > 49) ||
        //         ((_newAssetStatus < 50) && (userType < 5)),
        //     "NP:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        // );
        // require(
        //     (rec.assetStatus != 5) && (rec.assetStatus != 55),
        //     "NP:SLS: Transferred asset cannot be set to lost or stolen after transfer."
        // );
        // require(
        //     (rec.assetStatus != 50),
        //     "NP:SLS: Asset in locked escrow cannot be set to lost or stolen"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "NP:SLS: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setStolenOrLost(_idxHash, rec.assetStatus);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function _decCounter(
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
        // uint8 userType = getCallingUserType(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "NP:DC: This contract not authorized for specified AC"
        // );

        // require(
        //     (rec.rightsHolder != 0),
        //     "NP:DC: Record unclaimed: import required. "
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "NP:DC: User not authorized to modify records in specified asset class"
        // );
        // require(
        //     isEscrow(rec.assetStatus) == 0,
        //     "NP:DC: Cannot modify asset in Escrow"
        // );
        // require(_decAmount > 0, "NP:DC: cannot decrement by negative number");

        // require(
        //     needsImport(rec.assetStatus) == 0,
        //     "NP:DC Record in unregistered, exported, or discarded status"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "NP:DC: Rightsholder does not match supplied data"
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
    // function _decCounterFMR(
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
    //     // uint8 userType = getCallingUserType(rec.assetClass);
    //     // ContractDataHash memory contractInfo = getContractInfo(
    //     //     address(this),
    //     //     rec.assetClass
    //     // );

    //     // require(
    //     //     contractInfo.contractType > 0,
    //     //     "NP:DC: This contract not authorized for specified AC"
    //     // );

    //     // require(
    //     //     (rec.rightsHolder != 0),
    //     //     "NP:DC: Record unclaimed: import required. "
    //     // );
    //     // require(
    //     //     (userType > 0) && (userType < 10),
    //     //     "NP:DC: User not authorized to modify records in specified asset class"
    //     // );
    //     // require(
    //     //     isEscrow(rec.assetStatus) == 0,
    //     //     "NP:DC: Cannot modify asset in Escrow"
    //     // );
    //     // require(_decAmount > 0, "NP:DC: cannot decrement by negative number");

    //     // require(
    //     //     needsImport(rec.assetStatus) == 0,
    //     //     "NP:DC Record in unregistered, exported, or discarded status"
    //     // );
    //     require(
    //         rec.rightsHolder == _rgtHash,
    //         "NP:DC: Rightsholder does not match supplied data"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     // if (rec.forceModCount > _decAmount) {
    //     //     rec.forceModCount = rec.forceModCount - (_decAmount);
    //     // } else {
    //     //     rec.forceModCount = 0;
    //     // }
    //     //^^^^^^^effects^^^^^^^^^
    //     rec.forceModCount = rec.forceModCount - (_decAmount);
    //     writeRecord(_idxHash, rec);
    //     return (rec.forceModCount);
    //     //^^^^^^^interactions^^^^^^^^^
    // }
                                                                                               //NEEDS TO BE MODIFIED IN STORAGE
    // function _decCounterTXFR(
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
    //     // uint8 userType = getCallingUserType(rec.assetClass);
    //     // ContractDataHash memory contractInfo = getContractInfo(
    //     //     address(this),
    //     //     rec.assetClass
    //     // );

    //     // require(
    //     //     contractInfo.contractType > 0,
    //     //     "NP:DC: This contract not authorized for specified AC"
    //     // );

    //     // require(
    //     //     (rec.rightsHolder != 0),
    //     //     "NP:DC: Record unclaimed: import required. "
    //     // );
    //     // require(
    //     //     (userType > 0) && (userType < 10),
    //     //     "NP:DC: User not authorized to modify records in specified asset class"
    //     // );
    //     // require(
    //     //     isEscrow(rec.assetStatus) == 0,
    //     //     "NP:DC: Cannot modify asset in Escrow"
    //     // );
    //     // require(_decAmount > 0, "NP:DC: cannot decrement by negative number");

    //     // require(
    //     //     needsImport(rec.assetStatus) == 0,
    //     //     "NP:DC Record in unregistered, exported, or discarded status"
    //     // );
    //     require(
    //         rec.rightsHolder == _rgtHash,
    //         "NP:DC: Rightsholder does not match supplied data"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     // if (rec.numberOfTransfers > _decAmount) {
    //     //     rec.numberOfTransfers = rec.numberOfTransfers - (_decAmount);
    //     // } else {
    //     //     rec.numberOfTransfers = 0;
    //     // }
    //     //^^^^^^^effects^^^^^^^^^
    //     rec.numberOfTransfers = rec.numberOfTransfers.sub(_decAmount);
    //     writeRecord(_idxHash, rec);
    //     return (rec.numberOfTransfers);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    /*
     * @dev Modify **Record**.Ipfs1 with confirmation
     */
    function _modIpfs1(
        bytes32 _idxHash,
        // bytes32 _rgtHash,
        bytes32 _IpfsHash
    )
        external
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "NP:MI1: This contract not authorized for specified AC"
        // );
        // require(
        //     (rec.rightsHolder != 0),
        //     "NP:MI1: Record unclaimed: import required."
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "NP:MI1: User not authorized to modify records in specified asset class"
        // );
        // require(rec.Ipfs1 != _IpfsHash, "NP:MI1: New data same as old");

        // require(
        //     isEscrow(rec.assetStatus) == 0,
        //    "NP:MI1: Cannot modify asset in Escrow"
        // );
        // require(
        //     needsImport(rec.assetStatus) == 0,
        //     "NP:MI1: Record in unregistered, exported, or discarded status"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "NP:MI1: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     */
    function $addIpfs2Note(
        bytes32 _idxHash,
        // bytes32 _rgtHash,
        bytes32 _IpfsHash
    )
        external
        payable
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );

        // require(
        //     contractInfo.contractType > 0,
        //     "A:I2: This contract not authorized for specified AC"
        // );
        // require(
        //     (rec.rightsHolder != 0),
        //     "A:I2: Record unclaimed: import required. "
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "A:I2: User not authorized to modify records in specified asset class"
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
        //     rec.Ipfs2 == 0,
        //     "A:I2: Ipfs2 has data already. Overwrite not permitted"
        // );
        // require(
        //     rec.rightsHolder == _rgtHash,
        //     "A:I2: Rightsholder does not match supplied data"
        // );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductServiceCosts(rec.assetClass, 3);

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     *     @dev Export FROM Custodial:
     */
    function changeAC(bytes32 _idxHash, uint32 newAssetClass)
        external
        // nonReentrant
        // whenNotPaused
        // isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );
        // AC memory AC_info = getACinfo(rec.assetClass);

        // require(
        //     contractInfo.contractType > 0,
        //     "A:MS: This contract not authorized for specified AC"
        // );
        // require(
        //     (userType > 0) && (userType < 10),
        //     "A:EA: User not authorized to modify records in specified asset class"
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
        STOR.changeAC(_idxHash, newAssetClass);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    function setEscrow(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external 
    // nonReentrant whenNotPaused isAuthorized(_idxHash) 
    {
        // Record memory rec = getRecord(_idxHash);
        // uint8 userType = getCallingUserType(rec.assetClass);
        uint256 escrowTime = block.timestamp.add(_escrowTime);
        uint8 newEscrowStatus;
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );

        // require(                                                                   //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:SE: This contract not authorized for specified AC"
        // );
        // require((rec.assetClass != 0), "E:SE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:SE: User not authorized to modify records in specified asset class"
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
        // uint8 userType = getCallingUserType(rec.assetClass);
        // uint256 escrowTime = block.timestamp.add(_escrowTime);
        // uint8 newEscrowStatus;
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     rec.assetClass
        // );

        // require(                                                                   //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:SE: This contract not authorized for specified AC"
        // );
        // require((rec.assetClass != 0), "E:SE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:SE: User not authorized to modify records in specified asset class"
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
        //     rec.assetClass
        // );
        // uint8 userType = getCallingUserType(rec.assetClass);
        // bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        // require(                                                                 //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:EE: This contract not authorized for specified AC"
        // );

        // require((rec.assetClass != 0), "E:EE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:EE: User not authorized to modify records in specified asset class"
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
        //         (keccak256(abi.encodePacked(msg.sender)) == ownerHash),
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
        //     rec.assetClass
        // );
        // uint8 userType = getCallingUserType(rec.assetClass);
        // bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        // require(                                                                 //Storage IA mod takes care of it?
        //     contractInfo.contractType > 0,
        //     "E:EE: This contract not authorized for specified AC"
        // );

        // require((rec.assetClass != 0), "E:EE: Record does not exist");
        // require(
        //     (userType > 0) && (userType < 10),
        //     "E:EE: User not authorized to modify records in specified asset class"
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
        //         (keccak256(abi.encodePacked(msg.sender)) == ownerHash),
        //     "E:EE: Escrow period not ended and caller is not escrow owner"
        // );
        //^^^^^^^checks^^^^^^^^^

        STOR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function retrieveRecordStor(bytes32 _idxHash)
        external view
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
        
        // require(                 //REDUNDANT---will throw in RCLR.discard()
        //     _isApprovedOrOwner(_msgSender(), tokenId),
        //     "AT:D:transfer caller is not owner nor approved"
        // );
        // require(
        //     (rec.assetStatus == 59),
        //     "AT:D:Asset must be in status 59 (discardable) to be discarded"
        // );

        //^^^^^^^checks^^^^^^^^^
        RCLR.discard(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
    
}
