/*-----------------------------------------------------------------
 *  TO DO :
 *  AssetTokenContract.burn still just burns, sets 0x0 and 60)  is this wanted?
 *
 *  Implement Recycle
 *          Not possible in Custodial asset classes
 *          Caller must hold token, must be in status 59
 *          Token goes into "indefinite" escrow, RGT set to 0xFFF...
 *              Caller is escrow controller, but escrow contract is "owner", can break escrow (resets to status 51)
 *              Price set when escrow is to be broken by reregistering, from costs of the category 
 *                     that it is to be imported into (endEscrow called from T_PRUF_APP?)
 *              Importing breaks the escrow
 *                  payment divided between ACroot, ACholder, and recycling address (escrow owner)     
 *                  token sent to new owner (payment sender), status set to 51
 *
 *
 *
 *  Implement export
 *            FROM Custodial:
 *                 sets to status 51
 *                 sends token to rightsholder wallet
 *                 sets asset to status 70
 *            FROM NonCustodial
 *                 sets asset status to 70
 *  Implement Import
 *            TO Custodial
 *                 Holder sends to custudial contract
 *                 Authorized agent approves / rejects import
 *                          change asset class
 *                     or to refuse, import then reexport
 *            TO NonCustodial
 *                 Import checks for token posession
 *                          change asset class
 *
 *
 *  ** Above 65k segregation (probably by ACinfo custodial type) (just need to add a wild west cotract?)
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 *Rules for reminting tokens:
 *  must have the plaintext that generates the rgtHash on-chain
 *
 *
 *Rules for burning records: 
 *  record is locked in escrow and the escrow contract gets the token. The asset is put into an indefinite escrow, 
 *  where the escrow amount is unpaid and time is indefinite. the asset owner is the escrow "holder" and can revert
 *  the escrow if they desire, which reverts the assetToken to their address. escrow amount is determined 
 *  #AT THE TIME OF RECYCLING# by the new record costs of the AC that the record is being recycled into by
 *  the new owner.
 *
 *
 * Rules for recycling records:
 *  escrow amount is the same as registration in the asset class where it will be registered (as per the "recycle asset" call),
 *  when the fee is paid the escrow is broken, and the asset token is assigned to the sender. The funds (less assetClassRoot fees)
 *  are divided 50/50 between the old owner (setter of the escrow) and the ACtoken holder for the new asset class. If funds are sent 
 *  to a dead escrow or there is an overpayment, the balance can be withdrawn.
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
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorizedNonCustodial(bytes32 _idxHash) {
        uint256 tokenID = uint256(_idxHash);
        require(
            (AssetTokenContract.ownerOf(tokenID) == msg.sender), //msg.sender is token holder
            "TPA:IA: Caller does not hold token"
        );
        _;
    }

    modifier isAuthorizedCustodial(bytes32 _idxHash) {
        User memory user = getUser();
        uint256 tokenID = uint256(_idxHash);

        require(
            (user.userType > 0) && (user.userType < 10),
            "PA:IA: User not registered"
        );
        require(
            (AssetTokenContract.ownerOf(tokenID) == address(this)),
            "PA:IA: Custodial contract does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

}