pragma solidity >=0.4.22 <0.6.7;

import "./Ownable.sol";

/**
 * @title BP_Storage
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
 * 5 = private sale permitted SEE NOTE
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

contract BulletProof is Ownable {
    
    struct Record {
        bytes32 registrar; // tokenID (or address) of registrant 
        bytes32 registrant;  // KEK256 Registered  owner
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
    }
    
    mapping(uint => Record) private database; //registry
    mapping(bytes32 => uint8) private registeredUsers; //authorized registrar database

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

    function adminLock(uint idx) public onlyOwner{
        
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

    function adminUnLock(uint idx) public onlyOwner{
        
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
    function newRecord(uint idx, bytes32 regstrnt, uint8 stat) private { //public
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        require(
            (registeredUsers[senderHash] == 1) || (registeredUsers[senderHash] == 9) ,
            "Not authorized"
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
        
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
        database[idx].registrant = regstrnt;
        database[idx].status = stat;
    }

    
    /**
     * @dev modify record field 'status' at index idx
     */
    
    function modifyStatus(uint idx, uint8 stat) public {
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        require(
            (registeredUsers[senderHash] == 1) || (registeredUsers[senderHash] == 9) ,
            "Not authorized"
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
        require(
            stat != database[idx].status ,
            "New status is same as old status"
        );
        
        
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
        database[idx].status = stat;
    }
    
    
    /**
     * @dev modify record field 'registrant' at index idx
     */
    
    function modifyRegistrant(uint idx, bytes32 regstrnt) private { //public
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        require(
            (registeredUsers[senderHash] == 1) || (registeredUsers[senderHash] == 9) ,
            "Not authorized"
        );
        require(
            database[idx].registrant != 0 ,
            "No Record exists to modify"
        );
        require(
            database[idx].registrant != regstrnt ,
            "New record is identical to old record"
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
        (database[idx].status == 0) || (database[idx].status == 1) || (database[idx].status == 5) ,
            "Tranfer prohibited"
        );
        require(
            regstrnt != 0 ,
            "Registrant cannot be empty"
        );
        
        database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
        database[idx].registrant = regstrnt;
    }
    
    function transferAsset (uint256 idx, bytes32 oldreg, bytes32 newreg, uint8 newstat) private returns(uint8){
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        require(
            (registeredUsers[senderHash] == 1) || (registeredUsers[senderHash] == 9) ,
            "Not authorized"
        );
        if (oldreg == database[idx].registrant){
            modifyRegistrant(idx, newreg);
            modifyStatus(idx,newstat);
            return 1;
        } else {
            return 0;
        }
     }

    
    /**
     * @dev Return complete record from datatbase at index idx
     */

    function retrieveRecord (uint idx) public view returns (bytes32,bytes32,uint8){
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
     
    function NEW_RECORD (uint256 idx, string memory reg, uint8 stat) public {
        newRecord(idx, keccak256(abi.encodePacked(reg)), stat);
    }
     
    function FORCE_MOD_REGISTRANT (uint256 idx, string memory reg) public {
        modifyRegistrant(idx, keccak256(abi.encodePacked(reg)));
     }
     
    function COMPARE_REGISTRANT (uint256 idx, string memory reg) public view returns(string memory){
         
        if (keccak256(abi.encodePacked(reg)) == database[idx].registrant){
            return "Registrant match confirmed";
        } else {
            return "Registrant does not match";
        }
    }
    
    function TRANSFER_ASSET (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public returns(string memory) {
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        require(
            registeredUsers[senderHash] == 1 ,
            "Not authorized"
        );
        if (transferAsset(idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat) == 1) {
            return "Asset record modified";
        } else {
            return "Asset record does not match - not modified";
        }
     }

     
    function PRIVATE_SALE (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public returns(string memory) {
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        require(
            registeredUsers[senderHash] == 9 ,
            "Address Not authorized for automation"
        );
        if (transferAsset(idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat) == 1) {
            return "Asset record modified";
        } else {
            return "Asset record does not match - not modified";
        }
     }
    
}

   /**
     * @dev update an address from an existing address to make record modifications
     * 
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     * something like:
     * 
     *function newAuthorize(bytes32 newAuthAddrHash) public {
     *    require(
     *        registeredUsers[keccak256(abi.encodePacked(msg.sender))] == 1 ,
     *        "Not authorized"
     *    );
     *    
     *    registeredUsers[newAuthAddrHash] = 1;
     *    
     *   registeredUsers[keccak256(abi.encodePacked(msg.sender))] = 0 ;
     *}
     * 
     */
    //-----------------------------------------------------This function and the activity it is designed to support (address hopping) will not meaningfully enhance security
    //function newAuthorize(address newAuthAddr) public {
    //    require(
    //        registeredUsers[keccak256(abi.encodePacked(msg.sender))] == 1 ,
    //        "Not authorized"
    //    );
    //    
    //    bytes32 hash;
    //    hash = keccak256(abi.encodePacked(newAuthAddr));
    //    registeredUsers[hash] = 1;
    //    registeredUsers[keccak256(abi.encodePacked(msg.sender))] = 0 ;
    //}

    /**
     * @dev Administrative Modify registrar field of aa database entry 
     * ----------------Security risk....probably should not be in production code
     */

    //function ForceOverwriteRegistrar(uint idx, bytes32 regstrar) public onlyOwner {
    //    database[idx].registrar = regstrar;
    //    database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    //}
    
    
    /**
     * @dev Administrative Modify registrant field of aa database entry 
     * ----------------Security risk....probably should not be in production code
     */

    //function forceOverwriteRegistrant(uint idx, bytes32 regtrnt) public onlyOwner {
    //    database[idx].registrant = regtrnt;
    //    database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    //}
    
    
    /**
     * @dev Administrative modify status field of a database entry
     * ----------------Security risk....probably should not be in production code
     */

    //function forceOverwriteStatus(uint idx, uint8 stat) public onlyOwner{
    //    database[idx].status = stat;
    //    database[idx].registrar = keccak256(abi.encodePacked(msg.sender));
    //}
    
