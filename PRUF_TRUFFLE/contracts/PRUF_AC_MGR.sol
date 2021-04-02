/*--------------------------------------------------------PRüF0.8.0
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
 *-----------------------------------------------------------------
 */

// string name;
// uint32 assetClassRoot;
// uint8 custodyType;
// uint8 managementType;
// uint8 storageProvider;
// uint32 discount;
// address referenceAddress;
// uint8 switches;
// bytes32 IPFS;

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_BASIC.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract AC_MGR is BASIC {
    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    uint256 private ACtokenIndex = 1000000; //Starting index for purchased ACnode tokens
    uint256 public acPrice_L1 = 200000 ether;
    uint256 private currentACtokenPrice = acPrice_L1;
    uint32 private constant startingDiscount = 9500; // Purchased nodes start with 95% profit share
    /*
        Cost indexes
        1 newRecordCost; // Cost to create a new record
        2 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        3 createNoteCost; // Cost to add a static note to an asset
        4 reMintRecordCost; // Extra
        5 changeStatusCost; // Extra
        6 forceModifyCost; // Cost to brute-force a record transfer
    */
    mapping(uint32 => mapping(uint16 => Costs)) private cost; // Cost per function by asset class => Cost Type
    mapping(uint32 => AC) private AC_data; // AC info database asset class to AC struct (NAME,ACroot,CUSTODIAL/NC,uint32)
    mapping(string => uint32) private AC_number; //name to asset class resolution map
    mapping(bytes32 => mapping(uint32 => uint8)) private registeredUsers; // Authorized recorder database by asset class, by address hash

    constructor() {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
        AC_number[""] = 4294967295; //points the blank string name to AC 4294967295 to make "" owned
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is admin
     */
    modifier isNodeMinter() {
        require(
            hasRole(NODE_MINTER_ROLE, _msgSender()),
            "ACM:MOD-INM: Must have NODE_MINTER_ROLE"
        );
        _;
    }

    /*
     * @dev Verify caller holds ACtoken of passed assetClass
     */
    modifier isACtokenHolderOfClass(uint32 _assetClass) {
        require(
            (AC_TKN.ownerOf(_assetClass) == _msgSender()),
            "ACM:MOD-IACTHoC: _msgSender() not authorized in asset class"
        );
        _;
    }

    //--------------------------------------------ADMIN only Functions--------------------------

    /*
     * @dev Set pricing
     */
    function OO_SetACpricing(uint256 _L1) external isAdmin {
        //^^^^^^^checks^^^^^^^^^

        acPrice_L1 = _L1;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACnode pricing Changed!"); //report access to internal parameter
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Tincreases (but cannot decrease) price share for a given AC
     * !! to be used with great caution
     * This breaks decentralization and must eventually be given over to some kind of governance contract. //CTS:EXAMINE
     */

    function adminIncreaseShare(uint32 _assetClass, uint32 _newDiscount)
        external
        isAdmin
    {
        require(
            (AC_data[_assetClass].assetClassRoot != 0),
            "ACM:AIS: AC not in use"
        );
        require(
            _newDiscount >= AC_data[_assetClass].discount,
            "ACM:AIS: New share < old share"
        );
        require(_newDiscount <= 10000, "ACM:AIS: Discount > 100% (10000)");
        //^^^^^^^checks^^^^^^^^^

        AC_data[_assetClass].discount = _newDiscount;
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
        uint32 _assetClass_source,
        uint32 _assetClass_dest,
        string calldata _name
    ) external isAdmin {
        require(
            AC_number[_name] == _assetClass_source,
            "ACM:TN: Name not in source AC"
        ); //source AC_Name must match name given

        require(
            (AC_data[_assetClass_dest].IPFS == B320xF_), //dest AC must have ipfs set to 0xFFFF.....
            "ACM:TN: Destination AC not prepared for name transfer"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_name] = _assetClass_dest;
        AC_data[_assetClass_dest].name = _name;
        AC_data[_assetClass_source].name = "";
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Modifies an asset class with minimal controls
     */
    function AdminModAssetClass(
        uint32 _assetClass,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        address _refAddress,
        bytes32 _IPFS
    ) external isAdmin nonReentrant {
        AC memory _ac = AC_data[_assetClassRoot];
        uint256 tokenId = uint256(_assetClass);

        require((tokenId != 0), "ACM:AMAC: AC = 0"); //sanity check inputs
        require(_discount <= 10000, "ACM:AMAC: Discount > 10000 (100%)");
        require( //has valid root
            (_ac.custodyType == 3) || (_assetClassRoot == _assetClass),
            "ACM:AMAC: Root !exist"
        );
        require(AC_TKN.tokenExists(tokenId) == 170, "ACM:AMAC: ACtoken !exist");
        //^^^^^^^checks^^^^^^^^^

        AC_data[_assetClass].assetClassRoot = _assetClassRoot;
        AC_data[_assetClass].discount = _discount;
        AC_data[_assetClass].custodyType = _custodyType;
        AC_data[_assetClass].managementType = _managementType;
        AC_data[_assetClass].storageProvider = _storageProvider;
        AC_data[_assetClass].referenceAddress = _refAddress;
        AC_data[_assetClass].IPFS = _IPFS;
        //^^^^^^^effects^^^^^^^^^
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modifies AC.switches bitwise DPS:TEST
     */
    function AdminModAssetClassSwitches(
        uint32 _assetClass,
        uint8 _position,
        uint8 _bit
    ) external isAdmin nonReentrant {
        require(
            (_position > 0) && (_position < 9),
            "bit position must be between 1 and 8"
        );

        //^^^^^^^checks^^^^^^^^^

        uint256 switches = AC_data[_assetClass].switches;

        if (_bit == 1) {
            switches = switches | (1 << (_position - 1));
        }

        if (_bit == 0) {
            switches = switches & ~(1 << (_position - 1)); //make zero mask
        }

        AC_data[_assetClass].switches = uint8(switches);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------------NODEMINTER only Functions--------------------------

    /*
     * @dev Mints asset class token and creates an assetClass. Mints to @address
     * Requires that:
     *  name is unuiqe
     *  AC is not provisioned with a root (proxy for not yet registered)
     *  that ACtoken does not exist
     *  _discount 10000 = 100 percent price share , cannot exceed
     */
    function createAssetClass(
        uint32 _assetClass,
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint32 _discount,
        bytes32 _IPFS,
        address _recipientAddress
    ) external isNodeMinter nonReentrant {
        //^^^^^^^checks^^^^^^^^^
        _createAssetClass(
            _assetClass,
            _recipientAddress,
            _name,
            _assetClassRoot,
            _custodyType,
            _managementType,
            _discount,
            _IPFS
        );
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Burns (amount) tokens and mints a new asset class token to the caller address
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function purchaseACnode(
        //--------------will fail in burn / transfer if insufficient tokens
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _IPFS
    ) external whenNotPaused nonReentrant returns (uint256) {
        require( //Impossible to test??
            ACtokenIndex < 4294000000,
            "ACM:IS: Only 4294000000 AC tokens allowed"
        );
        // require(
        //     (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is token holder
        //     "ACM:MOD-IA: Caller does not hold a valid PRuF_ID token"
        // );
        //^^^^^^^checks^^^^^^^^^

        if (ACtokenIndex < 4294000000) ACtokenIndex++; //increment ACtokenIndex up to last one

        uint256 newACtokenPrice;
        address rootPaymentAddress = cost[_assetClassRoot][1].paymentAddress; //payment for upgrade goes to root AC payment adress specified for service (1)

        newACtokenPrice = acPrice_L1;

        //mint an asset class token to _msgSender(), at tokenID ACtokenIndex, with URI = root asset Class #

        UTIL_TKN.trustedAgentBurn(_msgSender(), currentACtokenPrice / 2);
        UTIL_TKN.trustedAgentTransfer(
            _msgSender(),
            rootPaymentAddress,
            currentACtokenPrice - (currentACtokenPrice / 2)
        );

        currentACtokenPrice = newACtokenPrice;

        _createAssetClass(
            uint32(ACtokenIndex), //safe because ACtokenIndex <  4294000000 required
            _msgSender(),
            _name,
            _assetClassRoot,
            _custodyType,
            255, //creates ACNODES at managementType 255 = not yet usable
            startingDiscount,
            _IPFS
        );

        //Set the default 11 authorized contracts
        if (_custodyType == 2) {
            STOR.enableDefaultContractsForAC(uint32(ACtokenIndex));
        }

        return ACtokenIndex; //returns asset class # of minted token
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     */
    function addUser(
        uint32 _assetClass,
        bytes32 _addrHash,
        uint8 _userType
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

    /*
     * @dev Modifies an assetClass
     * Sets a new AC name. Asset Classes cannot be moved to a new root or custody type.
     * Requires that:
     *  caller holds ACtoken
     *  name is unuiqe or same as old name
     */
    function updateACname(uint32 _assetClass, string calldata _name)
        external
        whenNotPaused
        isACtokenHolderOfClass(_assetClass)
    {
        require( //should pass if name is same as old name or name is unassigned. Should fail if name is assigned to other AC
            (AC_number[_name] == 0) || //name is unassigned
                (keccak256(abi.encodePacked(_name)) == //name is same as old name
                    (keccak256(abi.encodePacked(AC_data[_assetClass].name)))),
            "ACM:UACN: Name already in use"
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
    function updateACipfs(uint32 _assetClass, bytes32 _IPFS)
        external
        isACtokenHolderOfClass(_assetClass)
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        AC_data[_assetClass].IPFS = _IPFS;
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

    //-------------------------------------------Functions dealing with immutable data ----------------------------------------------

    /*
     * @dev Modifies an assetClass
     * Sets the immutable data on an ACNode
     * Requires that:
     * caller holds ACtoken
     * ACnode is managementType 255 (unconfigured)
     */
    function updateACImmutable(
        uint32 _assetClass,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress
    ) external isACtokenHolderOfClass(_assetClass) whenNotPaused {
        require(
            AC_data[_assetClass].managementType == 255,
            "ACM:UACI: Immutable AC data aleady set"
        );
        require(
            _managementType != 255,
            "ACM:UACI: managementType = 255(Unconfigured)"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_data[_assetClass].managementType = _managementType;
        AC_data[_assetClass].storageProvider = _storageProvider;
        AC_data[_assetClass].referenceAddress = _refAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------Read-only functions ----------------------------------------------
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
            uint8,
            uint32,
            address
        )
    {
        //^^^^^^^checks^^^^^^^^^
        return (
            AC_data[_assetClass].assetClassRoot,
            AC_data[_assetClass].custodyType,
            AC_data[_assetClass].managementType,
            AC_data[_assetClass].discount,
            AC_data[_assetClass].referenceAddress
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /* CTS:EXAMINE CAN'T RETURN A STRUCT WITH A STRING WITHOUT WIERDNESS-0.8.1
     * @dev Retrieve AC_data @ _assetClass
     */
    function getExtAC_data(uint32 _assetClass)
        external
        view
        returns (AC memory)
    {
        //^^^^^^^checks^^^^^^^^^
        return (AC_data[_assetClass]);
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
            uint256
        )
    {
        //^^^^^^^checks^^^^^^^^^

        //uint256 numberOfTokensSold = ACtokenIndex - uint256(1000000);
        return (ACtokenIndex, currentACtokenPrice, acPrice_L1);
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /*
     * @dev get bit from .switches at specified position //DPS:TEST
     */
    function getSwitchAt(uint32 _assetClass, uint8 _position)
        external
        view
        returns (uint256)
    {
        require(
            (_position > 0) && (_position < 9),
            "AM:GSA: bit position must be between 1 and 8"
        );
        //^^^^^^^checks^^^^^^^^^

        if ((AC_data[_assetClass].switches & (1 << (_position - 1))) > 0) {
            return 1;
        } else {
            return 0;
        }
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    //-------------------------------------------functions for payment calculations----------------------------------------------

    /*
     * @dev Retrieve function costs per asset class, per service type, in Wei
     */
    function getServiceCosts(uint32 _assetClass, uint16 _service)
        external
        view
        returns (Invoice memory)
    {
        AC memory AC_info = AC_data[_assetClass];
        require(AC_info.assetClassRoot != 0, "ACM:GSC: AC !exist");

        require(_service != 0, "ACM:GSC: Service type = 0");
        //^^^^^^^checks^^^^^^^^^

        Costs memory costs = cost[_assetClass][_service];
        uint32 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass][_service];

        Invoice memory invoice;

        invoice.rootAddress = rootCosts.paymentAddress;
        invoice.rootPrice = rootCosts.serviceCost;
        invoice.ACTHaddress = costs.paymentAddress;
        invoice.ACTHprice = costs.serviceCost;
        invoice.assetClass = _assetClass;
        //^^^^^^^effects^^^^^^^^^

        return invoice;
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

    //-------------------------------------------INTERNAL / PRIVATE functions ----------------------------------------------

    /*
     * @dev creates an assetClass
     * makes ACdata record with new name, mints token
     *
     */

    function _createAssetClass(
        uint32 _assetClass,
        address _recipientAddress,
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint32 _discount,
        bytes32 _IPFS
    ) private whenNotPaused {
        AC memory _ac = AC_data[_assetClassRoot];
        uint256 tokenId = uint256(_assetClass);

        require((tokenId != 0), "ACM:CAC: AC = 0"); //sanity check inputs
        require(_discount <= 10000, "ACM:CAC: Discount > 10000 (100%)");
        require( //has valid root
            (_ac.custodyType == 3) || (_assetClassRoot == _assetClass),
            "ACM:CAC: Root !exist"
        );
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1), //_msgSender() is ID token holder
            "ACM:MOD-IA: Caller does not hold a valid PRuF_ID token"
        );
        if (_ac.managementType != 0) {
            require( //holds root token if root is restricted
                (AC_TKN.ownerOf(_assetClassRoot) == _msgSender()),
                "ACM:CAC: Restricted from creating AC's in this root - does not hold root token"
            );
        }
        require(AC_number[_name] == 0, "ACM:CAC: AC name exists");
        require(
            (AC_data[_assetClass].assetClassRoot == 0),
            "ACM:CAC: AC exists"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_name] = _assetClass;
        AC_data[_assetClass].name = _name;
        AC_data[_assetClass].assetClassRoot = _assetClassRoot;
        AC_data[_assetClass].discount = _discount;
        AC_data[_assetClass].custodyType = _custodyType;
        AC_data[_assetClass].managementType = _managementType;
        AC_data[_assetClass].switches = _ac.switches;
        AC_data[_assetClass].IPFS = _IPFS;

        //^^^^^^^effects^^^^^^^^^

        AC_TKN.mintACToken(
            _recipientAddress,
            tokenId,
            "pruf.io/assetClassToken"
        );
        //^^^^^^^interactions^^^^^^^^^
    }
}
