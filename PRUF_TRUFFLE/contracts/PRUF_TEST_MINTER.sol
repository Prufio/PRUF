/*--------------------------------------------------------PRuF0.7.1
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
 *-----------------------------------------------------------------
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/Ownable.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/math/safeMath.sol";

contract AIR_MINTER is ReentrancyGuard, Ownable, Pausable {
    using SafeMath for uint256;

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address internal ID_TKN_Address;
    ID_TKN_Interface internal ID_TKN;

    address payable payment_address;

    //----------------------External Admin functions / onlyowner ---------------------//

    /*
     * @dev Set address of PRUF_TKN contract to interface with
     */
    function OO_setPRUF_TKN(address _address) external onlyOwner {
        require(_address != address(0), "PTM:SPT: token address cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _address;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set address of ID_TKN contract to interface with
     */
    function OO_setID_TKN(address _address) external onlyOwner {
        require(_address != address(0), "PTM:SIT: token address cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        ID_TKN_Address = _address;
        ID_TKN = ID_TKN_Interface(ID_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set Payment addrress to send eth to
     */
    function OO_setPaymentAddress(address payable _address) external onlyOwner {
        require(_address != address(0), "PTM:SPA: token address cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        payment_address = _address;

        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /*
     * @dev Mint PRUF to an addresses (ADMIN)
     */
    function OO_MintPRUF(address _addr, uint256 _amount)
        external
        onlyOwner
        nonReentrant
        whenNotPaused
    {
        require((_amount != 0) && (_addr != address(0)),
        "PTM:MP: mint amount or address is zero"
        );
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_addr, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Mint a single ID Token to an addresses
     */
    function mintID_Token(address _recipientAddress, uint256 _tokenId)
        external
    {
        require( 
            ID_TKN.balanceOf(_recipientAddress) == 0,
            "PTM:MIT: Calling address already holds an ID token"
        );
        ID_TKN.mintPRUF_IDToken(_recipientAddress, _tokenId);
    }

    /*
     * @dev Mint PRUF to an addresses at the rate of 5000 * ETH recieved
     */
    function mintPRUF() external payable nonReentrant {
                    UTIL_TKN.mint(msg.sender, msg.value.mul(5000));
    }

    function withdraw() external {
            payment_address.transfer(address(this).balance);
    }

    function balance() external view returns (uint256) {
            return address(this).balance;
    }

    /**
     * @dev Triggers stopped state. (pausable)
     *
     */
    function OO_pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Returns to normal state. (pausable)
     */
    function OO_unpause() external onlyOwner {
        _unpause();
    }

    //--------------------------------------------------------------------------------------INTERNAL functions
}
