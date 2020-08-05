/*-----------------------------------------------------------V0.6.7
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
pragma solidity ^0.7.0;

import "./PRUF_CORE.sol";

contract APP is CORE {
    modifier isAuthorized(bytes32 _idxHash) override {
        //require that user is authorized and token is held by contract
        uint256 tokenID = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenID) == APP_Address),
            "PA:IA: Custodial contract does not hold token"
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
        uint16 _assetClass,
        uint256 _countDownStart
    ) external payable nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(_assetClass);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            _assetClass
        );

        require(
            contractInfo.contractType > 0,
            "PNP:MS: Contract not authorized for this asset class"
        );
        require(
            (userType > 0) && (userType < 10),
            "PA:NR: User not authorized to create records in specified asset class"
        );
        require(userType < 5, "PA:NR: User not authorized to create records");
        require(_rgtHash != 0, "PA:NR: rights holder cannot be zero");
        require(rec.assetStatus < 200, "TPA:NR: Old Record locked");
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
     *     @dev Export FROM Custodial:
     */
    function exportAsset(bytes32 _idxHash, address _addr)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            contractInfo.contractType > 0,
            "PA:MS: Contract not authorized for this asset class"
        );
        require(
            (userType > 0) && (userType < 10),
            "PA:EA: User not authorized to modify records in specified asset class"
        );
        require( // require transferrable (51) status
            rec.assetStatus == 51,
            "PA:EA: Asset status must be 51 to export"
        );
        //^^^^^^^checks^^^^^^^^^
        
        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }
        rec.assetStatus = 70; // Set status to 70 (exported)
        //^^^^^^^effects^^^^^^^^^
        
        A_TKN.safeTransferFrom(address(this), _addr, tokenId); // sends token to rightsholder wallet (specified by auth user)
        writeRecord(_idxHash, rec);
        STOR.changeAC(_idxHash, AC_info.assetClassRoot);
        

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
            "PNP:MS: Contract not authorized for this asset class"
        );

        require((rec.rightsHolder != 0), "PA:FMR: Record unclaimed: import required. ");

        require(
            userType == 1,
            "PA:FMR: User not authorized to force modify records in this asset class"
        );
        require(_rgtHash != 0, "PA:FMR: rights holder cannot be zero");
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54),
            "PA:FMR: Cannot modify asset in lost or stolen status"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "PA:FMR: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PA:FMR: Record In Transferred-unregistered status"
        );
        require(rec.assetStatus < 200, "PA:FMR: Record locked");
        //^^^^^^^checks^^^^^^^^^

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }

        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductForceModifyCosts(rec.assetClass);

        return rec.forceModCount;
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
            "PNP:MS: Contract not authorized for this asset class"
        );
        require((rec.rightsHolder != 0), "PA:TA: Record unclaimed: import required. ");
        require(
            (userType > 0) && (userType < 10),
            "PA:TA: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus > 49) || (userType < 5),
            "PA:TA:Only usertype < 5 can change status < 50"
        );
        require(
            (rec.assetStatus == 1) || (rec.assetStatus == 51),
            "PA:TA:Asset status is not transferrable"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "PA:TA:Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^
        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }

        if (_newrgtHash == 0x0) {
            //set to transferred status
            rec.assetStatus = 5;
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

        require(
            contractInfo.contractType > 0,
            "PNP:MS: Contract not authorized for this asset class"
        );
        require((rec.rightsHolder != 0), "PA:I2: Record unclaimed: import required. ");
        require(
            (userType > 0) && (userType < 10),
            "PA:I2: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "PA:I2: Cannot modify asset in Escrow"
        );
        require(rec.assetStatus < 200, "PA:I2: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PA:I2: Record In Transferred-unregistered status"
        );
        require(
            rec.Ipfs2 == 0,
            "PA:I2: Ipfs2 has data already. Overwrite not permitted"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "PA:I2: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductCreateNoteCosts(rec.assetClass);

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev import **Record** (no confirmation required -
     * posessor is considered to be owner. sets rec.assetStatus to 0.
     */
    function $importAsset(
        bytes32 _idxHash,
        bytes32 _newRgtHash,
        uint16 _newAssetClass
    )
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(_newAssetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "PNP:MS: Contract not authorized for this asset class"
        );
        require((rec.assetClass != 0), "PA:IA: Record does not exist. ");
        require(userType < 3, "PA:IA: User not authorized to reimport assets");

        require(
            (userType > 0) && (userType < 10),
            "PA:IA: User not authorized to modify records in specified asset class"
        );
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "TPA:IA:Cannot change AC to new root"
        );
        require(
            (rec.assetStatus == 5) ||
                (rec.assetStatus == 55) ||
                (rec.assetStatus == 70),
            "PA:IA: Only Transferred or exported assets can be reimported"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        rec.assetStatus = 0; // --------------------------------Should this be?
        rec.rightsHolder = _newRgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        STOR.changeAC(_idxHash, _newAssetClass);
        deductNewRecordCosts(rec.assetClass);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }
}
