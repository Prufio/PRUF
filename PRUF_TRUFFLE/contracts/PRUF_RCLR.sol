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

        require( // caller is assetToken contract
            msg.sender == A_TKN_Address,
            "R:D:Caller is not Asset Token Contract"
        );
        require((rec.assetClass != 0), "R:D:Record does not exist");
        require((rec.assetStatus == 59), "R:D:Must be in recyclable status");

        //^^^^^^^checks^^^^^^^^^

        uint256 escrowTime = block.timestamp + 3153600000000; //100,000 years in the FUTURE.........
        bytes32 escrowOwnerHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        ECR_MGR.setEscrow(
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
        uint256 _assetClass
    ) external payable nonReentrant whenNotPaused {
        //bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        uint256 tokenId = uint256(_idxHash);
        escrowData memory escrow = getEscrowData(_idxHash);
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "R:R: This contract not authorized for specified AC"
        );
        require(_rgtHash != 0, "R:R:New rights holder cannot be zero");
        require(_assetClass != 0, "R:R:Asset class cannot be zero");
        require( //if creating new record in new root and idxhash is identical, fail because its probably fraud
            ((AC_info.assetClassRoot == oldAC_info.assetClassRoot) ||
                (rec.assetClass == 0)),
            "R:R:Cannot re-create asset in new root assetClass"
        );
        require(rec.assetStatus == 60, "R:R:Asset not discarded");
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }
        //^^^^^^^effects^^^^^^^^^^^^
        
        A_TKN.mintAssetToken(msg.sender, tokenId, "pruf.io");
        ECR_MGR.endEscrow(_idxHash);
        STOR.changeAC(_idxHash, _assetClass);
        writeRecord(_idxHash, rec);
        deductRecycleCosts(_assetClass, escrow.addr2);
        //^^^^^^^interactions^^^^^^^^^^^^
    }
}
