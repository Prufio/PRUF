/*--------------------------------------------------------PRuF0.7.1
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

contract PURCHASE is CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == _msgSender()), //_msgSender() is token holder
            "PP:MOD-IA: Caller does not hold token"
        );
        _;
    }

    /*
     * @dev Purchse an item in transferrable status with price and currency set to pruf
     */
    function purchaseWithPRUF(bytes32 _idxHash) //CTS:EXAMINE NO CHECK TO SEE IF PRICE IS SET?
        external
        whenNotPaused
    //isAuthorized(_idxHash) //purchaser is not holder
    {
        Record memory rec = getRecord(_idxHash);
        (rec.price, rec.currency) = STOR.getPriceData(_idxHash);

        uint256 tokenId = uint256(_idxHash);
        address assetHolder = A_TKN.ownerOf(tokenId);

        require(
            rec.assetStatus == 51,
            "PP:PURCHASE: Must be in transferrable status (51)"
        );
        require( // CTS:REDUNDANT, THROWS IN _setPrice
            rec.currency == 2,
            "PP:PURCHASE: Payment must be in PRUF tokens for this contract"
        );
        //^^^^^^^checks^^^^^^^^^

        // --- transfer the PRUF tokens
        if (rec.price > 0) {
            // allow for freeCycling
            UTIL_TKN.trustedAgentTransfer(_msgSender(), assetHolder, rec.price);
        }

        // --- transfer the asset token
        A_TKN.trustedAgentTransferFrom(assetHolder, _msgSender(), tokenId);

        //^^^^^^^effects^^^^^^^^^

        deductServiceCosts(rec.assetClass, 2);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set price and currency in rec.pricer rec.currency
     */
    function _setPrice(
        bytes32 _idxHash,
        uint120 _price,
        uint8 _currency,
        uint256 _setForSale // if 170 then change to transferrable
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);

        require(
            needsImport(rec.assetStatus) == 0,
            "E:SP Record in unregistered, exported, or discarded status"
        );
        require((rec.assetStatus > 49) || (_setForSale != 170) , "E:SP Asset Status < 50"); //CTS:EXAMINE Status < 50 not reachable with current contract structure, caller must hold token.
        require(isEscrow(rec.assetStatus) == 0, "E:SP Record is in escrow");

        require(
            _currency == 2,
            "E:SP: Price must be in PRUF tokens for this contract"
        );
        //^^^^^^^checks^^^^^^^^^
        if (_setForSale == 170){
            rec.assetStatus = 51;
            writeRecord(_idxHash, rec);
        }

        STOR.setPrice(_idxHash, _price, _currency);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set price and currency in rec.pricer rec.currency
     */
    function _clearPrice(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);

        require(
            needsImport(rec.assetStatus) == 0,
            "E:DC Record in unregistered, exported, or discarded status"
        );
        require(isEscrow(rec.assetStatus) == 0, "E:SP Record is in escrow");
        //^^^^^^^checks^^^^^^^^^

        STOR.clearPrice(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
