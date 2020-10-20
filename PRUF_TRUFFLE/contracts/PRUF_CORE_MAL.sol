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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/payment/PullPayment.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./PRUF_BASIC.sol";

contract CORE_MAL is PullPayment, BASIC {
    using SafeMath for uint256;

    struct Costs {
        uint256 serviceCost; // Cost to brute-force a record transfer
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    struct Invoice {
        address rootAddress;
        uint256 rootPrice;
        address ACTHaddress;
        uint256 ACTHprice;
    }

    
    //--------------------------------------------------------------------------------------Storage Reading internal functions

    // /*
    //  * @dev retrieves costs from Storage and returns Costs struct
    //  */
    // function getCost(uint32 _assetClass, ) internal returns (Costs memory) {
    //     //^^^^^^^checks^^^^^^^^^

    //     Costs memory cost;
    //     //^^^^^^^effects^^^^^^^^^
    //     (
    //         cost.serviceCost,
    //         cost.paymentAddress
    //     ) = AC_MGR.retrieveCosts(_assetClass);

    //     return (cost);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    //--------------------------------------------------------------------------------------Storage Writing internal functions

    /*
     * @dev create a Record in Storage @ idxHash
     */
    function createRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) internal {
        uint256 tokenId = uint256(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);

        // require(
        //     A_TKN.tokenExists(tokenId) == 0,
        //     "C:CR:Asset token already exists"
        // );

        require(
            AC_info.custodyType != 3,
            "C:CR:Cannot create asset in a root asset class"
        );

        if (AC_info.custodyType == 1) {
            A_TKN.mintAssetToken(address(this), tokenId, "pruf.io");
        }

        if (AC_info.custodyType == 2) {
            A_TKN.mintAssetToken(msg.sender, tokenId, "pruf.io");
        }

        STOR.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
    }


    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        internal
        whenNotPaused
    //isAuthorized(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^

        STOR.modifyRecord(
            _idxHash,
            _rec.rightsHolder,
            _rec.assetStatus,
            _rec.countDown,
            _rec.incrementForceModCount,
            _rec.incrementNumberOfTransfers
        ); // Send data and writehash to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write an Ipfs Record to Storage @ idxHash
     */
    function writeRecordIpfs1(bytes32 _idxHash, Record memory _rec)
        internal
        whenNotPaused
    {
        //^^^^^^^Checks^^^^^^^^^

        STOR.modifyIpfs1(_idxHash, _rec.Ipfs1); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    function writeRecordIpfs2(bytes32 _idxHash, Record memory _rec)
        internal
        whenNotPaused
    //isAuthorized(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^

        STOR.modifyIpfs2(_idxHash, _rec.Ipfs2); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Payment internal functions

    /*
     * @dev Send payment to appropriate pullPayment adresses for payable function
     */
    function deductServiceCosts(uint32 _assetClass, uint16 _service) internal whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AC_MGR.getServiceCosts(_assetClass, _service);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    

    //--------------------------------------------------------------PAYMENT FUNCTIONS
    /*
     * @dev Withdraws user's credit balance from contract
     */
    function $withdraw() external virtual payable nonReentrant {
        //^^^^^^^checks^^^^^^^^^
        withdrawPayments(msg.sender);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Deducts payment from transaction
     */
    function deductPayment(Invoice memory pricing) internal whenNotPaused {
        uint256 messageValue = msg.value;
        uint256 change;
        uint256 total = pricing.rootPrice.add(pricing.ACTHprice);
        require(msg.value >= total, "C:DP: TX value too low.");
        //^^^^^^^checks^^^^^^^^^
        change = messageValue.sub(total);
        _asyncTransfer(pricing.rootAddress, pricing.rootPrice);
        _asyncTransfer(pricing.ACTHaddress, pricing.ACTHprice);
        _asyncTransfer(msg.sender, change);
        //^^^^^^^interactions^^^^^^^^^
    }

//--------------------------------------------------------------------------------------status test internal functions

    function isLostOrStolen(uint8 _assetStatus) internal pure returns (uint8) {
        if (
            (_assetStatus != 3) &&
            (_assetStatus != 4) &&
            (_assetStatus != 53) &&
            (_assetStatus != 54)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    /*
     * @dev Check to see if record is in escrow status
     */
    function isEscrow(uint8 _assetStatus) internal pure returns (uint8) {
        if (
            (_assetStatus != 6) &&
            (_assetStatus != 50) &&
            (_assetStatus != 56)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    function needsImport(uint8 _assetStatus) internal pure returns (uint8) {
        if (
            (_assetStatus != 5) &&
            (_assetStatus != 55) &&
            (_assetStatus != 70) &&
            (_assetStatus != 60)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    // function isReserved(uint8 _assetStatus) internal pure returns (uint8) {
    //     if (
    //         (_assetStatus != 7) &&
    //         (_assetStatus != 57) &&
    //         (_assetStatus != 58) &&
    //         (_assetStatus != 60) &&
    //         (_assetStatus != 70)
    //     ) {
    //         return 0;
    //     } else {
    //         return 170;
    //     }
    // }


    
}
