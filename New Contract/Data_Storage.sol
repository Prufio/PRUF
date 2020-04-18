pragma solidity 0.6.0;
//pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract Storage is Ownable {
   
    struct Record {
        bytes32 registrar; // Address hash of registrar 
        bytes32 registrant;  // KEK256 Registered  owner
        bytes32 lastRegistrar; //// Address hash of last non-automation registrar
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; //Type of asset
        uint countDown; // variable that can only be dencreased from countDownStart
        uint countDownStart; //starting point for countdown variable (set once)
        bytes32 IPFS1; // publically viewable asset description
        bytes32 IPFS2; // publically viewable immutable notes
    }
    
    struct User {
        uint8 userType; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint16 authorizedAssetClass; // extra status for future expansion
    }
    
    struct Costs{
        uint cost1;
        uint cost2;
        uint cost3;
        uint cost4;
        uint cost5;
        uint cost6;
    }
    

    mapping(bytes32 => uint8) private authorizedAdresses;
    
    mapping(bytes32 => Record) private database; //registry
    
    mapping(bytes32 => User) private registeredUsers; //authorized registrar database
    
    mapping(uint16 => Costs) private cost; //cost per function by asset class
    
    /*
    * Authorized external Contract / address types:   authorizedAdresses[]
    *
    * 0   --NONE
    * 1   --E
    * 2   --RE
    * 3   --RWE
    * 4  --Administrator
    * >4 NONE
    * Owner (onlyOwner)
    * other = unauth
    *
    * Authorized User Types   registeredUsers[]
    * 1 = standard User
    * 9 = Robot
    * other = unauth
    *
    */
    
    
     //--------------------------------------------------------------------------Modifiers----------------------------------------------------------   
     /*
     * @dev check msg.sender against authorized adresses
     */
    modifier addrAuth (uint8 _userType){
        require ( 
            (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] >= _userType) && (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] <= 4),
            //|| (authorizedAdresses[keccak256(abi.encodePacked(msg.sender))] == authorizedAdresses[keccak256(abi.encodePacked(owner()))]),
            "Contract not authorized or improperly permissioned"
            );
            _;
    }
    
 
    /*
     * @dev Verify user credentials
     */     
    modifier userAuth (bytes32 _senderHash, bytes32 _idxHash) {
        uint8 senderType = registeredUsers[_senderHash].userType;
        
        require(
            (senderType == 1) || (senderType == 9) || (database[_idxHash].assetClass > 8192),
            "AU:ERR-User not registered"
        );
        require(
            (database[_idxHash].assetClass == registeredUsers[_senderHash].authorizedAssetClass) || (database[_idxHash].assetClass > 8192),
            "AU:ERR-User not registered for asset type"
        );
        _;
    }
    
    
    /*
     * @dev check record exists and is not locked
     */     
    modifier unlocked(bytes32 _idxHash) {
        require(
            database[_idxHash].status != 255 ,
            "CR:ERR-record Locked"
        );
        _;
        
    }
    
    modifier exists(bytes32 _idxHash) {
        require(
            database[_idxHash].registrant != 0 ,
            "CR:ERR-record does not exist"
        );
        _;
        
    }
    

    
    //--------------------------------------------------------------------------Events----------------------------------------------------------

    event REPORT (string _msg);
    
    //event EMIT_RECORD (Record record);  //use when ABIencoder V2 is ready for prime-time
    event EMIT_RECORD (bytes32, bytes32, bytes32, uint8, uint8, uint16, uint, uint, bytes32, bytes32);
    

    
    
    //--------------------------------------------internal Admin functions //onlyowner----------------------------------------------------------
    
    
    /*
     * @dev Authorize / Deauthorize / Authorize users for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function addUser(address _authAddr, uint8 userType, uint16 _authorizedAssetClass) external onlyOwner {
      
        require((userType == 0)||(userType == 1)||(userType == 9) ,
        "AUTHU:ER-13 Invalid user type"
        );

        bytes32 hash;
        hash = keccak256(abi.encodePacked(_authAddr));
        registeredUsers[hash].userType = userType;
        registeredUsers[hash].authorizedAssetClass = _authorizedAssetClass;
    }
    
        /*
     * @dev Authorize / Deauthorize / Authorize ADRESSES permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function AddContract(address _addr, uint8 _userType) external onlyOwner {
        require ( 
            _userType <= 3,
            "AUTHC:ER-13 Invalid user type"
        );
        emit REPORT ("DS:SU: internal user database access!");  //report access to the internal user database
        authorizedAdresses[keccak256(abi.encodePacked(_addr))] = _userType;
    }
    
    
    /*
     * @dev retrieve function costs per asset class, in Wei
     */    
    function XRETRIEVE_COSTS (uint16 _assetClass) external view addrAuth(3) returns (uint, uint, uint, uint, uint, uint) {

        return (cost[_assetClass].cost1, cost[_assetClass].cost2, cost[_assetClass].cost3, cost[_assetClass].cost4, 
                cost[_assetClass].cost5, cost[_assetClass].cost6);
    }
   
   
    /*
     * @dev Set function costs per asset class, in Wei
     */
    function _SET_costs (uint16 _assetClass, uint _cost1, uint _cost2, uint _cost3, uint _cost4, uint _cost5, uint _cost6) external onlyOwner {
                            
        cost[_assetClass].cost1 = _cost1;
        cost[_assetClass].cost2 = _cost2;
        cost[_assetClass].cost3 = _cost3;
        cost[_assetClass].cost4 = _cost4;
        cost[_assetClass].cost5 = _cost5;
        cost[_assetClass].cost6 = _cost6;

    }
    
    
    //----------------------------------------external contract functions  //authuser----------------------------------------------------------
    

    
    /*
     * @dev Make a new record in the database  *read fullHash, write registrant, registrars, assetClass,countDownStart --new_record
     */ 
    function newRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _reg, uint16 _assetClass, uint _countDownStart, bytes32 _IPFS1) external addrAuth(3){
       
        
        require(
            registeredUsers[_userHash].userType == 1 || (_assetClass > 8192),
            "NR:ERR-User not registered"
        );
        require(
            (_assetClass == registeredUsers[_userHash].authorizedAssetClass) || (_assetClass > 8192) ,
            "NR:ERR-User not registered for asset class"
        );
        require(
            database[_idxHash].registrant == 0 ,
            "NR:ERR-Record already exists"
        );
        require(
            _reg != 0 ,
            "NR:ERR-Registrant cannot be blank"
        );
        
        database[_idxHash].assetClass = _assetClass;
        database[_idxHash].countDownStart = _countDownStart;
        database[_idxHash].countDown = _countDownStart;
        database[_idxHash].registrar = _userHash;
        database[_idxHash].registrant = _reg;
        database[_idxHash].lastRegistrar = database[_idxHash].registrar;
        database[_idxHash].forceModCount = 0;
        database[_idxHash].IPFS1= _IPFS1;
    }
    
    /*
    * @dev Modify a record in the database  *read fullHash, write registrant, update registrars, assetClass,countDown update registrars,
    *
    *Modifies
        bytes32 registrar; // Address hash of registrar > internal
        bytes32 registrant;  // KEK256 Registered  owner < external
        bytes32 lastRegistrar; //// Address hash of last non-automation registrar > internal
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc. < external
        uint8 forceModCount; // Number of times asset has been forceModded. < external increment only
        uint countDown; // variable that can only be dencreased from countDownStart < external reduction only
    *
    
    bytes32 writeHash = keccak256(abi.encodePacked(_recordHash, userHash, _idxHash, _reg, _status, _countDown, _forceCount));
        
    Storage.modifyRecord(userHash, _idxHash, _regHash, _status, _countDown, _forceCount, writeHash);
    */ 
    function modifyRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _regHash, uint8 _status, uint _countDown, uint8 _forceCount, bytes32 _writeHash) 
                            external addrAuth(3) userAuth (_userHash, _idxHash) exists (_idxHash) unlocked (_idxHash){
                                
        require(
            _writeHash == keccak256(abi.encodePacked(getHash(_idxHash), _userHash, _idxHash, _regHash, _status, _countDown, _forceCount )) ,
            // requires that _writeHash is an identical hash of the oldhash and the new data
            "MR:ERR-record has been changed or sent data invalid"
        );
        require(
            _regHash != 0 ,
            "MR:ERR-Registrant cannot be blank"
        );
        require(
            _countDown <= database[_idxHash].countDown,
            "MR:ERR-new countDown exceeds original countDown"
        );
        require(
            _forceCount >= database[_idxHash].forceModCount,
            "MR:ERR-new forceModCount less than original forceModCount"
        );
        
        database[_idxHash].registrant = _regHash;
        database[_idxHash].status = _status;
        database[_idxHash].countDown = _countDown;
        database[_idxHash].forceModCount = _forceCount;
        lastRegistrar(_userHash, _idxHash);
    }
    
    
    /*
     * @dev modify record IPFS1 data
     */
    function modifyIPFS1 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS1, bytes32 _writeHash) external addrAuth(3) userAuth (_userHash, _idxHash) exists (_idxHash) unlocked (_idxHash) {
        require(
            _writeHash == keccak256(abi.encodePacked(getHash(_idxHash), _userHash, _idxHash, _IPFS1)) ,
            // requires that _writeHash is an identical hash of the oldhash and the new data
            "MR:ERR-record has been changed or sent data invalid"
        );
        require(
            database[_idxHash].IPFS1 != _IPFS1,
            "MIPFS2:ERR-- New IPFS Data identical to old"
        );
        
        
        if (database[_idxHash].IPFS1 != _IPFS1) {
            database[_idxHash].IPFS1 = _IPFS1;
        }
        
        lastRegistrar(_userHash, _idxHash);
    }
    
    
    /*
     * @dev modify record IPFS2 data
     */
    function modifyIPFS2 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS2, bytes32 _writeHash) external addrAuth(3) userAuth (_userHash, _idxHash) exists (_idxHash) unlocked (_idxHash) {
        require(
            _writeHash == keccak256(abi.encodePacked(getHash(_idxHash), _userHash, _idxHash, _IPFS2)) ,
            // requires that _writeHash is an identical hash of the oldhash and the new data
            "MR:ERR-record has been changed or sent data invalid"
        );
        require(
            database[_idxHash].IPFS2 == 0,
            "MIPFS2:ERR-IPFS2 Data already exists and cannot be overwritten"
        );
        
        if (database[_idxHash].IPFS2 == 0) {
            database[_idxHash].IPFS2 = _IPFS2;
        }
        
        lastRegistrar(_userHash, _idxHash);
    }
    
    
 
