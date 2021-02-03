/*--------------------------------------------------------PRuF0.7.1
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
 * STATEMENT OF TERMS OF SERVICE (TOS):
 * User agrees not to intentionally claim any namespace that is a recognized or registered brand name, trade mark,
 * or other Intellectual property not belonging to the user, and agrees to voluntarily remove any name or brand found to be
 * infringing from any record that the user controls, within 30 days of notification. If notification is not possible or
 * there is no response to notification, the user agrees that the name record may be changed without their permission or cooperation.
 * Use of this software constitutes consent to the terms above.
 *-----------------------------------------------------------------
 */

/*-----------------------------------------------------------------
 *  TO DO
 * REWORK TO TAKE ALL INPUTS FOR TOKEN MANIPULATION IN wei notation (18 zeros)
 * ADD ROLES! (need role for ACNODE MINTER)
 * all 18 dec math for price share
 * 100% price share option to hook into dNodes
 *-----------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_BASIC.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract AC_MGR is BASIC {
    using SafeMath for uint256;

    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    struct Costs {
        uint256 serviceCost; // Cost in the given item category
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    uint256 private ACtokenIndex = 1000000; //Starting index for purchased ACnode tokens

    uint256 public acPrice_L1 = 20000000000000000000000;
    uint256 public acPrice_L2 = 30000000000000000000000;
    uint256 public acPrice_L3 = 45000000000000000000000;
    uint256 public acPrice_L4 = 70000000000000000000000;
    uint256 public acPrice_L5 = 100000000000000000000000;
    uint256 public acPrice_L6 = 150000000000000000000000;
    uint256 public acPrice_L7 = 200000000000000000000000;

    uint256 private currentACtokenPrice = acPrice_L1;

    mapping(uint32 => mapping(uint16 => Costs)) private cost; // Cost per function by asset class => Cost Type
    /*
        Cost indexes
        1 newRecordCost; // Cost to create a new record
        2 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        3 createNoteCost; // Cost to add a static note to an asset
        4 reMintRecordCost; // Extra
        5 changeStatusCost; // Extra
        6 forceModifyCost; // Cost to brute-force a record transfer
    */

    mapping(uint32 => AC) private AC_data; // AC info database asset class to AC struct (NAME,ACroot,CUSTODIAL/NC,uint32)
    mapping(string => uint32) private AC_number; //name to asset class resolution map

    mapping(bytes32 => mapping(uint32 => uint8)) private registeredUsers; // Authorized recorder database by asset class, by address hash

    uint256 private priceThreshold; //threshold of price where fractional pricing is implemented

    /* ----prufPerShare-----
     * divisor to divide amount of pruf (18d) sent to determine the profit share.
     * profit share of 1000 = 10% default u10 for .01% profit share = "1 share"
     */
    uint256 public prufPerShare = 10000000000000000000;
    uint256 public upperLimit = 9500; // default max profit share = 95%

    uint32 private constant startingDiscount = 5100; // Purchased nodes start with 51% profit share

    constructor() public {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
        AC_number[""] = 4294967295; //points the blank string name to AC 4294967295
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is admin
     */
    modifier isNodeMinter() {
        require(
            hasRole(NODE_MINTER_ROLE, _msgSender()),
            "PAM:MOD: must have NODE_MINTER_ROLE"
        );
        _;
    }

    /*
     * @dev Verify caller holds ACtoken of passed assetClass
     */
    modifier isACtokenHolderOfClass(uint32 _assetClass) {
        require(
            (AC_TKN.ownerOf(_assetClass) == _msgSender()),
            "ACM:MOD-IACTHoC:_msgSender() not authorized in asset class"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------
    /*
     * @dev Set upgrade COST AND UPPER LIMIT----------------------DPB:TEST ---- NEW functionality
     */
    function OO_SetACupgrade(uint256 _prufPerShare, uint256 _upperLimit)
        external
        isAdmin
    {
        //^^^^^^^checks^^^^^^^^^
        upperLimit = _upperLimit;
        prufPerShare = _prufPerShare;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACnode Upgrade parameter(s) Changed!"); //report access to internal parameter
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set pricing
     */
    function OO_SetACpricing(
        uint256 _L1,
        uint256 _L2,
        uint256 _L3,
        uint256 _L4,
        uint256 _L5,
        uint256 _L6,
        uint256 _L7
    ) external isAdmin {
        //^^^^^^^checks^^^^^^^^^

        acPrice_L1 = _L1;
        acPrice_L2 = _L2;
        acPrice_L3 = _L3;
        acPrice_L4 = _L4;
        acPrice_L5 = _L5;
        acPrice_L6 = _L6;
        acPrice_L7 = _L7;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACnode pricing Changed!"); //report access to internal parameter
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     */
    function addUser(
        bytes32 _addrHash,
        uint8 _userType,
        uint32 _assetClass
    ) external whenNotPaused isACtokenHolderOfClass(_assetClass) {
        //^^^^^^^checks^^^^^^^^^

        registeredUsers[_addrHash][_assetClass] = _userType;

        if ((_userType != 0) && (registeredUsers[_addrHash][0] < 255)) {
            registeredUsers[_addrHash][0]++;
        }

        if ((_userType == 0) && (registeredUsers[_addrHash][0] > 0)) {
            registeredUsers[_addrHash][0]--;
        }

        //^^^^^^^effects^^^^^^^^^
        emit REPORT("Internal user database access!"); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Burns (amount) tokens and mints a new asset class token to the caller address
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function purchaseACnode(
        //--------------will fail in burn if insufficient tokens
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS
    ) external whenNotPaused nonReentrant returns (uint256) {
        require( //Impossible to test??
            ACtokenIndex < 4294000000,
            "PRuf:IS:Only 4294000000 AC tokens allowed"
        );
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is token holder
            "ANC:MOD-IA: Caller does not hold a valid PRuF_ID token"
        );
        //^^^^^^^checks^^^^^^^^^

        if (ACtokenIndex < 4294000000) ACtokenIndex++; //increment ACtokenIndex up to last one

        uint256 newACtokenPrice;
        uint256 numberOfTokensSold = ACtokenIndex.sub(uint256(1000000));

        if (numberOfTokensSold >= 4000) {
            newACtokenPrice = acPrice_L7;
        } else if (numberOfTokensSold >= 2000) {
            newACtokenPrice = acPrice_L6;
        } else if (numberOfTokensSold >= 1000) {
            newACtokenPrice = acPrice_L5;
        } else if (numberOfTokensSold >= 500) {
            newACtokenPrice = acPrice_L4;
        } else if (numberOfTokensSold >= 250) {
            newACtokenPrice = acPrice_L3;
        } else if (numberOfTokensSold >= 125) {
            newACtokenPrice = acPrice_L2;
        } else {
            newACtokenPrice = acPrice_L1;
        }
        //^^^^^^^effects^^^^^^^^^

        //mint an asset class token to _msgSender(), at tokenID ACtokenIndex, with URI = root asset Class #

        UTIL_TKN.trustedAgentBurn(_msgSender(), currentACtokenPrice);
        currentACtokenPrice = newACtokenPrice;

        _createAssetClass(
            _msgSender(),
            _name,
            uint32(ACtokenIndex), //safe because ACtokenIndex <  4294000000 required
            _assetClassRoot,
            _custodyType,
            _IPFS,
            startingDiscount
        );

        return ACtokenIndex; //returns asset class # of minted token
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /*
     * @dev Mints asset class token and creates an assetClass. Mints to @address
     * Requires that:
     *  name is unuiqe
     *  AC is not provisioned with a root (proxy for not yet registered)
     *  that ACtoken does not exist
     *  _discount 10000 = 100 percent price share , cannot exceed
     */
    function createAssetClass(
        address _recipientAddress,
        string calldata _name,
        uint32 _assetClass,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS,
        uint32 _discount
    ) external isNodeMinter whenNotPaused nonReentrant {
        //^^^^^^^checks^^^^^^^^^
        _createAssetClass(
            _recipientAddress,
            _name,
            _assetClass,
            _assetClassRoot,
            _custodyType,
            _IPFS,
            _discount
        );
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Modifies an assetClass
     * Sets a new AC name. Asset Classes cannot be moved to a new root or custody type.
     * Requires that:
     *  caller holds ACtoken
     *  name is unuiqe or same as old name
     */
    function updateACname(string calldata _name, uint32 _assetClass)
        external
        whenNotPaused
        isACtokenHolderOfClass(_assetClass)
    {
        require( //should pass if name is same as old name or name is unassigned. Should fail if name is assigned to other AC
            (AC_number[_name] == 0) || //name is unassigned
                (keccak256(abi.encodePacked(_name)) == //name is same as old name
                    (keccak256(abi.encodePacked(AC_data[_assetClass].name)))),
            "ACM:UAC:AC name already in use in other AC"
        );
        //^^^^^^^checks^^^^^^^^^

        delete AC_number[AC_data[_assetClass].name];

        AC_number[_name] = _assetClass;
        AC_data[_assetClass].name = _name;
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Modifies an assetClass
     * Sets a new AC IPFS Address. Asset Classes cannot be moved to a new root or custody type.
     * Requires that:
     *  caller holds ACtoken
     */
    function updateACipfs(bytes32 _IPFS, uint32 _assetClass)
        external
        isACtokenHolderOfClass(_assetClass)
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        AC_data[_assetClass].IPFS = _IPFS;
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Modifies an assetClass
     * Sets a new AC EXT Data uint32
     * Requires that:
     *  caller holds ACtoken
     */
    function updateACextendedData(
        uint160 _extData,
        uint32 _assetClass //-------------------------------------------------------TEST
    ) external isACtokenHolderOfClass(_assetClass) whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        AC_data[_assetClass].extendedData = _extData;
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set function costs and payment address per asset class, in Wei
     */
    function ACTH_setCosts(
        uint32 _assetClass,
        uint16 _service,
        uint256 _serviceCost,
        address _paymentAddress
    ) external whenNotPaused isACtokenHolderOfClass(_assetClass) {
        //^^^^^^^checks^^^^^^^^^
        cost[_assetClass][_service].serviceCost = _serviceCost;
        cost[_assetClass][_service].paymentAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Increase payment share of an asset class
     *
     * Requirements:
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function increaseShare(uint32 _assetClass, uint256 _amount)
        external
        whenNotPaused
        nonReentrant
        isACtokenHolderOfClass(_assetClass)
        returns (uint32)
    {
        require(
            AC_data[_assetClass].discount < upperLimit,
            "PRuf:IS:price share already maxed out"
        );

        require(
            _amount > prufPerShare,
            "PRuf:IS:amount too low to increase price share"
        );

        //^^^^^^^checks^^^^^^^^^
        address rootPaymentAddress =
            cost[AC_data[_assetClass].assetClassRoot][1].paymentAddress; //payment for upgrade goes to root AC payment adress specified for service (1)

        uint256 oldShare = uint256(AC_data[_assetClass].discount);
        uint256 maxShareIncrease = (upperLimit.sub(oldShare)); //max payment percentage never goes over upperLimit%
        uint256 sharesToBuy = _amount.div(prufPerShare);
        if (sharesToBuy > maxShareIncrease) {
            sharesToBuy = maxShareIncrease;
        }

        uint256 upgradeCost = sharesToBuy.mul(prufPerShare); //multiplies and adds 18d

        //^^^^^^^effects^^^^^^^^^

        increasePriceShare(_assetClass, sharesToBuy);

        UTIL_TKN.trustedAgentTransfer(
            _msgSender(),
            rootPaymentAddress,
            upgradeCost
        );
        return AC_data[_assetClass].discount;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Increases priceShare in an assetClass
     *
     */
    function increasePriceShare(uint32 _assetClass, uint256 _increaseAmount)
        private
        whenNotPaused
    {
        uint256 discount = AC_data[_assetClass].discount;
        require(discount < upperLimit, "PRuf:IPS:price share already max"); //-----------This is to throw if priceShare is already >= upperLimit, otherwise will be reverted to upperLimit

        //^^^^^^^checks^^^^^^^^^

        discount = discount.add(_increaseAmount);
        if (discount > upperLimit) discount = upperLimit;

        AC_data[_assetClass].discount = uint32(discount); //type conversion safe because discount always <= upperLimit
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Transfers a name from one asset class to another
     * !! -------- to be used with great caution and only as a result of community governance action -----------
     * Designed to remedy brand infringement issues. This breaks decentralization and must eventually be given
     * over to some kind of governance contract.
     * Destination AC must have IPFS Set to 0xFFF.....
     *
     */
    function transferName(
        //---------------------------------------DPS TEST-----NEW
        string calldata _name,
        uint32 _assetClass_source,
        uint32 _assetClass_dest
    ) external isAdmin whenNotPaused nonReentrant {
        require(
            AC_number[_name] == _assetClass_source,
            "ACM:TA: name not in source AC"
        ); //source AC_Name must match name given

        require(
            (AC_data[_assetClass_dest].IPFS == B320xF_), //dest AC must have ipfs set to 0xFFFF.....
            "ACM:TA:Destination AC not prepared for name transfer"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_name] = _assetClass_dest;
        AC_data[_assetClass_dest].name = _name;
        AC_data[_assetClass_source].name = "";
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev creates an assetClass
     * makes ACdata record with new name, mints token
     *
     */
    function _createAssetClass(
        address _recipientAddress,
        string calldata _name,
        uint32 _assetClass,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS,
        uint32 _discount
    ) private whenNotPaused {
        AC memory _ac = AC_data[_assetClassRoot];
        uint256 tokenId = uint256(_assetClass);

        require((tokenId != 0), "ACM:CAC: AC cannot be 0"); //sanity check inputs
        require(
            _discount <= 10000,
            "ACM:CAC: discount cannot exceed 100% (10000)"
        );
        require( //has valid root
            (_ac.custodyType != 0) || (_assetClassRoot == _assetClass),
            "ACM:CAC:Root asset class does not exist"
        );

        require(AC_number[_name] == 0, "ACM:CAC:AC name already in use");
        require(
            (AC_data[_assetClass].assetClassRoot == 0),
            "ACM:CAC:AC already in use"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_name] = _assetClass;
        AC_data[_assetClass].name = _name;
        AC_data[_assetClass].assetClassRoot = _assetClassRoot;
        AC_data[_assetClass].discount = _discount;
        AC_data[_assetClass].custodyType = _custodyType;
        AC_data[_assetClass].IPFS = _IPFS;
        //^^^^^^^effects^^^^^^^^^

        AC_TKN.mintACToken(
            _recipientAddress,
            tokenId,
            "pruf.io/assetClassToken"
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //-------------------------------------------functions for information retrieval----------------------------------------------
    /*
     * @dev get a User Record
     */
    function getUserType(bytes32 _userHash, uint32 _assetClass)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (registeredUsers[_userHash][_assetClass]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_data @ _assetClass
     */
    function getAC_data(uint32 _assetClass)
        external
        view
        returns (
            uint32,
            uint8,
            uint32,
            uint160,
            bytes32
        )
    {
        //^^^^^^^checks^^^^^^^^^
        return (
            AC_data[_assetClass].assetClassRoot,
            AC_data[_assetClass].custodyType,
            AC_data[_assetClass].discount,
            AC_data[_assetClass].extendedData,
            AC_data[_assetClass].IPFS
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_data @ _assetClass
     */
    function getExtAC_data(uint32 _assetClass)
        external
        view
        returns (
            uint8,
            uint8,
            uint8,
            uint160
        )
    {
        //^^^^^^^checks^^^^^^^^^
        return (
            AC_data[_assetClass].byte1,
            AC_data[_assetClass].byte2,
            AC_data[_assetClass].byte3,
            AC_data[_assetClass].extendedData
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev compare the root of two asset classes
     */
    function isSameRootAC(uint32 _assetClass1, uint32 _assetClass2)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        if (
            AC_data[_assetClass1].assetClassRoot ==
            AC_data[_assetClass2].assetClassRoot
        ) {
            return uint8(170);
        } else {
            return uint8(0);
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_name @ _tokenId
     */
    function getAC_name(uint32 _tokenId) external view returns (string memory) {
        //^^^^^^^checks^^^^^^^^^
        uint32 assetClass = _tokenId; //check for overflow andf throw
        return (AC_data[assetClass].name);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_number @ AC_name
     */
    function resolveAssetClass(string calldata _name)
        external
        view
        returns (uint32)
    {
        //^^^^^^^checks^^^^^^^^^
        return (AC_number[_name]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev return current AC token index pointer
     */
    function currentACpricingInfo()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        //^^^^^^^checks^^^^^^^^^

        uint256 numberOfTokensSold = ACtokenIndex.sub(uint256(1000000));
        return (
            numberOfTokensSold,
            currentACtokenPrice,
            acPrice_L1,
            acPrice_L2,
            acPrice_L3,
            acPrice_L4,
            acPrice_L5,
            acPrice_L6,
            acPrice_L7
        );
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    //-------------------------------------------functions for payment calculations----------------------------------------------

    /*
     * @dev Retrieve function costs per asset class, per service type, in Wei
     */
    function getServiceCosts(uint32 _assetClass, uint16 _service)
        external
        view
        returns (
            address,
            uint256,
            address,
            uint256
        )
    {
        AC memory AC_info = AC_data[_assetClass];
        require(AC_info.assetClassRoot != 0, "ACM:GC:AC not yet populated");

        require(_service != 0, "ACM:GC:Service type zero is invalid");

        Costs memory costs = cost[_assetClass][_service];
        uint32 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass][_service];

        //^^^^^^^checks^^^^^^^^^
        return (
            rootCosts.paymentAddress,
            rootCosts.serviceCost,
            costs.paymentAddress,
            costs.serviceCost
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_discount @ _assetClass, in percent ACTH share, * 100 (9000 = 90%)
     */
    function getAC_discount(uint32 _assetClass) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        return (AC_data[_assetClass].discount);
        //^^^^^^^interactions^^^^^^^^^
    }
}
