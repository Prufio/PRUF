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
/*-----------------------------------------------------------------
 * only tokenHolder can put items "in pouch" 
 * only trusted entities can take items "out"
 * only pouchholder can mark item status, auth as user type 1+ in asset class
 * joe public can check only?
 * statuses:
 *
 * 0 = no status; clean
 * 1 = items with this SN are questionable (found an item that is apparently not real) --settable/clearable by type 2-3 user
 * 2 = items with this SN are counterfeit (original, authentic item recovered (and held/destroyed), or SN does not officially exist) --settable/clearable by type 3 user
 * 3 = this item SN was stolen --settable/clearable by type 2-3 user
 * 4 = this item SN was lost --settable/clearable by type 2-3 user
 * 5 = this item SN is in process --settable by type 2-3 user - clearable by type 3 user 
 * 6 =
 *
 * usertypes are indicated in idxAuthInVerify[_idxHash] 
 * 0 not authorized
 * 1 basic auth
 * 2 priveledged level auth
 * 3 admin level auth
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.1;

import "./PRUF_CORE.sol";
import "./PRUF_INTERFACES.sol";

contract VERIFY is CORE {
    using SafeMath for uint256;

    struct ItemData {
        uint8 status; //Item status (suspect, counterfeit, stolen, lost, etc) type 3+ user
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
            (A_TKN.ownerOf(tokenId) == _msgSender()), // ||
            "VFY:MOD-IA: Caller does not hold verify enabled token"
        );
        require(
            (idxAuthInVerify[_idxHash] > 0),
            "VFY:MOD-IA: Token IDX not listed in VERIFY approved tokens" //must be auth or "1"
        );
        _;
    }

    /*
     * @dev:authorize an asset token _idxHash as a wallet token in verify
     *      the caller must posess AC token for given asset Class (reverts)
     *      AC must be VERIFY custody type (4) (reverts)
     *      AC of Asset token to be approved must be of the same assetClass as the held ACtoken (reverts)
     */
    function authorizeTokenForVerify(
        bytes32 _idxHash,
        uint8 _verified, //0 for not verify authorized, 1 for admin level auth, 2 for priveledged level auth and 3 = basic verify authorization
        uint32 _assetClass
    ) external {
        AC memory ACdata = getACinfo(_assetClass);
        Record memory rec = getRecord(_idxHash);

        require(
            AC_TKN.ownerOf(uint256(_assetClass)) == _msgSender(),
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
     * @dev:Put an item into the (_idxHash) VERIFY wallet, with maximum assurances
     *      the caller must posess Asset token, must pass isAuth (reverts)
     *      item cannot already be registered as "in" the callers wallet (reverts)
     *      itemData.status must be 0 (clean) (returns status)
     *      Item collisions cannot exceed maxCollisions (returns 100)
     *      If item is marked as held in another wallet, collisions++ (return 0)     
     *      If item is not marked as held, it will be listed as held "in" the callers wallet (return 170)
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
        //^^^^^^^checks^^^^^^^^^

        if (itemData[_itemHash].status != 0) {
            //if status is not "clean" (0) return the status
            return itemData[_itemHash].status;
        }

        if (itemData[_itemHash].collisions > maxCollisions) {
            //if status is not "clean" (0) return the status
            return 100; //return 100 if max collisions exceeded
        }

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
     *      the caller must posess Asset token, must pass isAuth (reverts)
     *      item cannot already be registered as "in" the callers wallet (reverts)
     *      if status is stolen return 3
     *      if status is counterfeit return 2
     *      If item is marked as held in another wallet, collisions++ (return 0)
     *      If item is not marked as held, it will be listed as held "in" the callers wallet (return 170)
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

        if (itemData[_itemHash].status == 3) {
            //if status is stolen return 3
            return 3;
        }

        if (itemData[_itemHash].status == 2) {
            //if status is counterfeit return 2
            return 2;
        }

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
     *      the caller must posess Asset token, must pass isAuth (reverts)
     *      item must be registered as "in" the callers wallet (reverts)
     *      must not be lost/stolen (reverts)
     */
    function takeOut(bytes32 _idxHash, bytes32 _itemHash)
        external
        isAuthorized(_idxHash)
        returns (uint256)
    {
        require(items[_itemHash] == _idxHash, "VFY:TO:item not held by caller"); //check to see if held by _idxHash
        require(
            (itemData[_itemHash].status != 3) &&
                (itemData[_itemHash].status != 4),
            "VFY:T:Item SN is marked as lost or stolen"
        );
        //^^^^^^^checks^^^^^^^^^

        delete items[_itemHash]; // release item _asset
        //^^^^^^^effects^^^^^^^^^

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev:Transfer an item out of one (_idxHash) verify wallet into another
     *      the caller must posess Asset token, must pass isAuth (reverts)
     *      item must be registered as "in" the callers wallet (reverts)
     *      item must not be lost/stolen (reverts)
     *      destination wallet must be in same asset class as sending wallet (reverts)
     */
    function transfer(
        //IS THIS A TERRIBLE IDEA? EXAMINE
        bytes32 _idxHash,
        bytes32 _newIdxHash,
        bytes32 _itemHash
    ) external isAuthorized(_idxHash) returns (uint256) {
        Record memory rec = getRecord(_idxHash);
        Record memory newRec = getRecord(_newIdxHash);

        require(items[_itemHash] == _idxHash, "VFY:TO:item not held by caller"); //check to see if held by _idxHash
        require( //must move to same asset class root
            AC_MGR.isSameRootAC(rec.assetClass, newRec.assetClass) == 170,
            "VFY:TO:Wallet is not in the same asset class root"
        );
        require(
            itemData[_itemHash].status != 2,
            "VFY:PI:item marked counterfeit"
        ); //check to see if item status is clean
        require(
            (itemData[_itemHash].status != 3) &&
                (itemData[_itemHash].status != 4),
            "VFY:T:Item SN is marked as lost or stolen"
        );
        //^^^^^^^checks^^^^^^^^^

        items[_itemHash] = _newIdxHash; // transfer item _asset
        //^^^^^^^effects^^^^^^^^^

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev:Mark an item conterfeit . Admin function, user marks conterfeit regardless of who holds it
     *      the caller must posess Asset token authorized at userlevel 3
     */
    function adminMarkCounterfeit(
        bytes32 _idxHash,
        bytes32 _itemHash
    ) external isAuthorized(_idxHash) returns (uint256) {
        require(
            idxAuthInVerify[_idxHash] == 3, //token is auth amdmin
            "VFY:MI: Caller not authorized as a admin user (type3) in the asset class"
        );
        //^^^^^^^checks^^^^^^^^^

        itemData[_itemHash].status = 2;
        //^^^^^^^effects^^^^^^^^^

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev:Mark an item with a status (see docs at top of contract)
     *      the caller must posess Asset token, must pass isAuth and user must be auth as a 3 in that AC (reverts)
     *      item must be listed as "in" the callers wallet (reverts)
     *      Other than that, unrestricted power to change ststus of held items
     */
    function markItem(
        bytes32 _idxHash,
        bytes32 _itemHash,
        uint8 _status,
        uint32 _value
    ) external isAuthorized(_idxHash) returns (uint256) {
        require(                                                             
            idxAuthInVerify[_idxHash] > 2, //token is auth privelidged+
            "VFY:MI: Caller not authorized as a verified user (>= 3)"
        );

        require(items[_itemHash] == _idxHash, "VFY:MI:item not held by caller"); //check to see if held by _idxHash
        //^^^^^^^checks^^^^^^^^^

        itemData[_itemHash].status = _status;
        itemData[_itemHash].value = _value;
        //^^^^^^^effects^^^^^^^^^

        return 170;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev:Retrieve data about an item
     * unrestricted access
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

/*-----------------------------------------------------------------
 *  TESTING
 *
/*-----------------------------------------------------------------
 Make a 2 Verify AC's (custody type 4)
 make 2 assets in each new AC (1,2) (3,4)
 verify all 4 Assets as pruf verify wallets | 1 = 1 | 2 = 1 | 3 = 2 | 4 = 3 |

 put an item A in wallet 1 (should succeed)
 put an item B in wallet 1 (should succeed)
 try to put item A in wallet 2 (should fail) -- item already held, collision ++
 take item A out of wallet 1 (should succeed)
 put item A in wallet 2 (should succeed) 
 transfer item A to wallet 3 (should fail)  -- non matching asset class
 transfer item A to wallet 1 (should succeed)
 take item A out of wallet 1 (should succeed)
 safePutIn item A to wallet 2 with collision threshold at 1 (should succeed)
 put item A to wallet 1 (should fail) -- item already held, collision ++
 take item A out of wallet 1 (should fail) -- not held in wallet
 take item A out of wallet 2 (should succeed)
 safePutIn item A to wallet 2 with collision threshold at 1 (should Fail) -- excess collisions
 safePutIn item A to wallet 3 with collision threshold at 2 (should succeed)
 transfer item A to wallet 1 (should fail) -- non matching asset class
 transfer item A to wallet 4 (should succeed)


 AdminMark item A as counterfeit (2) (should succeed)
 transfer item A to wallet 3 (should fail) -- counterfeit

 mark item A as in process (5)  (should succeed)
 transfer item A to wallet 3 (should succeed)

 mark item A as counterfeit (2) (should fail) -- not auth
 mark item A as lost (4) (should fail) -- in process
 take item A out of wallet 3 (should succeed)

 safePutIn item A to wallet 4 with collision threshold at 2 (should Fail) -- not clean
 PutIn item A to wallet 4 (should succeed)
 mark item A as clean (0) (should succeed)
 safePutIn item A to wallet 1 with collision threshold at 1 (should Fail) -- excess collisions
 safePutIn item A to wallet 1 with collision threshold at 2 (should succeed)
 PutIn item B to wallet 4 (should fail) -- item already held, collision ++
 take item B out of wallet 1 (should succeed)

 retrieve both items. 
 item A should be status 0, collisions 2
 item B should be status 0, collisions 1


 * 0 = no status; clean
 * 1 = items with this SN are questionable (found an item that is apparently not real)
 * 2 = items with this SN are counterfeit (original, authentic item recovered (and held/destroyed), or SN does not officially exist) (SUPER AUTH ONLY)
 * 3 = this item SN was stolen
 * 4 = this item SN was lost
 * 5 = this item SN is in process
 * 6 =
 *
 * usertypes are indicated in idxAuthInVerify[_idxHash] 
 * 0 not authorized
 * 1 basic auth
 * 2 priveledged level auth
 * 3 admin level auth
 *---------------------------------------------------------------*/
