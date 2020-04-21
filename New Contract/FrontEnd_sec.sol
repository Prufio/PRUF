pragma solidity 0.6.0;
//pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract StorageInterface {
    function emitRecord (bytes32 _idxHash) external {}
    function retrieveIPFSdata (bytes32 _idxHash) external returns (bytes32, uint8, uint16, bytes32, bytes32, bytes32) {}
    function retrieveRecord (bytes32 _idxHash) external returns (bytes32, uint8, uint8, uint16, uint, uint, bytes32) {}
    function getHash(bytes32 _idxHash) external returns (bytes32) {}
    function checkOutRecord (bytes32 _idxHash, bytes32 _) external returns (bytes32) {}
    function newRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _reg, uint16 _assetClass, uint _countDownStart, bytes32 _IPFS1) external {}
    function modifyRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _reg, uint8 _status, uint _countDown, uint8 _forceCount, bytes32 _writeHash) external {}
    function modifyIPFS1 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS1, bytes32 _writeHash) external {}
    function modifyIPFS2 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS2, bytes32 _writeHash) external {}
}    
    

contract FrontEnd is Ownable {
    
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
     * @dev Wrapper for retrieveRecord
     */
    function _RETRIEVE_RECORD (string calldata _idx) external returns (bytes32, uint8, uint8, uint16, uint, uint, bytes32) {
        return Storage.retrieveRecord (keccak256(abi.encodePacked(_idx)));
    }
    
    
    /*
     * @dev Wrapper for retrieveIPFSdata
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
    function _NEW_RECORD (string memory _idx, string memory _reg, uint16 _assetClass, uint _countDownStart, string memory _IPFS) public payable {
        Storage.newRecord(keccak256(abi.encodePacked(msg.sender)), keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)),
        _assetClass, _countDownStart, keccak256(abi.encodePacked(_IPFS)));
    }
    
    
    /*
     * @dev Wrapper for ModifyRecord
     */
    //function _MOD_RECORD (bytes32 _idxHash, bytes32 _regHash, uint8 _status, uint _countDown, uint8 _forceCount, bytes32 _recordHash) public payable {
    function _MOD_RECORD (string memory _idx, string memory _reg, uint8 _status, uint _countDown, uint8 _forceCount) public payable { 
        
        bytes32 checkoutKey = keccak256(abi.encodePacked(msg.sender,_idx,_reg,_status,_countDown,_forceCount));
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _regHash = keccak256(abi.encodePacked(_reg));//temp
        
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutKey);//temp until is in function arguments-------------------------------------TESTING  //checkOutRecord
        bytes32 writeHash = keccak256(abi.encodePacked(_recordHash, userHash, _idxHash, _regHash, _status, _countDown, _forceCount));
        
        Storage.modifyRecord(userHash, _idxHash, _regHash, _status, _countDown, _forceCount, writeHash);
        
    }
    
    
    
    /*
     * @dev Wrapper for modifyIPFS1
     */
    //function _MOD_IPFS1 (bytes32 _idxHash, bytes32 _IPFShash, bytes32 _recordHash) public payable {
    function _MOD_IPFS1 (string memory _idx, string memory _IPFS) public payable {
        
        bytes32 checkoutKey = keccak256(abi.encodePacked(msg.sender,_idx,_IPFS));
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _IPFShash = keccak256(abi.encodePacked(_IPFS)); //temp until is in function arguments-------------------------------------TESTING
        
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutKey);//temp until is in function arguments-------------------------------------TESTING  //checkOutRecord
        //bytes32 _recordHash = Storage.getHash(_idxHash);//temp until is in function arguments-------------------------------------TESTING
        bytes32 writeHash = keccak256(abi.encodePacked(_recordHash, userHash, _idxHash, _IPFShash)); 
        
        Storage.modifyIPFS1 (userHash, _idxHash, _IPFShash, writeHash);
    }
    
    
    /*
     * @dev Wrapper for modifyIPFS2
     */
    //function _MOD_IPFS2 (bytes32 _idxHash, bytes32 _IPFShash, bytes32 _recordHash) public payable {
    function _MOD_IPFS2 (string memory _idx, string memory _IPFS) public payable {
        
        bytes32 checkoutKey = keccak256(abi.encodePacked(msg.sender,_idx,_IPFS));
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        bytes32 _idxHash = keccak256(abi.encodePacked(_idx));//temp
        bytes32 _IPFShash = keccak256(abi.encodePacked(_IPFS)); //temp until is in function arguments-------------------------------------TESTING
        
        bytes32 _recordHash = Storage.checkOutRecord(_idxHash, checkoutKey);//temp until is in function arguments-------------------------------------TESTING  //checkOutRecord
        //bytes32 _recordHash = Storage.getHash(_idxHash);//temp until is in function arguments-------------------------------------TESTING
        bytes32 writeHash = keccak256(abi.encodePacked(_recordHash, userHash, _idxHash, _IPFShash)); 
        
        Storage.modifyIPFS2 (userHash, _idxHash, _IPFShash, writeHash);
    }

}