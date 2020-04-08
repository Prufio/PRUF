pragma solidity ^0.6.0;
 
 import "./BulletProof_0_1_3.sol";
 import "./PullPayment.sol";
 
 contract BP_Frontend is BulletProof, PullPayment {
    
   uint private costUnit = 0.1 ether;
   address mainWallet = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
    /**
     * @dev Wrapper for create new record
     */
     
    function NEW_RECORD (uint256 idx, string memory reg, uint8 stat) public payable {
       address _address = msg.sender;
       uint messageValue = msg.value;
       uint cost = 1;
       uint change;
       cost = cost * costUnit;
       change = messageValue - cost;
       require (messageValue > 0, "Failed to Accept Payment: no txfr Balance"); 
       require (messageValue >= costUnit, "Failed to accept payment: txfr amount too low");
       
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(_address, change);
        
        newRecord(idx, keccak256(abi.encodePacked(reg)), stat);
    }

    /**
     * @dev Wrapper for comparing records
     */
     
    function COMPARE_REGISTRANT (uint256 idx, string calldata reg) external view returns(string memory) {
         
        if (keccak256(abi.encodePacked(reg)) == database[idx].registrant){
            return "Registrant match confirmed";
        } else {
            return "Registrant does not match";
        }
    }

    /**
     * @dev Wrapper for force changing record status
     */
    
    function FORCE_MOD_STATUS(uint idx, uint8 stat) public payable {
        
       address _address = msg.sender;
       uint messageValue = msg.value;
       uint cost = 1;
       uint change;
       cost = cost * costUnit;
       change = messageValue - cost;
       require (messageValue > 0, "Failed to Accept Payment: no txfr Balance"); 
       require (messageValue >= costUnit, "Failed to accept payment: txfr amount too low");
       
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(_address, change);
        
        forceModifyStatus(idx,stat);
    }
    
    /**
     * @dev Wrapper for force changing the record without tests
     */
     
    function FORCE_MOD_REGISTRANT (uint256 idx, string memory reg) public payable {
         
       address _address = msg.sender;
       uint messageValue = msg.value;
       uint cost = 1;
       uint change;
       cost = cost * costUnit;
       change = messageValue - cost;
       require (messageValue > 0, "Failed to Accept Payment: no txfr Balance"); 
       require (messageValue >= costUnit, "Failed to accept payment: txfr amount too low");
       
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(_address, change);
        
        modifyRegistrant(idx, keccak256(abi.encodePacked(reg)));
    }
    
    
    /**
     * @dev Wrapper for changing record status with tests
     */
    
    function MOD_STATUS(uint idx, string memory regstrnt, uint8 stat) public payable {
         
       address _address = msg.sender;
       uint messageValue = msg.value;
       uint cost = 1;
       uint change;
       cost = cost * costUnit;
       change = messageValue - cost;
       require (messageValue > 0, "Failed to Accept Payment: no txfr Balance"); 
       require (messageValue >= costUnit, "Failed to accept payment: txfr amount too low");
       
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(_address, change);
        
        modifyStatus(idx,keccak256(abi.encodePacked(regstrnt)),stat);
    }

    /**
     * @dev Wrapper for Asset transfer with tests
     */
    
    function TRANSFER_ASSET (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public payable {
         
       address _address = msg.sender;
       uint messageValue = msg.value;
       uint cost = 1;
       uint change;
       cost = cost * costUnit;
       change = messageValue - cost;
       require (messageValue > 0, "Failed to Accept Payment: no txfr Balance"); 
       require (messageValue >= costUnit, "Failed to accept payment: txfr amount too low");
       
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(_address, change);
        
        transferAsset(idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat);
     }


     /**
     * @dev Wrapper for automated Asset transfer with tests
     */

    function PRIVATE_SALE (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public payable {
         
       address _address = msg.sender;
       uint messageValue = msg.value;
       uint cost = 1;
       uint change;
       cost = cost * costUnit;
       change = messageValue - cost;
       require (messageValue > 0, "Failed to Accept Payment: no txfr Balance"); 
       require (messageValue >= costUnit, "Failed to accept payment: txfr amount too low");
       
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(_address, change);
        
        robotTransferAsset(idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat);
     }
}