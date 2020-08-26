/*-----------------------------------------------------------V0.6.8
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
 *-----------------------------------------------------------------
 *PRUF basic provides core data structures and functionality to PRUF contracts.
 *Features include contract name resolution, and getters for records, users, and asset class information.
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
        //struct for holding and manipulating record data
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint32 assetClass; // Type of asset
        uint32 countDown; // Variable that can only be dencreased from countDownStart
        uint32 countDownStart; // Starting point for countdown variable (set once)
        uint256 incrementNumberOfTransfers; //increment flag for number of transfers and forcemods
        uint256 incrementForceModCount; // increment flag for Number of times asset has been forceModded.
        bytes32 rightsHolder; // KEK256 Registered owner
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
    }

    struct AC {
        //Struct for holding and manipulating assetClass data
        string name; // NameHash for assetClass
        uint32 assetClassRoot; // asset type root (bycyles - USA Bicycles)
        uint8 custodyType; // custodial or noncustodial
        uint32 extendedData; // Future Use
    }

    struct ContractDataHash {
        //Struct for holding and manipulating contract authorization data
        uint8 contractType; // Auth Level / type
        bytes32 nameHash; // Contract Name hashed
    }

    address internal STOR_Address;
    STOR_Interface internal STOR;

    address internal AC_MGR_Address;
    AC_MGR_Interface internal AC_MGR;

    address internal A_TKN_Address;
    A_TKN_Interface internal A_TKN;

    address internal AC_TKN_Address;
    AC_TKN_Interface internal AC_TKN;

    address internal ECR_MGR_Address;
    ECR_MGR_Interface internal ECR_MGR;

    address internal RCLR_Address;
    RCLR_Interface internal RCLR;

    address internal APP_Address;
    APP_Interface internal APP;

    address internal NAKED_Address;
    address internal APP_NC_Address;
    address internal NP_Address;

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
            "B:MOD-IA: Modifier MUST BE OVERRIDDEN"
        );
        _;
    }

    //----------------------External Admin functions / onlyowner or isAdmin----------------------//
    /*
     * @dev Resolve Contract Addresses from STOR
     */
    function OO_ResolveContractAddresses()
        external
        virtual
        nonReentrant
        onlyOwner
    {
        //^^^^^^^checks^^^^^^^^^
        AC_TKN_Address = STOR.resolveContractAddress("AC_TKN");
        AC_TKN = AC_TKN_Interface(AC_TKN_Address);

        AC_MGR_Address = STOR.resolveContractAddress("AC_MGR");

        AC_MGR = AC_MGR_Interface(AC_MGR_Address);

        A_TKN_Address = STOR.resolveContractAddress("A_TKN");
        A_TKN = A_TKN_Interface(A_TKN_Address);

        ECR_MGR_Address = STOR.resolveContractAddress("ECR_MGR");
        ECR_MGR = ECR_MGR_Interface(ECR_MGR_Address);

        APP_Address = STOR.resolveContractAddress("APP");
        APP = APP_Interface(APP_Address);

        RCLR_Address = STOR.resolveContractAddress("RCLR");
        RCLR = RCLR_Interface(RCLR_Address);

        APP_NC_Address = STOR.resolveContractAddress("APP_NC");
        NP_Address = STOR.resolveContractAddress("NP");
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Transfer any assetTokens from contract
     */
    function transferAssetToken(address _to, bytes32 _idxHash)
        external
        virtual
        nonReentrant
    //^^^^^^^checks^^^^^^^^^
    {
        require(
            (msg.sender == owner()) || (msg.sender == NP_Address),
            "B:TX:Invalid caller for transfer token"
        );
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^effects^^^^^^^^^
        A_TKN.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Transfer any assetClassTokens from contract
     */
    function OO_transferACToken(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
        nonReentrant
    {
        //^^^^^^^checks^^^^^^^^^
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^effects^^^^^^^^^
        AC_TKN.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "B:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR = STOR_Interface(_storageAddress);
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
    function getUserType(uint32 _assetClass)
        internal
        virtual
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^

        uint8 userTypeInAssetClass = AC_MGR.getUserType(
            keccak256(abi.encodePacked(msg.sender)),
            _assetClass
        );

        return userTypeInAssetClass;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Get asset class information from AC_manager and return an AC Struct
     */
    function getACinfo(uint32 _assetClass)
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
        ) = AC_MGR.getAC_data(_assetClass);
        return AC_info;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Get contract information from STOR and return a ContractDataHash Struct
     */
    function getContractInfo(address _addr, uint32 _assetClass)
        internal
        returns (ContractDataHash memory)
    {
        ContractDataHash memory contractInfo;
        (contractInfo.contractType, contractInfo.nameHash) = STOR
            .ContractInfoHash(_addr, _assetClass);
        return contractInfo;
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev Get a Record from Storage @ idxHash and return a Record Struct
     */
    function getRecord(bytes32 _idxHash) internal returns (Record memory) {
        //^^^^^^^checks^^^^^^^^^
        Record memory rec;
        //^^^^^^^effects^^^^^^^^^

        {
            //Start of scope limit for stack depth
            (
                bytes32 _rightsHolder,
                uint8 _assetStatus,
                uint32 _assetClass,
                uint32 _countDown,
                uint32 _countDownStart,
                bytes32 _Ipfs1,
                bytes32 _Ipfs2
            ) = STOR.retrieveRecord(_idxHash); // Get record from storage contract

            rec.rightsHolder = _rightsHolder;
            rec.assetStatus = _assetStatus;
            rec.assetClass = _assetClass;
            rec.countDown = _countDown;
            rec.countDownStart = _countDownStart;
            rec.Ipfs1 = _Ipfs1;
            rec.Ipfs2 = _Ipfs2;
        } //end of scope limit for stack depth

        return (rec); // Returns Record struct rec
        //^^^^^^^interactions^^^^^^^^^
    }
}
