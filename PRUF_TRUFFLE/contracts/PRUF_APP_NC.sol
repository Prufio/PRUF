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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";

contract APP_NC is CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == msg.sender), //msg.sender is token holder
            "ANC:MOD-IA: Caller does not hold token"
        );
        _;
    }



    //--------------------------------------------External Functions--------------------------
    /*
     * @dev Create a  newRecord
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
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "ANC:NR: This contract not authorized for specified AC"
        );
        require(
            userType == 1,
            "ANC:NR: User not authorized to create records in this asset class"
        );
        require(_rgtHash != 0, "ANC:NR: rights holder cannot be zero");
        require(_assetClass != 0, "ANC:NR: Asset class cannot be zero");
        require( //if creating new record in new root and idxhash is identical, fail because its probably fraud
            ((AC_info.assetClassRoot == oldAC_info.assetClassRoot) ||
                (rec.assetClass == 0)),
            "ANC:NR: Cannot re-create asset in new root assetClass"
        );
        //^^^^^^^checks^^^^^^^^^

        //bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) {
            // if record exists as a "dead record" has an old AC, and is being recreated in the same root class,
            // do not overwrite anything besides assetClass and rightsHolder (STOR will set assetStatus to 51)
            createRecord(_idxHash, _rgtHash, _assetClass, rec.countDownStart);
        } else {
            // Otherwise, idxHash is unuiqe and an entirely new record is created
            createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        }

        deductNewRecordCosts(_assetClass);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Import a record into a new asset class
     */
    function $importAsset(bytes32 _idxHash, uint16 _newAssetClass)
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            _newAssetClass
        );
        require(
            rec.assetStatus == 70,
            "ANC:IA: Asset not exported"
        );
        require(
            contractInfo.contractType > 0,
            "ANC:IA: This contract not authorized for specified AC"
        );
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "ANC:IA:Cannot change AC to new root"
        );
        //^^^^^^^checks^^^^^^^^^
        rec.assetStatus = 52;

        STOR.changeAC(_idxHash, _newAssetClass);
        writeRecord(_idxHash, rec);
        deductNewRecordCosts(_newAssetClass);
        //^^^^^^^interactions / effects^^^^^^^^^^^^
    }


    /*
     * @dev remint token with confirmation of posession of RAWTEXT hash inputs
     * must Match rgtHash using raw data fields ---------------------------security risk--------REVIEW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     */
    function $reMintToken(
        bytes32 _idxHash,
        string calldata first,
        string calldata middle,
        string calldata last,
        string calldata id,
        string calldata secret
    ) external payable nonReentrant whenNotPaused returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );
        uint256 tokenId = uint256(_idxHash);
        bytes32 rawHash = keccak256(
            abi.encodePacked(first, middle, last, id, secret)
        );

        require(
            contractInfo.contractType > 0,
            "ANC:RMT: This contract not authorized for specified AC"
        );
        require(rec.rightsHolder != 0, "ANC:RMT:Record not remintable");
        require(
            rec.rightsHolder !=
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
            "ANC:RMT:Record not remintable"
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "ANC:RMT:Cannot modify asset in Escrow"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:RMT:Record In Transferred-unregistered or discarded status"
        );
        require(
            rec.rightsHolder == keccak256(abi.encodePacked(_idxHash, rawHash)),
            "ANC:RMT:Rightsholder does not match hash from data"
        );
        //^^^^^^^checks^^^^^^^^^

        deductNewRecordCosts(rec.assetClass);

        tokenId = A_TKN.reMintAssetToken(msg.sender, tokenId);

        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     */
    function $addIpfs2Note(bytes32 _idxHash, bytes32 _IpfsHash)
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "ANC:I2: This contract not authorized for specified AC"
        );
        require((rec.assetClass != 0), "ANC:I2: Record does not exist");
        require(
            isEscrow(rec.assetStatus) == 0,
            "ANC:I2:Cannot modify asset in Escrow"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "ANC:I2:Record In Transferred, exported, or discarded status"
        );
        require(
            rec.Ipfs2 == 0,
            "ANC:I2:Ipfs2 has data already. Overwrite not permitted"
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
