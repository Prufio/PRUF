/*-----------------------------------------------------------V0.6.7
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

import "./PRUF_BASIC.sol";
import "./PRUF_INTERFACES.sol";
import "./Imports/PullPayment.sol";
import "./Imports/ReentrancyGuard.sol";

contract ECR_CORE is BASIC {
    using SafeMath for uint256;
    using SafeMath for uint16;
    using SafeMath for uint8;

    struct escrowData {
        uint8 data;
        bytes32 controllingContractNameHash;
        bytes32 escrowOwnerAddressHash;
        uint256 timelock;
        bytes32 ex1;
        bytes32 ex2;
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
