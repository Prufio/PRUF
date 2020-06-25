/*  TO DO
 * Recheck user level security and user permissioning /modifiers (after all is done)
 * implement escrow rules /conditions
 *
 * mint a token at asset creation
 *
 * @implement remint_asset ?
 *-----------------------------------------------------------------------------------------------------------------
 * Should all assets have a token, minted to reside within the contract for curated / "nontokenized" asset classes?
 * If so, make a move-token function that can be enabled later (set to an address to control it)
 *-----------------------------------------------------------------------------------------------------------------
 *
 * IMPORTANT NOTE : DO NOT REMOVE FROM CODE:
 *      Verification of rgtHash in curated, tokenly non-custodial asset classes is not secure beyond the honorable intentions
 * of authorized recorders. All blockchain info is readable, so a bad actor could trivially obtain a copy of the
 * correct rgtHash on chain. This "stumbling block" measure is in place primarily to keep honest people honest, and
 * to require an actual, malicious effort to bypass security rather than a little copy-paste. Actual decentralized
 * security is provided with tokenized assets, which do not rely on the coercive trust relationship that creates the
 * incentive for recorders not to engage in malicious practices.
 *
 *
 *
 * Order of require statements:
 * 1: (modifiers)
 * 2: checking the asset existance
 * 3: checking the idendity and credentials of the caller
 * 4: checking the suitability of provided data for the proposed operation
 * 5: checking the suitability of asset details for the proposed operation
 * 6: verifying that provided verification data matches required data
 * 7: verifying that message contains any required payment
 *
 *
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;
import "./_ERC721/IERC721Receiver.sol";
import "./Ownable.sol";

interface AssetClassTokenInterface {
    function ownerOf(uint256) external view returns (address);

    function transferAssetClassToken(
        address from,
        address to,
        bytes32 idxHash
    ) external;
}

interface AssetTokenInterface {
    function ownerOf(uint256) external view returns (address);

    function transferAssetToken(
        address from,
        address to,
        bytes32 idxHash
    ) external;
}

interface StorageInterface {

    function setBaseCosts(
        uint256 _newRecordCost,
        uint256 _transferRecordCost,
        uint256 _createNoteCost,
        uint256 _reMintRecordCost,
        uint256 _modifyStatusCost,
        uint256 _forceModCost,
        address _paymentAddress
    ) external;

    function ACTH_setCosts(
        uint16 _class,
        uint256 _newRecordCost,
        uint256 _transferRecordCost,
        uint256 _createNoteCost,
        uint256 _reMintRecordCost,
        uint256 _modifyStatusCost,
        uint256 _forceModCost,
        address _paymentAddress
    ) external;

    function retrieveCosts(uint16 _assetClass)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function retrieveBaseCosts()
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function resolveContractAddress(string calldata _name)
        external
        returns (address);
}

contract Admin_Panel is Ownable, IERC721Receiver {
    // using SafeMath for uint256;

    struct User {
        uint8 userType; // User type: 1 = human, 9 = automated
        uint16 authorizedAssetClass; // Asset class in which user is permitted to transact
    }

    struct Costs {
        uint256 newRecordCost; // Cost to create a new record
        uint256 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        uint256 createNoteCost; // Cost to add a static note to an asset
        uint256 reMintRecordCost; // Extra
        uint256 changeStatusCost; // Extra
        uint256 forceModifyCost; // Cost to brute-force a record transfer
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    mapping(bytes32 => User) private registeredUsers; // Authorized recorder database

    address storageAddress;

    //Costs baseCosts;

    StorageInterface private Storage; // Set up external contract interface

    // address minterContractAddress;
    address AssetTokenAddress;
    AssetTokenInterface AssetTokenContract; //erc721_token prototype initialization
    address AssetClassTokenAddress;
    AssetClassTokenInterface AssetClassTokenContract; //erc721_token prototype initialization
    // --------------------------------------Events--------------------------------------------//

    event REPORT(string _msg);
    // --------------------------------------Modifiers--------------------------------------------//
    /*
     * @dev msg.sender holds assetClass token
     */

    modifier isACtokenHolder(uint16 _assetClass) {
        //-----------------------------------------FAKE AS HELL
        uint256 assetClass256 = uint256(_assetClass);
        require((assetClass256 > 0), "what the actual fuck");
        _;
    }
    // modifier isACtokenHolder(uint16 _assetClass) { //----------------------------------------THE REAL SHIT
    //     uint256 assetClass256 = uint256(_assetClass);
    //     require(
    //         (AssetClassTokenContract.ownerOf(assetClass256) == msg.sender),
    //         "MOD-ACToken: msg.sender not authorized in asset class"
    //     );
    //     _;
    // }


    modifier isAuthorized(bytes32 _idxHash) {

        //START OF SECTION----------------------------------------------------FAKE AS HELL
        User memory user = registeredUsers[keccak256(
            abi.encodePacked(msg.sender)
        )];
        require(
            (user.userType == 9) || (msg.sender == owner()),
            "ST:MOD-UA-ERR:User not registered "
        );
     _;
    }

    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//
    /*
     * @dev Address Setters
     */
    function OO_setAssetClassTokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        AssetClassTokenAddress = _contractAddress;
        AssetClassTokenContract = AssetClassTokenInterface(_contractAddress);
    }

    function OO_setAssetTokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        AssetTokenAddress = _contractAddress;
        AssetTokenContract = AssetTokenInterface(_contractAddress);
    }

    function OO_TX_asset_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
    {
        AssetTokenContract.transferAssetToken(address(this), _to, _idxHash);
    }

    function OO_TX_AC_Token(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
    {
        AssetClassTokenContract.transferAssetClassToken(
            address(this),
            _to,
            _idxHash
        );
    }

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "ADMIN: storage address cannot be zero"
        );

        Storage = StorageInterface(_storageAddress);
    }

    function OO_setBaseCosts(
        uint256 _newRecordCost,
        uint256 _transferRecordCost,
        uint256 _createNoteCost,
        uint256 _reMintRecordCost,
        uint256 _modifyStatusCost,
        uint256 _forceModCost,
        address _paymentAddress
    ) external onlyOwner {

        Storage.setBaseCosts(
            _newRecordCost,
            _transferRecordCost,
            _createNoteCost,
            _reMintRecordCost,
            _modifyStatusCost,
            _forceModCost,
            _paymentAddress
        );
    }

    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function OO_addUser(
        address _authAddr,
        uint8 _userType,
        uint16 _authorizedAssetClass
    ) external onlyOwner {
        require(
            (_userType == 0) ||
                (_userType == 1) ||
                (_userType == 9) ||
                (_userType == 99),
            "ST:OO-AU-ERR:Invalid user type"
        );

        bytes32 hash;
        hash = keccak256(abi.encodePacked(_authAddr));

        emit REPORT("Internal user database access!"); //report access to the internal user database
        registeredUsers[hash].userType = _userType;
        registeredUsers[hash].authorizedAssetClass = _authorizedAssetClass;
    }

    //--------------------------------------External functions--------------------------------------------//
    /*
     * @dev Portal for AC TokenHolders to set costs
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
    ) external isACtokenHolder(_class) {
        Storage.ACTH_setCosts(
            _class,
            _newRecordCost,
            _transferAssetCost,
            _createNoteCost,
            _reMintRecordCost,
            _changeStatusCost,
            _forceModifyCost,
            _paymentAddress
        );
    }

    /*
     * @dev Compliance for erc721
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    

    //--------------------------------------------------------------------------------------Private functions
    /*
     * @dev Get a User Record from Storage @ msg.sender
     */
    function getUser() private view returns (User memory) {
        //User memory callingUser = getUser();
        User memory user;
        user = registeredUsers[keccak256(abi.encodePacked(msg.sender))];
        return user;
    }

    //--------------------------------------------------------------------------------------Storage Reading private functions

    /*
     * @dev retrieves Base Costs from Storage and returns Costs struct
     */
    function getBaseCost() private returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.reMintRecordCost,
            cost.changeStatusCost,
            cost.forceModifyCost,
            cost.paymentAddress
        ) = Storage.retrieveBaseCosts();

        return (cost);
    }

    /*
     * @dev retrieves costs from Storage and returns Costs struct
     */
    function getCost(uint16 _class) private returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.reMintRecordCost,
            cost.changeStatusCost,
            cost.forceModifyCost,
            cost.paymentAddress
        ) = Storage.retrieveCosts(_class);

        return (cost);
    }
}