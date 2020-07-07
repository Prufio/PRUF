/*  TO DO
 * verify security and user permissioning /modifiers
 * DEAL WITH SUPERVISED VS NONSUPERVISED ASSET CLASS HANDLING (DIFFERENT APPLICATIONS?)
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

import "./PRUF_interfaces_064.sol";
import "./Imports/PullPayment.sol";
import "./Imports/ReentrancyGuard.sol";
import "./_ERC721/IERC721Receiver.sol";

contract PRUF is ReentrancyGuard, Ownable, IERC721Receiver, PullPayment {
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

    struct AC {
        string name; // NameHash for assetClass
        uint16 assetClassRoot; // asset type root (bycyles - USA Bicycles)
        uint8 custodyType; // custodial or noncustodial
        uint256 extendedData; // asset type root (bycyles - USA Bicycles)
    }

    mapping(bytes32 => User) internal registeredUsers; // Authorized recorder database

    address internal storageAddress;
    StorageInterface internal Storage; // Set up external contract interface

    address internal AssetClassTokenManagerAddress;
    AssetClassTokenManagerInterface internal AssetClassTokenManagerContract; // Set up external contract interface

    address internal AssetTokenAddress;
    AssetTokenInterface internal AssetTokenContract; //erc721_token prototype initialization

    address internal AssetClassTokenAddress;
    AssetClassTokenInterface internal AssetClassTokenContract; //erc721_token prototype initialization
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

    modifier isAuthorized(bytes32 _idxHash) virtual {
        require(
            _idxHash == 0, //function should always be overridden
            "PC:MOD-IA: Modifier MUST BE OVERRIDDEN"
        );
        _;
    }

    // modifier isCustodial(uint16 _assetClass) virtual {
    //     AC memory AC_info = getACinfo(_assetClass);
    //     require(
    //         AC_info.custodyType == 1,
    //         "PC:MOD-IA: Asset class is not custodial"
    //     );
    //     _;
    // }

    // modifier isNonCustodial(uint16 _assetClass) virtual {
    //     AC memory AC_info = getACinfo(_assetClass);
    //     require(
    //         AC_info.custodyType == 2,
    //         "PC:MOD-IA: Asset class is custodial"
    //     );
    //     _;
    // }



    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//
    /*
     * @dev Address Setters
     */
    function OO_ResolveContractAddresses()
        external
        virtual
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

        AssetClassTokenManagerAddress = Storage.resolveContractAddress(
            "assetClassTokenManager"
        );

        AssetClassTokenManagerContract = AssetClassTokenManagerInterface(
            AssetClassTokenManagerAddress
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
        uint256 tokenId = uint256(_idxHash);
        AssetTokenContract.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    function OO_TX_AC_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
        nonReentrant
    //^^^^^^^checks^^^^^^^^^
    {
        uint256 tokenId = uint256(_idxHash);
        AssetClassTokenContract.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "PC:SSC: storage address cannot be zero"
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
            "PC:AU:Invalid user type"
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

    //--------------------------------------------------------------------------------------INTERNAL functions

    /*
     * @dev Get a User Record from Storage @ msg.sender
     */
    function getUser() internal virtual view returns (User memory) {
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

    /*
     * @dev Get asset class information from AC_manager (FUNCTION IS VIEW)
     */
    function getACinfo(uint16 _assetClass)
        internal
        virtual
        returns (AC memory)
    {
        AC memory AC_info;
        (
            AC_info.assetClassRoot,
            AC_info.custodyType,
            AC_info.extendedData
        ) = AssetClassTokenManagerContract.getAC_data(_assetClass);
        return AC_info;
    }

    /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord(bytes32 _idxHash) internal returns (Record memory) {
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

    function getShortRecord(bytes32 _idxHash) internal returns (Record memory) {
        Record memory rec;

        {
            //Start of scope limit for stack depth
            (
                bytes32 _recorder,
                bytes32 _lastRecorder,
                uint8 _assetStatus,
                uint8 _forceModCount,
                uint16 _assetClass,
                uint256 _countDown,
                uint256 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2,
                uint16 _numberOfTransfers,
                uint256 _timeLock
            ) = Storage.retrieveShortRecord(_idxHash); // Get record from storage contract

            rec.recorder = _recorder;
            rec.lastRecorder = _lastRecorder;
            rec.assetStatus = _assetStatus;
            rec.forceModCount = _forceModCount;
            rec.assetClass = _assetClass;
            rec.countDown = _countDown;
            rec.countDownStart = _countDownStart;
            rec.Ipfs1 = _Ipfs1;
            rec.Ipfs2 = _Ipfs2;
            rec.numberOfTransfers = _numberOfTransfers;
            rec.timeLock = _timeLock;
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves Base Costs from Storage and returns Costs struct
     */
    function getBaseCost() internal returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.reMintRecordCost,
            cost.changeStatusCost,
            cost.forceModifyCost,
            cost.paymentAddress
        ) = AssetClassTokenManagerContract.retrieveBaseCosts();

        return (cost);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev retrieves costs from Storage and returns Costs struct
     */
    function getCost(uint16 _assetClass) internal returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.reMintRecordCost,
            cost.changeStatusCost,
            cost.forceModifyCost,
            cost.paymentAddress
        ) = AssetClassTokenManagerContract.retrieveCosts(_assetClass);

        return (cost);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        internal
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

    /*
     * @dev Write an Ipfs Record to Storage @ idxHash
     */
    function writeRecordIpfs1(bytes32 _idxHash, Record memory _rec)
        internal
        isAuthorized(_idxHash)
    //^^^^^^^checks^^^^^^^^^
    {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging
        //^^^^^^^effects^^^^^^^^^
        Storage.modifyIpfs1(userHash, _idxHash, _rec.Ipfs1); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Storage Writing internal functions

    function writeRecordIpfs2(bytes32 _idxHash, Record memory _rec)
        internal
        isAuthorized(_idxHash)
    //^^^^^^^checks^^^^^^^^^
    {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging

        Storage.modifyIpfs2(userHash, _idxHash, _rec.Ipfs2); // Send data to storage
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
    ) internal {
        uint256 messageValue = msg.value;
        uint256 change;
        uint256 total = _ACTHamount;

        change = messageValue.sub(total);
        _asyncTransfer(_basePaymentAddress, _baseAmount);
        _asyncTransfer(_ACTHpaymentAddress, (_ACTHamount.sub(_baseAmount)));
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
