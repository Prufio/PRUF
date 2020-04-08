pragma solidity ^0.6.0;

import "./PullPayment.sol";

contract PaymentProcessor is PullPayment {
    
   uint private costUnit = 0.1 ether;
   address mainWallet = 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C;
   
   function notPayable () pure internal returns (uint8) {
       uint8 test = 2;
       return test; 
   }
    
   function acceptPayment () public payable {
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
        
        uint8 _test = notPayable();
   } 
}