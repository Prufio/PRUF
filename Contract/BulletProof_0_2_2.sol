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
    function adminLock(bytes32 idx) internal onlyOwner {
        
        require(
            database[idx].status != 255 ,
            "AL: Record already locked"
        );
        
        database[idx].status = 255;
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    
    /**
     * @dev Administrative unlock a database entry at index idx
     */
    function adminUnlock(bytes32 idx) internal onlyOwner {
        
        require(
            database[idx].status == 255 ,
            "AU: Record not locked"
        );
        
        database[idx].status = 2;            // set to notransferrable on unlock????????????????????!!!!!!!!!!!!!!!!!
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }


    /**
     * @dev Store a complete record at index idx
     */
    function newRecord(address sender, bytes32 idx, bytes32 regstrnt, uint8 stat, uint8 _extra, string memory desc) internal { //public
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 1 ,
            "NR: Address not authorized"
        );
        require(
            database[idx].registrant == 0 ,
            "NR: Record already exists"
        );
        require(
            regstrnt != 0 ,
            "NR: Registrant cannot be empty"
        );
        require(
            stat != 255 ,
            "NR: creation of locked record prohibited"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(sender));
        database[idx].registrant = regstrnt;
        database[idx].status = stat;
        database[idx].extra = _extra;
        database[idx].forceModCount = 0;
        database[idx].description = desc;
    }


    /**
     * @dev force modify record field 'status' at index idx
     */
    function modifyStatus(address sender, bytes32 idx, bytes32 regstrnt, uint8 stat) internal {
        require(
            database[idx].registrant == regstrnt,
            "MS: records do not match - status change aborted"
        );
        if (registeredUsers[keccak256(abi.encodePacked(sender))] == 9){
            robotModifyStatus(sender,idx,stat);
        } else {
            forceModifyStatus(sender,idx,stat);
        }
    }
    
    
    /**
     * @dev modify record field 'status' at index idx
     */
    function forceModifyStatus(address sender, bytes32 idx, uint8 stat) internal {
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 1,
            "FMS: Address not authorized"
        );
        require(
            database[idx].registrant != 0 ,
            "FMS: No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "FMS: Record locked"
        );
        require(
            stat != 255 ,
            "FMS: locking by user prohibited"
        );
    
        if(  stat == database[idx].status) {
            return;                         //save gas?
        }
        
        database[idx].registrar = keccak256(abi.encodePacked(sender));
        database[idx].status = stat;
        database[idx].forceModCount ++;
    }
    
    function resetForceModCount(bytes32 idx) internal {
        database[idx].forceModCount = 0;
    }
    /**
     * @dev robot modify record field 'status' at index idx
     */
    function robotModifyStatus(address sender, bytes32 idx, uint8 stat) internal {
        
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 9,
            "RMS: Address not authorized for automation"
        );
        require(
            database[idx].registrant != 0 ,
            "RMS: No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "RMS: Record locked"
        );
        require(
            stat != 255 ,
            "RMS: locking by user prohibited"
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
    function modifyRegistrant(address sender, bytes32 idx, bytes32 regstrnt) internal { //public
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 1  ,
            "MR: Address not authorized"
        );
        require(
            database[idx].registrant != 0 ,
            "MR: No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "MR: Record locked"
        );
        require(
            database[idx].status != 2 ,
            "MR: Asset marked nontransferrable"
        );
        require(
            database[idx].status != 3 ,
            "MR: Asset reported stolen"
        );
        require(
            database[idx].status != 4 ,
            "MR: Asset reported lost"
        );
        require(
            (database[idx].status == 0) || (database[idx].status == 1) ,
            "MR: Tranfer prohibited"
        );
        require(
            regstrnt != 0 ,
            "MR: Registrant cannot be empty"
        );
        require(
            database[idx].registrant != regstrnt ,
            "MR: New record is identical to old record"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(sender));
        database[idx].registrant = regstrnt;
    }
    
    
    /**
     * @dev robot modify record field 'registrant' at index idx
     */
    function robotModifyRegistrant(address sender, bytes32 idx, bytes32 regstrnt) internal { //public
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 9 ,
            "RMR: Address not authorized for auttomation"
        );
        require(
            database[idx].registrant != 0 ,
            "RMR: No Record exists to modify"
        );
        require(
            database[idx].status != 255 ,
            "RMR: Record locked"
        );
        require(
            database[idx].status != 2 ,
            "RMR: Asset marked nontransferrable"
        );
        require(
            database[idx].status != 3 ,
            "RMR: Asset reported stolen"
        );
        require(
            database[idx].status != 4 ,
            "RMR: Asset reported lost"
        );
        require(
            (database[idx].status == 0) || (database[idx].status == 1) ,
            "RMR: Tranfer prohibited"
        );
        require(
            regstrnt != 0 ,
            "RMR: Registrant cannot be empty"
        );
        require(
            database[idx].registrant != regstrnt ,
            "RMR: New record is identical to old record"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(sender));
        database[idx].registrant = regstrnt;
    }


    /**
     * @dev modify record with test for match to old record
     */
    function transferAsset (address sender, bytes32 idx, bytes32 oldreg, bytes32 newreg, uint8 newstat) internal {
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 1  ,
            "TS: Address not authorized"
        );
        require(
            database[idx].registrant == oldreg ,
            "TS: Records do not match - record change aborted"
        );
        
        modifyRegistrant(sender, idx, newreg);
        forceModifyStatus(sender, idx, newstat);
     
     }
     
     
    /**
     * @dev Automation modify record with test for match to old record
     */
    function robotTransferAsset (address sender, bytes32 idx, bytes32 oldreg, bytes32 newreg, uint8 newstat) internal {
        require(
            registeredUsers[keccak256(abi.encodePacked(sender))] == 9 ,
            "RTA: Address not authorized for automation"
        );
        require(
            database[idx].registrant == oldreg ,
            "RTA: Records do not match - record change aborted"
        );
        
        robotModifyRegistrant(sender, idx, newreg);
        robotModifyStatus(sender, idx, newstat);
     
     }
    
}
