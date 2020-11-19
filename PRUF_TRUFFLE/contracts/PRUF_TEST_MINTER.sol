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

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address internal ID_TKN_Address;
    ID_TKN_Interface internal ID_TKN;

    //----------------------External Admin functions / onlyowner ---------------------//
    

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function OO_setPRUF_TKN(address _address)
        external
        virtual
        onlyOwner
    {
        require(
            _address != address(0),
            "AM:SSC: token address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _address;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }


    //--------------------------------------External functions--------------------------------------------//

    /*
     * @dev Mint PRUF to an addresses (ADMIN)
     */
    function OO_MintPRUF(address _addr, uint256 _amount) external onlyOwner nonReentrant whenNotPaused {
        require(_amount != 0, "AM:BM: airdrop amount cannot be zero");
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.mint(_addr, _amount);
        //^^^^^^^effects^^^^^^^^^
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
