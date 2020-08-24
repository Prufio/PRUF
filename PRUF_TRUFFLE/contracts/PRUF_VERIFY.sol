/*-----------------------------------------------------------V0.6.8
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
PRUF VERIFY will:
allow the inclusion of a range of values, through 











 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";
import "./PRUF_INTERFACES.sol";
//import "./Imports/PullPayment.sol";
//import "./Imports/ReentrancyGuard.sol";

contract VERIFY is CORE {
    using SafeMath for uint256;

    struct escrowData {
        bytes32 controllingContractNameHash;
        bytes32 escrowOwnerAddressHash;
        bytes32 ex1;
        bytes32 ex2;
        uint256 timelock;
        uint8 data;
        address addr1;
        address addr2;
    }

    /*
     * @dev retrieves costs from Storage and returns Costs struct
     */
    function getEscrowData(bytes32 _idxHash)
        internal
        returns (escrowData memory)
    {
        //^^^^^^^checks^^^^^^^^^

        escrowData memory escrow;
        //^^^^^^^effects^^^^^^^^^

        (
            escrow.data,
            escrow.controllingContractNameHash,
            escrow.escrowOwnerAddressHash,
            escrow.timelock,
            escrow.ex1,
            escrow.ex2,
            escrow.addr1,
            escrow.addr2
        ) = ECR_MGR.retrieveEscrowData(_idxHash);

        return (escrow);
        //^^^^^^^interactions^^^^^^^^^
    }
}
