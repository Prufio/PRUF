pragma solidity ^0.6.0;

    /*****
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
     * 9 = authorized for automation function
     * 
     * A Status 5 authorizes private sales, in which an point of sale app can verify that the "seller" can verify his/her
     * 
     * 
     */

import "./BP_Storage.sol";
import "./SafeMath.sol";

contract BulletProof is Storage {
    using SafeMath for uint8;
    using SafeMath for uint;
    
    /*
     * @dev Authorize / Deauthorize / Authorize automation for an address be permitted to make record modifications
     * ----------------INSECURE -- keccak256 of address must be generated clientside in release.
     */
    function authorize(address _authAddr, uint8 userType) internal onlyOwner {
      
        require((userType == 0)||(userType == 1)||(userType == 9) ,
        "AUTH: Usertype must be 1(human) 9(robot) or 0(unauthorized)"
        );
        
        bytes32 hash;
        hash = keccak256(abi.encodePacked(_authAddr));
        registeredUsers[hash].userType = userType;
    }
    
    
    /*
     * @dev Administrative lock a database entry at index idx
     */
    function adminLock(bytes32 _idx) internal onlyOwner {
        
        require(
            database[_idx].registrant != 0 ,
            "AL: No Record exists to modify"
        );
        require(
            database[_idx].status != 255 ,
            "AL: Record already locked"
        );
 
 
        database[_idx].status = 255;
        database[_idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    
    /*
     * @dev Administrative unlock a database entry at index idx
     */
    function adminUnlock(bytes32 _idx) internal onlyOwner {
        
        require(
            database[_idx].registrant != 0 ,
            "AU: No Record exists to modify"
        );
        require(
            database[_idx].status == 255 ,
            "AU: Record not locked"
        );
        
        
        database[_idx].status = 2;
        database[_idx].registrar = keccak256(abi.encodePacked(msg.sender));
    }
    
    
    /*
     * @dev Administrative reset of forceModCount to zero
     * Relies on onlyOwner from frontend
     */
    function resetForceModCount(bytes32 _idx) internal onlyOwner {
        require(
            database[_idx].registrant != 0 ,
            "RFMC: No Record exists to modify"
        );
        require(
            database[_idx].status != 255 ,
            "RFMC: Record locked"
        );
        require(
            database[_idx].forceModCount != 0 ,
            "RFMC: fmc is already 0"
        );
        
        
        database[_idx].forceModCount = 0;
    }


    /*
     * @dev Store a complete record at index idx
     */
    function newRecord(address _sender, bytes32 _idx, bytes32 _reg, string memory _desc, uint _countDownStart) internal {
       
        require(
            registeredUsers[keccak256(abi.encodePacked(_sender))].userType == 1 ,
            "NR: Address not authorized"
        );
        require(
            database[_idx].registrant == 0 ,
            "NR: Record already exists"
        );
        require(
            _reg != 0 ,
            "NR: Registrant cannot be empty"
        );
        
        database[_idx].countDownStart = _countDownStart;
        database[_idx].countDown = _countDownStart;
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].registrant = _reg;
        database[_idx].lastRegistrar = database[_idx].registrar;
        database[_idx].forceModCount = 0;
        database[_idx].description = _desc;
    }

    
    /*
     * @dev Store a permanant note at index idx
     */
        function addNote(address _sender, bytes32 _idx, bytes32 _reg, string memory _note) internal {
       
        require(
            registeredUsers[keccak256(abi.encodePacked(_sender))].userType == 1 ,
            "AN: Address not authorized"
        );
        require(
            database[_idx].registrant != 0 ,
            "AN: No Record exists to modify"
        );
        require(
            database[_idx].registrant == _reg ,
            "AN: Records do not match - record change aborted"
        );
        require(
            database[_idx].status != 255 ,
            "AN: Record locked"
        );
        require(
            keccak256(abi.encodePacked(database[_idx].note)) == keccak256(abi.encodePacked("")),
            "AN: Record note already exists"
        );
        
        lastRegistrar(_sender, _idx);


        database[_idx].note = _note;
    }
    

    /*
     * @dev force modify registrant at index idx
     */
    function forceModifyRecord(address _sender, bytes32 _idx, bytes32 _reg) internal {
       
        require(
            registeredUsers[keccak256(abi.encodePacked(_sender))].userType == 1  ,
            "FMR: Address not authorized"
        );
        require(
            database[_idx].registrant != 0 ,
            "FMR: No Record exists to modify"
        );
        require(
            database[_idx].status != 255 ,
            "FMR: Record locked"
        );
        require(
            _reg != 0 ,
            "FMR: Registrant cannot be empty"
        );
        require(
            database[_idx].registrant != _reg ,
            "FMR: New record is identical to old record"
        );
        
        uint8 count = database[_idx].forceModCount;
        
        if (count < 255) {
            count.add(1);
        }
        
        lastRegistrar(_sender, _idx);
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].registrant = _reg;
        database[_idx].forceModCount = count;
    }
    
    
    /*
     * @dev Modify TRANSFER record REGISTRANT and STATUS with test for match to old record
     */
    function transferAsset (address _sender, bytes32 _idx, bytes32 _oldreg, bytes32 _newreg) internal {
        uint8 senderType = registeredUsers[keccak256(abi.encodePacked(_sender))].userType;
       
        require(
            (senderType == 1) || (senderType == 9) ,
            "TA: Address not authorized"
        );
        require(
            database[_idx].registrant != 0 ,
            "TA: No Record exists to modify"
        );
        require(
            database[_idx].registrant == _oldreg ,
            "TA: Records do not match - record change aborted"
        );
        require(
            database[_idx].status != 255 ,
            "TA: Record locked"
        );
        require(
            database[_idx].status != 2 ,
            "TA: Asset marked nontransferrable"
        );
        require(
            database[_idx].status != 3 ,
            "TA: Asset reported stolen"
        );
        require(
            database[_idx].status != 4 ,
            "TA: Asset reported lost"
        );
        require(
            (database[_idx].status == 0) || (database[_idx].status == 1) ,
            "TA: Tranfer prohibited"
        );
        require(
            _newreg != 0 ,
            "TA: Registrant cannot be empty"
        );
        require(
            database[_idx].registrant != _newreg ,
            "TA: New record is identical to old record"
        );
        
        lastRegistrar(_sender, _idx);
    
    
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].registrant = _newreg;
    }
    
    
    /*
     * @dev decrements from current value of countDown in database. Starting value of countDown set on record creation
     */
    function decrementCountdown (address _sender, bytes32 _idx, bytes32 _reg, uint _decrementAmount) internal {
        
        uint8 senderType = registeredUsers[keccak256(abi.encodePacked(_sender))].userType;
        
        require(
            database[_idx].status != 255 ,
            "TA: Record locked"
        );
        require(
            (senderType == 1) || (senderType == 9) ,
            "TA: Address not authorized"
        );
        require(
            database[_idx].registrant != 0 ,
            "TA: No Record exists to modify"
        );
        require(
            database[_idx].registrant == _reg ,
            "TA: Records do not match - record change aborted"
        );
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].countDown.sub(_decrementAmount);
    }

     
    /*
     * @dev Modify record STATUS with test for match to old record
     */
    function changeStatus (address _sender, bytes32 _idx, bytes32 _oldreg, uint8 _newstat) internal {
        uint8 senderType = registeredUsers[keccak256(abi.encodePacked(_sender))].userType;
       
        require(
            (senderType == 1) || (senderType == 9) ,
            "CS: Address not authorized"
        );
        require(
            database[_idx].registrant != 0 ,
            "CS: No Record exists to modify"
        );
        require(
            database[_idx].registrant == _oldreg ,
            "CS: Records do not match - record change aborted"
        );
        require(
            database[_idx].status != 255 ,
            "CS: Record locked"
        );
        require(
            _newstat != 255 ,
            "CS: locking by user prohibited"
        );
        
        lastRegistrar(_sender, _idx);
        
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].status = _newstat;
    }
     

    /*
     * @dev user modify record DESCRIPTION with test for match to old record
     */
    function changeDescription (address _sender, bytes32 _idx, bytes32 _reg, string memory _desc) internal {
        uint8 senderType = registeredUsers[keccak256(abi.encodePacked(_sender))].userType;
        
        require(
            (senderType == 1) || (senderType == 9) ,
            "CD: Address not authorized"
        );
        require(
            database[_idx].registrant != 0 ,
            "CD: No Record exists to modify"
        );
        require(
            database[_idx].registrant == _reg ,
            "CD: Records do not match - record change aborted"
        );
        require(
            database[_idx].status != 255 ,
            "CD: Record locked"
        );
        
        lastRegistrar(_sender, _idx);
        
        
        database[_idx].registrar = keccak256(abi.encodePacked(_sender));
        database[_idx].description = _desc;
    }
    
     
    /*
     * @dev Update lastRegistrant
     */ 
    function lastRegistrar(address _sender, bytes32 _idx) internal {
        bytes32 senderHash = keccak256(abi.encodePacked(_sender));
        
        if ((registeredUsers[database[_idx].registrar].userType == 1) && (senderHash != database[_idx].registrar)) {     // Rotate last registrar
                                                                                                                //into lastRegistrar field if uniuqe and not a robot
                                                                                                
            database[_idx].lastRegistrar = database[_idx].registrar;
        }
    }
}
