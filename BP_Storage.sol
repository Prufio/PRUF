pragma solidity ^0.6.0;

import "./Ownable.sol";

contract Storage is Ownable {
    struct Record {
        bytes32 registrar; // tokenID (or address) of registrant 
        bytes32 registrant;  // KEK256 Registered  owner
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint8 assetClass; // Variable defines asset by distinctive class
        string description; // publically viewable asset description
    }
    
    /*
    struct IndexReference {
        bytes32 assetClass;
        bytes32 indexNum;
        bytes32 make;
        bytes32 model;
    }
    */
    
    // mapping(bytes32 => IndexReference) internal index;
    mapping(bytes32 => Record) internal database; //registry
    mapping(bytes32 => uint8) internal registeredUsers; //authorized registrar database
}