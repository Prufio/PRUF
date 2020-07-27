/*-----------------------------------------------------------V0.6.7
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/Ownable.sol";
import "./Imports/Pausable.sol";
import "./Imports/ReentrancyGuard.sol";
import "./_ERC721/IERC721Receiver.sol";

contract BASIC is ReentrancyGuard, Ownable, IERC721Receiver, Pausable {
    struct Record {
        //bytes32 recorder; // Address hash of recorder
        bytes32 rightsHolder; // KEK256 Registered owner
        //bytes32 lastRecorder; // Address hash of last non-automation recorder
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        //uint256 timeLock; // Time sensitive mutex
        uint16 numberOfTransfers; //number of transfers and forcemods
    }
    // struct User {
    //     uint8 userType; // User type: 1 = human, 9 = automated
    //     mapping (uint16 => uint8) authorized;
    //     //uint16 authorizedAssetClass; // Asset class in which user is permitted to transact
    // }

    struct AC {
        string name; // NameHash for assetClass
        uint16 assetClassRoot; // asset type root (bycyles - USA Bicycles)
        uint8 custodyType; // custodial or noncustodial
        uint256 extendedData; // Future Use
    }

    struct ContractDataHash {
        uint8 contractType; // Auth Level / type
        bytes32 nameHash; // Contract Name hashed
    }

    struct escrowData {
        uint8 data;
        bytes32 controllingContractNameHash;
        bytes32 escrowOwnerAddressHash;
        uint256 timelock;
        bytes32 ex1;
        bytes32 ex2;
        address addr1;
        address addr2;
    }

    //mapping(bytes32 => User) internal registeredUsers; // Authorized recorder database

    address internal storageAddress;
    S_Interface internal Storage; // Set up external contract interface

    address internal AssetClassTokenManagerAddress;
    AC_MGR_Interface internal AssetClassTokenManagerContract; // Set up external contract interface

    address internal AssetTokenAddress;
    A_TKN_Interface internal AssetTokenContract; //erc721_token prototype initialization

    address internal AssetClassTokenAddress;
    AC_TKN_Interface internal AssetClassTokenContract; //erc721_token prototype initialization

    address internal escrowMGRAddress;
    ECR_MGR_Interface internal escrowMGRcontract; //Set up external contract interface for escrowmgr

    address internal recyclerAddress; //Set up external contract interface for recycler
    RCLR_Interface internal Recycler;

    address internal PrufAppAddress;
    address internal T_PrufAppAddress;

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
            "PB:MOD-IA: Modifier MUST BE OVERRIDDEN"
        );
        _;
    }

    //----------------------External Admin functions / onlyowner or isAdmin----------------------//
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
            "AC_TKN"
        );
        AssetClassTokenContract = AC_TKN_Interface(AssetClassTokenAddress);

        AssetClassTokenManagerAddress = Storage.resolveContractAddress(
            "AC_MGR"
        );

        AssetClassTokenManagerContract = AC_MGR_Interface(
            AssetClassTokenManagerAddress
        );

        AssetTokenAddress = Storage.resolveContractAddress("A_TKN");
        AssetTokenContract = A_TKN_Interface(AssetTokenAddress);

        escrowMGRAddress = Storage.resolveContractAddress("ECR_MGR");
        escrowMGRcontract = ECR_MGR_Interface(escrowMGRAddress);

        PrufAppAddress = Storage.resolveContractAddress("APP");
        T_PrufAppAddress = Storage.resolveContractAddress("APP_NC");

        recyclerAddress = Storage.resolveContractAddress("RCLR");
        Recycler = RCLR_Interface(recyclerAddress);
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
        //^^^^^^^effects^^^^^^^^^
        AssetTokenContract.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    function OO_TX_AC_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
        nonReentrant
    {
        //^^^^^^^checks^^^^^^^^^
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^effects^^^^^^^^^
        AssetClassTokenContract.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "PB:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage = S_Interface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
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
        //^^^^^^^checks^^^^^^^^^
        return this.onERC721Received.selector;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Triggers stopped state.
     *
     */
    function OO_pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state.
     */
    function OO_unpause() external onlyOwner {
        _unpause();
    }

    //--------------------------------------------------------------------------------------INTERNAL functions

    /*
     * @dev Get a User Record from AC_manager @ msg.sender
     */
    function getUserType(uint16 _assetClass)
        internal
        virtual
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^

        uint8 userTypeInAssetClass = AssetClassTokenManagerContract.getUserType(
            keccak256(abi.encodePacked(msg.sender)),
            _assetClass
        );

        return userTypeInAssetClass;
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
        //^^^^^^^checks^^^^^^^^^
        AC memory AC_info;
        //^^^^^^^effects^^^^^^^^^
        (
            AC_info.assetClassRoot,
            AC_info.custodyType,
            AC_info.extendedData
        ) = AssetClassTokenManagerContract.getAC_data(_assetClass);
        return AC_info;
        //^^^^^^^interactions^^^^^^^^^
    }

    function getContractInfo(address _addr)
        internal
        returns (ContractDataHash memory)
    {
        ContractDataHash memory contractInfo;
        (contractInfo.contractType, contractInfo.nameHash) = Storage
            .ContractInfoHash(_addr);
        return contractInfo;
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord(bytes32 _idxHash) internal returns (Record memory) {
        //^^^^^^^checks^^^^^^^^^
        Record memory rec;
        //^^^^^^^effects^^^^^^^^^

        {
            //Start of scope limit for stack depth
            (
                //bytes32 _recorder,
                bytes32 _rightsHolder,
                //bytes32 _lastRecorder,
                uint8 _assetStatus,
                uint8 _forceModCount,
                uint16 _assetClass,
                uint256 _countDown,
                uint256 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2,
                uint16 _numberOfTransfers
            ) = Storage.retrieveRecord(_idxHash); // Get record from storage contract

            //rec.recorder = _recorder;
            rec.rightsHolder = _rightsHolder;
            //rec.lastRecorder = _lastRecorder;
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
}
