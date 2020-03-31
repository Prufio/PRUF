pragma solidity >=0.4.22 <0.7.0;

/**
 * @title BP_Storage
 * @dev Store & retreive a record
 */
contract BP_Storage {
    
    struct Record {
        uint256 registrar; // tokenID (or address) of registrant 
        uint256 registrant;  // KEK256 Registered  owner
        uint256 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
    }
    
    mapping(uint256 => Record) public database;

    /**
     * @dev Store values in database
     * @param idx = record index , rec = struct value to store
     */
    function storeRegistrar(uint256 idx, uint256 regstr) public {
        database[idx].registrar = regstr;  //how to reference only a part of the struct?
        // could take form 'database[idx] = rec.status' or similar for modifying only part of the record ?
    }
    
    function storeRegistrant(uint256 idx, uint256 regtrnt) public {
        database[idx].registrant = regtrnt;  //how to reference only a part of the struct?
        // could take form 'database[idx] = rec.status' or similar for modifying only part of the record ?
    }
    
    function storeStatus(uint256 idx, uint256 stat) public {
        database[idx].status = stat;  //how to reference only a part of the struct?
        // could take form 'database[idx] = rec.status' or similar for modifying only part of the record ?
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
}
