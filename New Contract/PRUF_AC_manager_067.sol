/*-----------------------------------------------------------------
 *  TO DO
 *
*-----------------------------------------------------------------
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_core_067.sol";

contract PRUF_AC_MGR is PRUF {
    using SafeMath for uint256;
    using SafeMath for uint8;


    mapping(uint16 => Costs) private cost; // Cost per function by asset class
    mapping(uint16 => AC) internal AC_data; // AC info database
    mapping(string => uint16) internal AC_number;

    mapping(bytes32 => mapping(uint16 => uint8)) internal registeredUsers; // Authorized recorder database
    //mapping(bytes32 => User) internal registeredUsers; // Authorized recorder database

    address AC_minterAddress;
    uint256 private priceThreshold; //threshold of price where fractional pricing is implemented

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      is owner
     */
    modifier isAdmin() {
        require(
            (msg.sender == owner()) || (msg.sender == AC_minterAddress),
            "PAM:IA:Calling address does not belong to an Admin"
        );
        _;
    }

    /*
     * @dev Verify caller holds ACtoken of passed assetClass
     */
    modifier isACtokenHolderOfClass(uint16 _assetClass) {
        uint256 assetClass256 = uint256(_assetClass);
        require(
            (AssetClassTokenContract.ownerOf(assetClass256) == msg.sender),
            "PAM:IACTHoC:msg.sender not authorized in asset class"
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
        uint16 _assetClass
    ) external isACtokenHolderOfClass(_assetClass) {
        require(
            (_userType == 0) ||
                (_userType == 1) ||
                (_userType == 2) ||
                (_userType == 9) ||
                (_userType == 99),
            "PAM:AU:Invalid user type"
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 addrHash = keccak256(abi.encodePacked(_authAddr));

        registeredUsers[addrHash][_assetClass] = _userType;
        //registeredUsers[addrHash].userType = _userType;
        //registeredUsers[addrHash].authorizedAssetClass = _assetClass;
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
        uint16 _assetClass,
        uint16 _assetClassRoot,
        uint8 _custodyType
    ) external isAdmin {
        AC memory _ac = AC_data[_assetClassRoot];

        require((_tokenId != 0), "PAM:CAC: Token id cannot be 0"); //sanity check inputs
        require((_custodyType != 0), "PAM:CAC:CustodyType cannot be 0"); //sanity check inputs
        require( //has valid root
            (_ac.custodyType != 0) || (_assetClassRoot == _assetClass),
            "PAM:CAC:Root asset class does not exist"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_number[_name] = _assetClass;
        AC_data[_assetClass].name = _name;
        AC_data[_assetClass].assetClassRoot = _assetClassRoot;
        AC_data[_assetClass].custodyType = _custodyType;
        //^^^^^^^effects^^^^^^^^^

        AssetClassTokenContract.mintACToken(
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
        uint16 _class,
        uint256 _newRecordCost,
        uint256 _transferAssetCost,
        uint256 _createNoteCost,
        uint256 _reMintRecordCost,
        uint256 _changeStatusCost,
        uint256 _forceModifyCost,
        address _paymentAddress
    ) external isACtokenHolderOfClass(_class) {
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

    /*
     * @dev Retrieve AC_data @ _assetClass
     */
    function getAC_data(uint16 _assetClass)
        external
        view
        returns (
            uint16,
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
    function isSameRootAC(uint16 _assetClass1, uint16 _assetClass2)
        external
        view
        returns (
            uint8
        )
    {
        //^^^^^^^checks^^^^^^^^^
        if (AC_data[_assetClass1].assetClassRoot == AC_data[_assetClass2].assetClassRoot){
            return uint8 (170);
        } else {
            return uint8 (0);
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
        uint16 assetClass = uint16(_tokenId);
        return (AC_data[assetClass].name);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_number @ AC_name
     */
    function resolveAssetClass(string memory _name)
        external
        view
        returns (uint16)
    {
        //^^^^^^^checks^^^^^^^^^
        return (AC_number[_name]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve function costs per asset class, in Wei
     */
    function getNewRecordCosts(uint16 _assetClass)
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
        uint16 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];
        uint256 assetClass256 = uint256(_assetClass);

        require(
            (AssetClassTokenContract.ownerOf(assetClass256) !=
                AssetClassTokenAddress), //this will throw in the token contract if not minted
            "PAM:Costs:Asset class not yet populated"
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
    function getTransferAssetCosts(uint16 _assetClass)
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
        uint16 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];
        uint256 assetClass256 = uint256(_assetClass);

        require(
            (AssetClassTokenContract.ownerOf(assetClass256) !=
                AssetClassTokenAddress), //this will throw in the token contract if not minted
            "PAM:Costs:Asset class not yet populated"
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
    function getCreateNoteCosts(uint16 _assetClass)
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
        uint16 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];
        uint256 assetClass256 = uint256(_assetClass);

        require(
            (AssetClassTokenContract.ownerOf(assetClass256) !=
                AssetClassTokenAddress), //this will throw in the token contract if not minted
            "PAM:Costs:Asset class not yet populated"
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
    function getReMintRecordCosts(uint16 _assetClass)
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
        uint16 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];
        uint256 assetClass256 = uint256(_assetClass);

        require(
            (AssetClassTokenContract.ownerOf(assetClass256) !=
                AssetClassTokenAddress), //this will throw in the token contract if not minted
            "PAM:Costs:Asset class not yet populated"
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
    function getChangeStatusCosts(uint16 _assetClass)
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
        uint16 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];
        uint256 assetClass256 = uint256(_assetClass);

        require(
            (AssetClassTokenContract.ownerOf(assetClass256) !=
                AssetClassTokenAddress), //this will throw in the token contract if not minted
            "PAM:Costs:Asset class not yet populated"
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
    function getForceModifyCosts(uint16 _assetClass)
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
        uint16 rootAssetClass = AC_info.assetClassRoot;
        Costs memory rootCosts = cost[rootAssetClass];
        uint256 assetClass256 = uint256(_assetClass);

        require(
            (AssetClassTokenContract.ownerOf(assetClass256) !=
                AssetClassTokenAddress), //this will throw in the token contract if not minted
            "PAM:Costs:Asset class not yet populated"
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
    function retrieveCosts(uint16 _assetClass)
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
        uint256 assetClass256 = uint256(_assetClass);
        Costs memory costs = cost[_assetClass];

        require(
            (AssetClassTokenContract.ownerOf(assetClass256) !=
                AssetClassTokenAddress), //this will throw in the token contract if not minted
            "PAM:Costs:Asset class not yet populated"
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

    /*
     * @dev Serve a User Record
     */
    function getUserType(bytes32 _userHash, uint16 _assetClass)
        external
        view
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^
        return (
            registeredUsers[_userHash][_assetClass]
            //registeredUsers[_userHash].userType,
            //registeredUsers[_userHash].authorizedAssetClass
        );
        //^^^^^^^interactions^^^^^^^^^
    }
}
