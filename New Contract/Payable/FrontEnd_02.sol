pragma solidity 0.6.0;
//pragma experimental ABIEncoderV2;

import "./PullPayment.sol";


contract StorageInterface {
    function emitRecord (bytes32 _idxHash) external {}
    function retrieveIPFSdata (bytes32 _idxHash) external returns (bytes32, uint8, uint16, bytes32, bytes32) {}
    function retrieveRecord (bytes32 _idxHash) external returns (bytes32, uint8, uint8, uint16, uint, uint) {}
    function newRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _rgt, uint16 _assetClass, uint _countDownStart, bytes32 _IPFS1) external {}
    function modifyRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _rgt, uint8 _status, uint _countDown, uint8 _forceCount) external {}
    function modifyIPFS (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS1, bytes32 _IPFS2) external {}
    function retrieveRecorder (bytes32 _idxHash) external returns (bytes32, bytes32) {}
    function RETRIEVE_COSTS (uint16 _assetClass) external returns (uint, uint, uint, uint, uint, uint) {}
}    


    

contract FrontEnd is PullPayment, Ownable {
    
    //using SafeMath for uint8;
    using SafeMath for uint;
 
    
    struct Record {
        bytes32 recorder; // Address hash of recorder 
        bytes32 rightsHolder;  // KEK256 Registered  owner
        bytes32 lastRecorder; //// Address hash of last non-automation recorder
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; //Type of asset
        uint countDown; // variable that can only be dencreased from countDownStart
        uint countDownStart; //starting point for countdown variable (set once)
        bytes32 IPFS1; // publically viewable asset description
        bytes32 IPFS2; // publically viewable immutable notes
        uint timeLock; // time sensitive mutex
    }
    
    struct User {
        uint8 userType; // User type: 1 = human, 9 = automated
        uint16 authorizedAssetClass; // asset class in which user is permitted to transact
    }
    
    struct Costs{
        uint NRcost; // Cost to create a new record
        uint TAcost; // Cost to transfer a record from known rights holder to a new one
        uint NOTEcost; // Cost to add a static note to an asset
        uint cost4; // Extra
        uint cost5; // Extra
        uint FMcost; // Cost to brute-force a record transfer
    }
    
    address internal mainWallet;
    
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
     * @dev Set wallet for contract to direct payments to
     */
    function _setMainWallet (address _addr) public onlyOwner {
        mainWallet = _addr;
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
     * @dev Wrapper for newRecord
     */
    function _NEW_RECORD (string memory _idx, string memory _rgt, uint16 _assetClass, uint _countDownStart, string memory _IPFSs) public payable {
        
        Costs memory cost = getCost(1);
        
        require (msg.value >= cost.NRcost, 
        "NR: tx value too low. Send more eth.");
        
        bytes32 senderHash = keccak256(abi.encodePacked(msg.sender));
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));
        bytes32 _IPFS = keccak256(abi.encodePacked(_IPFSs));
        
        Storage.newRecord(senderHash, 
                            _idxHash,
                            _rgtHash,
                            _assetClass, 
                            _countDownStart, 
                            _IPFS);
                            
        deductPayment(cost.NRcost);
        
    }

    
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
    //function _MOD_RECORD (string memory _idx, string memory _rgt, uint8 _status, uint _countDown, uint8 _forceCount) onlyOwner public payable { 
    //    Record memory rec;
    //    bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
    //    bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        
        
    //    rec.rightsHolder = _rgtHash;
    //    rec.status = _status;
    //    rec.forceModCount = _forceCount;
    //    rec.countDown = _countDown;
       
    //    writeRecord (_idxHash, rec);
    //}
    
    
     /*
     * @dev modify **Record**.rightsHolder without confirmation required
     */
    function FORCE_MOD_RECORD (string memory _idx, string memory _rgt) public payable {
        Costs memory cost = getCost(1);
        
        require (msg.value >= cost.FMcost, 
        "FMR: tx value too low. Send more eth.");
        
        Record memory rec;
        
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        
        require( 
            rec.status < 200,
            "FMR:ERR-Record locked"
        );
        if (rec.forceModCount < 255) {
            rec.forceModCount ++;
        }
        rec.rightsHolder = _rgtHash;
        
 
        writeRecord (_idxHash, rec);
        
        deductPayment(cost.FMcost);
    }
    
    
     /*
     * @dev modify **Record**.status with confirmation required
     */
    function MOD_STATUS (string memory _idx, string memory _rgt, uint8 _status) public { 
        Record memory rec;
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
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
        
        writeRecord (_idxHash, rec);
    }
    
    
     /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function DEC_COUNTER (string memory _idx, string memory _rgt, uint _decAmount) public { 
        Record memory rec;
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
      
        rec = getRecord (_idxHash);
        require( 
            rec.status < 200,
            "DC:ERR-Record locked"
        );
        require( 
            rec.rightsHolder == _rgtHash,
            "DC:ERR--Rightsholder does not match supplied data"
        );
        
        if  (rec.countDown > _decAmount){
            rec.countDown = rec.countDown.sub(_decAmount);
        } else {
            rec.countDown = 0;
        }
            
        writeRecord (_idxHash, rec);
    }
    
    
     /*
     * @dev transfer Rights to new rightsHolder with confirmation
     */
    function TRANSFER_ASSET (string memory _idx, string memory _rgt, string memory _newrgt) public payable { 
        Costs memory cost = getCost(1);
        
        require (msg.value >= cost.TAcost, 
        "TA: tx value too low. Send more eth.");
        
        Record memory rec;
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        bytes32 _newrgtHash = keccak256(abi.encodePacked(_newrgt));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
      
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
       
        
        writeRecord (_idxHash, rec);
        
        deductPayment(cost.TAcost);
    }
    
    
    /*
     * @dev modify **Record**.IPFS1 with confirmation
     */
    function MOD_IPFS1 (string memory _idx, string memory _rgt, string memory _IPFS ) public { 
        Record memory rec;
        
        bytes32 _IPFSHash = keccak256(abi.encodePacked(_IPFS));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp
        
        rec = getRecordIPFS (_idxHash);
        require ( 
            rec.status < 200,
            "MI1:ERR-Record locked"
        );
        require ( 
            rec.rightsHolder ==  _rgtHash,
            "MI1:ERR--Rightsholder does not match supplied data"
        );
        require ( 
            rec.IPFS1 !=  _IPFSHash,
            "MI1:ERR--New data same as old"
        );
        
        rec.IPFS1 = _IPFSHash;
        
        writeRecordIPFS (_idxHash, rec);
    }
    
    
    /*
     * @dev modify **Record**.IPFS2 with confirmation
     */
    function CREATE_IPFS2 (string memory _idx, string memory _rgt, string memory _IPFS ) public payable { 
        Costs memory cost = getCost(1);
        
        require (msg.value >= cost.NOTEcost, 
        "tx value too low. Send more eth.");
        Record memory rec;
        
        bytes32 _IPFSHash = keccak256(abi.encodePacked(_IPFS));//temp
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _rgtHash = keccak256(abi.encodePacked(_rgt));//temp

        rec = getRecordIPFS (_idxHash);
        require ( 
            rec.status < 200,
            "MI1:ERR-Record locked"
        );
        require ( 
            rec.rightsHolder ==  _rgtHash,
            "MI1:ERR--Rightsholder does not match supplied data"
        );
        require ( 
            rec.IPFS2 == 0,
            "MI1:ERR--IPFS2 has data already. Overwrite not permitted"
        );
        
        rec.IPFS2 = _IPFSHash;
        
        writeRecordIPFS (_idxHash, rec);
        
        deductPayment(cost.NOTEcost);
    }
    
    function deductPayment (uint _amount) private {
        uint messageValue = msg.value;
        uint change;

        change = messageValue.sub(_amount);
        
        _asyncTransfer(mainWallet, _amount);
        _asyncTransfer(msg.sender, change);
        
    }
    
    function _WITHDRAW() public virtual payable {
        withdrawPayments(msg.sender);
    }
    
     /*
     * @dev Get a Record from Storage @ idxHash
     */
    function getRecord (bytes32 _idxHash) private returns (Record memory) { 
        Record memory rec;
        
        (rec.rightsHolder, rec.status, rec.forceModCount, rec.assetClass, rec.countDown, rec.countDownStart) 
            = Storage.retrieveRecord (_idxHash);//get record from storage contract
            
        return (rec);  //returns Record struct rec and checkout supplied key
    }
    
    
     /*
     * @dev Get an IPFS Record from Storage @ idxHash
     */
    function getRecordIPFS (bytes32 _idxHash) private returns (Record memory) { 
        Record memory rec;
        
        (rec.rightsHolder, rec.status, rec.assetClass, rec.IPFS1, rec.IPFS2) = Storage.retrieveIPFSdata (_idxHash);//get record from storage contract
        
        return (rec);  //returns Record struct rec and checkout supplied key
    }
    
    
    function getRecorders (bytes32 _idxHash) private returns (Record memory) { 
        Record memory rec;

        
        (rec.lastRecorder, rec.recorder) = Storage.retrieveRecorder (_idxHash);//get record from storage contract

        return (rec);  //returns Record struct rec and checkout supplied key
    }
    
    
     /*
     * @dev Write an IPFS Record to Storage @ idxHash
     */
    function writeRecordIPFS (bytes32 _idxHash, Record memory _rec) private {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); //get a userhash for authentication and recorder logging
              Storage.modifyIPFS(userHash,
                            _idxHash,
                            _rec.IPFS1,
                            _rec.IPFS2);  //send datah to storage
    }
    
    
     /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord (bytes32 _idxHash, Record memory _rec) private {
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); //get a userhash for authentication and recorder logging
               Storage.modifyRecord(userHash,
                            _idxHash,
                            _rec.rightsHolder,
                            _rec.status,
                            _rec.countDown,
                            _rec.forceModCount);  //send data and writehash to storage
    }
    
    
    /*
     * @dev Wrapper for getRecord  //does this need to exist in production?????!!!!!!!!!!!!
     */
    function _GET_RECORD (string calldata _idx) external returns (bytes32, uint8, uint8, uint16, uint, uint){
         Record memory rec = getRecord(keccak256(abi.encodePacked(_idx)));
         return (rec.rightsHolder,
                 rec.status,
                 rec.forceModCount,
                 rec.assetClass,
                 rec.countDown,
                 rec.countDownStart);
    }
     
    /*
     * @dev Wrapper for getRecordIPFS  //does this need to exist in production?????!!!!!!!!!!!!
     */ 
    function _GET_RECORD_IPFS (string calldata _idx) external returns (bytes32, uint8, uint16, bytes32, bytes32){
         Record memory rec = getRecordIPFS(keccak256(abi.encodePacked(_idx)));
         return (rec.rightsHolder,
                 rec.status,
                 rec.assetClass,
                 rec.IPFS1,
                 rec.IPFS2);
    }
    
    /*
     * @dev Wrapper for getRecorders  //does this need to exist in production?????!!!!!!!!!!!!
     */ 
    function _GET_RECORDERS (string calldata _idx) external returns (bytes32, bytes32){
         Record memory rec = getRecorders(keccak256(abi.encodePacked(_idx)));
         return (rec.lastRecorder, rec.recorder);
    }
    
    
     /*
     * @dev Wrapper for emitRecord
     */
    function _EMIT_RECORD (string calldata _idx) external {
        Storage.emitRecord (keccak256(abi.encodePacked(_idx)));
    }
    
    function getCost (uint16 _class) private returns(Costs memory) {
        Costs memory cost;
        (cost.NRcost, cost.TAcost, cost.NOTEcost, cost.cost4, cost.cost5, cost.FMcost) = 
        Storage.RETRIEVE_COSTS(_class);
        return (cost);
    }
    
    

}