//----------------------------------------external READ ONLY contract functions  //authuser---------------------------------------------------------- 
 
 

    
    
    /*
     * @dev return abbreviated record
     */
   function retrieveRecord (bytes32 _idxHash) external view addrAuth(2) exists (_idxHash) returns (bytes32, uint8, uint8, uint16, uint, uint, bytes32) {   

        bytes32 idxHash = _idxHash ;  //somehow magically saves the stack.

        return (database[idxHash].registrant, database[idxHash].status, database[idxHash].forceModCount, 
        database[idxHash].assetClass, database[idxHash].countDown, database[idxHash].countDownStart, getHash(idxHash));
    }
    
     /*
     * @dev return abbreviated record
     */
    function retrieveIPFSdata (bytes32 _idxHash) external view addrAuth(2) exists (_idxHash) returns (bytes32, uint8, uint16, bytes32, bytes32, bytes32) {  

        return (database[_idxHash].registrant, database[_idxHash].status,
        database[_idxHash].assetClass, database[_idxHash].IPFS1, database[_idxHash].IPFS2, getHash(_idxHash));
    }
    
    
    /*
     * @dev emit a complete record at _idxHash
     */
    function emitRecord (bytes32 _idxHash) external addrAuth(1) exists (_idxHash) { 
        
        //emit EMIT_RECORD (database[_idx]);  //use when ABIencoder V2 is ready for prime-time
        emit EMIT_RECORD (database[_idxHash].registrar, database[_idxHash].registrant, database[_idxHash].lastRegistrar, database[_idxHash].status, 
                database[_idxHash].forceModCount, database[_idxHash].assetClass, database[_idxHash].countDown, database[_idxHash].countDownStart, 
                database[_idxHash].IPFS1, database[_idxHash].IPFS2);
    }
    
    
    /*
     * @dev return a hash of a record
     */
    function getHash(bytes32 _idxHash) public view addrAuth(2) exists (_idxHash) returns (bytes32) {
    
        return (keccak256(abi.encodePacked(database[_idxHash].registrar, database[_idxHash].registrant, database[_idxHash].lastRegistrar, database[_idxHash].status, 
                database[_idxHash].forceModCount, database[_idxHash].assetClass, database[_idxHash].countDown, database[_idxHash].countDownStart,
                database[_idxHash].IPFS1, database[_idxHash].IPFS2)));
    }
    
    
    
    
    //------------------------------------------------------------private functions-------------------------------------------------------------------
    
     /*
     * @dev Update lastRegistrar
     */ 
    function lastRegistrar(bytes32 _senderHash, bytes32 _idxHash) private exists (_idxHash) {
        
        
        if ( (registeredUsers[database[_idxHash].registrar].userType == 1) || (_senderHash == keccak256(abi.encodePacked(owner()))) 
                        && (_senderHash != database[_idxHash].registrar) ) {     // Rotate last registrar into lastRegistrar field if uniuqe and not a robot
            database[_idxHash].lastRegistrar = database[_idxHash].registrar;
        }
        database[_idxHash].registrar = keccak256(abi.encodePacked(_senderHash));
    }
    
    
     /*
     * @dev Wrapper for comparing records // ------------------------testing
     */
    function XCOMPARE_REG (string calldata _idx, string calldata _reg) external view addrAuth(1) returns(string memory) {
         
        if (keccak256(abi.encodePacked(_reg)) == database[keccak256(abi.encodePacked(_idx))].registrant) {
            return "Registrant match confirmed";
        } else {
            return "Registrant does not match";
        }
    }
    
}