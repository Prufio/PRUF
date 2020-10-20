// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Imports/GSN/Context.sol";
import "./Imports/Math/SafeMath.sol";
//import "./PRUF_INTERFACES.sol";
import "./Imports/access/Ownable.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";



/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 *
 * The split can be in equal parts or in any other arbitrary proportion. The way this is specified is by assigning each
 * account to a number of shares. Of all the Ether that this contract receives, each account will then be able to claim
 * an amount proportional to the percentage of total shares they were assigned.
 *
 * `PaymentSplitter` follows a _pull payment_ model. This means that payments are not automatically forwarded to the
 * accounts but kept in this contract, and the actual transfer is triggered as a separate step by calling the {release}
 * function.
 */
contract PAY_AGENT is Context, ReentrancyGuard, Ownable, Pausable{
    using SafeMath for uint256;

    event PayeeSet(address account, uint256 shares);
    event PaymentReleased(address to, uint256 amount);
    event PaymentReceived(address from, uint256 amount);
    event NoPaymentDue(address to);

    uint256 private _totalShares;
    uint256 private _totalReleased;
    uint256 private _shareHolders;

    struct Payee { 
        uint256 shares;
        uint256 shareHolderId;
    }

    mapping(address => Payee) private _shares;
    mapping(address => uint256) private _released;
    mapping(uint256 => address) private shareHolderById;

    //address internal STOR_Address;
    //STOR_Interface internal STOR;
    
    //address internal APP_Address;
    //APP_Interface internal APP;

    //address internal APP_NC_Address;
    //APP_NC_Interface internal APP_NC;


    //----------------------External Admin functions / onlyowner or isAdmin----------------------//

    /*
     * @dev Set adress of STOR contract to interface with
     */
    // function OO_setStorageContract(address _storageAddress) external virtual onlyOwner {
    //     require(
    //         _storageAddress != address(0),
    //         "B:SSC: storage address cannot be zero"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     STOR = STOR_Interface(_storageAddress);
    //     //^^^^^^^effects^^^^^^^^^
    // }


    /*
     * @dev Resolve Contract Addresses from STOR
     */
    // function OO_resolveContractAddresses()
    //     external
    //     nonReentrant
    //     onlyOwner
    // {
    //     //^^^^^^^checks^^^^^^^^^

    //     APP_Address = STOR.resolveContractAddress("APP");
    //     APP = APP_Interface(APP_Address);

    //     APP_NC_Address = STOR.resolveContractAddress("APP_NC");
    //     APP_NC = APP_NC_Interface(APP_NC_Address);

    //     //^^^^^^^effects^^^^^^^^^
    // }

    /**
     * @dev The Ether received will be logged with {PaymentReceived} events. Note that these events are not fully
     * reliable: it's possible for a contract to receive Ether without triggering this function. This only affects the
     * reliability of the events, and not the actual splitting of Ether.
     *
     * To learn more about this see the Solidity documentation for
     * https://solidity.readthedocs.io/en/latest/contracts.html#fallback-function[fallback
     * functions].
     */
    receive () external payable virtual {
        emit PaymentReceived(_msgSender(), msg.value);
    }

    /**
     * @dev Getter for the total shares held by payees.
     */
    function totalShares() public view returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Getter for the total amount of Ether already released.
     */
    function totalReleased() public view returns (uint256) {
        return _totalReleased;
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view returns (uint256) {
        return _shares[account].shares;
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     */
    function released(address account) public view returns (uint256) {
        return _released[account];
    }

    /**
     * @dev Getter for the address of the payee number `index`.
     */
    function payee(uint256 index) public view returns (address) {
        return shareHolderById[index];
    }

    /**
     * @dev Getter for the total number of shareHolders.
     */
    function numberOfShareHolders() public view returns (uint256) {
        return _shareHolders;
    }


    /**
     * @dev Triggers a transfer to `account` of the amount of Ether they are owed, according to their percentage of the
     * total shares and their previous withdrawals.
     */
    function withdraw(address payable account) public payable virtual {
        require(_shares[account].shares > 0, "PAY_AGENT: account has no shares");

        uint256 totalReceived = address(this).balance.add(_totalReleased);
        uint256 payment = totalReceived.mul(_shares[account].shares).div(_totalShares).sub(_released[account]);

        //require(payment != 0, "PaymentSplitter: account is not due payment");

        if(payment != 0){

            _released[account] = _released[account].add(payment);
            _totalReleased = _totalReleased.add(payment);

            account.transfer(payment);
            emit PaymentReleased(account, payment);
        } else {
            emit NoPaymentDue(account);
        }
    }

    /**
     * @dev Add a new payee to the contract.
     * @param account The address of the payee to add.
     * @param shares_ The number of shares owned by the payee.
     */
    function _setPayee(address account, uint256 shares_) external onlyOwner {
        require(account != address(0), "PaymentSplitter: account is the zero address");

        if (_shares[account].shares > shares_) {
        _totalShares = _totalShares.sub( _shares[account].shares.sub(shares_) );
        }

        if (_shares[account].shares < shares_) {
        _totalShares = _totalShares.add(shares_.sub(_shares[account].shares) );
        }

        if (_shares[account].shareHolderId == 0){ //if a shareholder address in not yet set up
            _shareHolders ++;
            _shares[account].shareHolderId = _shareHolders;
            shareHolderById[_shareHolders] = account;
        }

        _shares[account].shares = shares_;
        emit PayeeSet(account, shares_);
    }

    //  function getPaid() internal {  //collect any payments owed to this contract
    //     APP.$withdraw();
    //     APP_NC.$withdraw();
    //  }

    function sendMeEth() external payable{
        //this is just the payable function (mainly for testing)
        require(msg.value > 0, "MOAR ETH!!!!!");
    }

    function balance() external view returns (uint256) {
            return address(this).balance;
    }
}
