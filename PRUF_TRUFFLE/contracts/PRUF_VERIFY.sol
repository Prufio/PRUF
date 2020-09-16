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
/*-----------------------------------------------------------------
 * only tokenHolder can put items "in pouch" 
 * only trusted entities can take items "out"
 * only pouchholder can mark item status, auth as user type 1+ in asset class
 * joe public can check only?
 * statuses:
 *
 * 0 = no status; clean
 * 1 = items with this SN are questionable (found an item that is apparently not real, or collisions found)
 * 2 = items with this SN are counterfiet (original, authentic item recovered (and held/destroyed), or SN does not officially exist) (SUPER AUTH ONLY)
 * 3 = this item SN was stolen
 * 4 = this item SN was lost
 * 5 =
 * 6 =
 *
 * usertypes are indicated in idxAuthInVerify[_idxHash] 
 * 0 basic verify authorized
 * 1 for admin level auth
 * 2 for priveledged level auth
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";
import "./PRUF_INTERFACES.sol";

contract VERIFY is CORE {
    using SafeMath for uint256;

    struct ItemData {
        uint8 status; //Item status (suspect, counterfiet, stolen, lost, etc) //maybe only bank /mint can mark counterfiet?
        uint32 value; //denomination, if applicable
        uint32 collisions; //number of times the item was attempted to be "locked" when held
        //room here for more data for 32 bytes!
    }

    mapping(bytes32 => bytes32) private items; // itemHash -> idxHash of the owning wallet
    mapping(bytes32 => ItemData) private itemData; //itemhash -> itemdata

    mapping(bytes32 => uint8) private idxAuthInVerify; //idxHash -> verification level

    /**
     * Requires:
     *      the caller must posess Asset token _idxhash
     *      Asset Token must be set to value = 1 in  idxAuthInVerify
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        //checks to see if caller holds the wallet token (asset token minted as a wallet)
        uint256 tokenId = uint256(_idxHash);

        require(
            (A_TKN.ownerOf(tokenId) == msg.sender), // ||
            "VFY:MOD-IA: Caller does not hold verify enabled token"
        );
        require(
            (idxAuthInVerify[_idxHash] == 1),
            "VFY:MOD-IA: Token IDX not listed in VERIFY approved tokens"  //must be auth or "1"
        );
        _;
    }

    /*
     * @dev:authorize an asset token _idxHash as a wallet token in verify
     *      the caller must posess AC token for given asset Class
     *      AC must be VERIFY custody type (4)
     *      AC of Asset token to be approved must be of the same assetClass as the held ACtoken
     */
    function authorizeTokenForVerify(
        bytes32 _idxHash,
        uint8 _verified,   //0 for not verify authorized, 1 for admin level auth, 2 for priveledged level auth and 3 = basic verify authorization
        uint32 _assetClass
    ) external {
        AC memory ACdata = getACinfo(_assetClass);
        Record memory rec = getRecord(_idxHash);

        require(
            AC_TKN.ownerOf(uint256(_assetClass)) == msg.sender,
            "VFY:ATFV: caller does not hold AC token"
        );
        require(ACdata.custodyType == 4, "VFY:ATFV: AC not VERIFY enabled");
        require(
            rec.assetClass == _assetClass,
            "VFY:ATFV: AC of Asset Token does not match supplied AC "
        );
        //^^^^^^^checks^^^^^^^^^

        idxAuthInVerify[_idxHash] = _verified;
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev:Put an item into the (_idxHash) verify wallet, with maximum assurances
     *      the caller must posess Asset token, must pass isAuth
     *      item cannot already be registered as "in" the callers wallet
     *      itemData.status must be 0 (clean)
     *      Item collisions cannot exceed maxCollisions
     *      If item is not marked as held, it will be listed as held "in" the callers wallet (return 170)
     *      If item is marked as held in another wallet, collisions++ (return 0)
     */
    function safePutIn(
        bytes32 _idxHash,
        bytes32 _itemHash,
        uint32 maxCollisions
    ) external isAuthorized(_idxHash) returns (uint256) {
        require( //check to see if held by _idxHash
            items[_itemHash] != _idxHash,
            "VFY:PI:item already held by caller"
        );
        require(itemData[_itemHash].status == 0, "VFY:PI:item status not zero"); //check to see if item status is clean
        require( //check to see if collisions > limit
            itemData[_itemHash].collisions <= maxCollisions,
            "VFY:PI:item collisions exceeds limit"
        );

        //^^^^^^^checks^^^^^^^^^
        if (items[_itemHash] != 0) {
            if (itemData[_itemHash].collisions < 4294967295)
                itemData[_itemHash].collisions++;
            return 0;
        } else {
            items[_itemHash] = _idxHash; // put item _asset into wallet _idxHash\
            return 170;
        }
        //^^^^^^^effects / interactions^^^^^^^^^
    }

    /*
     * @dev:Put an item into the (_idxHash) verify wallet
     *      the caller must posess Asset token, must pass isAuth
     *      item cannot already be registered as "in" the callers wallet
     *      If item is not marked as held, it will be listed as held "in" the callers wallet (return 170)
     *      If item is marked as held in another wallet, collisions++ (return 0)
     */
    function putIn(bytes32 _idxHash, bytes32 _itemHash)
        external
        isAuthorized(_idxHash)
        returns (uint256)
    {
        require( //check to see if held by _idxHash
            items[_itemHash] != _idxHash,
            "VFY:PI:item already held by caller"
        );
        //^^^^^^^checks^^^^^^^^^
        if (items[_itemHash] != 0) {
            if (itemData[_itemHash].collisions < 4294967295)
                itemData[_itemHash].collisions++;
            return 0;
        } else {
            items[_itemHash] = _idxHash; // put item _asset into wallet _idxHash\
            return 170;
        }
        //^^^^^^^effects / interactions^^^^^^^^^
    }

    /*
     * @dev:Take an item out of the (_idxHash) verify wallet
     *      the caller must posess Asset token, must pass isAuth
     *      item must be registered as "in" the callers wallet
     *      If item is not marked as held, it will be listed as held "in" the callers wallet (return 170)
     *      If item is marked as held in another wallet, collisions++ (return 0)
     */
    function takeOut(bytes32 _idxHash, bytes32 _itemHash)
        external
        isAuthorized(_idxHash)
        returns (uint256)
    {
        require(items[_itemHash] == _idxHash, "VFY:TO:item not held by caller"); //check to see if held by _idxHash
        //^^^^^^^checks^^^^^^^^^

        items[_itemHash] = 0; // release item _asset
        //^^^^^^^effects^^^^^^^^^

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    function transfer(
        //IS THIS A TERRIBLE IDEA? EXAMINE
        bytes32 _idxHash,
        bytes32 _newIdxHash,
        bytes32 _itemHash
    ) external isAuthorized(_idxHash) returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        Record memory newRec = getRecord(_newIdxHash);

        require(items[_itemHash] == _idxHash, "VFY:TO:item not held by caller"); //check to see if held by _idxHash
        require( //must move to same asset class
            AC_MGR.isSameRootAC(rec.assetClass, newRec.assetClass) == 170,
            "VFY:TO:Wallet is not in the same asset class"
        );
        //^^^^^^^checks^^^^^^^^^

        items[_itemHash] = _newIdxHash; // transfer item _asset
        //^^^^^^^effects^^^^^^^^^

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev:Mark an item with a status (see docs at top of contract)
     *      the caller must posess Asset token, must pass isAuth and user must be auth as a "1" in that AC
     *      item must be listed as "in" the callers wallet
     */
    function markItem(
        bytes32 _idxHash,
        bytes32 _itemHash,
        uint8 _status,
        uint32 _value
    ) external isAuthorized(_idxHash) returns (uint256) {
        uint256 tokenId = uint256(_idxHash);

        require(
            (A_TKN.ownerOf(tokenId) == msg.sender) && //msg.sender is token holder
                (idxAuthInVerify[_idxHash] == 1), //token is auth amdmin asset class
            "VFY:MI: Caller does not hold token or is not authorized as a admin user (type1) in the asset class"
        );
        require(items[_itemHash] == _idxHash, "VFY:MI:item not held by caller"); //check to see if held by _idxHash

        itemData[_itemHash].status = _status;
        itemData[_itemHash].value = _value;
        return 170;
    }

        /*
     * @dev:Mark an item with lost or stolen status (see docs at top of contract)
     *      the caller must posess Asset token, must pass isAuth and user must be auth as a "1" in that AC
     *      item must be listed as "in" the callers wallet
     */
    function markLS(
        bytes32 _idxHash,
        bytes32 _itemHash,
        uint8 _status,
        uint32 _value
    ) external isAuthorized(_idxHash) returns (uint256) {
        uint256 tokenId = uint256(_idxHash);

        require((_status == 3) || (_status == 4), "VFY:MILS:must set to L/S 3 || 4 only"); //verify _status is l/s
        require(
            (A_TKN.ownerOf(tokenId) == msg.sender) && //msg.sender is token holder
                (idxAuthInVerify[_idxHash] > 0), //msg sender is auth in asset class
            "VFY:MILS: Caller does not hold token or is not authorized as a verified user (>= 2) in the asset class"
        );
        require(items[_itemHash] == _idxHash, "VFY:MILS:item not held by caller"); //check to see if held by _idxHash

        itemData[_itemHash].status = _status;
        itemData[_itemHash].value = _value;
        return 170;
    }

    /*
     * @dev:Retrieve data about an item
     */
    function getItemData(bytes32 _itemHash)
        external
        view
        returns (
            bytes32,
            uint8,
            uint32,
            uint32
        )
    {
        return (
            items[_itemHash], //holding _idxHash, if any
            itemData[_itemHash].status, //item status
            itemData[_itemHash].value, //value field (example 10 for 10USD bill)
            itemData[_itemHash].collisions //number of collisions on this serial number
        );
    }
}
