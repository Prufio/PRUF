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

contract NAKED is CORE {
    uint256 importDiscount = 2;

    /*
     * @dev Sets import discount for this contract
     */
    function setImportDiscount(uint256 _importDiscount) external onlyOwner {
        if (_importDiscount < 1) {
            importDiscount = 1;
        } else {
            importDiscount = _importDiscount;
        }
    }

    function mintNakedAsset(
        bytes32 _idxHash,
        string calldata _tokenURI, // token URI needs to be K256(packed( uint16 assetClass, string authCode)) supplied off chain
        uint16 _assetClass
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(_assetClass);

        require(
            (AC_TKN.ownerOf(_assetClass) == msg.sender), //msg.sender is token holder
            "ANC:MOD-IA: Caller does not hold asset token"
        );
        require(userType == 10,"user not authorized to mint naked assets");
        require(
            A_TKN.tokenExists(tokenId) == 0,
            "PNP:INA: Token already exists"
        );
        require(
            rec.assetClass == 0,
            "PNP:INA: Asset already registered in system"
        );
        //^^^^^^^checks^^^^^^^^^

        A_TKN.mintAssetToken(address(this), tokenId, _tokenURI); //mint a naked token

        //^^^^^^^interactions / effects^^^^^^^^^^^^
    }

    /*
     * @dev Import a record into a new asset class
     */
    function $claimNakedAsset(
        bytes32 _idxHash,
        string calldata _authCode,
        uint16 _newAssetClass,
        bytes32 _rgtHash,
        uint256 _countDownStart
    ) external payable nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            A_TKN.ownerOf(tokenId) == address(this),
            "PNP:INA: Token not found in PRUF_NAKED"
        );
        require(
            contractInfo.contractType > 0,
            "PNP:INA: This contract not authorized for specified AC"
        );
        require(
            rec.assetClass == 0,
            "PNP:INA: Asset already registered in system"
        );
        //^^^^^^^checks^^^^^^^^^

        A_TKN.validateNakedToken(tokenId, _newAssetClass, _authCode); //Verify supplied data matches tokenURI

        STOR.newRecord(_idxHash, _rgtHash, _newAssetClass, _countDownStart); // Make a new record at the tokenId b32

        A_TKN.setURI(tokenId, "pruf.io"); // set URI

        A_TKN.safeTransferFrom(address(this), msg.sender, tokenId); // sends token from this holding contract to caller wallet

        deductImportRecordCosts(_newAssetClass);

        //^^^^^^^interactions / effects^^^^^^^^^^^^
    }

    function deductImportRecordCosts(uint16 _assetClass)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AC_MGR.getNewRecordCosts(_assetClass);

        pricing.rootPrice = pricing.rootPrice.div(importDiscount);
        pricing.ACTHprice = pricing.ACTHprice.div(importDiscount);

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }
}
