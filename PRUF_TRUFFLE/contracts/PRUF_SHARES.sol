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

import "./PRUF_SHAR_INTERFACES.sol";
import "./Imports/access/Ownable.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/utils/Address.sol";
import "./Imports/payment/escrow/Escrow.sol";

interface PAY_AGENT_Interface {
    function withdraw(address) external;
}

contract SHARES is ReentrancyGuard, Ownable, Pausable {
    Escrow private _escrow;

    constructor() public {
        _escrow = new Escrow();
    }

    using Address for address payable;
    using SafeMath for uint256;

    uint256 private constant payPeriod = 2 minutes; //set to 30 days

    uint256 private nextPayDay = block.timestamp.add(payPeriod);
    uint256 private lastPayDay = block.timestamp;

    uint256 internal heldFunds;
    uint256 private dividend_number;

    address PAY_AGENT_Address;
    PAY_AGENT_Interface internal PAY_AGENT;

    address internal SHAR_TKN_Address;
    SHARE_TKN_Interface internal SHAR_TKN;

    address authorizedAutomationAddress;

    struct paidDividend {
        uint256 heldForThisDividend;
        uint256 snapShotId;
        uint256 dividendAmount;
    }

    //mapping(uint256 => uint256) private tokenPaymentDate;

    mapping(uint256 => paidDividend) private paidDividends; //holder address -> dividendNumber ->(paid?,snapShotId,amount)
    //zero address used to hold overall dividend history

    mapping(address => uint256) private lastPaidDividendNumber; //holder address -> last Paid dividend number

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuth(uint256 __tokenId) {
        require(
            (SHAR_TKN.balanceOf(msg.sender)) > 0 || //msg.sender is a token holder or..
                (msg.sender == authorizedAutomationAddress), //auth address
            "ANC:MOD-IA: Caller not authorized"
        );
        _;
    }

    //-----------------------------------------------Events------------------------------------------------//
    event REPORT(string _msg);

    //--------------------------------Internal Admin functions / onlyowner or isAdmin---------------------------------//

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setPayAgentAdress(address _payAgentAddress) external onlyOwner {
        require(
            _payAgentAddress != address(0),
            "B:SSC: address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^
        PAY_AGENT_Address = _payAgentAddress;
        PAY_AGENT = PAY_AGENT_Interface(PAY_AGENT_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setShareContractAdress(address _SHAR_TKN_Address)
        external
        onlyOwner
    {
        require(
            _SHAR_TKN_Address != address(0),
            "B:SSC: address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^
        SHAR_TKN_Address = _SHAR_TKN_Address;
        SHAR_TKN = SHARE_TKN_Interface(SHAR_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setAutomationAddress(address _automationAddress)
        external
        onlyOwner
    {
        require(
            _automationAddress != address(0),
            "B:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^
        authorizedAutomationAddress = _automationAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    //wrapper to expose NDP
    function StartNewDividendPeriod() external {
        newDividendPeriod();
    }

    /**
     * sets a new dividend ending period payPeriod.seconds in the future
     * takes the contract balance less the heldFunds and divides it by the number of tokens to get a didivend amount
     * requires old dividend period must have expired
     */
    function newDividendPeriod() internal returns (uint256) {
        require(block.timestamp >= nextPayDay, "PS:SNDP:not payday yet");
        //^^^^^^^checks^^^^^^^^^
        getPaid();

        lastPayDay = nextPayDay; //today is the new most recent PayDay
        nextPayDay = block.timestamp.add(payPeriod); //set the next payday for payPeriod.seconds in the future

        uint256 shareTokenSupply = SHAR_TKN.totalSupply();
        uint256 payableFunds = address(this).balance.sub(heldFunds); //the new balance is the total balance less the amount held back for payment reservations
        uint256 dividend = payableFunds.div(shareTokenSupply);

        //dividend = payableFunds.div(SHAR_TKN.max_Supply()); //calculate the dividend per share of the last interval's reciepts

        dividend_number++;

        paidDividends[dividend_number].snapShotId = SHAR_TKN.takeSnapshot();
        paidDividends[dividend_number].dividendAmount = dividend;
        paidDividends[dividend_number].heldForThisDividend = payableFunds;

        heldFunds = address(this).balance;
        //paidDividends[address(0)][current_snapShot].heldForThisDividend = ?????;

        //^^^^^^^effects^^^^^^^^^
        return dividend_number;
        //^^^^^^^interactions^^^^^^^^^
    }

    function claimDividend() external {
        if (block.timestamp > nextPayDay) {
            //if no one has done it yet, start a new dividend period
            newDividendPeriod();
        }

        uint256 thisDividend = lastPaidDividendNumber[msg.sender].add(1);

        uint256 tokenBalanceAtDividend = SHAR_TKN.balanceOfAt(
            msg.sender,
            paidDividends[thisDividend].snapShotId
        ); //get the token balance at specified dividendPeriod

        uint256 dividendForDividendPeriod = paidDividends[thisDividend]
            .dividendAmount; //get the dividend amount at specified dividendPeriod

        uint256 totalDividend = dividendForDividendPeriod.mul(
            tokenBalanceAtDividend
        ); //calculate the total dividend for this account

        require(
            (dividend_number > 0) && (thisDividend > 0),
            "PS:GP:Zero dividend period not valid"
        );
        require(
            thisDividend <= dividend_number,
            "PS:GP:sender address has already claimed all dividends"
        );
        require(
            tokenBalanceAtDividend > 0,
            "PS:GP:sender address did not hold any tokens when this dividend was disbursed"
        );
        require(
            (paidDividends[dividend_number].heldForThisDividend >=
                totalDividend) || (totalDividend <= address(this).balance),
            "PS:GP:ERROR! funds depleted! "
        );

        lastPaidDividendNumber[msg.sender] = thisDividend;

        paidDividends[thisDividend]
            .heldForThisDividend = paidDividends[thisDividend]
            .heldForThisDividend
            .sub(totalDividend);

        //^^^^^^^effects^^^^^^^^^
        _asyncTransfer(msg.sender, totalDividend);
        //^^^^^^^interactions^^^^^^^^^
    }

    function withdrawFunds(address payable payee) public {
        //^^^^^^^checks^^^^^^^^^
        heldFunds = heldFunds.sub(payments(payee));
        //^^^^^^^effects^^^^^^^^^
        withdrawPayments(payee);
        //^^^^^^^interactions^^^^^^^^^
    }

    function sec_until_payday() public view returns (uint256) {
        if (nextPayDay > block.timestamp) {
            return (nextPayDay.sub(block.timestamp));
        } else {
            return 0;
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    function getCurrentInfo()
        external
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        if (nextPayDay > block.timestamp) {
            return (
                nextPayDay.sub(block.timestamp),
                block.timestamp,
                lastPayDay,
                nextPayDay,
                dividend_number,
                paidDividends[dividend_number].snapShotId,
                paidDividends[dividend_number].dividendAmount,
                paidDividends[dividend_number].heldForThisDividend
                );
        } else {
            return (
                0,
                block.timestamp,
                lastPayDay,
                nextPayDay,
                dividend_number,
                paidDividends[dividend_number].snapShotId,
                paidDividends[dividend_number].dividendAmount,
                paidDividends[dividend_number].heldForThisDividend
                );
        }

        
        //^^^^^^^interactions^^^^^^^^^
    }

    function getDividendInfo(uint256 _dividend_number)
        external
        view
        returns (
            uint256,
            uint256,
            uint256
        )
    {
        return (
            paidDividends[_dividend_number].snapShotId,
            paidDividends[_dividend_number].dividendAmount,
            paidDividends[_dividend_number].heldForThisDividend
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    function getlastPaidDividend() external view returns (uint256,uint256) {
        return (lastPaidDividendNumber[msg.sender], dividend_number);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------FROM OZ PULLPAYMENT-------------------------------------------------
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
        _escrow.deposit{value: amount}(dest);
    }

    //--------------------------------------------------Payable functions-------------------------------------------------
    function sendMeEth() external payable {
        //this is just the payable function (mainly for testing)
        require(msg.value > 0, "MOAR ETH!!!!!");
    }

    function getPaid() internal {
        //collect any payments owed to this contract
        //PAY_AGENT.withdraw(address(this));
    }

    function balance() external view returns (uint256) {
        return address(this).balance;
    }

    receive() external payable {}
}
