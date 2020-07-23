/*-----------------------------------------------------------------
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
 *-----------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_core_067.sol";

contract PRUF_APP is PRUF {
    modifier isAuthorized(bytes32 _idxHash) override {
        //require that user is authorized and token is held by contract
        uint256 tokenID = uint256(_idxHash);
        require(
            (AssetTokenContract.ownerOf(tokenID) == PrufAppAddress),
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
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external payable nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(_assetClass);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:NR: Contract not authorized for non-custodial assets"
        );
        require(
            (userType > 0) && (userType < 10),
            "PA:NR: User not authorized to create records in specified asset class"
        );
        require(userType < 5, "PA:NR: User not authorized to create records");
        require(_rgtHash != 0, "PA:NR: rights holder cannot be zero");

        //^^^^^^^checks^^^^^^^^^

        //bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) {
            Storage.newRecord(
                //userHash,
                _idxHash,
                _rgtHash,
                _assetClass,
                rec.countDownStart,
                rec.Ipfs1
            );
        } else {
            Storage.newRecord(
                //userHash,
                _idxHash,
                _rgtHash,
                _assetClass,
                _countDownStart,
                _Ipfs1
            );
        }
        deductNewRecordCosts(_assetClass);
        AssetTokenContract.mintAssetToken(address(this), tokenId, "pruf.io");
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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PNP:EA: Contract not authorized for non-custodial assets"
        );
        require(
            (userType > 0) && (userType < 10),
            "PNP:EA: User not authorized to modify records in specified asset class"
        );
        require( // require transferrable (51) status
            rec.assetStatus == 51,
            "PNP:EA: Asset status must be 51 to export"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = 70; // Set status to 70 (exported)

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }
        //^^^^^^^effects^^^^^^^^^
        
        AssetTokenContract.safeTransferFrom(address(this), _addr, tokenId); // sends token to rightsholder wallet (specified by auth user)
        writeRecord(_idxHash, rec);

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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:FMR: Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "PA:FMR: Record does not exist");

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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:TA: Contract not authorized for non-custodial assets"
        );
        require((rec.rightsHolder != 0), "PA:TA: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "PA:TA: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus > 49) || (userType < 5),
            "PA:TA:Only usertype < 5 can change status < 50"
        );
        require(_newrgtHash != 0, "PA:TA:new Rightsholder cannot be blank");
        require(
            (rec.assetStatus == 1) || (rec.assetStatus == 51),
            "PA:TA:Asset status is not transferrable"
        );
        require(rec.assetStatus < 200, "PA:TA: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "PA:TA:Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^
        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:I2: Contract not authorized for non-custodial assets"
        );
        require((rec.rightsHolder != 0), "PA:I2: Record does not exist");
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
        bytes32 _rgtHash,
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
        AC memory AC_info = getACinfo(_newAssetClass);

        require(
            AC_info.custodyType == 1,
            "PA:IA: Contract not authorized for non-custodial assets"
        );
        require((rec.rightsHolder != 0), "PA:IA: Record does not exist");
        require(userType < 3, "PA:IA: User not authorized to reimport assets");

        require(
            (userType > 0) && (userType < 10),
            "PA:IA: User not authorized to modify records in specified asset class"
        );
        require(
            AssetClassTokenManagerContract.isSameRootAC(
                _newAssetClass,
                rec.assetClass
            ) == 170,
            "TPA:IA:Cannot change AC to new root"
        );
        require(
            (rec.assetStatus == 5) ||
                (rec.assetStatus == 55) ||
                (rec.assetStatus == 70),
            "PA:IA: Only Transferred or exported assets can be reimported"
        );
        require(rec.assetStatus < 200, "PA:IA: Record locked");
        //^^^^^^^checks^^^^^^^^^

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        rec.assetStatus = 0;   // --------------------------------Should this be?
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        Storage.changeAC(_idxHash, _newAssetClass);
        deductNewRecordCosts(rec.assetClass);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }
}
