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
 * only trusted entities can put items "in pouch"
 * only trusted entities can take items "out"
 * only pouchholder can mark item status, etc
 * joe public can check only?
 * statuses:
 * 0 = no status; clean
 * 1 = items with this SN are questionable (found an item that is apparently not real, or collisions found)
 * 2 = items with this SN are counterfiet (original, authentic item recovered (and held/destroyed), or SN does not officially exist) (SUPER AUTH ONLY)
 * 3 = this item SN was stolen
 * 4 = this item SN was lost
 * 5 =
 * 6 =
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
        //uint32 assetClass; //assetClass of item (must be the same assetClass as the _idxHash)
        //room here for more data for 32 bytes!
    }

    mapping(bytes32 => bytes32) internal items;
    mapping(bytes32 => ItemData) internal itemData;


    modifier isAuthorized(bytes32 _idxHash) override {
        Record memory rec = getRecord(_idxHash);
        uint256 tokenId = uint256(_idxHash);

        require(
            (A_TKN.ownerOf(tokenId) == msg.sender), //msg.sender is token holder
            "VFY:MOD-IA: Caller does not hold token"
        );
        require(
            (getUserType(rec.assetClass) >= 1),
            "VFY:MOD-IA: User not authorized for this operation"
        );
        _;
    }


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
        if (
            (items[_itemHash] != 0) &&
            (itemData[_itemHash].collisions < 4294967295)
        ) {
            itemData[_itemHash].collisions++;
            return 0;
        } else {
            items[_itemHash] = _idxHash; // put item _asset into wallet _idxHash\
            return 170;
        }
        //^^^^^^^effects / interactions^^^^^^^^^
    }


    function takeOut(bytes32 _idxHash, bytes32 _itemHash)
        external
        isAuthorized(_idxHash)
    {
        require(items[_itemHash] == _idxHash, "VFY:TO:item not held by caller"); //check to see if held by _idxHash
        items[_itemHash] = 0; // release item _asset
    }


    function transfer(                                                               //IS THIS A TERRIBLE IDEA? EXAMINE
        bytes32 _idxHash,
        bytes32 _newIdxHash,
        bytes32 _itemHash
    ) external isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        Record memory newRec = getRecord(_newIdxHash);

        require(items[_itemHash] == _idxHash, "VFY:TO:item not held by caller"); //check to see if held by _idxHash
        require(    //must move to same asset class
            AC_MGR.isSameRootAC(rec.assetClass, newRec.assetClass) == 170,
            "VFY:TO:item not held by caller"
        ); 

        items[_itemHash] = _newIdxHash; // transfer item _asset
    }


    function markItem(bytes32 _idxHash, bytes32 _itemHash, uint8 _status, uint32 _value)
        external
    {
        Record memory rec = getRecord(_idxHash);
        uint256 tokenId = uint256(_idxHash);

        require(
            (A_TKN.ownerOf(tokenId) == msg.sender), //msg.sender is token holder
            "VFY:MI: Caller does not hold token"
        );
        require(
            (getUserType(rec.assetClass) == 1),   // must be userType 1 in the assetClass
            "VFY:MI: User not authorized for this operation"
        );
        require(items[_itemHash] == _idxHash, "VFY:TO:item not held by caller"); //check to see if held by _idxHash

        itemData[_itemHash].status = _status;
        itemData[_itemHash].value = _value;
    }


    function examine(bytes32 _itemHash)
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
            itemData[_itemHash].status,
            itemData[_itemHash].value,
            itemData[_itemHash].collisions
            //,itemData[_itemHash].assetClass
        );
    }
}

function getACinfo(uint32 _assetClass)
        internal
        virtual
        returns (AC memory)
    {
        //^^^^^^^checks^^^^^^^^^
        
        AC memory AC_info;
        //^^^^^^^effects^^^^^^^^^
        (
            AC_info.assetClassRoot,
            AC_info.custodyType,
            AC_info.extendedData
        ) = AC_MGR.getAC_data(_assetClass);
        return AC_info;
        //^^^^^^^interactions^^^^^^^^^
    }
