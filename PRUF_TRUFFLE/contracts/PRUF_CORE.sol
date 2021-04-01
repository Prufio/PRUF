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
 *-----------------------------------------------------------------
 * IMPORTANT!!! NO EXTERNAL OR PUBLIC FUNCTIONS ALLOWED IN THIS CONTRACT!!!!!!!!
 *-----------------------------------------------------------------
 * PRUF core provides switches core functionality covering cost getters, payment processing, withdrawls, common test conditionals, and setters for data in storage
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

//import "./PRUF_INTERFACES.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./PRUF_BASIC.sol";

contract CORE is BASIC {
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
            (AC_info.managementType < 5),
            "C:CR:Contract does not support management types > 4 or AC is locked"
        );
        if (AC_info.custodyType != 1) {
            if (
                (AC_info.managementType == 1) || (AC_info.managementType == 2)
            ) {
                require(
                    (AC_TKN.ownerOf(_assetClass) == _msgSender()),
                    "C:CR:Cannot create asset in AC mgmt type 1||2 - caller does not hold AC token"
                );
            }
            if (AC_info.managementType == 3) {
                require(
                    AC_MGR.getUserType(
                        keccak256(abi.encodePacked(_msgSender())),
                        _assetClass
                    ) == 1,
                    "C:CR:Cannot create asset - caller address not authorized"
                );
            }
            if (AC_info.managementType == 4) {
                require(
                    ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                    "C:CR:Caller does not hold sufficiently trusted ID"
                );
            }
        }
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
        //^^^^^^^Checks^^^^^^^^

        STOR.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        //^^^^^^^interactions^^^^^^^^^
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
            _rec.forceModCount,
            _rec.numberOfTransfers
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

        STOR.modifyIpfs1(_idxHash, _rec.Ipfs1a, _rec.Ipfs1b); // Send data to storage
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

        STOR.modifyIpfs2(_idxHash, _rec.Ipfs2a, _rec.Ipfs2b); // Send data to storage
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
        uint256 ACTHnetPercent =
            uint256(AC_MGR.getAC_discount(_assetClass)) / uint256(100);
        require( //IMPOSSIBLE TO REACH unless stuff is really broken, still ensures sanity
            (ACTHnetPercent >= 0) && (ACTHnetPercent <= 100),
            "C:DSC:invalid discount value for price calculation"
        );
        pricing = AC_MGR.getServiceCosts(_assetClass, _service);

        uint256 percent = pricing.ACTHprice / uint256(100); //calculate 1% of listed ACTH price
        uint256 _ACTHprice = ACTHnetPercent * percent; //calculate the share proprotrion% * 1%
        uint256 prufShare = pricing.ACTHprice - _ACTHprice;

        pricing.ACTHprice = _ACTHprice;
        pricing.rootPrice = pricing.rootPrice + prufShare;

        deductPayment(pricing);
        //^^^^^^^interactions/effects^^^^^^^^^
    }

    /*
     * @dev Send payment to appropriate  adresses
     */
    function deductRecycleCosts(
        uint32 _assetClass,
        address _oldOwner 
    ) internal virtual whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        uint256 half;
        //^^^^^^^effects^^^^^^^^^

        pricing = AC_MGR.getServiceCosts(_assetClass, 1);
        pricing.rootAddress = _oldOwner;

        half = pricing.ACTHprice / 2;
        pricing.rootPrice = pricing.rootPrice + half;
        pricing.ACTHprice = pricing.ACTHprice - half;

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------PAYMENT FUNCTIONS

    /*
     * @dev Deducts payment from transaction -- NON_LEGACY
     * sets ACTHaddress to rootAddress if ACTHaddress is not set
     */
    function deductPayment(Invoice memory pricing)
        internal
        virtual
        whenNotPaused
    {
        require(
            pricing.rootAddress != address(0),
            "C:DP: root payment adress is zero address"
        );
        if (pricing.ACTHaddress == address(0)) {
            pricing.ACTHaddress = pricing.rootAddress;
        }
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN.payForService(_msgSender(), pricing);
        //^^^^^^^interactions^^^^^^^^^
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
