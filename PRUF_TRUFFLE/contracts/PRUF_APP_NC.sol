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
        uint32 _assetClass,
        uint32 _countDownStart
    ) external payable nonReentrant whenNotPaused {
        require(
            (ID_TKN.balanceOf(msg.sender) == 1), //msg.sender is token holder
            "ANC:MOD-IA: Caller does not hold a valid PRuF_ID token"
        );
        //^^^^^^^Checks^^^^^^^^^

        createRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);

        deductServiceCosts(_assetClass, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Import a record into a new asset class
     */
    function $importAsset(bytes32 _idxHash, uint32 _newAssetClass)
        external
        payable
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(rec.assetStatus == 70, "ANC:IA: Asset not exported");
        require(
            AC_MGR.isSameRootAC(_newAssetClass, rec.assetClass) == 170,
            "ANC:IA:Cannot change AC to new root"
        );
        //^^^^^^^checks^^^^^^^^^
        rec.assetStatus = 52;

        STOR.changeAC(_idxHash, _newAssetClass);
        writeRecord(_idxHash, rec);
        deductServiceCosts(_newAssetClass, 1);

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
            "ANC:RMT: contract not auth for AC"
        );
        require(
            rec.rightsHolder !=
                0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF,
            "ANC:RMT:Record not remintable"
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "ANC:RMT:Cannot modify asset in Escrow"
        );
        require(                                          //STATE UNREACHABLE
            needsImport(rec.assetStatus) == 0,
            "ANC:RMT:Record In Transferred-unregistered or discarded status"
        );
        require(
            rec.rightsHolder == keccak256(abi.encodePacked(_idxHash, rawHash)),
            "ANC:RMT:Rightsholder does not match hash from data"
        );
        //^^^^^^^checks^^^^^^^^^

        deductServiceCosts(rec.assetClass, 1);

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
        require(                                          //STATE UNREACHABLE
            needsImport(rec.assetStatus) == 0,
            "ANC:I2:Record In Transferred, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductServiceCosts(rec.assetClass, 3);

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }
}
