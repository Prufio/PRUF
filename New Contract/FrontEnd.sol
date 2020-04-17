pragma solidity 0.6.0;
//pragma experimental ABIEncoderV2;

import "./Ownable.sol";

contract StorageInterface {
    function emitRecord (bytes32 _idxHash) private {}
    function retrieveIPFSdata (bytes32 _idxHash) private returns (bytes32, uint8, uint16, bytes32, bytes32, bytes32) {}
    function retrieveRecord (bytes32 _idxHash) private returns (bytes32, uint8, uint8, uint16, uint, uint, bytes32) {}
    function getHash(bytes32 _idxHash) private returns (bytes32) {}
    function modifyIPFS1 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS1, bytes32 _writeHash) public {}
    function modifyIPFS2 (bytes32 _userHash, bytes32 _idxHash, bytes32 _IPFS2, bytes32 _writeHash) public {}
    function ModifyRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _reg, uint8 _status, uint _countDown, uint8 _forceCount, bytes32 _writeHash) public {}
    function newRecord(bytes32 _userHash, bytes32 _idxHash, bytes32 _reg, uint16 _assetClass, uint _countDownStart, bytes32 _IPFS1) public {}
}


contract FrontEnd is Ownable {
    
    StorageInterface private Storage; //set up external contract interface
        
    address storageAddress;

    function setStorageContract(address _storageAddress) public onlyOwner { //set storage address
        require(_storageAddress != address(0));
        Storage = StorageInterface(_storageAddress);
    }
    
    
    /*
     * @dev Wrapper for create new record
     */
     
    //function newRecord(address _user, bytes32 _idx, bytes32 _reg, uint16 _assetClass, uint _countDownStart, bytes32 _desc) public {
    function _NEW_RECORD (string memory _idx, string memory _reg, uint16 _assetClass, uint _countDownStart, string memory _desc) public payable {
        Storage.newRecord(msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)), _assetClass, _countDownStart, keccak256(abi.encodePacked(_desc)));
    }
    
    
    /*
     * @dev Wrapper for Asset transfer with tests
     */
    function _TRANSFER_ASSET (string memory _idx, string memory _oldreg, string memory _newreg) public payable {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        Storage.transferAsset(msg.sender, idxHash, keccak256(abi.encodePacked(_oldreg)), keccak256(abi.encodePacked(_newreg)));
    }
    
    
    /*
     * @dev Wrapper for GetHash
     */
    function _GET_HASH(string calldata _idx) external view returns (bytes32){
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        Storage.getHash (msg.sender, idxHash);
    }
    
    
    /*
     * @dev Wrapper for GetHash
     */
    function _EMIT_RECORD(string calldata _idx) external {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        Storage.emitRecord (msg.sender, idxHash);
    }
    
    
    function _RETRIEVE_RECORD(string calldata _idx) external view returns (bytes32, bytes32, bytes32, uint8, uint8, uint16, uint, uint){
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        Storage.retrieveRecord (msg.sender, idxHash);
    }
 
    
}