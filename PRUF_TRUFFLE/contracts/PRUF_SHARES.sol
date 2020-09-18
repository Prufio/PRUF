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
import "./Imports/math/Safemath.sol";

contract SHARES is ReentrancyGuard, Ownable, Pausable {

    using Address for address payable;
    using SafeMath for uint256;

    address internal SHAR_TKN_Address;
    SHAR_TKN_Interface internal SHAR_TKN;

    address internal STOR_Address;
    STOR_Interface internal STOR;

//    takes eth. at end of period (>= 1 month?) checks balance. 

uint256 private payDay = block.timestamp + 30 days;
uint256 private lastPayDay;
uint256 private oldBalance;
uint256 private newBalance;
uint256 private held;
uint256 private dividend;

 struct ShareData{
        uint256 balance;
        uint256 date;
        //uint256 dividend;
    }
mapping(uint256 => ShareData) private tokenData; // Main Data Storage


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




    
    function OnPayDay() external returns(uint256) { 

        uint256 daysUntilPayday;

        (, daysUntilPayday) = days_until_payday();
        require (daysUntilPayday == 0, "not payday yet");
            lastPayDay = payDay;

            payDay = block.timestamp.add(30);

            newBalance = (address(this).balance - held).sub(oldBalance);

            dividend = oldBalance.div(100000);  //calculate the dividend per share of the last time period take
            held = oldBalance;
            oldBalance = newBalance;
            return dividend;
    }

    function days_until_payday() public view returns (uint256 , uint256) {
        if (payDay > block.timestamp){
            return (lastPayDay, (payDay.sub(block.timestamp)));
        } else {
            return (lastPayDay, 0);
        }
    }
        



    function getPaid (uint256 tokenId) external {

        require(
            block.timestamp > lastPayDay, "PS:PM:not payday."
        );
        require(
            SHAR_TKN.ownerOf(tokenId) == msg.sender, "PS:PM:caller does not hold token"
        );
        require(
            tokenData[tokenId].date < payDay, "PS:PM:not payday for this token"
        );

            tokenData[tokenId].date = payDay;
            tokenData[tokenId].balance = dividend;
            held = held.sub(dividend);

    }

    function balance (uint256 tokenId) external view returns (uint256) {
        return tokenData[tokenId].balance;
    }

    function withdraw (uint256 tokenId, address payable tokenHolder) external returns (uint256) {
        require(
            SHAR_TKN.ownerOf(tokenId) == tokenHolder, "PS:PM:caller does not hold token"
        );
        
        uint256 toSend = tokenData[tokenId].balance;
        tokenData[tokenId].balance = 0;
        tokenHolder.sendValue(toSend);
        assert (tokenData[tokenId].balance == 0);
    }

}
