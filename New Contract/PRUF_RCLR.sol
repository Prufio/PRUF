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

import "./PRUF_ECR_CORE.sol";
import "./PRUF_CORE.sol";

contract RCLR is ECR_CORE , CORE{
    using SafeMath for uint256;

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev //gets item out of recycled status -- caller is assetToken contract
     */
    function discard(bytes32 _idxHash) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);

        require( // caller is assetToken contract
            msg.sender == AssetTokenAddress,
            "PR:Recycle:Caller is not Asset Token Contract"
        );

        require((rec.rightsHolder != 0), "SE: Record does not exist");
        require(
            (rec.assetStatus == 59),
            "PR:Recycle:Must be in recyclable status"
        );

        //^^^^^^^checks^^^^^^^^^

        uint256 escrowTime = now + 3153600000000; //100,000 years in the FUTURE.........
        bytes32 escrowOwnerHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        escrowMGRcontract.setEscrow(
            _idxHash,
            60, //recycled status
            255, //escrow data 255 is recycled
            escrowOwnerHash,
            escrowTime,
            0x0,
            0x0,
            address(0),
            msg.sender
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev reutilize a recycled asset
     */
    function $recycle(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass
    ) external payable nonReentrant whenNotPaused {
        //bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        uint256 tokenId = uint256(_idxHash);
        escrowData memory escrow = getEscrowData(_idxHash);
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 2,
            "PR:R:Contract not authorized for custodial assets"
        );
        require(_rgtHash != 0, "PR:R:Rights holder cannot be zero");
        require(_assetClass != 0, "PR:R:Asset class cannot be zero");
        require( //if creating new record in new root and idxhash is identical, fail because its probably fraud
            ((AC_info.assetClassRoot == oldAC_info.assetClassRoot) ||
                (rec.assetClass == 0)),
            "PR:R:Cannot re-create asset in new root assetClass"
        );
        require(rec.assetStatus == 60, "PR:R:Asset not discarded");
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }
        //^^^^^^^effects^^^^^^^^^^^^

        AssetTokenContract.mintAssetToken(msg.sender, tokenId, "pruf.io");
        Storage.changeAC(_idxHash, _assetClass);
        escrowMGRcontract.endEscrow(_idxHash);
        writeRecord(_idxHash, rec);
        deductRecycleCosts(_assetClass, escrow.addr2);
        //^^^^^^^interactions^^^^^^^^^^^^
    }
}
