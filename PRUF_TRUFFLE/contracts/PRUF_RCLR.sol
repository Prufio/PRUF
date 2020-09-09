/*-----------------------------------------------------------V0.7.0
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

import "./PRUF_ECR_CORE.sol";
import "./PRUF_CORE.sol";

contract RCLR is ECR_CORE, CORE {
    using SafeMath for uint256;

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev //gets item out of recycled status -- caller is assetToken contract
     */
    function discard(bytes32 _idxHash) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);

        require(
            msg.sender == A_TKN_Address,
            "R:D:Caller is not Asset Token Contract"
        );
        require((rec.assetStatus == 59), "R:D:Must be in recyclable status");
        //^^^^^^^checks^^^^^^^^^

        uint256 escrowTime = block.timestamp + 3153600000000; //100,000 years in the FUTURE.........
        bytes32 escrowOwnerHash = keccak256(abi.encodePacked(msg.sender));
        escrowDataExtLight memory escrowDataLight;
        escrowDataLight.escrowData = 255;
        escrowDataLight.addr_1 = msg.sender;
        //^^^^^^^effects^^^^^^^^^

       _setEscrowData(
            _idxHash,
            60, //recycled status
            escrowOwnerHash,
            escrowTime
        );

        _setEscrowDataLight(
            _idxHash,
            escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev reutilize a recycled asset
     */
    function $recycle(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass
    ) external payable nonReentrant whenNotPaused {

        uint256 tokenId = uint256(_idxHash);
        escrowDataExtLight memory escrowDataLight = getEscrowDataLight(_idxHash);
        Record memory rec = getRecord(_idxHash);

        require(_rgtHash != 0, "R:R:New rights holder cannot be zero");

        require(rec.assetStatus == 60, "R:R:Asset not discarded");
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        rec.incrementNumberOfTransfers = 170;
        //^^^^^^^effects^^^^^^^^^^^^

        A_TKN.mintAssetToken(msg.sender, tokenId, "pruf.io");
        ECR_MGR.endEscrow(_idxHash);
        STOR.changeAC(_idxHash, _assetClass);
        rec.assetStatus = 58;
        writeRecord(_idxHash, rec);
        deductRecycleCosts(_assetClass, escrowDataLight.addr_1);
        //^^^^^^^interactions^^^^^^^^^^^^
    }
}
