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
    


    /**
     * @dev Authorize an address to make record modifications
     */
    function authorize(address authAddr) public onlyOwner {
        registeredUsers[authAddr] = 1;
    }

    /**
     * @dev De-authorize an address to make record modifications
     */
    
    function deauthorize(address authAddr) public onlyOwner {
        registeredUsers[authAddr] = 0;
    }


    /**
     * @dev ----------------- OBSOLETE ----------------- OBSOLETE (REGISTRANT MUST BE AUTOMATICALLY PROVIDED)
     */
    function storeRegistrar(uint idx, uint regstr) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].registrar = regstr;
    }
    
    /**
     * @dev Modify registrant field of aa database entry 
     */

    function storeRegistrant(uint idx, uint regtrnt) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].registrant = regtrnt;
    }
    
    /**
     * @dev modify status field of a database entry
     */

    function storeStatus(uint idx, uint stat) public {
        require(
            registeredUsers[msg.sender] == 1 ,
            "Not authorized"
        );
        database[idx].status = stat;
    }
    

    /**
     * @dev ----------------- OBSOLETE (REGISTRANT MUST BE AUTOMATICALLY PROVIDED)
     */
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
     * @dev Return value from dtatbase at index idx
     */

    function retrieveRecord (uint idx) public view returns (uint,uint,uint){
        return (database[idx].registrar,database[idx].registrant,database[idx].status);
    }
    
 
}
