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
 *rules for burning records:
 *
 *rules for reminting records:
 *
 *rules for recycling records:
 *  if recycled in same asset class group:
 *      in record: new rgtHash assigned, anything else left as-was (in case there was a pre-existing record)
 *      token is reissued to recycling address
 *  if recycled in new asset class group:
 *
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
 * 55 = asset transferred automation set/unset (secret confirmed)(ACAdmin can unset)
 * 56 = escrow - automation set/unset (secret confirmed)(ACAdmin can unset)
 * 57 = out of escrow
 * 58 = out of locked escrow
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
        bytes32 _Ipfs1
    ) external payable nonReentrant {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 2,
            "PA:I2: Contract not authorized for custodial assets"
        );
        require(_rgtHash != 0, "PA:NR: rights holder cannot be zero");
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

        deductNewRecordCosts(_assetClass);

        AssetTokenContract.mintAssetToken(msg.sender, tokenId, "pruf.io");
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Wrapper for RecycleAsset  ---------------------------------------Security Risk-----------REVIEW
     * if creating new record in same root, and idxHash is identical, only change assetclass, rgthash, and IPFS1
     * if creating new record in same root and idxhash is different, set old asset to status 60, burn token, and create a new record and token
     * if creating new record in new root and idxhash is different, set old asset to status 60, burn token, and create a new record and token
     * if creating new record in new root and idxhash is identical, fail because its probably fraud
     *
     */

    function $recycleAsset(
        bytes32 _newIdxHash,
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external payable nonReentrant {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));

        require(
            AC_info.custodyType == 2,
            "PA:I2: Contract not authorized for custodial assets"
        );
        require(_rgtHash != 0, "PA:NR: rights holder cannot be zero");
        //^^^^^^^checks^^^^^^^^^


        if ((AC_info.assetClassRoot == oldAC_info.assetClassRoot) && (_idxHash == _newIdxHash)) {
            rec.rightsHolder = _rgtHash;
            rec.assetClass = _assetClass;
            rec.Ipfs1 = _Ipfs1;
            //write new asset class to storage
            //write ipfs1 to storage
        }

        //...........implement stuff from comments

        Storage.newRecord(
                userHash,
                _idxHash,
                rec.rightsHolder,
                rec.assetClass,
                rec.countDownStart,
                rec.Ipfs1
            );

        deductNewRecordCosts(_assetClass);

        AssetTokenContract.reMintAssetToken(msg.sender, tokenId, "pruf.io");
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remint token with confirmation of posession of RAWTEXT hash inputs
     * must Match rgtHash using raw data fields ---------------------------security risk--------REVIEW!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
     */
    function $reMintToken(
        bytes32 _idxHash,
        string memory first,
        string memory middle,
        string memory last,
        string memory id,
        string memory secret
    ) external payable nonReentrant returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);
        uint256 tokenId = uint256(_idxHash);

        require(
            AC_info.custodyType == 2,
            "PA:I2: Contract not authorized for custodial assets"
        );
        require(rec.rightsHolder != 0, "PA:I2: Record does not exist");
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
        //^^^^^^^checks^^^^^^^^^

        deductNewRecordCosts(rec.assetClass);

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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 2,
            "PA:I2: Contract not authorized for custodial assets"
        );
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
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductCreateNoteCosts(rec.assetClass);

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }
}
