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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.7.1;
import "./Imports/access/Ownable.sol";


contract GASTEST is Ownable {
    struct Data {
        uint8 U8_1;
        uint8 U8_2;
        uint8 U8_3;
        uint8 U8_4;
        uint32 U32; 
        uint64 U64;
        uint128 U128;
    }

    struct BigData {
        uint8 U8_1;
        uint8 U8_2;
        uint8 U8_3;
        uint8 U8_4;
        uint32 U32; 
        uint64 U64;
        uint128 U128;
        uint256 U256;
        bytes32 B32_1;
        bytes32 B32_2;
    }

    mapping(uint256 => uint256) internal smallMap;
    mapping(uint256 => Data) internal medMap;
    mapping(uint256 => BigData) internal bigMap;

    function storeSmall(uint256 _key, uint256 _val) public {
        smallMap[_key] = _val;
    }

    function storeMed(
        uint256 _key, 
        uint8 U8_1,
        uint8 U8_2,
        uint8 U8_3,
        uint8 U8_4,
        uint32 U32, 
        uint64 U64,
        uint128 U128) public {
        
        medMap[_key].U8_1 = U8_1;
        medMap[_key].U8_2 = U8_2;
        medMap[_key].U8_3 = U8_3;
        medMap[_key].U8_4 = U8_4;
        medMap[_key].U32 = U32;
        medMap[_key].U64 = U64;
        medMap[_key].U128 = U128;
    }

    function storeBig(
        uint256 _key, 
        uint8 U8_1,
        uint8 U8_2,
        uint8 U8_3,
        uint8 U8_4,
        uint32 U32, 
        uint64 U64,
        uint128 U128,
        uint256 U256,
        bytes32 B32_1,
        bytes32 B32_2
        ) public {
        
        bigMap[_key].U8_1 = U8_1;
        bigMap[_key].U8_2 = U8_2;
        bigMap[_key].U8_3 = U8_3;
        bigMap[_key].U8_4 = U8_4;
        bigMap[_key].U32 = U32;
        bigMap[_key].U64 = U64;
        bigMap[_key].U128 = U128;
        bigMap[_key].U256 = U256;
        bigMap[_key].B32_1 = B32_1;
        bigMap[_key].B32_2 = B32_2;
    }

    function getSmall(uint256 _key) public view returns (uint256){
        return smallMap[_key];
    }

    function getMed(uint256 _key) public view returns (uint8, uint8, uint8, uint8, uint32, uint64, uint256){
        return (
            medMap[_key].U8_1,
            medMap[_key].U8_2,
            medMap[_key].U8_3,
            medMap[_key].U8_4,
            medMap[_key].U32, 
            medMap[_key].U64,
            medMap[_key].U128);
    }

    function getBig(uint256 _key) public view returns (uint8, uint8, uint8, uint8, uint32, uint64, uint256){
        return (
            bigMap[_key].U8_1,
            bigMap[_key].U8_2,
            bigMap[_key].U8_3,
            bigMap[_key].U8_4,
            bigMap[_key].U32, 
            bigMap[_key].U64,
            bigMap[_key].U128);
    }

    function clearSmall(uint256 _key) public {
        delete smallMap[_key];
    }

    function clearMed(uint256 _key) public {
        delete medMap[_key];
    }

    function clearBig(uint256 _key) public {
        delete bigMap[_key];
    }


    
}
