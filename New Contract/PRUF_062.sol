/*  TO DO
 * verify security and user permissioning /modifiers
 * DEAL WITH SUPERVISED VS NONSUPERVISED ASSET CLASS HANDLING (DIFFERENT APPLICATIONS?)
 *
 * mint a token at asset creation
 *
 * @implement remint_asset ?
 *-----------------------------------------------------------------------------------------------------------------
 * Should all assets have a token, minted to reside within the contract for curated / "nontokenized" asset classes?
 * If so, make a move-token function that can be enabled later (set to an address to control it)
 *-----------------------------------------------------------------------------------------------------------------
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
 *  prufPayable
 *  prufNonPayable
 *
 * CONTRACT Types (storage)
 * 0   --NONE
 * 1   --E
 * 2   --RE
 * 3   --RWE
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

import "./PRUF_interfaces.sol";
import "./Imports/PullPayment.sol";
import "./Imports/ReentrancyGuard.sol";
import "./_ERC721/IERC721Receiver.sol";

contract PRUF is ReentrancyGuard, PullPayment, Ownable, IERC721Receiver {
    using SafeMath for uint256;

    struct Record {
        bytes32 recorder; // Address hash of recorder
        bytes32 rightsHolder; // KEK256 Registered owner
        bytes32 lastRecorder; // Address hash of last non-automation recorder
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        uint256 timeLock; // Time sensitive mutex
        uint16 numberOfTransfers; //number of transfers and forcemods
    }
    struct User {
        uint8 userType; // User type: 1 = human, 9 = automated
        uint16 authorizedAssetClass; // Asset class in which user is permitted to transact
    }
    struct Costs {
        uint256 newRecordCost; // Cost to create a new record
        uint256 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        uint256 createNoteCost; // Cost to add a static note to an asset
        uint256 reMintRecordCost; // Extra
        uint256 changeStatusCost; // Extra
        uint256 forceModifyCost; // Cost to brute-force a record transfer
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    mapping(bytes32 => User) private registeredUsers; // Authorized recorder database

    address private storageAddress;
    StorageInterface private Storage; // Set up external contract interface

    // address minterContractAddress;
    address private AssetTokenAddress;
    AssetTokenInterface private AssetTokenContract; //erc721_token prototype initialization
    address private AssetClassTokenAddress;
    AssetClassTokenInterface private AssetClassTokenContract; //erc721_token prototype initialization
    // --------------------------------------Events--------------------------------------------//

    event REPORT(string _msg);
    // --------------------------------------Modifiers--------------------------------------------//

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 to 9
     *      Is authorized for asset class
     *      asset token held by this.contract
     * ----OR---- (comment out part that will not be used)
     *      holds asset token
     */
    modifier isAuthorized(bytes32 _idxHash) {
        uint256 tokenID = uint256(_idxHash);
        User memory user = getUser();

        require(
            (((user.userType > 0) && (user.userType < 10)) &&
                (AssetTokenContract.ownerOf(tokenID) == address(this))) || //User is authorized in database and contract holds token
                (AssetTokenContract.ownerOf(tokenID) == msg.sender), //or msg.sender is token holder
            "ST:MOD-UA-ERR:User not registered "
        );
        _;
    }

    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//
    /*
     * @dev Address Setters
     */
    function OO_ResolveContractAddresses() external nonReentrant onlyOwner {
        //^^^^^^^checks^^^^^^^^^
        AssetClassTokenAddress = Storage.resolveContractAddress(
            "assetClassToken"
        );
        AssetClassTokenContract = AssetClassTokenInterface(
            AssetClassTokenAddress
        );

        AssetTokenAddress = Storage.resolveContractAddress("assetToken");
        AssetTokenContract = AssetTokenInterface(AssetTokenAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    function OO_TX_asset_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
        nonReentrant
    //^^^^^^^checks^^^^^^^^^
    {
        AssetTokenContract.transferAssetToken(address(this), _to, _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function OO_TX_AC_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
        nonReentrant
    //^^^^^^^checks^^^^^^^^^
    {
        AssetClassTokenContract.transferAssetClassToken(
            address(this),
            _to,
            _idxHash
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "ADMIN: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage = StorageInterface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function OO_addUser(
        address _authAddr,
        uint8 _userType,
        uint16 _authorizedAssetClass
    ) external onlyOwner {
        require(
            (_userType == 0) ||
                (_userType == 1) ||
                (_userType == 2) ||
                (_userType == 9) ||
                (_userType == 99),
            "ST:OO-AU-ERR:Invalid user type"
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 addrHash = keccak256(abi.encodePacked(_authAddr));

        registeredUsers[addrHash].userType = _userType;
        registeredUsers[addrHash].authorizedAssetClass = _authorizedAssetClass;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("Internal user database access!"); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//
    /*
     * @dev Compliance for erc721
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Wrapper for newRecord
     */
    function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs
    ) external payable nonReentrant isAuthorized(_idxHash) {
        User memory callingUser = getUser();
        Costs memory cost = getCost(_assetClass);
        Costs memory baseCost = getBaseCost();

        require(
            callingUser.userType < 5,
            "NR: User not authorized to create records"
        );
        require(
            callingUser.authorizedAssetClass == _assetClass,
            "NR: User not authorized to create records in specified asset class"
        );
        require(_rgtHash != 0, "NR: rights holder cannot be zero");
        require(
            msg.value >= cost.newRecordCost,
            "NR: tx value too low. Send more eth."
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

        require((rec.rightsHolder != 0), "FMR: Record does not exist");

        require(
            callingUser.userType == 1,
            "FMR: User not authorized to force modify records"
        );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "FMR: User not authorized to modify records in specified asset class"
        );

        require(_rgtHash != 0, "FMR: rights holder cannot be zero");
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54),
            "FMR: Cannot modify asset in lost or stolen status"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "FMR: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "DC: Record In Transferred-unregistered status"
        );
        require(rec.assetStatus < 200, "FMR: Record locked");
        require(
            msg.value >= cost.forceModifyCost,
            "FMR: tx value too low. Send more eth."
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
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
        );

        return rec.forceModCount;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Reimport **Record**.rightsHolder (no confirmation required -
     * posessor is considered to be owner). sets rec.assetStatus to 0.
     */
    function $reimportRecord(bytes32 _idxHash, bytes32 _rgtHash)
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

        require((rec.rightsHolder != 0), "RR: Record does not exist");
        require(
            callingUser.userType < 3,
            "RR: User not authorized to reimport assets"
        );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "RR: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 5) || (rec.assetStatus == 55),
            "RR: Only Transferred status assets can be reimported"
        );
        require(rec.assetStatus < 200, "RR: Record locked");
        require(
            msg.value >= cost.reMintRecordCost,
            "RR: tx value too low. Send more eth."
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

        require((rec.rightsHolder != 0), "TA: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "TA: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus > 49) || (callingUser.userType < 5),
            "TA:ERR-Only usertype < 5 can change status < 50"
        );
        require(_newrgtHash != 0, "TA:ERR-new Rightsholder cannot be blank");
        require(
            (rec.assetStatus == 1) || (rec.assetStatus == 51),
            "TA:ERR--Asset status is not transferrable"
        );
        require(rec.assetStatus < 200, "RR: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "TA:ERR-Rightsholder does not match supplied data"
        );
        require(
            msg.value >= cost.transferAssetCost,
            "TA: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _newrgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductPayment(
            baseCost.paymentAddress,
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
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

        require((rec.rightsHolder != 0), "MI2: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "MI2: User not authorized to modify records in specified asset class"
        );
        require( //-------------------------------------Should an asset in escrow be modifiable?
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //Should it be contingent on the original recorder address?
            "MI2: Cannot modify asset in Escrow" //If so, it must not erase the recorder, or escrow termination will be broken!
        );
        require(rec.assetStatus < 200, "MI1: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "MI1: Record In Transferred-unregistered status"
        );
        require(
            rec.Ipfs2 == 0,
            "MI2: Ipfs2 has data already. Overwrite not permitted"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "MI2: Rightsholder does not match supplied data"
        );
        require(
            msg.value >= cost.createNoteCost,
            "MI2: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs2 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs2(_idxHash, rec);

        deductPayment(
            baseCost.paymentAddress,
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
        );

        return rec.Ipfs2;
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Private functions
    /*
     * @dev Get a User Record from Storage @ msg.sender
     */
    function getUser() private view returns (User memory) {
        return registeredUsers[keccak256(abi.encodePacked(msg.sender))];
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Get a User Record from Storage @ msg.sender
     */
    function getUserExt(bytes32 _userHash)
        external
        view
        returns (uint8, uint16)
    {
        return (
            registeredUsers[_userHash].userType,
            registeredUsers[_userHash].authorizedAssetClass
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Storage Reading private functions
    /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord(bytes32 _idxHash) private returns (Record memory) {
        Record memory rec;

        {
            //Start of scope limit for stack depth
            (
                bytes32 _recorder,
                bytes32 _rightsHolder,
                bytes32 _lastRecorder,
                uint8 _assetStatus,
                uint8 _forceModCount,
                uint16 _assetClass,
                uint256 _countDown,
                uint256 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2,
                uint16 _numberOfTransfers
            ) = Storage.retrieveRecord(_idxHash); // Get record from storage contract

            rec.recorder = _recorder;
            rec.rightsHolder = _rightsHolder;
            rec.lastRecorder = _lastRecorder;
            rec.assetStatus = _assetStatus;
            rec.forceModCount = _forceModCount;
            rec.assetClass = _assetClass;
            rec.countDown = _countDown;
            rec.countDownStart = _countDownStart;
            rec.Ipfs1 = _Ipfs1;
            rec.Ipfs2 = _Ipfs2;
            rec.numberOfTransfers = _numberOfTransfers;
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves Base Costs from Storage and returns Costs struct
     */
    function getBaseCost() private returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.reMintRecordCost,
            cost.changeStatusCost,
            cost.forceModifyCost,
            cost.paymentAddress
        ) = Storage.retrieveBaseCosts();

        return (cost);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves costs from Storage and returns Costs struct
     */
    function getCost(uint16 _class) private returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.reMintRecordCost,
            cost.changeStatusCost,
            cost.forceModifyCost,
            cost.paymentAddress
        ) = Storage.retrieveCosts(_class);

        return (cost);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Storage Writing private functions

    function writeRecordIpfs2(bytes32 _idxHash, Record memory _rec)
        private
        isAuthorized(_idxHash)
    //^^^^^^^checks^^^^^^^^^
    {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging

        Storage.modifyIpfs2(userHash, _idxHash, _rec.Ipfs2); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        private
        isAuthorized(_idxHash)
    //^^^^^^^checks^^^^^^^^^
    {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging

        Storage.modifyRecord(
            userHash,
            _idxHash,
            _rec.rightsHolder,
            _rec.assetStatus,
            _rec.countDown,
            _rec.forceModCount,
            _rec.numberOfTransfers
        ); // Send data and writehash to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*--------------------------------------------------------------------------------------PAYMENT FUNCTIONS
     * @dev Deducts payment from transaction
     */
    function deductPayment(
        address _basePaymentAddress,
        uint256 _baseAmount,
        address _ACTHpaymentAddress,
        uint256 _ACTHamount
    ) private {
        uint256 messageValue = msg.value;
        uint256 change;
        uint256 total = _baseAmount.add(_ACTHamount);

        change = messageValue.sub(total);
        _asyncTransfer(_basePaymentAddress, _baseAmount);
        _asyncTransfer(_ACTHpaymentAddress, _ACTHamount);
        _asyncTransfer(msg.sender, change);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Withdraws user's credit balance from contract
     */

    function $withdraw() external virtual payable nonReentrant {
        withdrawPayments(msg.sender);
        //^^^^^^^interactions^^^^^^^^^
    }
}
