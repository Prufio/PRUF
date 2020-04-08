pragma solidity ^0.6.0;
 
 import "./BulletProof_0_2_0.sol";
 import "./PullPayment.sol";
 import "./SafeMath.sol";
 
 contract BP_Frontend is BulletProof, PullPayment {
     using SafeMath for uint256;
    
   uint private costUnit = 0.01 ether;
   uint private minEscrowAmount = 0.1 ether;
   address mainWallet = 0xCA35b7d915458EF540aDe6068dFe2F44E8fa733c;
   
    /**
     * @dev Wrapper for create new record
     */
    function NEW_RECORD (uint256 idx, string memory reg, uint8 stat) public payable {
        deductPayment(1);
        newRecord(msg.sender, idx, keccak256(abi.encodePacked(reg)), stat);
    }

    
    /**
     * @dev Wrapper for changing record status with tests
     */
    function MOD_STATUS(uint idx, string memory regstrnt, uint8 stat) public payable {
        deductPayment(1);
        modifyStatus(msg.sender, idx,keccak256(abi.encodePacked(regstrnt)),stat);
    }


    /**
     * @dev Wrapper for Asset transfer with tests
     */
    function TRANSFER_ASSET (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public payable {
        deductPayment(1);
        transferAsset(msg.sender, idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat);
     }


    /**
     * @dev Wrapper for automated Asset transfer with tests
     */
    function PRIVATE_SALE (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public payable {
        deductPayment(1);
        robotTransferAsset(msg.sender, idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat);
    }
    

    
     /**
     * @dev Wrapper for force changing record status
     */
    function FORCE_MOD_STATUS(uint idx, uint8 stat) public payable {
        deductPayment(5);
        forceModifyStatus(msg.sender, idx,stat);
    }
    
    /**
     * @dev Wrapper for force changing the record without tests
     */
    function FORCE_MOD_REGISTRANT (uint256 idx, string memory reg) public payable {
        deductPayment(5);
        modifyRegistrant(msg.sender, idx, keccak256(abi.encodePacked(reg)));
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
     * @dev Deduct payment and transfer cost, change to PullPayment
     */   
    function deductPayment (uint256 amount) public payable {
        address _address = msg.sender;
        uint messageValue = msg.value;
        uint cost = amount.mul(costUnit);
        uint change;
        
        //require (messageValue > 0, "Failed to Accept Payment: no txfr Balance"); 
        require (messageValue >= costUnit.add(minEscrowAmount), "Insufficient Eth");
        
        change = messageValue.sub(cost);
        
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(_address, change);
        
    }
}