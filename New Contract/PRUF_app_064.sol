/*  TO DO
 * verify security and user permissioning /modifiers
 * @implement remint_asset ?
 *
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, tokenless asset classes are not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
 *
 * Order of require statements:
 * 1: (modifiers)
 * 2: checking the asset existance
 * 3: checking the idendity and credentials of the caller
 * 4: checking the suitability of provided data for the proposed operation
 * 5: checking the suitability of asset details for the proposed operation
 * 6: verifying that provided verification data matches required data
 * 7: verifying that message contains any required payment
 *
 * Contract Resolution Names -
 *  assetToken
 *  assetClassToken
 *  PRUF_APP
 *  PRUF_NP
 *  PRUF_simpleEscrow
 *  T_PRUF_APP
 *  T_PRUF_NP
 *  T_PRUF_simpleEscrow
 *
 * CONTRACT Types (storage)
 * 0   --NONE
 * 1   --Custodial
 * 2   --Non-Custodial
 * Owner (onlyOwner)
 * other = unauth
 *
 *
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
 * 55 = asset transferred automation set/unset (secret confirmed)(ACAdmin can unset)
 * 56 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
 * 57 = out of escrow
 * 58 = out of locked escrow
 *
 * ADD 100 for NONREMINTABLE!!!
 *
 * escrow status = lock time set to a time instead of a block number
 *
 *
 * Authorized User Types   registeredUsers[]
 *
 * 1 - 4 = Standard User types
 * 1 - all priveleges
 * 2 - all but force-modify
 * 5 - 9 = Robot (cannot create of force-modify)
 * Other = unauth
 *
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_core_064.sol";

contract PRUF_APP is PRUF {
    using SafeMath for uint256;
    using SafeMath for uint8;

    modifier isAuthorized(bytes32 _idxHash) override {
        User memory user = getUser();
        uint256 tokenID = uint256(_idxHash);

        require(
            (user.userType > 0) && (user.userType < 10),
            "PC:MOD-IA: User not registered"
        );
        require(
            (AssetTokenContract.ownerOf(tokenID) == address(this)),
            "PC:MOD-IA: Custodial contract does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------
    /*
     * @dev Wrapper for newRecord
     */
    function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external payable nonReentrant {
        uint256 tokenId = uint256(_idxHash);
        User memory callingUser = getUser();
        Record memory rec = getRecord(_idxHash);
        Costs memory cost = getCost(_assetClass);
        Costs memory baseCost = getBaseCost();
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:I2: Contract not authorized for non-custodial assets"
        );
        require(
            (callingUser.userType > 0) && (callingUser.userType < 10),
            "PC:MOD-IA: User not registered"
        );
        require(
            callingUser.userType < 5,
            "PA:NR: User not authorized to create records"
        );
        require(
            callingUser.authorizedAssetClass == _assetClass,
            "PA:NR: User not authorized to create records in specified asset class"
        );
        require(_rgtHash != 0, "PA:NR: rights holder cannot be zero");
        require(
            msg.value >= cost.newRecordCost,
            "PA:NR: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) {
            Storage.newRecord(
                userHash,
                _idxHash,
                _rgtHash,
                _assetClass,
                rec.countDownStart,
                rec.Ipfs1
            );
        } else {
            Storage.newRecord(
                userHash,
                _idxHash,
                _rgtHash,
                _assetClass,
                _countDownStart,
                _Ipfs1
            );
        }
        deductPayment(
            baseCost.paymentAddress,
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
        );
        AssetTokenContract.mintAssetToken(address(this), tokenId, "pruf.io");
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.rightsHolder without confirmation required
     */
    function $forceModRecord(bytes32 _idxHash, bytes32 _rgtHash)
        external
        payable
        nonReentrant
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        Costs memory cost = getCost(rec.assetClass);
        Costs memory baseCost = getBaseCost();
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:I2: Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "PA:FMR: Record does not exist");

        require(
            callingUser.userType == 1,
            "PA:FMR: User not authorized to force modify records"
        );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "PA:FMR: User not authorized to modify records in specified asset class"
        );

        require(_rgtHash != 0, "PA:FMR: rights holder cannot be zero");
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54),
            "PA:FMR: Cannot modify asset in lost or stolen status"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "PA:FMR: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PA:FMR: Record In Transferred-unregistered status"
        );
        require(rec.assetStatus < 200, "FMR: Record locked");
        require(
            msg.value >= cost.forceModifyCost,
            "PA:FMR: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }

        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductPayment(
            baseCost.paymentAddress,
            baseCost.forceModifyCost,
            cost.paymentAddress,
            cost.forceModifyCost
        );

        return rec.forceModCount;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Transfer Rights to new rightsHolder with confirmation
     */
    function $transferAsset(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _newrgtHash
    ) external payable nonReentrant isAuthorized(_idxHash) returns (uint8) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        Costs memory cost = getCost(rec.assetClass);
        Costs memory baseCost = getBaseCost();
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:I2: Contract not authorized for non-custodial assets"
        );
        require((rec.rightsHolder != 0), "PA:TA: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "PA:TA: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus > 49) || (callingUser.userType < 5),
            "PA:TA:Only usertype < 5 can change status < 50"
        );
        require(_newrgtHash != 0, "PA:TA:new Rightsholder cannot be blank");
        require(
            (rec.assetStatus == 1) || (rec.assetStatus == 51),
            "PA:TA:Asset status is not transferrable"
        );
        require(rec.assetStatus < 200, "PA:TA: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "PA:TA:Rightsholder does not match supplied data"
        );
        require(
            msg.value >= cost.transferAssetCost,
            "PA:TA: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _newrgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductPayment(
            baseCost.paymentAddress,
            baseCost.transferAssetCost,
            cost.paymentAddress,
            cost.transferAssetCost
        );

        return (170);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     */
    function $addIpfs2Note(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    ) external payable nonReentrant isAuthorized(_idxHash) returns (bytes32) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        Costs memory cost = getCost(rec.assetClass);
        Costs memory baseCost = getBaseCost();
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:I2: Contract not authorized for non-custodial assets"
        );
        require((rec.rightsHolder != 0), "PA:I2: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "PA:I2: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "PA:I2: Cannot modify asset in Escrow"
        );
        require(rec.assetStatus < 200, "PA:I2: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PA:I2: Record In Transferred-unregistered status"
        );
        require(
            rec.Ipfs2 == 0,
            "PA:I2: Ipfs2 has data already. Overwrite not permitted"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "PA:I2: Rightsholder does not match supplied data"
        );
        require(
            msg.value >= cost.createNoteCost,
            "PA:I2: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductPayment(
            baseCost.paymentAddress,
            baseCost.createNoteCost,
            cost.paymentAddress,
            cost.createNoteCost
        );

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Reimport **Record**.rightsHolder (no confirmation required -
     * posessor is considered to be owner). sets rec.assetStatus to 0.
     */
    function $importAsset(bytes32 _idxHash, bytes32 _rgtHash)
        external
        payable
        nonReentrant
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        Costs memory cost = getCost(rec.assetClass);
        Costs memory baseCost = getBaseCost();
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PA:I2: Contract not authorized for non-custodial assets"
        );
        require((rec.rightsHolder != 0), "PA:IA: Record does not exist");
        require(
            callingUser.userType < 3,
            "PA:IA: User not authorized to reimport assets"
        );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "PA:IA: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 5) || (rec.assetStatus == 55),
            "PA:IA: Only Transferred status assets can be reimported"
        );
        require(rec.assetStatus < 200, "PA:IA: Record locked");
        require(
            msg.value >= cost.reMintRecordCost,
            "PA:IA: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }

        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductPayment(
            baseCost.paymentAddress,
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
        );

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }
}
