/*-----------------------------------------------------------------
 *  TO DO
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
 * CONTRACT Types:
 * 0   --NONE
 * 1   --Custodial
 * 2   --Non-Custodial
 * Owner (onlyOwner)
 * other = unauth
 *
*-----------------------------------------------------------------

*-----------------------------------------------------------------
 * ASSET CLASS Types:
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
 * 60 = Burned (can only be reimported by an ACAdmin can unset)
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
*/


// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_core_065.sol";

contract PRUF_simpleEscrow is PRUF {
    using SafeMath for uint256;

    mapping (bytes32 => bytes32) private escrows;

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 to 9
     *      Is authorized for asset class
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        User memory user = getUser();
        uint256 tokenID = uint256(_idxHash);

        require(
            (user.userType > 0) && (user.userType < 10),
            "PSE:IA:User not registered"
        );
        require(
            AssetTokenContract.ownerOf(tokenID) == PrufAppAddress,
            "PSE:IA: Custodial contract does not hold token"
        );
        _;
    }

    /*
     * @dev puts asset into an escrow status for a certain time period
     */
    function setEscrow(
        bytes32 _idxHash,
        bytes32 escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        uint256 escrowTime = now.add(_escrowTime);
        uint8 newAssetStatus;
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PSE:SE: Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "SE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "PSE:SE: User not authorized to modify records in specified asset class"
        );
        require(
            (escrowTime >= now),
            "PSE:SE: Escrow must be set to a time in the future"
        );
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "PSE:SE: Transferred, lost, or stolen status cannot be set to escrow."
        );
        require(
            (callingUser.userType < 5) ||
                ((callingUser.userType > 4) && (_escrowStatus > 49)),
            "PSE:SE: Non supervisored agents must set asset status within scope."
        );
        require(
            (_escrowStatus == 6) ||
                (_escrowStatus == 50) ||
                (_escrowStatus == 56),
            "PSE:SE: Must specify an valid escrow status"
        );
        //^^^^^^^checks^^^^^^^^^

        escrows[_idxHash] = escrowOwnerHash;
        newAssetStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        Storage.setEscrow(
            _idxHash,
            newAssetStatus,
            escrowTime
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev takes asset out of excrow status if time period has resolved || is escrow issuer
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Record memory shortRec = getShortRecord(_idxHash);
        User memory callingUser = getUser();
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 2,
            "PSE:EE: Contract not authorized for custodial assets"
        );

        require((rec.rightsHolder != 0), "EE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "PSE:EE: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 6) ||
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "EE:ERR- record must be in escrow status"
        );
        require(
            ((rec.assetStatus > 49) || (callingUser.userType < 5)),
            "PSE:EE: Usertype less than 5 required to end this escrow"
        );
        require(
            (shortRec.timeLock < now) ||
                (keccak256(abi.encodePacked(msg.sender)) == escrows[_idxHash]),
            "PSE:EE: Escrow period not ended and caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
