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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";

contract NAKED is CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenID) == msg.sender), //msg.sender is token holder
            "ANC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    /*
     * @dev Import a record into a new asset class
     */
    function $importNakedAsset(
        bytes32 _idxHash,
        string calldata _authCode,
        uint16 _newAssetClass,
        bytes32 _rgtHash,
        uint256 _countDownStart
    ) external payable nonReentrant whenNotPaused {
        uint256 tokenID = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            A_TKN.ownerOf(tokenID) == address(this),
            "PNP:INA: Token not found in importing contract"
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

        A_TKN.validateNakedToken(tokenID, _newAssetClass, _authCode); //Verify supplied data matches tokenURI

        STOR.newRecord(_idxHash, _rgtHash, _newAssetClass, _countDownStart); // Make a new record at the tokenID b32

        A_TKN.setURI(tokenID, "pruf.io"); // set URI

        A_TKN.safeTransferFrom(address(this), msg.sender, tokenID); // sends token from this holding contract to caller wallet

        //^^^^^^^interactions / effects^^^^^^^^^^^^
    }


    
}
