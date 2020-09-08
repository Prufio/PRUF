/*-----------------------------------------------------------V0.7.0
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

import "./PRUF_CORE.sol";

contract AC_MGR is CORE {
    using SafeMath for uint256;

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

    /*
     * @dev Mints asset class token and creates an assetClass. Mints to @address
     * Requires that:
     *  name is unuiqe
     *  AC is not provisioned with a root (proxy for not yet registered)
     *  that ACtoken does not exist
     */
    function createAssetClass(
        address _recipientAddress,
        string calldata _name,
        uint32 _assetClass,
        uint32 _assetClassRoot,
        uint8 _custodyType
    ) external isAdmin {
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
        AC_data[_assetClass].discount = 3000; //basic discount, 30% (70% to PRUF)
        AC_data[_assetClass].custodyType = _custodyType;
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
     * @dev Increases priceShare in an assetClass
     *
     */
    function increasePriceShare(uint32 _assetClass, uint256 _increaseAmount)
        external
    {
        require( //require caller is UTIL_TKN
            (msg.sender == UTIL_TKN_Address),
            "ACM:IPS: Caller is not UTIL_TKN contract"
        );
        uint256 discount = AC_data[_assetClass].discount;
        //^^^^^^^checks^^^^^^^^^

        discount = discount.add(_increaseAmount);
        if (discount > 9000) discount = 9000;

        AC_data[_assetClass].discount = uint32(discount); //type conversion safe because discount always <= 10000
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
            uint32
        )
    {
        //^^^^^^^checks^^^^^^^^^
        return (
            AC_data[_assetClass].assetClassRoot,
            AC_data[_assetClass].custodyType,
            AC_data[_assetClass].discount,
            AC_data[_assetClass].extendedData
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_discount @ _assetClass
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

    //-------------------------------------------functions for payment calculations----------------------------------------------

    /*
     * @dev Retrieve function costs per asset class, per service type, in Wei
     */
    function getServiceCosts(uint32 _assetClass, uint16 _service)
        external view
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
