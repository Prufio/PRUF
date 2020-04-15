pragma solidity 0.6.0;
 
import "./BulletProof_0_2_4.sol";
import "./PullPayment.sol";
 
contract Frontend is BulletProof, PullPayment {
    using SafeMath for uint;
    
    uint public minEscrowAmount = 0 ether;
    address internal mainWallet;
    

    //-------------------------------SECURITY RISK!!!!!!!!-----------------------------------------
    //-----------!!!!!!!-------------this contract accepts raw strings for hashing. In production,
    //-----------!!!!!!!-------------raw strings of data to be hashed must never be sent to the contract.


    /*
     * @dev Set main payment wallet
     */
    function _SET_wallet (address _addr) public onlyOwner {
        mainWallet = _addr;
    }
   
    /*
     * @dev Set function costs per asset class, in Wei
     */
    function _SET_costs (uint16 _assetClass, uint _newRecord, uint _modStatus, uint _transferAsset, 
                        uint _changeDescription, uint _decrementCountdown, uint _forceMod, uint _addNote) public onlyOwner {
                            
        cost[_assetClass].newRecord = _newRecord;
        cost[_assetClass].modStatus = _modStatus;
        cost[_assetClass].transferAsset = _transferAsset;
        cost[_assetClass].changeDescription = _changeDescription;
        cost[_assetClass].decrementCountdown = _decrementCountdown;
        cost[_assetClass].forceMod = _forceMod;
        cost[_assetClass].addNote = _addNote;
    }
    
   
    /*
     * @dev Set escrow cost, in Wei
     */
    function _SET_escrow (uint _escrow) public onlyOwner {
        minEscrowAmount = _escrow;
    }
    

    function _SET_USERS(address _authAddr, uint8 userType, uint16 _authorizedAssetClass) public onlyOwner {
        authorize(_authAddr, userType, _authorizedAssetClass);
    }
   

    /*     
     * @dev Wrapper for admin lock record
     */
    function _ADMIN_LOCK (string memory _idx) public onlyOwner {
        adminLock(keccak256(abi.encodePacked(_idx)));
    }
    

     /*
     * @dev Wrapper for admin unlock record
     */
    function _ADMIN_UNLOCK (string memory _idx) public onlyOwner {
        adminUnlock(keccak256(abi.encodePacked(_idx)));
    }
    
    /*
     * @dev Wrapper for resetForceModCount
     */
    function _RESET_FORCEMOD_COUNT (string memory _idx) public onlyOwner {
        resetForceModCount(keccak256(abi.encodePacked(_idx)));
    }
    
    
    /*
     * @dev Wrapper for create new record
     */
    function NEW_RECORD (string memory _idx, string memory _reg, string memory _desc, uint16 _assetClass, uint _countDownStart) public payable {
        newRecord(msg.sender, keccak256(abi.encodePacked(_idx)), keccak256(abi.encodePacked(_reg)), _desc, _assetClass, _countDownStart);
        deductPayment(cost[_assetClass].newRecord);
    }
    
    
    /*
     * @dev Wrapper for changing record STATUS with tests
     */
    function MOD_STATUS(string memory _idx, string memory _reg, uint8 _stat) public payable {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        changeStatus(msg.sender, idxHash, keccak256(abi.encodePacked(_reg)), _stat);
        deductPayment(cost[ database[idxHash].assetClass].modStatus);
    }
    
    

    /*
     * @dev Wrapper for Asset transfer with tests
     */
    function TRANSFER_ASSET (string memory _idx, string memory _oldreg, string memory _newreg) public payable {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        transferAsset(msg.sender, idxHash, keccak256(abi.encodePacked(_oldreg)), keccak256(abi.encodePacked(_newreg)));
        deductPayment(cost[ database[idxHash].assetClass].transferAsset);
    }

    /*
     * @dev Wrapper for force changing the record without tests
     */
   function CHANGE_DESCRIPTION (string memory _idx, string memory _reg, string memory _desc) public payable {
       bytes32 idxHash = keccak256(abi.encodePacked(_idx));
       changeDescription (msg.sender, idxHash, keccak256(abi.encodePacked(_reg)), _desc);
       deductPayment(cost[ database[idxHash].assetClass].changeDescription);
    }
    
    
    /*
     * @dev Wrapper for decrementCountdown with tests
     */
    function DECREMENT_COUNTDOWN (string memory _idx, string memory _reg, uint _decrementAmount) public payable {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        decrementCountdown(msg.sender,idxHash, keccak256(abi.encodePacked(_reg)), _decrementAmount);
        deductPayment(cost[ database[idxHash].assetClass].decrementCountdown);
    }
    

    /*
     * @dev Wrapper for force changing the record without tests
     */
    function FORCE_MOD_RECORD  (string memory _idx, string memory _reg) public payable {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        forceModifyRecord(msg.sender, idxHash, keccak256(abi.encodePacked(_reg)));
        deductPayment(cost[ database[idxHash].assetClass].forceMod);
    }


    /*
     * @dev wraper for addNote  (with tests)
     */ 
    function ADD_NOTE (string memory _idx, string memory _reg, string memory _note) public payable {
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        addNote(msg.sender, idxHash, keccak256(abi.encodePacked(_reg)), _note);
        deductPayment(cost[ database[idxHash].assetClass].addNote);
    }

/*
     * @dev Deduct payment and transfer cost, call to PullPayment with msg.sender  *****MAKE pullPayment internal!!!! SECURITY
     */ 
    function _WITHDRAW() public virtual payable {
        auth(mainWallet);
        
        withdrawPayments(msg.sender);
    }
 
 
    /*
     * @dev Deduct payment and transfer cost, change to PullPayment
     */   
    function deductPayment (uint _amount) private {
        uint messageValue = msg.value;
        uint change;
        
        require (messageValue  >= _amount.add(minEscrowAmount),
            "DP:ER:14"
        );
        
        change = messageValue.sub(_amount);
        
        _asyncTransfer(mainWallet, _amount);
        _asyncTransfer(msg.sender, change);
        
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
    function XCOMPARE_REGISTRANT (string calldata _idx, string calldata _reg) external view returns(string memory) {
        auth(owner());
         
        if (keccak256(abi.encodePacked(_reg)) == database[keccak256(abi.encodePacked(_idx))].registrant) {
            return "Registrant match confirmed";
        } else {
            return "Registrant does not match";
        }
    }
    
    
    /*
     * @dev Return complete record from datatbase at index idx
    struct Record {
        bytes32 registrar; // Address hash of registrar 
        bytes32 registrant;  // KEK256 Registered  owner
        bytes32 lastRegistrar; //// Address hash of last non-automation registrar
        uint8 status; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; //Type of asset
        uint countDown; // variable that can only be dencreased from countDownStart
        uint countDownStart; //starting point for countdown variable (set once)
        string description; // publically viewable asset description
        string note; // publically viewable immutable notes
    }
     */
    function XRETRIEVE_RECORD (string calldata _idx) external view returns (bytes32, bytes32, bytes32, uint8, uint8, uint16, uint, uint, string memory, string memory) {
        //auth(owner());
        
        bytes32 idxHash = keccak256(abi.encodePacked(_idx));
        return (database[idxHash].registrar, database[idxHash].registrant, database[idxHash].lastRegistrar, database[idxHash].status, 
                database[idxHash].forceModCount, database[idxHash].assetClass, database[idxHash].countDown, database[idxHash].countDownStart, 
                database[idxHash].description, database[idxHash].note);
    }
    
    /*
     * @dev Return function costs for asset type 
    struct Costs{
        uint newRecord;
        uint modStatus;
        uint transferAsset;
        uint changeDescription;
        uint decrementCountdown;
        uint forceMod;
        uint addNote;
    }
     */
    function XRETRIEVE_COSTS (uint16 _assetClass) external view returns (uint, uint, uint, uint, uint, uint, uint) {
        auth(owner());

        return (cost[_assetClass].newRecord, cost[_assetClass].modStatus, cost[_assetClass].transferAsset, cost[_assetClass].changeDescription, 
                cost[_assetClass].decrementCountdown, cost[_assetClass].forceMod, cost[_assetClass].addNote );
    }
    
    
    /*
     * @dev check balance at _dest
     */ 
    function XBALANCE(address dest) public view returns (uint) {
        auth(mainWallet);
        
        return payments(dest);
    }
    
}
    