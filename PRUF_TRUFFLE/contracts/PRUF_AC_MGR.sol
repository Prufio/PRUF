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
 *
 *-----------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_BASIC.sol";

//import "./Imports/math/Safemath.sol";

contract AC_MGR is BASIC {
    using SafeMath for uint256;

    struct Costs {
        uint256 serviceCost; // Cost in the given item category
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    uint256 private ACtokenIndex = 1000000; //asset tokens created in sequence starting at at 1,000,000
    uint256 private currentACtokenPrice = 10000;

    //mapping(uint32 => Costs) private cost; // Cost per function by asset class
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

    uint256 constant  private upgradeMultiplier = 3; // multplier to determine the amount of pruf required to fully upgrade an AC node token
    uint32 constant  private startingDiscount = 5100; // Nodes start with 51% profit share
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is owner
     */
    modifier isAdmin() {
        require(
            (msg.sender == owner()) || (msg.sender == UTIL_TKN_Address),
            "ACM:MOD-IA:Calling address does not belong to an Admin"
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
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function OO_addUser(
        address _authAddr,
        uint8 _userType,
        uint32 _assetClass
    ) external whenNotPaused isACtokenHolderOfClass(_assetClass) {
        //^^^^^^^checks^^^^^^^^^

        bytes32 addrHash = keccak256(abi.encodePacked(_authAddr));

        registeredUsers[addrHash][_assetClass] = _userType;

        if ((_userType != 0) && (registeredUsers[addrHash][0] < 255)) {
            registeredUsers[addrHash][0]++;
        }

        if ((_userType == 0) && (registeredUsers[addrHash][0] > 0)) {
            registeredUsers[addrHash][0]--;
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
    function purchaseACtoken( //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS
    ) public returns (uint256) {
        require( //Impossible to test??
            ACtokenIndex < 4294000000,
            "PRuf:IS:Only 4294000000 AC tokens allowed"
        );
        //^^^^^^^checks^^^^^^^^^

        if (ACtokenIndex < 4294000000) ACtokenIndex++; //increment ACtokenIndex up to last one

        uint256 newACtokenPrice;
        uint256 numberOfTokensSold = ACtokenIndex.sub(uint256(1000000));

        if (numberOfTokensSold >= 4000) {
            newACtokenPrice = 100000;
        } else if (numberOfTokensSold >= 2000) {
            newACtokenPrice = 75937;
        } else if (numberOfTokensSold >= 1000) {
            newACtokenPrice = 50625;
        } else if (numberOfTokensSold >= 500) {
            newACtokenPrice = 33750;
        } else if (numberOfTokensSold >= 250) {
            newACtokenPrice = 22500;
        } else if (numberOfTokensSold >= 125) {
            newACtokenPrice = 15000;
        } else {
            newACtokenPrice = 10000;
        }
        //^^^^^^^effects^^^^^^^^^

        //mint an asset class token to msg.sender, at tokenID ACtokenIndex, with URI = root asset Class #
        _createAssetClass(
            msg.sender,
            _name,
            uint32(ACtokenIndex), //safe because ACtokenIndex <  4294000000 required
            _assetClassRoot,
            _custodyType,
            _IPFS
        );

        UTIL_TKN.trustedAgentBurn(msg.sender, currentACtokenPrice);

        currentACtokenPrice = newACtokenPrice;

        return ACtokenIndex; //returns asset class # of minted token
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /*
     * @dev Mints asset class token and creates an assetClass. Mints to @address
     * Requires that:
     *  name is unuiqe
     *  AC is not provisioned with a root (proxy for not yet registered)
     *  that ACtoken does not exist
     */
    function createAssetClass(  //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
        address _recipientAddress,
        string calldata _name,
        uint32 _assetClass,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS
    ) external onlyOwner {
        //^^^^^^^checks^^^^^^^^^
        _createAssetClass(
            _recipientAddress,
            _name,
            _assetClass,
            _assetClassRoot,
            _custodyType,
            _IPFS
        );
        //^^^^^^^effects^^^^^^^^^
    }

    function _createAssetClass(  //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
        address _recipientAddress,
        string calldata _name,
        uint32 _assetClass,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS
    ) private {
        AC memory _ac = AC_data[_assetClassRoot];
        uint256 tokenId = uint256(_assetClass);

        require((tokenId != 0), "ACM:CAC: AC cannot be 0"); //sanity check inputs
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
        AC_data[_assetClass].discount = startingDiscount; //basic discount (% to PRUF Foundation)
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

    /*
     * @dev Modifies an assetClass
     * Sets a new AC name. Asset Classes cannot be moved to a new root or custody type.
     * Requires that:
     *  caller holds ACtoken
     *  name is unuiqe or same as old name
     */
    function updateACname(string calldata _name, uint32 _assetClass)
        external
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
    {
        //^^^^^^^checks^^^^^^^^^
        AC_data[_assetClass].IPFS = _IPFS;
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Increases priceShare in an assetClass
     *
     */
    function increasePriceShare(uint32 _assetClass, uint256 _increaseAmount)
        private
    {
        uint256 discount = AC_data[_assetClass].discount;
        //^^^^^^^checks^^^^^^^^^

        discount = discount.add(_increaseAmount);
        if (discount > 9000) discount = 9000;

        AC_data[_assetClass].discount = uint32(discount); //type conversion safe because discount always <= 10000
        //^^^^^^^effects^^^^^^^^^
    }

        /**
     * @dev See {IERC20-transfer}. Increase payment share of an asset class
     *
     * Requirements:
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function increaseShare(uint32 _assetClass, uint256 _amount)
        public
        returns (bool)
    {
        require(
            _amount > 199,
            "PRuf:IS:amount < 200 will not increase price share"
        );

        //^^^^^^^checks^^^^^^^^^

        uint256 oldShare = uint256(AC_MGR.getAC_discount(_assetClass));

        uint256 maxPayment = (uint256(9000).sub(oldShare)).mul(upgradeMultiplier); //max payment percentage never goes over 90%

        address rootPaymentAdress = cost[AC_data[_assetClass].assetClassRoot][1].paymentAddress ; //payment for upgrade goes to root AC payment adress specified for service (1)

        if (_amount > maxPayment) _amount = maxPayment;
        UTIL_TKN.trustedAgentTransfer(_msgSender(), rootPaymentAdress, _amount);

        increasePriceShare(_assetClass, _amount.div(upgradeMultiplier));
        return true;
        //^^^^^^^effects/interactions^^^^^^^^^
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
    function getAC_data(uint32 _assetClass) //-------------------------------------------------------DS:TEST -- modified with new IPFS parameter
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
     * @dev Retrieve AC_discount @ _assetClass, in percent ACTH share, * 100 (9000 = 90%)
     */
    function getAC_discount(uint32 _assetClass) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        return (AC_data[_assetClass].discount);
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
    function currentACtokenInfo() external view returns (uint256, uint256) {
        //^^^^^^^checks^^^^^^^^^

        uint256 numberOfTokensSold = ACtokenIndex.sub(uint256(1000000));
        return (numberOfTokensSold, currentACtokenPrice);
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
}
