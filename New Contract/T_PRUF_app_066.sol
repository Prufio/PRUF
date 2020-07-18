/*-----------------------------------------------------------------
 *  TO DO
 * Make Newrecord require authorized user
 * Make recycle .... deposit?
*-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_core_066.sol";

contract T_PRUF_NP is PRUF {
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
            (AssetTokenContract.ownerOf(tokenID) == msg.sender), //msg.sender is token holder
            "TPA:IA: Caller does not hold token"
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
    ) external payable nonReentrant {
        uint256 tokenId = uint256(_idxHash);
        User memory user = getUser();
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            user.userType == 1,
            "TPA:NR: User not authorized to create records"
        );
        require(
            user.authorizedAssetClass == _assetClass,
            "TPA:NR: User not authorized for asset class"
        );
        require(
            AC_info.custodyType == 2,
            "TPA:NR: Contract not authorized for custodial assets"
        );
        require(_rgtHash != 0, "PA:NR: rights holder cannot be zero");
        require(_assetClass != 0, "PA:NR: Asset class cannot be zero");
        require( //if creating new record in new root and idxhash is identical, fail because its probably fraud
            ((AC_info.assetClassRoot == oldAC_info.assetClassRoot) ||
                (rec.assetClass == 0)),
            "TPA:NR: Cannot re-create asset in new root assetClass"
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) {
            // if record exists as a "dead record" has an old AC, and is being recreated in the same root class,
            // do not overwrite anything besides assetClass and rightsHolder (storage will set assetStatus to 51)
            Storage.newRecord(
                userHash,
                _idxHash,
                _rgtHash,
                _assetClass,
                rec.countDownStart,
                rec.Ipfs1
            );
        } else {
            // Otherwise, idxHash is unuiqe and an entirely new record is created
            Storage.newRecord(
                userHash,
                _idxHash,
                _rgtHash,
                _assetClass,
                _countDownStart,
                _Ipfs1
            );
        }

        deductNewRecordCosts(_assetClass);

        AssetTokenContract.mintAssetToken(msg.sender, tokenId, "pruf.io");
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remint token with confirmation of posession of RAWTEXT hash inputs
     * must Match rgtHash using raw data fields ---------------------------security risk--------REVIEW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     */
    function $reMintToken(
        bytes32 _idxHash,
        string memory first,
        string memory middle,
        string memory last,
        string memory id,
        string memory secret
    ) external payable nonReentrant returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);
        uint256 tokenId = uint256(_idxHash);

        require(
            AC_info.custodyType == 2,
            "TPA:RMT:Contract not authorized for custodial assets"
        );
        require(rec.rightsHolder != 0, "PA:I2: Record does not exist");
        require(
            (rec.assetStatus != 60),
            "TPA:RMT:Record is burned and must be reimported by ACadmin"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "TPA:RMT:Cannot modify asset in Escrow"
        );
        require(rec.assetStatus < 200, "PA:I2: Record locked");
        require(
            (rec.assetStatus != 5) &&
                (rec.assetStatus != 55) &&
                (rec.assetStatus != 60),
            "TPA:RMT:Record In Transferred-unregistered or burned status"
        );
        require(
            rec.rightsHolder ==
                keccak256(abi.encodePacked(first, middle, last, id, secret)),
            "TPA:RMT:Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        deductNewRecordCosts(rec.assetClass);

        tokenId = AssetTokenContract.reMintAssetToken(
            msg.sender,
            tokenId,
            "pruf.io"
        );

        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     */
    function $addIpfs2Note(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    ) external payable nonReentrant isAuthorized(_idxHash) returns (bytes32) {
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 2,
            "TPA:I2:Contract not authorized for custodial assets"
        );
        require((rec.rightsHolder != 0), "PA:I2: Record does not exist");
        require(
            (rec.assetStatus != 60),
            "TPA:I2:Record is burned and must be reimported by ACadmin"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "TPA:I2:Cannot modify asset in Escrow"
        );
        require(rec.assetStatus < 200, "PA:I2: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "TPA:I2:Record In Transferred-unregistered status"
        );
        require(
            rec.Ipfs2 == 0,
            "TPA:I2:Ipfs2 has data already. Overwrite not permitted"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "TPA:I2:Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductCreateNoteCosts(rec.assetClass);

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------Internal Functions--------------------------
    function getUser() internal override view returns (User memory) {
        User memory user;
        (
            user.userType,
            user.authorizedAssetClass
        ) = AssetClassTokenManagerContract.getUserExt(
            keccak256(abi.encodePacked(msg.sender))
        );

        return user;
        //^^^^^^^interactions^^^^^^^^^
    }
}
