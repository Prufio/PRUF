// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.6.9;

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
 *  ** Make a function in storage that changes the asset class
 *                 
 *  ** Status 70:
 *          is a semi-transferrable status
 *          limit sending to approved addresses
 *                  Implement a separate status 70 safeTransfer function                             
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
*-----------------------------------------------------------------

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
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, tokenless asset classes are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Order of require statements:
 * 1: (modifiers)
 * 2: checking custodial status
 * 3: checking the asset existance 
 * 4: checking the idendity and credentials of the caller
 * 5: checking the suitability of provided data for the proposed operation
 * 6: checking the suitability of asset details for the proposed operation
 * 7: verifying that provided verification data matches required data
 * 8: verifying that message contains any required payment
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Contract Resolution Names -
 *  assetToken
 *  assetClassToken
 *  PRUF_APP
 *  PRUF_NP
 *  PRUF_simpleEscrow
 *  PRUF_AC_MGR
 *  PRUF_AC_Minter
 *  T_PRUF_APP
 *  T_PRUF_NP
 *  T_PRUF_simpleEscrow
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * CONTRACT Types:  contractAdresses (storage)
 * 0   --NONE
 * 1   --Custodial
 * 2   --Non-Custodial
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * ASSET CLASS Types: AC_data.custodyType (AC_manager)
 * 0   --NONE
 * 1   --Custodial
 * 2   --Non-Custodial
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Record status field key
 *
 * 0 = no status, Non transferrable. Default asset creation status
 *       default after FMR, and after status 5 (essentially a FMR) (IN frontend)
 * 1 = transferrable
 * 2 = nontransferrable
 * 3 = stolen
 * 4 = lost
 * 5 = transferred but not reImported (no new rghtsholder information) implies that asset posessor is the owner.
 *       must be re-imported by ACadmin through regular onboarding process
 *       no actions besides modify RGT to a new rightsholder can be performed on a statuss 5 asset (no status changes) (Frontend)
 * 6 = in supervised escrow, locked until timelock expires, but can be set to lost or stolen
 *       Status 1-6 Actions cannot be performed by automation.
 *       only ACAdmins can set or unset these statuses, except 5 which can be set by automation
 * 7 = out of Supervised escrow (user < 5)
 *
 * 50 Locked escrow
 * 51 = transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 * 52 = non-transferrable, automation set/unset (secret confirmed)(ACAdmin can unset)
 * 53 = stolen (automation set)(ONLY ACAdmin can unset)
 * 54 = lost (automation set/unset)(ACAdmin can unset)
 * 55 = asset transferred automation set/unset (secret confirmed)(Only ACAdmin can unset) ####DO NOT USE????
 * 56 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
 * 57 = out of escrow
 * 58 = out of locked escrow
 * 59 = Recyclable
 * 60 = Recycled (can only be reimported by an ACAdmin can unset)
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * Authorized User Types   registeredUsers[]
 * 1 - 4 = Standard User types
 * 1 - all priveleges
 * 2 - all but force-modify
 * 5 - 9 = Robot (cannot create of force-modify)
 * Other = unauth
 *
*-----------------------------------------------------------------
*-----------------------------------------------------------------
 * ----------SETUP PROCEDURES---------- *
 * 1 Deploy Contracts
 * 2 Add contracts @ respective names in storage
 * 3 Set storage contract in each contract
 * 4 Resolve contract addresses
 * 5 Print root && rooted AC token
 * 6 Set costs / users / types for root && rooted AC token
 * 7 THE WORKS
 * 
*-----------------------------------------------------------------
*/

Implement:

 below 65k
 mintAsset and reimport asset require an agent.
 Only an agent can remove from status 55 or status 60.
 Unreceived transfer sets token to status 55 and either sends or burns the token (set to 60 and burn).
 burn asset burns the token, requires a status 60. sets rgtHash to 0xFFF.....

 write storage function that allows setting a new asset class
