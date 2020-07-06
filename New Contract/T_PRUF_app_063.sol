/*  TO DO:
 * verify security and user permissioning /modifiers
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
 * 1   --Custodial (contract holds token)
 * 2   --NonCustodial (rightsHolder holds token)
 * 4   --ADMIN (isAdmin)
 * >4  NONE
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

import "./PRUF_core_063.sol";

contract T_PRUF_NP is PRUF {
    using SafeMath for uint256;
    using SafeMath for uint8;

    address internal PrufAppAddress;
    PrufAppInterface internal PrufAppContract; //erc721_token prototype initialization

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
            (AssetTokenContract.ownerOf(tokenID) == msg.sender), //msg.sender is token holder
            "PC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    function OO_ResolveContractAddresses()
        external
        override
        nonReentrant
        onlyOwner
    {
        //^^^^^^^checks^^^^^^^^^
        AssetClassTokenAddress = Storage.resolveContractAddress(
            "assetClassToken"
        );
        AssetClassTokenContract = AssetClassTokenInterface(
            AssetClassTokenAddress
        );

        AssetTokenAddress = Storage.resolveContractAddress("assetToken");
        AssetTokenContract = AssetTokenInterface(AssetTokenAddress);

        PrufAppAddress = Storage.resolveContractAddress("PRUF_APP");
        PrufAppContract = PrufAppInterface(PrufAppAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    function getUser() internal override view returns (User memory) {
        //User memory callingUser = getUser();
        User memory user;
        (user.userType, user.authorizedAssetClass) = PrufAppContract.getUserExt(
            keccak256(abi.encodePacked(msg.sender))
        );
        return user;
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------External Functions--------------------------
    /*
     * @dev Wrapper for newRecord  CAUTION ANYONE CAN CREATE ASSETS IN ALL ASSET CLASSES!!!!!!!!!!!!!!!!FIX
     */
    function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs
    ) external payable nonReentrant {
        uint256 tokenId = uint256(_idxHash);
        Costs memory cost = getCost(_assetClass);
        Costs memory baseCost = getBaseCost();

        require(_rgtHash != 0, "PA:NR: rights holder cannot be zero");
        require(
            msg.value >= cost.newRecordCost,
            "PA:NR: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        Storage.newRecord(
            userHash,
            _idxHash,
            _rgtHash,
            _assetClass,
            _countDownStart,
            _Ipfs
        );
        deductPayment(
            baseCost.paymentAddress,
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
        );

        AssetTokenContract.mintAssetToken(msg.sender, tokenId, "pruf.io");
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs2 with confirmation
     * must Match rgtHash using raw data fields
     */
    function reMintToken(
        bytes32 _idxHash,
        string memory first,
        string memory middle,
        string memory last,
        string memory id,
        string memory secret
    ) external payable nonReentrant isAuthorized(_idxHash) returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        Costs memory cost = getCost(rec.assetClass);
        Costs memory baseCost = getBaseCost();
        uint256 tokenId = uint256(_idxHash);

        require((rec.rightsHolder != 0), "PA:I2: Record does not exist");
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
            rec.rightsHolder ==
                keccak256(abi.encodePacked(first, middle, last, id, secret)),
            "PA:I2: Rightsholder does not match supplied data"
        );
        require(
            msg.value >= cost.createNoteCost,
            "PA:I2: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        deductPayment(
            baseCost.paymentAddress,
            baseCost.createNoteCost,
            cost.paymentAddress,
            cost.reMintRecordCost
        );

        tokenId = AssetTokenContract.reMintAssetToken(
            msg.sender,
            tokenId,
            "pruf.io"
        );

        return tokenId;
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
        Costs memory cost = getCost(rec.assetClass);
        Costs memory baseCost = getBaseCost();

        require((rec.rightsHolder != 0), "PA:I2: Record does not exist");
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
}
