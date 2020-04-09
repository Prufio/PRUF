pragma solidity ^0.6.0;

import "./Ownable.sol";

contract Storage is Ownable {
    struct Record {
        bytes32 registrar; // tokenID (or address) of registrant 
        bytes32 registrant;  // KEK256 Registered  owner
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
    }
    
    mapping(bytes32 => Record) internal database; //registry
    mapping(bytes32 => uint8) internal registeredUsers; //authorized registrar database
}