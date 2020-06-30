/*  TO DO
 * verify security and user permissioning /modifiers
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
import "./Imports/Ownable.sol";
import "./Imports/SafeMath.sol";
import "./Imports/ReentrancyGuard.sol";
import "./_ERC721/IERC721Receiver.sol";


contract PRUF_simpleEscrow is Ownable, IERC721Receiver, ReentrancyGuard {
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

    address private storageAddress;

    StorageInterface private Storage; // Set up external contract interface

    // address minterContractAddress;
    address private AssetTokenAddress;
    AssetTokenInterface private AssetTokenContract; //erc721_token prototype initialization
    address private AssetClassTokenAddress;
    AssetClassTokenInterface private AssetClassTokenContract; //erc721_token prototype initialization
    address private prufPayableAddress;
    prufPayableInterface private prufPayableContract; //erc721_token prototype initialization
    // --------------------------------------Events--------------------------------------------//

    event REPORT(string _msg);
    // --------------------------------------Modifiers--------------------------------------------//

    // modifier isAuthorized(bytes32 _idxHash) {
    //     uint256 tokenID = uint256(_idxHash);
    //     User memory user = getUser();

    //     require(
    //         (((user.userType > 0) && (user.userType < 10)) &&
    //             (AssetTokenContract.ownerOf(tokenID) == address(this))) || //User is authorized in database and contract holds token
    //             (AssetTokenContract.ownerOf(tokenID) == msg.sender), //or msg.sender is token holder
    //         "ST:MOD-UA-ERR:User not registered "
    //     );
    //     _;
    // }
    modifier isAuthorized(bytes32 _idxHash) {
        uint256 tokenID = uint256(_idxHash);
        User memory user = getUser();

        require(
            (((user.userType > 0) && (user.userType < 10)), 
            "ST:MOD-UA-ERR:User not registered "
        );
        _;
    }

    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//
    /*
     * @dev Address Setters
     */

    function OO_ResolveContractAddresses() external onlyOwner nonReentrant {
        //^^^^^^^checks^^^^^^^^^
        AssetClassTokenAddress = Storage.resolveContractAddress(
            "assetClassToken"
        );
        AssetClassTokenContract = AssetClassTokenInterface(
            AssetClassTokenAddress
        );

        AssetTokenAddress = Storage.resolveContractAddress("assetToken");
        AssetTokenContract = AssetTokenInterface(AssetTokenAddress);

        prufPayableAddress = Storage.resolveContractAddress("prufPayable");
        prufPayableContract = prufPayableInterface(prufPayableAddress);
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

    function setEscrow(
        bytes32 _idxHash,
        uint256 _escrowTime,
        uint8 _escrowStatus,
        bytes32 _escrowOwnerHash
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        uint256 escrowTime = now.add(_escrowTime);
        uint8 newAssetStatus;

        require((rec.rightsHolder != 0), "SE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "SE: User not authorized to modify records in specified asset class"
        );
        require(
            (escrowTime >= now),
            "SE:ERR-Escrow must be set to a time in the future"
        );
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "SE:ERR-Transferred, lost, or stolen status cannot be set to escrow."
        );
        require(
            (callingUser.userType < 5) ||
                ((callingUser.userType > 4) && (_escrowStatus > 49)),
            "SE:ERR-Non supervisored agents must set escrow witihn user type."
        );
        require(
            (_escrowStatus == 6) ||
                (_escrowStatus == 50) ||
                (_escrowStatus == 56),
            "SE:ERR-Must specify an valid escrow status"
        );
        //^^^^^^^checks^^^^^^^^^

        newAssetStatus = _escrowStatus;

        //^^^^^^^effects^^^^^^^^^

        Storage.setEscrow(
            _escrowOwnerHash,
            _idxHash,
            newAssetStatus,
            escrowTime
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Record memory shortRec = getShortRecord(_idxHash);
        User memory callingUser = getUser();

        require((rec.rightsHolder != 0), "EE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "EE: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 6) ||
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "EE:ERR- record must be in escrow status"
        );
        require(
            ((rec.assetStatus > 49) || (callingUser.userType < 5)),
            "EE:ERR- Usertype less than 5 required to end this escrow"
        );
        require(
            (shortRec.timeLock < now) ||
                (keccak256(abi.encodePacked(msg.sender)) == rec.recorder),
            "EE:ERR- Escrow period not ended"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage.endEscrow(keccak256(abi.encodePacked(msg.sender)), _idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
    
    //--------------------------------------------------------------------------------------Private functions
    /*
     * @dev Get a User Record from Storage @ msg.sender
     */
    function getUser() private view returns (User memory) {
        //User memory callingUser = getUser();
        User memory user;
        (user.userType, user.authorizedAssetClass) = prufPayableContract
            .getUserExt(keccak256(abi.encodePacked(msg.sender)));
        return user;
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
     * @dev Get a ShortRecord from Storage @ idxHash
     */
    function getShortRecord(bytes32 _idxHash) private returns (Record memory) {
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

}
