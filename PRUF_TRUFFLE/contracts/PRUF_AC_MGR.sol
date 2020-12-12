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

    struct Costs {
        uint256 serviceCost; // Cost in the given item category
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    uint256 private ACtokenIndex = 1000000; //asset tokens created in sequence starting at at 1,000,000

    uint256 private acPrice_L1 = 10000000000000000000000;
    uint256 private acPrice_L2 = 15000000000000000000000;
    uint256 private acPrice_L3 = 22500000000000000000000;
    uint256 private acPrice_L4 = 33750000000000000000000;
    uint256 private acPrice_L5 = 50625000000000000000000;
    uint256 private acPrice_L6 = 75937000000000000000000;
    uint256 private acPrice_L7 = 100000000000000000000000;

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

    //address AC_minterAddress;
    uint256 private priceThreshold; //threshold of price where fractional pricing is implemented

    uint256 private upgradeMultiplier = 3; // multplier to determine the amount of pruf required to fully upgrade an AC node token
    uint32 private constant startingDiscount = 5100; // Nodes start with 51% profit share

    constructor() public {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
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
            (AC_TKN.ownerOf(_assetClass) == msg.sender),
            "ACM:MOD-IACTHoC:msg.sender not authorized in asset class"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------
    /*
     * @dev Set upgrade price multiplier (default 3)----------------------DPB:TEST ---- NEW functionality
     */
    function OO_SetPricing(
        uint256 _newValue,
        uint256 _L1,
        uint256 _L2,
        uint256 _L3,
        uint256 _L4,
        uint256 _L5,
        uint256 _L6,
        uint256 _L7
    ) external isAdmin {
        //DPS:EXAMINE  -- NEW FUNCTIONALITY
        require(_newValue < 10001, "multiplier > 10 thousand!");
        //^^^^^^^checks^^^^^^^^^

        acPrice_L1 = _L1;
        acPrice_L2 = _L2;
        acPrice_L3 = _L3;
        acPrice_L4 = _L4;
        acPrice_L5 = _L5;
        acPrice_L6 = _L6;
        acPrice_L7 = _L7;
        upgradeMultiplier = _newValue;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("Upgrade Multiplier Changed!"); //report access to internal parameter
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     */
    function addUser(
        //add the K256HASH of the address, not the address. ----------------------DPB:TEST ---- NEW REQUIREMENT
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
     * @dev Burns (amout) tokens and mints a new asset class token to the caller address
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function purchaseACnode(
        //-------------------------------------------------------CTS:EXAMINE pruf balance check?
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS
    ) external whenNotPaused nonReentrant returns (uint256) {
        require( //Impossible to test??
            ACtokenIndex < 4294000000,
            "PRuf:IS:Only 4294000000 AC tokens allowed"
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

        //mint an asset class token to msg.sender, at tokenID ACtokenIndex, with URI = root asset Class #

        UTIL_TKN.trustedAgentBurn(msg.sender, currentACtokenPrice);
        currentACtokenPrice = newACtokenPrice;

        _createAssetClass(
            msg.sender,
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
        //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
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
    function updateACipfs(
        bytes32 _IPFS,
        uint32 _assetClass //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
    ) external isACtokenHolderOfClass(_assetClass) whenNotPaused {
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
        uint32 _extData,
        uint32 _assetClass //-------------------------------------------------------DS:TEST
    ) external isACtokenHolderOfClass(_assetClass) whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        AC_data[_assetClass].extendedData = _extData;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev See {IERC20-transfer}. Increase payment share of an asset class
     *
     * Requirements:
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function increaseShare(
        uint32 _assetClass,
        uint256 _amount //in whole pruf tokens, not 18 decimals
    )
        external
        whenNotPaused
        nonReentrant
        isACtokenHolderOfClass(_assetClass)
        returns (bool)
    {
        require( //-------------------------------------------------------DS:TEST
            _amount >= (upgradeMultiplier.mul(100)),
            "PRuf:IS:amount too low to increase price share"
        );
        require( //-------------------------------------------------------DS:TEST
            AC_data[_assetClass].discount <= 8999,
            "PRuf:IS:price share already maxed out"
        );

        //^^^^^^^checks^^^^^^^^^

        uint256 oldShare = uint256(getAC_discount(_assetClass));

        uint256 maxPayment = (uint256(9000).sub(oldShare)).mul(
            upgradeMultiplier
        ); //max payment percentage never goes over 90%

        address rootPaymentAdress = cost[AC_data[_assetClass].assetClassRoot][1]
            .paymentAddress; //payment for upgrade goes to root AC payment adress specified for service (1)

        if (_amount > maxPayment) _amount = maxPayment;

        //^^^^^^^effects^^^^^^^^^

        increasePriceShare(_assetClass, _amount.div(upgradeMultiplier));

        UTIL_TKN.trustedAgentTransfer(
            msg.sender,
            rootPaymentAdress,
            _amount.mul(1 ether) //adds 18 zeros to work in full tokens
        );
        //^^^^^^^interactions^^^^^^^^^
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

     /*
     * @dev Increases priceShare in an assetClass
     *
     */
    function increasePriceShare(uint32 _assetClass, uint256 _increaseAmount)
        private
        whenNotPaused
    {
        require( //-------------------------------------------------------DS:TEST
            AC_data[_assetClass].discount <= 8999,
            "PRuf:IPS:price share already max"
        );
        uint256 discount = AC_data[_assetClass].discount;
        //^^^^^^^checks^^^^^^^^^

        discount = discount.add(_increaseAmount);
        if (discount > 9000) discount = 9000;

        AC_data[_assetClass].discount = uint32(discount); //type conversion safe because discount always <= 10000
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev creates an assetClass
     * makes ACdata record with new name, mints token
     *
     */
    function _createAssetClass(
        //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
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
        ); //sanity check inputs //-------------------------------------------------------DS:TEST
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
    function getAC_data(
        uint32 _assetClass //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
    )
        external
        view
        returns (
            uint32,
            uint8,
            uint32,
            uint32,
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
    function getAC_discount(uint32 _assetClass) public view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        return (AC_data[_assetClass].discount);
        //^^^^^^^interactions^^^^^^^^^
    }
}
