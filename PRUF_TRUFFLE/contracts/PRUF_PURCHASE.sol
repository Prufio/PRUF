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
pragma solidity ^0.6.7;

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
            "ANC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    /*
     * @dev Purchse an item in transferrable status with price and currency set to pruf
     */
    function purchaseWithPRUF(bytes32 _idxHash)
        external
        whenNotPaused
    //isAuthorized(_idxHash) //purchaser is not holder
    {
        Record memory rec = getRecord(_idxHash);
        uint256 tokenId = uint256(_idxHash);
        address assetHolder = A_TKN.ownerOf(tokenId);

        require(
            rec.assetStatus == 51,
            "NPNC:PURCHASE: Must be in transferrable status (51)"
        );
        require(
            rec.currency == 2,
            "NPNC:PURCHASE: Payment must be in PRüF tokens for this contract"
        );
        //^^^^^^^checks^^^^^^^^^

        // --- transfer the PRüF tokens
        if(rec.price > 0){ // allow for freeCycling
            UTIL_TKN.trustedAgentTransfer(_msgSender(), assetHolder, rec.price);
        }

        // --- transfer the asset token
        A_TKN.trustedAgentTransferFrom(assetHolder, _msgSender(), tokenId);

        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        deductServiceCosts(rec.assetClass, 2);
        //^^^^^^^interactions^^^^^^^^^
    }
}
