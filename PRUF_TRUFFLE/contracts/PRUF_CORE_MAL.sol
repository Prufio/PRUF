/*--------------------------------------------------------PRüF0.8.0
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
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
//import "./Imports/payment/PullPayment.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./PRUF_BASIC.sol";

contract CORE_MAL is BASIC {
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
     * @dev create a Record in Storage @ idxHash (SETTER)
     */
    function createRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) internal virtual {
        uint256 tokenId = uint256(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "C:CR:Asset token already exists"
        );

        require(
            AC_info.custodyType != 3,
            "C:CR:Cannot create asset in a root asset class"
        );

        require(
            (AC_info.custodyType == 1) ||
                (AC_info.custodyType == 2) ||
                (AC_info.custodyType == 4),
            "C:CR:Cannot create asset - contract not authorized for asset class custody type"
        );

        if (AC_info.custodyType == 1) {
            A_TKN.mintAssetToken(address(this), tokenId, "pruf.io");
        }

        if ((AC_info.custodyType == 2) || (AC_info.custodyType == 4)) {
            A_TKN.mintAssetToken(_msgSender(), tokenId, "pruf.io");
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
            _rec.forceModCount,
            _rec.numberOfTransfers
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
    function deductServiceCosts(uint32 _assetClass, uint16 _service)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        pricing = AC_MGR.getServiceCosts(_assetClass, _service);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------PAYMENT FUNCTIONS

    /*
     * @dev Deducts payment from transaction
     */
    function deductPayment(Invoice memory pricing) internal whenNotPaused {
        UTIL_TKN.payForService(
            _msgSender(),
            pricing
        );
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
            (_assetStatus != 6) && (_assetStatus != 50) && (_assetStatus != 56)
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
