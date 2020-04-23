pragma solidity 0.6.0;
//pragma experimental ABIEncoderV2;

import "./Ownable.sol";
import "./SafeMath.sol";


contract StorageInterface {
    function emitRecord (bytes32 _idxHash) external {}
    function retrieveIPFSdata (bytes32 _idxHash) external returns (bytes32, uint8, uint16, bytes32, bytes32, bytes32) {}
    function retrieveRecord (bytes32 _idxHash) external returns (bytes32, uint8, uint8, uint16, uint, uint, bytes32) {}
    function getHash(bytes32 _idxHash) external returns (bytes32) {}
    function checkOutRecord (bytes32 _idxHash, bytes32 _checkout) external returns (bytes32) {}
    function newRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _rgt, uint16 _assetClass, uint _countDownStart, bytes32 _IPFS1) external {}
    function modifyRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _rgt, uint8 _status, uint _countDown, uint8 _forceCount, bytes32 _writeHash) external {}
    function modifyIPFS1 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS1, bytes32 _writeHash) external {}
    function modifyIPFS2 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS2, bytes32 _writeHash) external {}
}    
    

contract FrontEnd is Ownable {
    
    //using SafeMath for uint8;
    using SafeMath for uint;
 
    
       struct Record {
        bytes32 recorder; // Address hash of recorder 
        bytes32 rightsHolder;  // KEK256 Registered  owner
        bytes32 lastrecorder; //// Address hash of last non-automation recorder
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; //Type of asset
        uint countDown; // variable that can only be dencreased from countDownStart
        uint countDownStart; //starting point for countdown variable (set once)
        bytes32 IPFS1; // publically viewable asset description
        bytes32 IPFS2; // publically viewable immutable notes
        uint timeLock; // time sensitive mutex
        bytes32 checkOut; // checkout number
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
    
        bytes32 _user_;
        bytes32 _idx_;
        bytes32 _ipfs_;
        bytes32 _write_;
    
    
    StorageInterface private Storage; //set up external contract interface
    address storageAddress;
    
     event REPORT (string _msg);


    /*
     * @dev Set storage contract to interface with
     */
    function setStorageContract (address _storageAddress) public onlyOwner { //set storage address
        require(_storageAddress != address(0));
        Storage = StorageInterface(_storageAddress);
    }
    
    
    /*
     * @dev TESTING FUNCTIONS ----------------------------------
     */
    function Get_any_hash (string calldata _idx) external pure returns (bytes32){
        return keccak256(abi.encodePacked(_idx));
    }
    
    function Get_block () external view returns (bytes32){
        return keccak256(abi.encodePacked(block.number));
    }
    
  
//-----------------------------------------------------------External functions-----------------------------------------------------------
//SECURITY NOTE: MANY of these functions take strings. in production, all strings would be converted to hashes before being sent to the contract
//so these funtions would be accepting pre-hashed bytes32 instead of strings.
    /*
      ----------write a data thing pattern:
    * have data
    * get a record #hash from Storage using Storage.getHash(idxHash)
    * get a Record struct using getRecord(idxHash)
    * check out the record with the new / old data --
    * make a unuiqe ID from the data being sent
    * check out the record using newRecordHash = Storage.checkOutRecord(_idxHash, _checkoutID);
    * bytes32 key = keccak256(abi.encodePacked(block.number, checkoutID));
    * verify that the earlier record #hash hashed with the key matches newRecordHash 
    * write the modified Record struct (_rec) with the recordHash using writeRecord (idxHash, _rec, recordHash)
    */
    
    
    /*
     * @dev modify **Record**.rightsHolder,status,countdown,and forcecount without confirmation required 
     */
    function _MOD_RECORD (string memory _idx, string memory _rgt, uint8 _status, uint _countDown, uint8 _forceCount) onlyOwner public payable { 
        Record memory rec;
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        
        bytes32 checkoutID = keccak256(abi.encodePacked(msg.sender,_idxHash,_rgtHash,_status,_countDown,_forceCount)); //make a unuiqe ID from the data being sent
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutID);// checks out record with ID 
        
        rec.rightsHolder = _rgtHash;
        rec.status = _status;
        rec.forceModCount = _forceCount;
        rec.countDown = _countDown;
       
        writeRecord (_idxHash, rec, _recordHash);
    }
    
     /*
     * @dev modify **Record**.rightsHolder without confirmation required
     */
    function FORCE_MOD_RECORD (string memory _idx, string memory _rgt) public payable { 
        Record memory rec;
        
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        
        bytes32 cleanHash = Storage.getHash(_idxHash);
        rec = getRecord (_idxHash);
        require( 
            rec.status < 200,
            "FMR:ERR-Record locked"
        );
        if (rec.forceModCount < 255) {
            rec.forceModCount ++;
        }
        rec.rightsHolder = _rgtHash;
        
        bytes32 checkoutID = keccak256(abi.encodePacked(msg.sender,_idxHash, rec.rightsHolder, rec.status, rec.countDown, rec.forceModCount)); //make a unuiqe ID from the data being sent
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutID);// checks out record with ID 
        bytes32 key = keccak256(abi.encodePacked(block.number, checkoutID));
        require ( 
            _recordHash == keccak256(abi.encodePacked(cleanHash,key)),
            "FMR:ERR--record does not match"
        );
        
        writeRecord (_idxHash, rec, _recordHash);
    }
    
     /*
     * @dev modify **Record**.status with confirmation required
     */
    function MOD_STATUS (string memory _idx, string memory _rgt, uint8 _status) public payable { 
        Record memory rec;
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
      
        bytes32 cleanHash = Storage.getHash(_idxHash);
        rec = getRecord (_idxHash);
        require( 
            rec.status < 200,
            "MS:ERR-Record locked"
        );
        require( 
            rec.rightsHolder == _rgtHash,
            "MS:ERR-Rightsholder does not match supplied data"
        );
        
        rec.status = _status;
        
        bytes32 checkoutID = keccak256(abi.encodePacked(msg.sender,_idxHash, rec.rightsHolder, rec.status, rec.countDown, rec.forceModCount)); //make a unuiqe ID from the data being sent
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutID);// checks out record with ID 
        bytes32 key = keccak256(abi.encodePacked(block.number, checkoutID));
        require ( 
            _recordHash == keccak256(abi.encodePacked(cleanHash,key)),
            "MS:ERR--record does not match"
        );
        
        writeRecord (_idxHash, rec, _recordHash);
    }
    
     /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function DEC_COUNTER (string memory _idx, string memory _rgt, uint _decAmount) public payable { 
        Record memory rec;
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
      
        bytes32 cleanHash = Storage.getHash(_idxHash);
        rec = getRecord (_idxHash);
        require( 
            rec.status < 200,
            "DC:ERR-Record locked"
        );
        require( 
            rec.rightsHolder == _rgtHash,
            "DC:ERR-Rightsholder does not match supplied data"
        );
        
        if  (rec.countDown > _decAmount){
            rec.countDown = rec.countDown.sub(_decAmount);
        } else {
            rec.countDown = 0;
        }
            
        bytes32 checkoutID = keccak256(abi.encodePacked(msg.sender,_idxHash, rec.rightsHolder, rec.status, rec.countDown, rec.forceModCount)); //make a unuiqe ID from the data being sent
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutID);// checks out record with ID 
        bytes32 key = keccak256(abi.encodePacked(block.number, checkoutID));
        require ( 
            _recordHash == keccak256(abi.encodePacked(cleanHash,key)),
            "DC:ERR--record does not match"
        );
        
        writeRecord (_idxHash, rec, _recordHash);
    }
    
     /*
     * @dev transfer Rights to new rightsHolder with confirmation
     */
    function TRANSFER_ASSET (string memory _idx, string memory _rgt, string memory _newrgt) public payable { 
        Record memory rec;
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        bytes32 _newrgtHash = keccak256(abi.encodePacked(_newrgt));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
      
        bytes32 cleanHash = Storage.getHash(_idxHash);
        rec = getRecord (_idxHash);
        require( 
            rec.status < 200,
            "TA:ERR-Record locked"
        );
        require( 
            rec.rightsHolder == _rgtHash,
            "DC:ERR-Rightsholder does not match supplied data"
        );
        require( 
            _newrgtHash != 0,
            "TA:ERR-new Rightsholder cannot be blank"
        );
        require( 
            rec.status < 3,
            "TA:ERR--Asset status is not transferrable"
        );
        
        rec.rightsHolder = _newrgtHash;
       
        bytes32 checkoutID = keccak256(abi.encodePacked(msg.sender,_idxHash, rec.rightsHolder, rec.status, rec.countDown, rec.forceModCount)); //make a unuiqe ID from the data being sent
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutID);// checks out record with ID 
        bytes32 key = keccak256(abi.encodePacked(block.number, checkoutID));
        require ( 
            _recordHash == keccak256(abi.encodePacked(cleanHash,key)),
            "DC:ERR--record does not match"
        );
        
        writeRecord (_idxHash, rec, _recordHash);
    }
    
   
     /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord (bytes32 _idxHash) private returns (Record memory) { 
        Record memory rec;
        bytes32 datahash;
        
        (rec.rightsHolder, rec.status, rec.forceModCount, rec.assetClass, rec.countDown, rec.countDownStart, datahash) 
            = Storage.retrieveRecord (_idxHash);//get record from storage contract
            
        require (
            keccak256(abi.encodePacked(rec.rightsHolder, rec.status, rec.forceModCount, rec.assetClass, rec.countDown, rec.countDownStart)) == datahash,
            "GR:ERR--Hash does not match passed data"
        );
        return (rec);  //returns Record struct rec and checkout supplied key
    }
    
    
     /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord (bytes32 _idxHash, Record memory _rec, bytes32 _recordHash) private {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); //get a userhash for authentication and recorder logging
        bytes32 writeHash = keccak256(abi.encodePacked(_recordHash, userHash, _idxHash, _rec.rightsHolder, _rec.status, _rec.countDown, _rec.forceModCount)); //prepare a writehash with existing data , blocknumber, checkout key, and new data for authentication
        Storage.modifyRecord(userHash, _idxHash, _rec.rightsHolder, _rec.status, _rec.countDown, _rec.forceModCount, writeHash);  //send data and writehash to storage
    }
    

    
     /*
     * @dev Wrapper for retrieveRecord  //does this need to exist in production?????!!!!!!!!!!!!
     */
    function _RETRIEVE_RECORD (string calldata _idx) external returns (bytes32, uint8, uint8, uint16, uint, uint, bytes32) {
        return Storage.retrieveRecord (keccak256(abi.encodePacked(_idx)));
    }
    
    
    
    /*
     * @dev Wrapper for retrieveIPFSdata //does this need to exist in production?????!!!!!!!!!!!!
     */
    function _GET_IPFS (string calldata _idx) external returns (bytes32, uint8, uint16, bytes32, bytes32, bytes32) {
        return Storage.retrieveIPFSdata (keccak256(abi.encodePacked(_idx)));
    }
    
    
    /*
     * @dev Wrapper for GetHash
     */
    function _GET_HASH (string calldata _idx) external returns (bytes32){
        return Storage.getHash (keccak256(abi.encodePacked(_idx)));
    }
    
    
     /*
     * @dev Wrapper for emitRecord
     */
    function _EMIT_RECORD (string calldata _idx) external {
        Storage.emitRecord (keccak256(abi.encodePacked(_idx)));
    }
    
    
    /*
     * @dev Wrapper for newRecord
     */
    function _NEW_RECORD (string memory _idx, string memory _rgt
    , uint16 _assetClass, uint _countDownStart, string memory _IPFS) public payable {
        Storage.newRecord(keccak256(abi.encodePacked(msg.sender)), keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_rgt)),
        _assetClass, _countDownStart, keccak256(abi.encodePacked(_IPFS)));
    }
    
   
    /*
     * @dev Wrapper for modifyIPFS1
     */
    //function _MOD_IPFS1 (bytes32 _idxHash, bytes32 _IPFShash, bytes32 _recordHash) public payable {
    function _MOD_IPFS1 (string memory _idx, string memory _IPFS) public payable {
        
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _IPFShash = keccak256(abi.encodePacked(_IPFS)); //temp until is in function arguments-------------------------------------TESTING
        
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); //get a userhash for authentication and recorder logging
        bytes32 checkoutKey = keccak256(abi.encodePacked(msg.sender,_idxHash,_IPFShash)); //make a unuiqe ID from the data being sent
        
       
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutKey);
        //checks out record with keytemp until is in function arguments-------------------------------------TESTING  //checkOutRecord
        
        bytes32 writeHash = keccak256(abi.encodePacked(_recordHash, userHash, _idxHash, _IPFShash)); 
        //prepare a writehash with existing data , blocknumber, checkout key, and new data for authentication
        
        Storage.modifyIPFS1 (userHash, _idxHash, _IPFShash, writeHash); //send data and writehash to storage
    }
    
    
    /*
     * @dev Wrapper for modifyIPFS2
     */
    //function _MOD_IPFS2 (bytes32 _idxHash, bytes32 _IPFShash, bytes32 _recordHash) public payable {
    function _MOD_IPFS2 (string memory _idx, string memory _IPFS) public payable {
        
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _IPFShash = keccak256(abi.encodePacked(_IPFS)); //temp until is in function arguments-------------------------------------TESTING
        
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); //get a userhash for authentication and recorder logging
        bytes32 checkoutKey = keccak256(abi.encodePacked(msg.sender,_idxHash,_IPFShash)); //make a unuiqe ID from the data being sent
        
       
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutKey);
        //checks out record with keytemp until is in function arguments-------------------------------------TESTING  //checkOutRecord
        
        bytes32 writeHash = keccak256(abi.encodePacked(_recordHash, userHash, _idxHash, _IPFShash)); 
        //prepare a writehash with existing data , blocknumber, checkout key, and new data for authentication
        
        Storage.modifyIPFS2 (userHash, _idxHash, _IPFShash, writeHash);
    }

}