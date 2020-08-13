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
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";

contract AC_MGR is CORE {
    using SafeMath for uint256;
    using SafeMath for uint8;

    mapping(uint256 => Costs) private cost; // Cost per function by asset class

    mapping(uint256 => AC) internal AC_data; // AC info database asset class to AC struct (NAME,ACroot,CUSTODIAL/NC,uint256)
    mapping(string => uint256) internal AC_number; //name to asset class resolution map

    mapping(bytes32 => mapping(uint256 => uint8)) internal registeredUsers; // Authorized recorder database

    //address AC_minterAddress;
    uint256 private priceThreshold; //threshold of price where fractional pricing is implemented

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is owner
     */
    modifier isAdmin() {
        require(
            (msg.sender == owner()), // || (msg.sender == AC_minterAddress),
            "ACM:MOD-IA:Calling address does not belong to an Admin"
        );
        _;
    }

    /*
     * @dev Verify caller holds ACtoken of passed assetClass
     */
    modifier isACtokenHolderOfClass(uint256 _assetClass) {
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
        uint256 _assetClass
    ) external whenNotPaused isACtokenHolderOfClass(_assetClass) {
        require(
            (_userType == 0) ||
                (_userType == 1) ||
                (_userType == 2) ||
                (_userType == 9) ||
                (_userType == 10) ||
                (_userType == 99),
            "ACM:AU:Invalid user type"
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 addrHash = keccak256(abi.encodePacked(_authAddr));

        registeredUsers[addrHash][_assetClass] = _userType;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("Internal user database access!"); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Mints asset class @ address
     */
    function createAssetClass(
        uint256 _tokenId,
        address _recipientAddress,
        string calldata _name,
        uint256 _assetClass,
        uint256 _assetClassRoot,
        uint8 _custodyType
    ) external isAdmin {
        AC memory _ac = AC_data[_assetClassRoot];

        require((_tokenId != 0), "ACM:CAC: Token id cannot be 0"); //sanity check inputs
        require( //has valid root
            (_ac.custodyType != 0) || (_assetClassRoot == _assetClass),
            "ACM:CAC:Root asset class does not exist"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_name] = _assetClass;
        AC_data[_assetClass].name = _name;
        AC_data[_assetClass].assetClassRoot = _assetClassRoot;
        AC_data[_assetClass].custodyType = _custodyType;
        //^^^^^^^effects^^^^^^^^^

        AC_TKN.mintACToken(
            _recipientAddress,
            _tokenId,
            "pruf.io/assetClassToken"
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Set function costs and payment address per asset class, in Wei
     */
    function ACTH_setCosts(
        uint256 _class,
        uint256 _newRecordCost,
        uint256 _transferAssetCost,
        uint256 _createNoteCost,
        uint256 _reMintRecordCost,
        uint256 _changeStatusCost,
        uint256 _forceModifyCost,
        address _paymentAddress
    ) external whenNotPaused isACtokenHolderOfClass(_class) {
        //^^^^^^^checks^^^^^^^^^
        cost[_class].newRecordCost = _newRecordCost;
        cost[_class].transferAssetCost = _transferAssetCost;
        cost[_class].createNoteCost = _createNoteCost;
        cost[_class].reMintRecordCost = _reMintRecordCost;
        cost[_class].changeStatusCost = _changeStatusCost;
        cost[_class].forceModifyCost = _forceModifyCost;
        cost[_class].paymentAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    //-------------------------------------------functions for information retrieval----------------------------------------------
    /*
     * @dev get a User Record
     */
    function getUserType(bytes32 _userHash, uint256 _assetClass)
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
    function getAC_data(uint256 _assetClass)
        external
        view
        returns (
            uint256,
            uint8,
            uint256
        )
    {
        //^^^^^^^checks^^^^^^^^^
        return (
            AC_data[_assetClass].assetClassRoot,
            AC_data[_assetClass].custodyType,
            AC_data[_assetClass].extendedData
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev compare the root of two asset classes
     */
    function isSameRootAC(uint256 _assetClass1, uint256 _assetClass2)
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
    function getAC_name(uint256 _tokenId)
        external
        view
        returns (string memory)
    {
        //^^^^^^^checks^^^^^^^^^
        uint256 assetClass = _tokenId;
        return (AC_data[assetClass].name);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_number @ AC_name
     */
    function resolveAssetClass(string calldata _name)
        external
        view
        returns (uint256)
    {
        //^^^^^^^checks^^^^^^^^^
        return (AC_number[_name]);
        //^^^^^^^interactions^^^^^^^^^
    }

    //-------------------------------------------functions for payment calculations----------------------------------------------
    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getNewRecordCosts(uint256 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        )
    {
        AC memory AC_info = getACinfo(_assetClass);
        Costs memory costs = cost[_assetClass];
        uint256 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];

        require(
            (AC_TKN.ownerOf(_assetClass) != AC_TKN_Address), //this will throw in the token contract if not minted
            "ACM:GNRC:Asset class not yet populated"
        );
        //^^^^^^^checks^^^^^^^^^
        return (
            rootCosts.paymentAddress,
            rootCosts.newRecordCost,
            costs.paymentAddress,
            costs.newRecordCost
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getTransferAssetCosts(uint256 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        )
    {
        AC memory AC_info = getACinfo(_assetClass);
        Costs memory costs = cost[_assetClass];
        uint256 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];

        require(
            (AC_TKN.ownerOf(_assetClass) != AC_TKN_Address), //this will throw in the token contract if not minted
            "ACM:GTAC:Asset class not yet populated"
        );
        //^^^^^^^checks^^^^^^^^^
        return (
            rootCosts.paymentAddress,
            rootCosts.transferAssetCost,
            costs.paymentAddress,
            costs.transferAssetCost
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getCreateNoteCosts(uint256 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        )
    {
        AC memory AC_info = getACinfo(_assetClass);
        Costs memory costs = cost[_assetClass];
        uint256 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];

        require(
            (AC_TKN.ownerOf(_assetClass) != AC_TKN_Address), //this will throw in the token contract if not minted
            "ACM:GCNC:Asset class not yet populated"
        );
        //^^^^^^^checks^^^^^^^^^
        return (
            rootCosts.paymentAddress,
            rootCosts.createNoteCost,
            costs.paymentAddress,
            costs.createNoteCost
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getReMintRecordCosts(uint256 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        )
    {
        AC memory AC_info = getACinfo(_assetClass);
        Costs memory costs = cost[_assetClass];
        uint256 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];

        require(
            (AC_TKN.ownerOf(_assetClass) != AC_TKN_Address), //this will throw in the token contract if not minted
            "ACM:GMRC:Asset class not yet populated"
        );
        //^^^^^^^checks^^^^^^^^^
        return (
            rootCosts.paymentAddress,
            rootCosts.reMintRecordCost,
            costs.paymentAddress,
            costs.reMintRecordCost
        );
        //^^^^^^^Interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getChangeStatusCosts(uint256 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        )
    {
        AC memory AC_info = getACinfo(_assetClass);
        Costs memory costs = cost[_assetClass];
        uint256 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];

        require(
            (AC_TKN.ownerOf(_assetClass) != AC_TKN_Address), //this will throw in the token contract if not minted
            "ACM:GCSC:Asset class not yet populated"
        );
        //^^^^^^^checks^^^^^^^^^
        return (
            rootCosts.paymentAddress,
            rootCosts.changeStatusCost,
            costs.paymentAddress,
            costs.changeStatusCost
        );
        //^^^^^^^Interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getForceModifyCosts(uint256 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        )
    {
        AC memory AC_info = getACinfo(_assetClass);
        Costs memory costs = cost[_assetClass];
        uint256 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];

        require(
            (AC_TKN.ownerOf(_assetClass) != AC_TKN_Address), //this will throw in the token contract if not minted
            "ACM:GFMC:Asset class not yet populated"
        );
        //^^^^^^^checks^^^^^^^^^
        return (
            rootCosts.paymentAddress,
            rootCosts.forceModifyCost,
            costs.paymentAddress,
            costs.forceModifyCost
        );
        //^^^^^^^Interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function retrieveCosts(uint256 _assetClass)
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        )
    {
        Costs memory costs = cost[_assetClass];

        require(
            (AC_TKN.ownerOf(_assetClass) != AC_TKN_Address), //this will throw in the token contract if not minted
            "ACM:RC:Asset class not yet populated"
        );
        //^^^^^^^checks^^^^^^^^

        return (
            costs.newRecordCost,
            costs.transferAssetCost,
            costs.createNoteCost,
            costs.reMintRecordCost,
            costs.changeStatusCost,
            costs.forceModifyCost,
            costs.paymentAddress
        );
        //^^^^^^^interactions^^^^^^^^^
    }
}
