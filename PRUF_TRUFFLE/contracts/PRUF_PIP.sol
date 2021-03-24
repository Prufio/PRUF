/*--------------------------------------------------------PRüF0.8.0
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
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";

contract PIP is CORE {
    uint256 importDiscount = 2;

    /*
     * @dev Sets import discount for this contract
     */
    function setImportDiscount(uint256 _importDiscount) external isAdmin {
        //^^^^^^^checks^^^^^^^^^
        if (_importDiscount < 1) {
            importDiscount = 1;
        } else {
            importDiscount = _importDiscount;
        }
        //^^^^^^^effects^^^^^^^^^^^^
    }

    function mintPipAsset(
        bytes32 _idxHash,
        bytes32 _hashedAuthCode, // token URI needs to be K256(packed( uint32 assetClass, string authCode)) supplied off chain
        uint32 _assetClass
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(_assetClass);

        require(
            (AC_TKN.ownerOf(_assetClass) == _msgSender()), //_msgSender() is AC token holder
            "P:MPA: Caller does not hold AC token"
        );
        require(userType == 10, "P:MPA: User not authorized to mint PIP assets");
        require(
            rec.assetClass == 0, //verified as VALID
            "P:MPA: Asset already registered in system"
        );
        // //^^^^^^^checks^^^^^^^^^

        string memory tokenURI;
        bytes32 b32URI =
            keccak256(abi.encodePacked(_hashedAuthCode, _assetClass));
        tokenURI = uint256toString(uint256(b32URI));
        //^^^^^^^effects^^^^^^^^^^^^

        A_TKN.mintAssetToken(address(this), tokenId, tokenURI); //mint a PIP token
        //^^^^^^^interactions^^^^^^^^^^^^
    }

    /*
     * @dev Import a record into a new asset class
     */
    function claimPipAsset(
        bytes32 _idxHash,
        string calldata _authCode,
        uint32 _newAssetClass,
        bytes32 _rgtHash,
        uint32 _countDownStart
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);

        require(
            A_TKN.ownerOf(tokenId) == address(this),
            "P:CPA: Token not found in PRUF_PIP"
        );
        //^^^^^^^checks^^^^^^^^^

        A_TKN.validatePipToken(tokenId, _newAssetClass, _authCode); //check supplied data matches tokenURI
        STOR.newRecord(_idxHash, _rgtHash, _newAssetClass, _countDownStart); // Make a new record at the tokenId b32
        A_TKN.setURI(tokenId, "pruf.io"); // set URI
        A_TKN.safeTransferFrom(address(this), _msgSender(), tokenId); // sends token from this holding contract to caller wallet
        deductImportRecordCosts(_newAssetClass);

        //^^^^^^^interactions^^^^^^^^
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function uint256toString(uint256 value)
        internal
        pure
        returns (string memory)
    {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        // value = uint256(0x2ce8d04a9c35987429af538825cd2438cc5c5bb5dc427955f84daaa3ea105016);

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    function deductImportRecordCosts(uint32 _assetClass)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        Invoice memory pricing = AC_MGR.getServiceCosts(_assetClass, 1);

        pricing.rootPrice = pricing.rootPrice / importDiscount;
        pricing.ACTHprice = pricing.ACTHprice / importDiscount;
        //^^^^^^^effects^^^^^^^^^

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^
    }
}
