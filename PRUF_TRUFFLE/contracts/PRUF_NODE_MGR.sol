/**--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 * Contract for minting and managing AC Nodes
 *
 * STATEMENT OF TERMS OF SERVICE (TOS):
 * User agrees not to intentionally claim any namespace that is a recognized or registered brand name, trade mark,
 * or other Intellectual property not belonging to the user, and agrees to voluntarily remove any name or brand found to be
 * infringing from any record that the user controls, within 30 days of notification. If notification is not possible or
 * there is no response to notification, the user agrees that the name record may be changed without their permission or cooperation.
 * Use of this software constitutes consent to the terms above.
 *-----------------------------------------------------------------
 */

/**-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_BASIC.sol";
import "./Imports/utils/ReentrancyGuard.sol";

contract NODE_MGR is BASIC {
    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");
    bytes32 public constant B320xF_ =
        0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;

    uint256 private ACtokenIndex = 1000000; //Starting index for purchased ACnode tokens
    uint256 public AC_Price = 200000 ether;
    uint32 private constant startingDiscount = 9500; // Purchased nodes start with 95% profit share
    mapping(uint32 => mapping(uint16 => Costs)) private cost; // Cost per function by asset class => Costs struct (see PRUF_INTERFACES for struct definitions)
    mapping(uint32 => AC) private AC_data; // AC info database asset class to AC struct (see PRUF_INTERFACES for struct definitions)
    mapping(string => uint32) private AC_number; //name to asset class resolution map
    mapping(bytes32 => mapping(uint32 => uint8)) private registeredUsers; // Authorized recorder database by asset class, by address hash
    mapping(uint8 => uint8) private storageProvidersEnabled; //storageProvider -> status (enabled or disabled)
    mapping(uint8 => uint8) private managementTypesEnabled; //managementTypes -> status (enabled or disabled)
    mapping(uint8 => uint8) private custodyTypesEnabled; //managementTypes -> status (enabled or disabled)

    constructor() {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
        AC_number[""] = 4294967295; //points the blank string name to AC 4294967295 to make "" owned
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has NODE_MINTER_ROLE
     */
    modifier isNodeMinter() {
        require(
            hasRole(NODE_MINTER_ROLE, _msgSender()),
            "ACM:MOD-INM: Must have NODE_MINTER_ROLE"
        );
        _;
    }

    /**
     * @dev Verify caller holds ACtoken of passed assetClass
     * @param _assetClass - assetClass in which caller is queried for ownership
     */
    modifier isACtokenHolderOfClass(uint32 _assetClass) {
        require(
            (AC_TKN.ownerOf(_assetClass) == _msgSender()),
            "ACM:MOD-IACTHoC: _msgSender() not authorized in asset class"
        );
        _;
    }

    //--------------------------------------------ADMIN only Functions--------------------------

    /**
     * @dev Set pricing for AC Nodes
     * @param newACprice - cost per assetClass (18 decimals)
     */
    function adminSetACpricing(uint256 newACprice) external isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        AC_Price = newACprice;
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("ACnode pricing Changed!"); //report access to internal parameter (KEEP THIS)
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * !! to be used with great caution !!
     * This potentially breaks decentralization and must eventually be given over to some kind of governance contract.
     * @dev Increases (but cannot decrease) price share for a given AC
     * @param _assetClass - assetClass in which cost share is being modified
     * @param _newDiscount - discount(1% == 100, 10000 == max)
     */
    function adminIncreaseShare(uint32 _assetClass, uint32 _newDiscount)
        external
        isContractAdmin
    {
        require(
            (AC_data[_assetClass].assetClassRoot != 0),
            "ACM:AIS: AC !exist"
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

    /**
     *
     * @dev Sets the valid storage type providers.
     * @param _storageProvider - uint position for storage provider
     * @param _status - uint position for custody type status
     */
    function adminSetStorageProviders(uint8 _storageProvider, uint8 _status)
        external
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^
        storageProvidersEnabled[_storageProvider] = _status;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Sets the valid management types.
     * @param _managementType - uint position for management type
     * @param _status - uint position for custody type status
     */
    function adminSetManagementTypes(uint8 _managementType, uint8 _status)
        external
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^
        managementTypesEnabled[_managementType] = _status;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Sets the valid custody types.
     * @param _custodyType - uint position for custody type
     * @param _status - uint position for custody type status
     */
    function adminSetCustodyTypes(uint8 _custodyType, uint8 _status)
        external
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^
        custodyTypesEnabled[_custodyType] = _status;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution and only as a result of community governance action -----------
     * @dev Transfers a name from one asset class to another
     *   -Designed to remedy brand infringement issues. This breaks decentralization and must eventually be given
     *   -over to some kind of governance contract.
     * @param _assetClassSource - source assetClass
     * @param _assetClassDest - destination assetClass
     * @param _name - name to be transferred
     */
    function transferName(
        uint32 _assetClassSource,
        uint32 _assetClassDest,
        string calldata _name
    ) external isContractAdmin {
        require(
            AC_number[_name] == _assetClassSource,
            "ACM:TN: Name not in source AC"
        ); //source AC_Name must match name given

        require(
            (AC_data[_assetClassDest].CAS1 == B320xF_), //dest AC must have CAS1 set to 0xFFFF.....
            "ACM:TN: Destination AC not prepared for name transfer"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_name] = _assetClassDest;
        AC_data[_assetClassDest].name = _name;
        AC_data[_assetClassSource].name = "";
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution -----------
     * @dev Modifies an asset class with minimal controls
     * @param _assetClass - assetClass to be modified
     * @param _assetClassRoot - root of assetClass
     * @param _custodyType - custodyType of assetClass (see docs)
     * @param _managementType - managementType of assetClass (see docs)
     * @param _storageProvider - storageProvider of assetClass (see docs)
     * @param _discount - discount of assetClass (100 == 1%, 10000 == max)
     * @param _refAddress - referance address associated with an assetClass
     * @param _CAS1 - any external data attatched to assetClass 1/2
     * @param _CAS2 - any external data attatched to assetClass 2/2
     */
    function adminModAssetClass(
        uint32 _assetClass,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        address _refAddress,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external isContractAdmin nonReentrant {
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
        AC_data[_assetClass].CAS1 = _CAS1;
        AC_data[_assetClass].CAS2 = _CAS2;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Modifies AC.switches bitwise (see ASSET CLASS option switches in ZZ_PRUF_DOCS)
     * @param _assetClass - assetClass to be modified
     * @param _position - uint position of bit to be modified
     * @param _bit - switch - 1 or 0 (true or false)
     */
    function adminModAssetClassSwitches(
        uint32 _assetClass,
        uint8 _position,
        uint8 _bit
    ) external isContractAdmin nonReentrant {
        require(
            (_position > 0) && (_position < 9),
            "ACM:AMACS: Bit position !>0||<9"
        );
        require(_bit < 2, "ACM:AMACS: Bit != 1 or 0");

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

    /**
     * @dev Mints asset class token and creates an assetClass.
     * @param _assetClass - assetClass to be created (unique)
     * @param _name - name to be configured to assetClass (unique)
     * @param _assetClassRoot - root of assetClass
     * @param _custodyType - custodyType of new assetClass (see docs)
     * @param _managementType - managementType of new assetClass (see docs)
     * @param _storageProvider - storageProvider of new assetClass (see docs)
     * @param _discount - discount of assetClass (100 == 1%, 10000 == max)
     * @param _CAS1 - any external data attatched to assetClass 1/2
     * @param _CAS2 - any external data attatched to assetClass 2/2
     * @param _recipientAddress - address to recieve assetClass
     */
    function createAssetClass(
        uint32 _assetClass,
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        bytes32 _CAS1,
        bytes32 _CAS2,
        address _recipientAddress
    ) external isNodeMinter nonReentrant {
        //^^^^^^^checks^^^^^^^^^

        AC memory _AC;
        _AC.name = _name;
        _AC.assetClassRoot = _assetClassRoot;
        _AC.custodyType = _custodyType;
        _AC.managementType = _managementType;
        _AC.storageProvider = _storageProvider;
        _AC.discount = _discount;
        _AC.CAS1 = _CAS1;
        _AC.CAS2 = _CAS2;

        _createAssetClass(_AC, _assetClass, _recipientAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Burns (amount) tokens and mints a new asset class token to the calling address
     * @param _name - chosen name of assetClass
     * @param _assetClassRoot - chosen root of assetClass
     * @param _custodyType - chosen custodyType of assetClass (see docs)
     * @param _CAS1 - any external data attatched to assetClass 1/2
     * @param _CAS2 - any external data attatched to assetClass 2/2
     */
    function purchaseACnode(
        string calldata _name,
        uint32 _assetClassRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external nonReentrant returns (uint256) {
        require(
            ACtokenIndex < 4294000000,
            "ACM:PACN: Only 4294000000 AC tokens allowed"
        );
        require(
            (ID_TKN.balanceOf(_msgSender()) == 1),
            "ACM:PACN: Caller !valid PRuF_ID holder"
        );
        //^^^^^^^checks^^^^^^^^^

        ACtokenIndex++;

        address rootPaymentAddress = cost[_assetClassRoot][1].paymentAddress; //payment for upgrade goes to root AC payment address specified for service (1)

        //mint an asset class token to _msgSender(), at tokenID ACtokenIndex, with URI = root asset Class #

        UTIL_TKN.trustedAgentBurn(_msgSender(), AC_Price / 2);
        UTIL_TKN.trustedAgentTransfer(
            _msgSender(),
            rootPaymentAddress,
            AC_Price - (AC_Price / 2)
        ); //burning 50% so we have tokens to incentivise outreach performance
        AC memory _AC;
        _AC.name = _name;
        _AC.assetClassRoot = _assetClassRoot;
        _AC.custodyType = _custodyType;
        _AC.managementType = 255; //creates ACNODES at managementType 255 = not yet usable(disabled),
        _AC.storageProvider = 0; //creates ACNODES at storageType 0 = not yet usable(disabled),
        _AC.discount = startingDiscount;
        _AC.CAS1 = _CAS1;
        _AC.CAS2 = _CAS2;

        _createAssetClass(_AC, uint32(ACtokenIndex), _msgSender());

        //Set the default 11 authorized contracts
        if (_custodyType == 2) {
            STOR.enableDefaultContractsForAC(uint32(ACtokenIndex));
        }

        return ACtokenIndex; //returns asset class # of minted token
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /**
     * @dev Authorize / Deauthorize users for an address be permitted to make record modifications
     * @dev only useful for custody types that designate user adresses (type1...)
     * @param _assetClass - assetClass that user is being authorized in
     * @param _addrHash - hash of address belonging to user being authorized
     * @param _userType - authority level for user (see docs)
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
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Modifies an AC Node name for its exclusive namespace
     * @param _assetClass - assetClass being modified
     * @param _name - updated name associated with assetClass (unique)
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
            "ACM:UACN: Name already in use or is same as the previous"
        );
        //^^^^^^^checks^^^^^^^^^

        delete AC_number[AC_data[_assetClass].name];

        AC_number[_name] = _assetClass;
        AC_data[_assetClass].name = _name;
        //^^^^^^^effects^^^^^^^^^
    }

    /** CTS:EXAMINE Need 2 IPFS fields
     * @dev Modifies an AC Node IPFS data pointer
     * @param _assetClass - assetClass being modified
     * @param _CAS1 - any external data attatched to assetClass 1/2
     * @param _CAS2 - any external data attatched to assetClass 2/2
     */
    function updateNodeCAS(
        uint32 _assetClass,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external whenNotPaused isACtokenHolderOfClass(_assetClass) {
        require(
            getSwitchAt(_assetClass, 1) == 0,
            "ACM:UNC: CAS for node is locked and cannot be written"
        );
        //^^^^^^^checks^^^^^^^^^
        AC_data[_assetClass].CAS1 = _CAS1;
        AC_data[_assetClass].CAS2 = _CAS2;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Set function costs and payment address per asset class, in PRUF(18 decimals)
     * @param _assetClass - assetClass to set service costs
     * @param _service - service type being modified (see service types in ZZ_PRUF_DOCS)
     * @param _serviceCost - 18 decimal fee in PRUF associated with specified service
     * @param _paymentAddress - address to have _serviceCost paid to
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

    //-------------------------------------------Functions dealing with immutable data ---------------------------------------------

    /**
     * @dev Configure the immutable data in an asset class one time
     * @param _assetClass - assetClass being modified
     * @param _managementType - managementType of assetClass (see docs)
     * @param _storageProvider - storageProvider of assetClass (see docs)
     * @param _refAddress - address permanently tied to assetClass
     */
    function updateACImmutable(
        uint32 _assetClass,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress
    ) external whenNotPaused isACtokenHolderOfClass(_assetClass) {
        require(
            AC_data[_assetClass].managementType == 255,
            "ACM:UACI: Immutable AC data already set"
        );
        require(
            _managementType != 255,
            "ACM:UACI: managementType = 255(Unconfigured)"
        );
        require( //_managementType is a valid type
            (managementTypesEnabled[_managementType] > 0),
            "ACM:UACI: managementType is invalid (0)"
        );
        require( //_storageProvider is a valid type
            (storageProvidersEnabled[_storageProvider] > 0),
            "ACM:UACI: storageProvider is invalid (0)"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_data[_assetClass].managementType = _managementType;
        AC_data[_assetClass].storageProvider = _storageProvider;
        AC_data[_assetClass].referenceAddress = _refAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------Read-only functions ----------------------------------------------

    /**
     * @dev get bit from .switches at specified position
     * @param _assetClass - assetClass associated with query
     * @param _position - bit position associated with query
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getSwitchAt(uint32 _assetClass, uint8 _position)
        public
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
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get an AC Node User type for a specified address
     * @param _userHash - hash of selected user
     * @param _assetClass - assetClass of query
     *
     * @return type of user @ _assetClass (see docs)
     */
    function getUserType(bytes32 _userHash, uint32 _assetClass)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (registeredUsers[_userHash][_assetClass]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get the status of a specific management type
     * @param _managementType - management type associated with query (see docs)
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getManagementTypeStatus(uint8 _managementType)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (managementTypesEnabled[_managementType]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get the status of a specific storage provider
     * @param _storageProvider - storage provider associated with query (see docs)
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getStorageProviderStatus(uint8 _storageProvider)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (storageProvidersEnabled[_storageProvider]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev get the status of a specific custody type
     * @param _custodyType - custody type associated with query (see docs)
     *
     * @return 1 or 0 (enabled or disabled)
     */
    function getCustodyTypeStatus(uint8 _custodyType)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (custodyTypesEnabled[_custodyType]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve AC_data @ _assetClass
     * @param _assetClass - assetClass associated with query
     * DPS:THIS FUNCTION REMAINS FOR EXTERNAL TESTING ACCESS. try using getExtAcData, it should be depricated prior to production.
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

    /**
     * @dev Retrieve extended AC_data @ _assetClass
     * @param _assetClass - assetClass associated with query
     *
     * @return AC_data (see docs)
     */
    function getExtAC_data(uint32 _assetClass)
        external
        view
        returns (AC memory)
    {
        //^^^^^^^checks^^^^^^^^^
        return (AC_data[_assetClass]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev verify the root of two asset classes are equal
     * @param _assetClass1 - first assetClass associated with query
     * @param _assetClass2 - second assetClass associated with query
     *
     * @return 170 or 0 (true or false)
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
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve AC_name @ _tokenId or ACnode
     * @param assetClass - tokenId associated with query
     *
     * @return name of token @ _tokenID
     */
    function getAC_name(uint32 assetClass)
        external
        view
        returns (string memory)
    {
        //^^^^^^^checks^^^^^^^^^

        return (AC_data[assetClass].name);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve assetClass @ AC_name
     * @param _name - name of assetClass for assetClassNumber query
     *
     * @return assetClass number @ _name
     */
    function resolveAssetClass(string calldata _name)
        external
        view
        returns (uint32)
    {
        //^^^^^^^checks^^^^^^^^^
        return (AC_number[_name]);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev return current AC token index and price
     *
     * @return {
         ACtokenIndex: current token number
         AC_price: current price per assetClass
     }
     */
    function currentACpricingInfo() external view returns (uint256, uint256) {
        //^^^^^^^checks^^^^^^^^^
        return (ACtokenIndex, AC_Price);
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------functions for payment calculations----------------------------------------------

    /**
     * @dev Retrieve function costs per asset class, per service type in PRUF(18 decimals)
     * @param _assetClass - assetClass associated with query
     * @param _service - service number associated with query (see service types in ZZ_PRUF_DOCS)
     *
     * @return invoice{
         rootAddress: @ _assetClass root payment address @ _service
         rootPrice: @ _assetClass root service cost @ _service
         ACTHaddress: @ _assetClass payment address tied @ _service
         ACTHprice: @ _assetClass service cost @ _service
         assetClass: _assetClass
     }
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
        uint32 rootAssetClass = AC_info.assetClassRoot;

        Costs memory costs = cost[_assetClass][_service];
        Costs memory rootCosts = cost[rootAssetClass][_service];
        Invoice memory invoice;

        invoice.rootAddress = rootCosts.paymentAddress;
        invoice.rootPrice = rootCosts.serviceCost;
        invoice.ACTHaddress = costs.paymentAddress;
        invoice.ACTHprice = costs.serviceCost;
        invoice.assetClass = _assetClass;

        return invoice;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Retrieve AC_discount @ _assetClass
     * @param _assetClass - assetClass associated with query
     *
     * @return percentage of rewards distribution @ _assetClass
     */
    function getAC_discount(uint32 _assetClass) external view returns (uint32) {
        //^^^^^^^checks^^^^^^^^^
        return (AC_data[_assetClass].discount);
        //^^^^^^^interactions^^^^^^^^^
    }

    //-------------------------------------------INTERNAL / PRIVATE functions ----------------------------------------------

    /**
     * @dev creates an ACnode and its corresponding namespace and data fields
     * @param _AC - creation Data for new Node
     * @param _assetClass - Node to be created (unique)
     * @param _recipientAddress - address to recieve Node
     */
    function _createAssetClass(
        AC memory _AC,
        uint32 _assetClass,
        address _recipientAddress
    ) private whenNotPaused {
        AC memory _RootNodeData = AC_data[_AC.assetClassRoot];
        uint256 tokenId = uint256(_assetClass);

        require(tokenId != 0, "ACM:CAC: AC = 0"); //sanity check inputs
        require(_AC.discount <= 10000, "ACM:CAC: Discount > 10000 (100%)");
        require( //_ac.managementType is a valid type or explicitly unset (255)
            (managementTypesEnabled[_AC.managementType] > 0) ||
                (_AC.managementType == 255),
            "ACM:CAC: Management type is invalid (0)"
        );
        require( //_ac.storageProvider is a valid type or not specified (0)
            (storageProvidersEnabled[_AC.storageProvider] > 0) ||
                (_AC.storageProvider == 0),
            "ACM:CAC: Storage Provider is invalid (0)"
        );
        require( //_ac.custodyType is a valid type or specifically unset (255)
            (custodyTypesEnabled[_AC.custodyType] > 0) ||
                (_AC.custodyType == 255),
            "ACM:CAC: Custody type is invalid (0)"
        );
        require( //has valid root
            (_RootNodeData.custodyType == 3) ||
                (_AC.assetClassRoot == _assetClass),
            "ACM:CAC: Root !exist"
        );
        if (_RootNodeData.managementType != 0) {
            require( //holds root token if root is restricted
                (AC_TKN.ownerOf(_AC.assetClassRoot) == _msgSender()),
                "ACM:CAC: Restricted from creating AC's in this root - caller !hold root token"
            );
        }
        require(AC_number[_AC.name] == 0, "ACM:CAC: AC name exists");
        require(
            (AC_data[_assetClass].assetClassRoot == 0),
            "ACM:CAC: AC already exists"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_AC.name] = _assetClass;
        AC_data[_assetClass].name = _AC.name;
        AC_data[_assetClass].assetClassRoot = _AC.assetClassRoot;
        AC_data[_assetClass].discount = _AC.discount;
        AC_data[_assetClass].custodyType = _AC.custodyType;
        AC_data[_assetClass].managementType = _AC.managementType;
        AC_data[_assetClass].switches = _RootNodeData.switches;
        AC_data[_assetClass].CAS1 = _AC.CAS1;
        AC_data[_assetClass].CAS2 = _AC.CAS2;
        //^^^^^^^effects^^^^^^^^^

        AC_TKN.mintACToken(
            _recipientAddress,
            tokenId,
            "pruf.io/assetClassToken"
        );
        //^^^^^^^interactions^^^^^^^^^
    }
}
