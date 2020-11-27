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
 * PRUF core provides additional core functionality covering cost getters, payment processing, withdrawls, common test conditionals, and setters for data in storage
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
//import "./Imports/math/safeMath.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./PRUF_BASIC.sol";

contract CORE is BASIC {
    using SafeMath for uint256;

    struct Costs {
        uint256 serviceCost; // Cost in the given item category
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    struct Invoice {
        //invoice struct to facilitate payment messaging in-contract
        address rootAddress;
        uint256 rootPrice;
        address ACTHaddress;
        uint256 ACTHprice;
    }

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

        require( //-------------------------------------------------------DS:TEST
            (AC_info.custodyType == 1) ||
                (AC_info.custodyType == 2) ||
                (AC_info.custodyType == 4),
            "C:CR:Cannot create asset - contract not authorized for asset class custody type"
        );

        if (AC_info.custodyType == 1) {
            A_TKN.mintAssetToken(address(this), tokenId, "pruf.io");
        }

        if ((AC_info.custodyType == 2) || (AC_info.custodyType == 4)) {
            A_TKN.mintAssetToken(msg.sender, tokenId, "pruf.io");
        }

        STOR.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
    }

    /*
     * @dev Write a Record to Storage @ idxHash (SETTER)
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
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
     * @dev Write an Ipfs Record to Storage @ idxHash  (SETTER)
     */
    function writeRecordIpfs1(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
        whenNotPaused
    {
        //^^^^^^^Checks^^^^^^^^^

        STOR.modifyIpfs1(_idxHash, _rec.Ipfs1); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write an Ipfs Record to Storage @ idxHash  (SETTER)
     */
    function writeRecordIpfs2(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
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
        virtual
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        uint256 ACTHnetPercent = uint256(AC_MGR.getAC_discount(_assetClass))
            .div(uint256(100));
        require( //IMPOSSIBLE TO REACH
            (ACTHnetPercent >= 10) && (ACTHnetPercent <= 100),
            "PC:DSC:invalid discount value for price calculation"
        );
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AC_MGR.getServiceCosts(_assetClass, _service);

        //^^^^^^^effects^^^^^^^^^

        uint256 percent = pricing.ACTHprice.div(uint256(100)); //calculate 1% of listed ACTH price

        uint256 _ACTHprice = ACTHnetPercent.mul(percent); //calculate the share proprotrion% * 1%

        uint256 prufShare = pricing.ACTHprice.sub(_ACTHprice);

        pricing.ACTHprice = _ACTHprice;
        pricing.rootPrice = pricing.rootPrice.add(prufShare);

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Send payment to appropriate pullPayment adresses for payable function
     */
    function deductRecycleCosts(uint32 _assetClass, address _oldOwner)
        internal
        virtual
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        uint256 half;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AC_MGR.getServiceCosts(_assetClass, 1);
        pricing.rootAddress = _oldOwner;

        half = pricing.ACTHprice.div(2);
        pricing.rootPrice = pricing.rootPrice.add(half);
        pricing.ACTHprice = pricing.ACTHprice.sub(half);

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------PAYMENT FUNCTIONS

    /*
     * @dev Deducts payment from transaction
     */
    function deductPayment(Invoice memory pricing)
        internal
        virtual
        whenNotPaused
    {
        UTIL_TKN.payForService(
            msg.sender,
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        );
    }

    //----------------------------------------------------------------------STATUS CHECKS

    /*
     * @dev Check to see if record is lost or stolen
     */
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

    /*
     * @dev Check to see if record needs imported
     */
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
}
