pragma solidity >=0.4.22 <0.7.0;

import "./Ownable.sol";

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

contract BP_Authorize is Ownable {
    
    struct Record {
        uint registrar; // tokenID (or address) of registrant 
        uint registrant;  // KEK256 Registered  owner
        uint status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
    }
    
    mapping(uint => Record) public database; //registry
    mapping(address => uint) private registeredUsers; //authorized registrar database
    
    function authorize(address authAddr) public onlyOwner {
        registeredUsers[authAddr] = 1;
    }
    
    function deauthorize(address authAddr) public onlyOwner {
        registeredUsers[authAddr] = 0;
    }

     
    function storeRegistrar(uint idx, uint regstr) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].registrar = regstr;
    }
    
    function storeRegistrant(uint idx, uint regtrnt) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].registrant = regtrnt;
    }
    
    function storeStatus(uint idx, uint stat) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].status = stat;
    }
    
    function storeRecord(uint idx, uint regstr, uint regtrnt, uint stat) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].registrar = regstr;
        database[idx].registrant = regtrnt;
        database[idx].status = stat;
    }

    /**
     * @dev Return value from dtatbase 
     * @return struct of 'database record idx'
     */

    function retrieveRecord (uint idx) public view returns (uint,uint,uint){
        return (database[idx].registrar,database[idx].registrant,database[idx].status);
    }
    
   // function checkRecord(uint256 idx) public view returns (Record){   // I want the whole struct...but how?
   //     Record memory entry;
   //     entry = database[idx];
   //     return entry;
   //}
}
