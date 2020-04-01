pragma solidity >=0.4.22 <0.7.0;

import "./2_Owner.sol";

/**
 * @title BP_Storage
 * @dev Store & retreive a record
 * 
 * Authorization for registry changes from ERC721? or from adress -> uint mapping?
 * 
 * 
 * 
 * 
 */

contract BP_Storage is Owner{
    
    struct Record {
        uint256 registrar; // tokenID (or address) of registrant 
        uint256 registrant;  // KEK256 Registered  owner
        uint256 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
    }
    
    mapping(uint256 => Record) public database; //registry
    mapping(address => uint256) private registeredUsers; //authorized registrar database
    
    function authorize(address authAddr) public isOwner {
        registeredUsers[authAddr] = 1;
    }
    
    function deauthorize(address authAddr) public isOwner {
        registeredUsers[authAddr] = 0;
    }

     
    function storeRegistrar(uint256 idx, uint256 regstr) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].registrar = regstr;
    }
    
    function storeRegistrant(uint256 idx, uint256 regtrnt) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].registrant = regtrnt;
    }
    
    function storeStatus(uint256 idx, uint256 stat) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].status = stat;
    }

    /**
     * @dev Return value from dtatbase 
     * @return struct of 'database record idx'
     */
    function checkRegistrant(uint256 idx) public view returns (uint256){
        return database[idx].registrant;
    }
    
    function checkRegistrar(uint256 idx) public view returns (uint256){
        return database[idx].registrar;
    }
    
    function checkStatus(uint256 idx) public view returns (uint256){
        return database[idx].status;
    }
    
   // function checkRecord(uint256 idx) public view returns (Record){   // I want the whole struct...but how?
   //     Record memory entry;
   //     entry = database[idx];
   //     return entry;
   //}
}
