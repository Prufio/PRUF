pragma solidity 0.6.0;

import "./SafeMath.sol";
import "./Ownable.sol";
import "./Address.sol";

 /**
  * @title Escrow
  * @dev Base escrow contract, holds funds designated for a payee until they
  * withdraw them.
  *
  * Intended usage: This contract (and derived escrow contracts) should be a
  * standalone contract, that only interacts with the contract that instantiated
  * it. That way, it is guaranteed that all Ether will be handled according to
  * the `Escrow` rules, and there is no need to check for payable functions or
  * transfers in the inheritance tree. The contract that uses the escrow as its
  * payment method should be its owner, and provide public methods redirecting
  * to the escrow's deposit and withdraw.
  */
contract Escrow is Ownable {
    using SafeMath for uint;
    using Address for address payable;

    event Deposited(address indexed payee, uint weiAmount);
    event Withdrawn(address indexed payee, uint weiAmount);
    event Transferred(address indexed payer, address indexed payee, uint weiAmount);

    mapping(address => uint) private _deposits;

    function depositsOf(address payee) public view returns (uint) {
        return _deposits[payee];
    }

    /**
     * @dev Stores the sent amount as credit to be withdrawn.
     * @param payee The destination address of the funds.
     */
    function deposit(address payee) public virtual payable onlyOwner {
        uint amount = msg.value;
        _deposits[payee] = _deposits[payee].add(amount);

        emit Deposited(payee, amount);
    }

    /**
     * @dev Withdraw accumulated balance for a payee, forwarding all gas to the
     * recipient.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param payee The address whose funds will be withdrawn and transferred to.
     */
    function withdraw(address payable payee) public virtual onlyOwner {
        uint payment = _deposits[payee];

        _deposits[payee] = 0;

        payee.sendValue(payment);

        emit Withdrawn(payee, payment);
    }
    
     /**
     * @dev transfer balances within the escrow._deposits mapping  (NOT IMPLEMENTED)
     *
     * this would potentially be used to pay for registration modifications from the "escrow" account. We dont know if this is safe.
    
    function internalPayment(address payer, address payee, uint payment) private onlyOwner { //make payee olny owner?)
        require(
            _deposits[payer] >= payment,
            "IP: Insuffficient Balance"
        );
        
        _deposits[payer].sub(payment);
        _deposits[payee].add(payment);
        
        emit Transferred(payer, payee, payment);
    }
    */
    
    
    
}