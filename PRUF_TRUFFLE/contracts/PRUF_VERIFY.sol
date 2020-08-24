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

//import "./Imports/PullPayment.sol";
//import "./Imports/ReentrancyGuard.sol";

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
    {
        //check to see if held
        //held by _idxHash?
        //held by other?
        //item questionable?
        //check to see if marked as questionalble
        items[_itemHash] = _idxHash; // put item _asset into wallet _idxHash
    }

    function takeOut(bytes32 _idxHash, bytes32 _itemHash)
        external
        isAuthorized(_idxHash)
    {
        //must hold the item in _idxHash bag
        delete items[_itemHash]; // release item _asset
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
