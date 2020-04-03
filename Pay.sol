pragma solidity 0.6.0;
 
 import "./Ownable.sol";
 
 contract Pay is Ownable {
 
 uint regFee = 0.001 ether;

function pay() external payable {
        require(
            msg.value >= regFee ,
            "Insufficient funds transfered"
        );
            
        
        msg.sender.transfer(msg.value - regFee);
    }
    
      function setRegFee(uint _fee) external onlyOwner {
    regFee = _fee;
    }
}