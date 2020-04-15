pragma solidity 0.6.0;

import "./Ownable.sol";
/*
 */
 
 
contract StorageInterface {
    
        function SET_Data (uint8 _idx, uint8 _value) public returns(uint8) {}
        
        function GET_Data (uint8 _idx) public view returns (uint8) {}
}
 
 
 
contract Front is Ownable {
        
    
        
    StorageInterface private Storage; //set up external contract interface
        
    address storageAddress;
        
    event resultOut (uint8 indexed result);   

    function setStorageAddress(address _storageAddress) public onlyOwner { //set storage address
        require(_storageAddress != address(0));
        Storage = StorageInterface(_storageAddress);
    }
        
    function SET(uint8 _idx, uint8 _value) public returns (uint8) {
        
        uint8 result  = Storage.SET_Data(_idx,_value);  // access contract function located in other contract
        return result;
    }
    
    function GET (uint8 _idx) public returns (uint8) {
        uint8 result  = Storage.GET_Data(_idx);  // access contract function located in other contract
        emit resultOut(result);
        return result;
    }
    
    //function isAuthorized (address _addr) public onlyOwner {

    //}
    
}