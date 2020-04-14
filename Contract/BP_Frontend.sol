pragma solidity ^0.6.0;
 
import "./BulletProof_0_2_4.sol";
import "./PullPayment.sol";
 
contract Frontend is BulletProof, PullPayment {
    using SafeMath for uint;
    
    uint public costUnit = 0 ether;
    uint public minEscrowAmount = 0 ether;
    address internal mainWallet;
    

    //-------------------------------SECURITY RISK!!!!!!!!-----------------------------------------
    //-----------!!!!!!!-------------this contract accepts raw strings for hashing. In production,
    //-----------!!!!!!!-------------raw strings of data to be hashed must never be sent to the contract.


    /*
     * @dev Set contract parameters
     */
    function SET_wallet (address _addr) public onlyOwner {
        mainWallet = _addr;
    }
   

    function SET_cost (uint _cost) public onlyOwner {
        costUnit = _cost;
    }
   

    function SET_escrow (uint _escrow) public onlyOwner {
        minEscrowAmount = _escrow;
    }
    

    function SET_USERS(address _authAddr, uint8 userType, uint16 _authorizedAssetClass) public onlyOwner {
        authorize(_authAddr, userType, _authorizedAssetClass);
    }
   

    /*     
     * @dev Wrapper for admin lock record
     */
    function ADMIN_LOCK (string memory _idx) public onlyOwner {
        adminLock(keccak256(abi.encodePacked(_idx)));
    }
    

     /*
     * @dev Wrapper for admin unlock record
     */
    function ADMIN_UNLOCK (string memory _idx) public onlyOwner {
        adminUnlock(keccak256(abi.encodePacked(_idx)));
    }
    
    /*
     * @dev Wrapper for resetForceModCount
     */
    function RESET_FORCEMOD_COUNT (string memory _idx) public onlyOwner {
        resetForceModCount(keccak256(abi.encodePacked(_idx)));
    }
    
    /*
     * @dev Wrapper for decrementCountdown 
     */
    function DECREMENT_COUNTDOWN (string memory _idx, string memory _reg, uint _decrementAmount) public payable {
        
        if (_decrementAmount == 0) {
            _decrementAmount = 1;
        }
        
        decrementCountdown(msg.sender,keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)), _decrementAmount);
        
    }
    /*
     * @dev Wrapper for create new record
     */
    function NEW_RECORD (string memory _idx, string memory _reg, string memory _desc, uint16 _assetClass, uint _countDownStart) public payable {
        deductPayment(5);
        newRecord(msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)), _desc, _assetClass, _countDownStart);
    }
    
    
    /*
     * @dev Wrapper for changing record STATUS with tests
     */
    function MOD_STATUS(string memory _idx, string memory _reg, uint8 _stat) public payable {
        changeStatus(msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)), _stat);
        deductPayment(1);
    }
    
    

    /*
     * @dev Wrapper for Asset transfer with tests
     */
    function TRANSFER_ASSET (string memory _idx, string memory _oldreg, string memory _newreg) public payable {
        deductPayment(5);
        transferAsset(msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_oldreg)), keccak256(abi.encodePacked(_newreg)));
    }

    /*
     * @dev Wrapper for force changing the record without tests
     */
   function CHANGE_DESCRIPTION (string memory _idx, string memory _reg, string memory _desc) public payable {
       changeDescription (msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)), _desc);
       deductPayment(1);
    }
   
    

    /*
     * @dev Wrapper for force changing the record without tests
     */
    function FORCE_MOD_RECORD  (string memory _idx, string memory _reg) public payable {
        deductPayment(10);
        forceModifyRecord(msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)));
    }


    /*
     * @dev wraper for addNote  (with tests)
     */ 
    function ADD_NOTE (string memory _idx, string memory _reg, string memory _note) public payable {
        deductPayment(5); 
        addNote(msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)), _note);
    }

/*
     * @dev Deduct payment and transfer cost, call to PullPayment with msg.sender  *****MAKE pullPayment internal!!!! SECURITY
     */ 
    function WITHDRAW() public virtual payable {
        auth(mainWallet);
        
        withdrawPayments(msg.sender);
    }
 
 
    /*
     * @dev Deduct payment and transfer cost, change to PullPayment
     */   
    function deductPayment (uint _amount) private {
        address addr = msg.sender;
        uint messageValue = msg.value;
        uint cost = _amount.mul(costUnit);
        uint change;
        
        require (messageValue  >= cost.add(minEscrowAmount),
            "DP:ER:14"
        );
        
        change = messageValue.sub(cost);
        
        _asyncTransfer(mainWallet, cost);
        _asyncTransfer(addr, change);
        
    }
    
    /*
     * @dev require authorizations
     */ 
    function auth(address _authAddr) private view {
        uint8 senderType = registeredUsers[keccak256(abi.encodePacked(msg.sender))].userType;
       
        require(
            (senderType == 1) || (senderType == 9) || (msg.sender == _authAddr) ,
            "WITHDRAW:ER:1"
        );
    }


//-----------------READ ONLY FUNCTIONS ----------------SECURITY CHECKS ARE HERE IN FRONTEND

    /*
     * @dev Wrapper for comparing records
     */
    function COMPARE_REGISTRANT (string calldata _idx, string calldata _reg) external view returns(string memory) {
        auth(owner());
         
        if (keccak256(abi.encodePacked(_reg)) == database[keccak256(abi.encodePacked(_idx))].registrant) {
            return "Registrant match confirmed";
        } else {
            return "Registrant does not match";
        }
    }
    
    
    /*
     * @dev Return complete record from datatbase at index idx
     */
    function RETRIEVE_RECORD (string calldata _idx) external view returns (bytes32, bytes32, bytes32, uint8, uint8, string memory, string memory, uint) {
        auth(owner());
        
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        return (database[idxHash].registrar, database[idxHash].registrant, database[idxHash].lastRegistrar, database[idxHash].status, database[idxHash].forceModCount, database[idxHash].description, database[idxHash].note, database[idxHash].countDown);
    }
    
    
    /*
     * @dev check balance at _dest
     */ 
    function BALANCE(address dest) internal view returns (uint) {
        auth(mainWallet);
        
        return payments(dest);
    }
    
}
    