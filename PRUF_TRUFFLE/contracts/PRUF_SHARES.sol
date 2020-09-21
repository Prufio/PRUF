/*-----------------------------------------------------------V0.7.0
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/Ownable.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/utils/Address.sol";
import "./Imports/payment/escrow/Escrow.sol";

contract SHARES is ReentrancyGuard, Ownable, Pausable {

    Escrow private _escrow;

    constructor () internal {
        _escrow = new Escrow();
    }

    using Address for address payable;
    using SafeMath for uint256;

    address internal SHAR_TKN_Address;
    SHAR_TKN_Interface internal SHAR_TKN;

    address internal STOR_Address;
    STOR_Interface internal STOR;

uint256 private maxSupply =  100;  //set max supply (100000?)
uint256 private payPeriod =  5 minutes;  //set to 30 days

uint256 private nextPayDay = block.timestamp.add(payPeriod);
uint256 private lastPayDay = block.timestamp;

uint256 private newBalance;

uint256 private newDividend;

uint256 internal held;

mapping(uint256 => uint256) private tokenPaymentDate; // Main Data Storage


    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "B:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR = STOR_Interface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }


    /*
     * @dev Resolve Contract Addresses from STOR
     */
    function OO_resolveContractAddresses()
        external
        onlyOwner
    {
        //^^^^^^^checks^^^^^^^^^

        SHAR_TKN_Address = STOR.resolveContractAddress("SHAR_TKN");
        SHAR_TKN = SHAR_TKN_Interface(SHAR_TKN_Address);
        //^^^^^^^Intercations^^^^^^^^^
    }




    
    function calculateDividend() external returns(uint256) { 

        uint256 secUntilPayday;

        (, secUntilPayday) = sec_until_payday();
        require (secUntilPayday == 0, "not payday yet");

            lastPayDay = nextPayDay; //today is the new most recent PayDay
            nextPayDay = block.timestamp.add(payPeriod); //set the next payday for the future

            newBalance = address(this).balance.sub(held);  //the new balance is the total balance less the amount held back for payment reservations

            //oldDividend = newDividend; //update old diviend to the last new dividend

            newDividend = newBalance.div(maxSupply);  //calculate the dividend per share of the last interval's reciepts

            return newDividend;
    }

    function sec_until_payday() public view returns (uint256 , uint256) {
        if (nextPayDay > block.timestamp){
            return (lastPayDay, (nextPayDay.sub(block.timestamp)));
        } else {
            return (lastPayDay, 0);
        }
    }
        



    function payDay (uint256 tokenId) external {

        require(
            tokenPaymentDate[tokenId] < lastPayDay, "PS:GP:not payday for this token"
        );
        require(
            block.timestamp > lastPayDay, "PS:GP:not payday yet"
        );
        require(
            block.timestamp < nextPayDay, "PS:GP: dividend not yet processed for this period. call calculateDividend "
        );
        require(
            SHAR_TKN.ownerOf(tokenId) == msg.sender, "PS:GP:caller does not hold token"
        );

            tokenPaymentDate[tokenId] = nextPayDay;
            held = held.add(newDividend);
            _asyncTransfer(msg.sender, newDividend);

    }

    function withdrawFunds(address payable payee) public {

        held = held.sub(payments(payee));
        withdrawPayments(payee);
    }


    /**
     * @dev Withdraw accumulated payments, forwarding all gas to the recipient.
     *
     * Note that _any_ account can call this function, not just the `payee`.
     * This means that contracts unaware of the `PullPayment` protocol can still
     * receive funds this way, by having a separate account call
     * {withdrawPayments}.
     *
     * WARNING: Forwarding all gas opens the door to reentrancy vulnerabilities.
     * Make sure you trust the recipient, or are either following the
     * checks-effects-interactions pattern or using {ReentrancyGuard}.
     *
     * @param payee Whose payments will be withdrawn.
     */
    function withdrawPayments(address payable payee) internal {
        _escrow.withdraw(payee);
    }

    /**
     * @dev Returns the payments owed to an address.
     * @param dest The creditor's address.
     */
    function payments(address dest) public view returns (uint256) {
        return _escrow.depositsOf(dest);
    }

    /**
     * @dev Called by the payer to store the sent amount as credit to be pulled.
     * Funds sent in this way are stored in an intermediate {Escrow} contract, so
     * there is no danger of them being spent before withdrawal.
     *
     * @param dest The destination address of the funds.
     * @param amount The amount to transfer.
     */
    function _asyncTransfer(address dest, uint256 amount) internal {
        _escrow.deposit{ value: amount }(dest);
    }

}
