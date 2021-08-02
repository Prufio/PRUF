/*--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

 //CTS:EXAMINE quick explainer for the contract

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";

contract PURCHASE is CORE {

    /*
     * @dev Verify user credentials
     * //CTS:EXAMINE param
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
     * //CTS:EXAMINE param
     */
    function purchaseWithPRUF(
        bytes32 _idxHash
    ) external whenNotPaused
    {
        Record memory rec = getRecord(_idxHash);
        (rec.price, rec.currency) = STOR.getPriceData(_idxHash);

        uint256 tokenId = uint256(_idxHash);
        address assetHolder = A_TKN.ownerOf(tokenId);

        require(
            rec.assetStatus == 51,
            "PP:P: Must be in transferrable status (51)"
        );
        require(
            rec.currency == 2,
            "PP:P: Payment must be in PRUF tokens for this contract"
        );
        //^^^^^^^checks^^^^^^^^^

        // --- transfer the PRUF tokens
        if (rec.price > 0) {
            // allow for freeCycling
            UTIL_TKN.trustedAgentTransfer(_msgSender(), assetHolder, rec.price);
        }
        // --- transfer the asset token
        A_TKN.trustedAgentTransferFrom(assetHolder, _msgSender(), tokenId);
        deductServiceCosts(rec.assetClass, 2);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set price and currency in rec.pricer rec.currency
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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
            "PP:SP Record in unregistered, exported, or discarded status"
        );
        require(
            (rec.assetStatus > 49) || (_setForSale != 170),
            "PP:SP Asset Status < 50"
        ); // Status < 50 not reachable with current contract structure, caller must hold token.
        require(isEscrow(rec.assetStatus) == 0, "E:SP Record in escrow");
        require(
            _currency == 2,
            "PP:SP: Price must be in PRUF tokens for this contract"
        );
        //^^^^^^^checks^^^^^^^^^

        if (_setForSale == 170) {
            rec.assetStatus = 51;
            writeRecord(_idxHash, rec);
        }

        STOR.setPrice(_idxHash, _price, _currency);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set price and currency in rec.pricer rec.currency
     * //CTS:EXAMINE param
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
            "PP:CP Record in unregistered, exported, or discarded status"
        );
        require(isEscrow(rec.assetStatus) == 0, "PP:CP Record is in escrow");
        //^^^^^^^checks^^^^^^^^^

        STOR.clearPrice(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
