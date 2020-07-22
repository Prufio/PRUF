/*-----------------------------------------------------------------
 *  TO DO :
 *  AssetTokenContract.burn still just burns, sets 0x0 and 60)  is this wanted?
 *
 *
 *  ** Above 65k segregation (probably by ACinfo custodial type) (just need to add a wild west cotract?)
 *
*-----------------------------------------------------------------


*-----------------------------------------------------------------
 * FUTURE FEATURES
 *      "bottle deposit" on asset creation to encourage recycling
 *  New Recycle :
 *          Not possible in Custodial asset classes
 *          Caller must hold token, must be in status 59
 *          Caller recieves deposit amount (how the bloody hell do we manage this????)
 *          Token goes into "indefinite" escrow, RGT set to 0xFFF...
 *              Caller is escrow controller, but escrow contract is "owner", can break escrow 
 *                      (requires repayment of deposit amount, resets to status 51)
 *              Price set when escrow is to be broken by reregistering, from costs of the category 
 *                     that it is to be imported into (endEscrow called from T_PRUF_APP?)
 *              Importing breaks the escrow
 *                  payment divided between ACroot, ACholder, and recycling address (escrow owner)     
 *                  token sent to new owner (payment sender), status set to 51
 *
 *
 *
*-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_core_066.sol";

contract T_PRUF_NP is PRUF {
    using SafeMath for uint256;

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev performs the record escrow functions for a discarded token -- can only be called from asset token contract
     */
    function discard(bytes32 _idxHash)
        external
        nonReentrant //gets item out of recycled status
    {
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
     * @dev takes asset out of excrow status if time period has resolved || is escrow issuer
     */
    function recycle(bytes32 _idxHash) external nonReentrant {
        Record memory rec = getRecord(_idxHash);
        // bytes32 ownerHash = escrowMGRcontract.retrieveEscrowOwner(_idxHash);

        require((rec.rightsHolder != 0), "PR:reCon:Record does not exist");
        require(
            (rec.assetStatus == 60),
            "PR:reCon:Record must be recycled first."
        );
        require( //caller is escrow owner or T_pruf_app
            (keccak256(abi.encodePacked(msg.sender)) ==
                keccak256(abi.encodePacked(T_PrufAppAddress))),
            "PR:reCon:Caller is not T_PRUF_APP"
        );
        //^^^^^^^checks^^^^^^^^^
        escrowMGRcontract.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev reutilize a recycled asset
     */
    function $recycle(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass
    ) external payable nonReentrant {
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        uint256 tokenId = uint256(_idxHash);
        escrowData memory escrow =  getEscrowData(_idxHash);
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);
        
        require(
            AC_info.custodyType == 2,
            "TPA:RCYCL:Contract not authorized for custodial assets"
        );
        require(_rgtHash != 0, "TPA:RCYCL:Rights holder cannot be zero");
        require(_assetClass != 0, "TPA:RCYCL:Asset class cannot be zero");
        require( //if creating new record in new root and idxhash is identical, fail because its probably fraud
            ((AC_info.assetClassRoot == oldAC_info.assetClassRoot) ||
                (rec.assetClass == 0)),
            "TPA:RCYCL:Cannot re-create asset in new root assetClass"
        );
        require(rec.assetStatus == 60, "TPA:RCYCL:Asset not discarded");
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }
        //^^^^^^^effects^^^^^^^^^^^^

        AssetTokenContract.mintAssetToken(msg.sender, tokenId, "pruf.io");
        Storage.changeAC(senderHash, _idxHash, _assetClass);
        escrowMGRcontract.endEscrow(_idxHash);
        writeRecord(_idxHash, rec);
        deductRecycleCosts(_assetClass, escrow.addr2);
        //^^^^^^^interactions^^^^^^^^^^^^
    }
}
