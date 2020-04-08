pragma solidity ^0.6.0;

/**
 * @title BulletProof
 * @dev Store & retreive a record
 * Need to explore the implications of registering with serial only and reregistering with serial+secret
 * 
 * Authorization for registry changes from adress -> uint mapping?
 * 
 * Record status field key
 * 0 = no status, transferrable
 * 1 = transferrable
 * 2 = nontransferrable
 * 3 = stolen
 * 4 = lost
 * 255 = record locked (contract will not modify record without this first being unlocked by origin)
 * 
 * RegisteredUsers:
 * 0 = addressHash not authorized 
 * > 0 Authorized for database functions
 * 9 = authorized for automation function
 * 
 * 
 * A Status 5 authorizes private sales, in which an point of sale app can verify that the "seller" can verify his/her
 * registrant-hash in-app and allow transfer through our robot registrar to a party specified in-app. Implementation TBD
 * 
 * 
 */

import "./BP_Storage.sol";

contract BulletProof is Storage {
    

    /**
     * @dev Authorize / Deauthorize / Authorize automation for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     * something like:
     * 
     * function authorize(bytes32 authAddrHash) public onlyOwner {
     *   registeredUsers[authAddrHash] = 1;
     * }
     */
    function authorize(address authAddr) public onlyOwner {
        bytes32 hash;
        hash = keccak256(abi.encodePacked(authAddr));
        registeredUsers[hash] = 1;
    }
    
    function authorizeRobot(address authAddr) public onlyOwner {
        bytes32 hash;
        hash = keccak256(abi.encodePacked(authAddr));
        registeredUsers[hash] = 9;
    }
    
    function deauthorize(address authAddr) public onlyOwner {
        bytes32 hash;
        hash = keccak256(abi.encodePacked(authAddr));
        registeredUsers[hash] = 0;
    }
    
    
     /**
     * @dev Administrative lock a database entry at index idx
     */

    function adminLock(uint idx) public onlyOwner {
        
        require(
            database[idx].status != 255 ,
            "Record already locked"
        );
        
        database[idx].status = 255;
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    
    /**
     * @dev Administrative unlock a database entry at index idx
     */

    function adminUnLock(uint idx) public onlyOwner {
        
        require(
            database[idx].status == 255 ,
            "Record not locked"
        );
        
        database[idx].status = 2;            // set to notransferrable on unlock????????????????????!!!!!!!!!!!!!!!!!
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    

    /**
     * @dev Store a complete record at index idx
     */
    function newRecord(address sender, uint idx, bytes32 regstrnt, uint8 stat) internal { //public
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 1 ,
            "Address not authorized"
        );
        require(
            database[idx].registrant == 0 ,
            "Record already exists"
        );
        require(
            regstrnt != 0 ,
            "Registrant cannot be empty"
        );
        require(
            stat != 255 ,
            "creation of locked record prohibited"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(sender));
        database[idx].registrant = regstrnt;
        database[idx].status = stat;
    }


    function modifyStatus(address sender, uint idx, bytes32 regstrnt, uint8 stat) internal {
        require(
            database[idx].registrant == regstrnt,
            "records do not match - status change aborted"
        );
        forceModifyStatus(sender,idx,stat);
    }
    
    /**
     * @dev force modify record field 'status' at index idx
     */
    
    function forceModifyStatus(address sender, uint idx, uint8 stat) internal {
        bytes32 senderHash = keccak256(abi.encodePacked(sender));
        require(
            (registeredUsers[senderHash] == 1) || (registeredUsers[senderHash] == 9) ,
            "Address not authorized"
        );
        require(
            database[idx].registrant != 0 ,
            "No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "Record locked"
        );
        require(
            stat != 255 ,
            "locking by user prohibited"
        );
    
        if(  stat == database[idx].status) {
            return;                         //save gas?
        }
        
        database[idx].registrar = keccak256(abi.encodePacked(sender));
        database[idx].status = stat;
    }
    
    
    /**
     * @dev modify record field 'registrant' at index idx
     */
    
    function modifyRegistrant(address sender, uint idx, bytes32 regstrnt) internal { //public
        bytes32 senderHash = keccak256(abi.encodePacked(sender));
        require(
            (registeredUsers[senderHash] == 1) || (registeredUsers[senderHash] == 9) ,
            "Address not authorized"
        );
        require(
            database[idx].registrant != 0 ,
            "No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "Record locked"
        );
        require(
            database[idx].status != 2 ,
            "Asset marked nontransferrable"
        );
        require(
            database[idx].status != 3 ,
            "Asset reported stolen"
        );
        require(
            database[idx].status != 4 ,
            "Asset reported lost"
        );
        require(
            (database[idx].status == 0) || (database[idx].status == 1) ,
            "Tranfer prohibited"
        );
        require(
            regstrnt != 0 ,
            "Registrant cannot be empty"
        );
        require(
            database[idx].registrant != regstrnt ,
            "New record is identical to old record"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(sender));
        database[idx].registrant = regstrnt;
    }

     /**
     * @dev modify record with test for match to old record
     */
    
    function transferAsset (address sender, uint256 idx, bytes32 oldreg, bytes32 newreg, uint8 newstat) internal {
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 1  ,
            "Address not authorized"
        );
        require(
            database[idx].registrant == oldreg,
            "Records do not match - record change aborted"
        );
        
        modifyRegistrant(sender, idx, newreg);
        forceModifyStatus(sender, idx, newstat);
     
     }
     
     
    /**
     * @dev Automation modify record with test for match to old record
     */
    
    function robotTransferAsset (address sender, uint256 idx, bytes32 oldreg, bytes32 newreg, uint8 newstat) internal {
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 9 ,
            "Address not authorized"
        );
        require(
            database[idx].registrant == oldreg,
            "Records do not match - record change aborted"
        );
        
        modifyRegistrant(sender, idx, newreg);
        forceModifyStatus(sender, idx, newstat);
     
     }

    
    /**
     * @dev Return complete record from datatbase at index idx
     */

    function retrieveRecord (uint idx) public view returns (bytes32,bytes32,uint8) {
        return (database[idx].registrar,database[idx].registrant,database[idx].status);
    }
    

    /** Funtions for plaintext contract interaction
     * ------------------------------------------------------------------------------------------------------------------------------------------------
     * newRecord
     * modifyRegistrant
     * 
     * Additional wrappers:
     * registrant compare / verify registrant hash
     * 
     */
    
}
