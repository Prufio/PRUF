/*-----------------------------------------------------------V0.6.8
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
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";

contract APP is CORE {
    modifier isAuthorized(bytes32 _idxHash) override {
        //require that user is authorized and token is held by contract
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == APP_Address),
            "A:MOD-IA: Custodial contract does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Wrapper for newRecord
     */
    function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) external payable nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(_assetClass);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);
        // ContractDataHash memory contractInfo = getContractInfo(
        //     address(this),
        //     _assetClass
        // );

        // require(contractInfo.contractType > 0, "A:NR: contract not auth in AC"); //MAKE INTO MODIFIER?!?!?!?!    //REDUNDANT, THROWS IN STORAGE newRecord
        require((userType > 0) && (userType < 10), "A:NR: User not auth in AC");
        require(userType < 5, "A:NR: User not authorized to create records");
        // require(_rgtHash != 0, "A:NR: RGT = 0");                      //REDUNDANT, THROWS IN STORAGE newRecord
        //^^^^^^^checks^^^^^^^^^

        //bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) {
            createRecord(_idxHash, _rgtHash, _assetClass, rec.countDownStart);
        } else {
            createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        }
        deductNewRecordCosts(_assetClass);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev import **Record** (no confirmation required -
     * posessor is considered to be owner. sets rec.assetStatus to 0.
     */
    function $importAsset(
        bytes32 _idxHash,
        bytes32 _newRgtHash,
        uint32 _newAssetClass
    )
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash) //contract holds token (user sent to contract)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(_newAssetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            _newAssetClass
        );

        require(
            contractInfo.contractType > 0,
            "A:IA: unauthorized for AC. Orphan token?"
        );
        require(rec.assetClass != 0, "A:IA: Record does not exist. "); //CANNOT BE TESTED, ASSERT??
        require(userType < 3, "A:IA: User not authorized to import assets");
        require((userType > 0) && (userType < 10), "A:IA: User not auth in AC");
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "A:IA:Cannot change AC to new root"
        );
        require(
            (rec.assetStatus == 5) ||
                (rec.assetStatus == 55) ||
                (rec.assetStatus == 70),
            "A:IA: Only Transferred or exported assets can be reimported"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.incrementForceModCount = 170;

        rec.assetStatus = 0;
        rec.rightsHolder = _newRgtHash;
        //^^^^^^^effects^^^^^^^^^

        STOR.changeAC(_idxHash, _newAssetClass);
        writeRecord(_idxHash, rec);
        deductNewRecordCosts(_newAssetClass);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.rightsHolder without confirmation required
     */
    function $forceModRecord(bytes32 _idxHash, bytes32 _rgtHash)
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "A:FMR: unauthorized for AC. Orphan token?"
        );
        require(userType == 1, "A:FMR: User not auth in AC");
        require(_rgtHash != 0, "A:FMR:RGT = 0");
        require(
            isLostOrStolen(rec.assetStatus) == 0,
            "A:FMR: Asset marked L/S"
        );
        require(isEscrow(rec.assetStatus) == 0, "A:FMR: Asset in escrow");
        require(isEscrow(rec.assetStatus) == 0, "A:FMR: Asset in escrow");
        require( //IMPOSSIBLE TO THROW REVERTS IN REQ1
            needsImport(rec.assetStatus) == 0,
            "A:FMR: Asset needs re-imported"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.incrementForceModCount = 170;

        rec.incrementNumberOfTransfers = 170;

        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductForceModifyCosts(rec.assetClass);

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Transfer Rights to new rightsHolder with confirmation
     */
    function $transferAsset(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _newrgtHash
    )
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "A:TA: unauthorized for AC. Orphan token?"
        );
        require((userType > 0) && (userType < 10), "A:TA: User not auth in AC");
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

        rec.incrementNumberOfTransfers = 170;

        if (_newrgtHash == 0x0) {
            //set to transferred status
            rec.assetStatus = 5;
            _newrgtHash = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
        }

        rec.rightsHolder = _newrgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductTransferAssetCosts(rec.assetClass);

        return (170);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     */
    function $addIpfs2Note(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    )
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(                                                                           //redundant, will throw in storage
            contractInfo.contractType > 0,
            "A:I2: unauthorized for AC. Orphan token?"
        );
        require((userType > 0) && (userType < 10), "A:I2: User not auth in AC");
        require(
            isLostOrStolen(rec.assetStatus) == 0,
            "A:FMR: Asset marked lost or stolen"
        );
        // require(                                                                           //redundant, will throw in storage
        //     isEscrow(rec.assetStatus) == 0,
        //     "A:FMR: Asset in escrow"
        // );
        require(                                                      //IMPOSSIBLE TO THROW REVERTS IN REQ1
            needsImport(rec.assetStatus) == 0,
            "A:FMR: Asset needs re-imported"
        );
        // require(                                                                           //redundant, will throw in storage
        //     rec.Ipfs2 == 0,
        //     "A:I2: Ipfs2 has data already. Overwrite not permitted"
        // );
        require(
            rec.rightsHolder == _rgtHash,
            "A:I2: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductCreateNoteCosts(rec.assetClass);

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }
}
