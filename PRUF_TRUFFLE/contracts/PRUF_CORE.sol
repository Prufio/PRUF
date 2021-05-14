/**--------------------------------------------------------PRüF0.8.0
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

/**-----------------------------------------------------------------
 *  TO DO
 *  //CTS:!!EXAMINE GLOBAL!! we need to be using pascal case for all acronyms ex. htmlButton or bigHtmlButton, except for things with two acronyms ex. prufIO rather than prufIo !!important
 *-----------------------------------------------------------------
 * IMPORTANT!!! NO EXTERNAL OR PUBLIC FUNCTIONS ALLOWED IN THIS CONTRACT!!!!!!!!
 *-----------------------------------------------------------------
 * PRUF core provides switches core functionality covering cost getters, payment processing, withdrawls, common test conditionals, and setters for data in storage
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Imports/utils/ReentrancyGuard.sol";
import "./PRUF_BASIC.sol";

contract CORE is BASIC {
    //--------------------------------------------------------------------------------------Storage Writing internal functions

    /**
     * @dev create a Record in Storage @ idxHash (SETTER)
     * @param _idxHash - Asset Index
     * @param _rgtHash - Owner ID Hash
     * @param _assetClass - asset class to create asset in
     * @param _countDownStart - initial value for decrement only register
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
            (AC_info.managementType < 6),
            "C:CR:Contract does not support management types > 5 or AC is locked"
        );
        if (AC_info.custodyType != 1) {
            if (
                (AC_info.managementType == 1) ||
                (AC_info.managementType == 2) ||
                (AC_info.managementType == 5)
            ) {
                require(
                    (AC_TKN.ownerOf(_assetClass) == _msgSender()),
                    "C:CR:Cannot create asset in AC mgmt type 1||2||5 - caller does not hold AC token"
                );
            } else if (AC_info.managementType == 3) {
                require(
                    AC_MGR.getUserType(
                        keccak256(abi.encodePacked(_msgSender())),
                        _assetClass
                    ) == 1,
                    "C:CR:Cannot create asset - caller not authorized"
                );
            } else if (AC_info.managementType == 4) {
                require(
                    ID_TKN.trustedLevelByAddress(_msgSender()) > 9,
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
        //^^^^^^^Checks^^^^^^^^

        if (AC_info.custodyType == 1) {
            A_TKN.mintAssetToken(address(this), tokenId, "");
        }

        if ((AC_info.custodyType == 2) || (AC_info.custodyType == 4)) {
            A_TKN.mintAssetToken(_msgSender(), tokenId, "");
        }

        STOR.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Write a Record to Storage @ idxHash (SETTER)
     * @param _idxHash - Asset Index
     * @param _rec - a Record Struct (see interfaces for struct definitions)
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        STOR.modifyRecord(
            _idxHash,
            _rec.rightsHolder,
            _rec.assetStatus,
            _rec.countDown,
            _rec.modCount,
            _rec.numberOfTransfers
        ); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Write an Ipfs1 Record to Storage @ idxHash (SETTER)
     * @param _idxHash - Asset Index
     * @param _rec - a Record Struct (see interfaces for struct definitions)
     */
    function writeRecordIpfs1(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
        whenNotPaused
    {
        AC memory AC_info = getACinfo(_rec.assetClass);

        require(
            (AC_info.managementType < 6),
            "C:CR:Contract does not support management types > 5 or AC is locked"
        );
        if ((AC_info.custodyType != 1) && (AC_info.managementType == 5)) {
            require(
                (AC_TKN.ownerOf(_rec.assetClass) == _msgSender()),
                "C:WIPFS1: Caller must hold ACnode (management type 5)"
            );
        }
        //^^^^^^^Checks^^^^^^^^^

        STOR.modifyIpfs1(_idxHash, _rec.Ipfs1a, _rec.Ipfs1b); // Send IPFS1 data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Write an Ipfs2 Record to Storage @ idxHash (SETTER)
     * @param _idxHash - Asset Index
     * @param _rec - a Record Struct (see interfaces for struct definitions)
     */
    function writeRecordIpfs2(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        STOR.modifyIpfs2(_idxHash, _rec.Ipfs2a, _rec.Ipfs2b); // Send IPFS2 data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Payment internal functions

    /**
     * @dev Send payment to appropriate adresseses for payable function
     * @param _assetClass - selected asset class for payment
     * @param _service - selected service for payment
     */
    function deductServiceCosts(uint32 _assetClass, uint16 _service)
        internal
        virtual
        whenNotPaused
    {
        uint256 ACTHnetPercent =
            uint256(AC_MGR.getAC_discount(_assetClass)) / uint256(100);
        require( //IMPOSSIBLE TO REACH unless stuff is really broken, still ensures sanity
            (ACTHnetPercent >= 0) && (ACTHnetPercent <= 100),
            "C:DSC:invalid discount value for price calculation"
        );
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing = AC_MGR.getServiceCosts(_assetClass, _service);

        uint256 percent = pricing.ACTHprice / uint256(100); //calculate 1% of listed ACTH price
        uint256 _ACTHprice = ACTHnetPercent * percent; //calculate the share proprotrion% * 1%
        uint256 prufShare = pricing.ACTHprice - _ACTHprice;

        pricing.ACTHprice = _ACTHprice;
        pricing.rootPrice = pricing.rootPrice + prufShare;
        //^^^^^^^effects^^^^^^^^^

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Send payment to appropriate adresses for recycle operation
     * @param _assetClass - selected asset class for payment
     * @param _prevOwner - adddress to pay recycle bonus to
     */
    function deductRecycleCosts(uint32 _assetClass, address _prevOwner)
        internal
        virtual
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        Invoice memory pricing;
        uint256 half;

        pricing = AC_MGR.getServiceCosts(_assetClass, 1);
        pricing.rootAddress = _prevOwner;

        half = pricing.ACTHprice / 2;
        pricing.rootPrice = pricing.rootPrice + half;
        pricing.ACTHprice = pricing.ACTHprice - half;
        //^^^^^^^effects^^^^^^^^^

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Deducts payment from transaction
     * @param _pricing - an Invoice Struct to pay (see interfaces for struct definitions)
     */
    function deductPayment(Invoice memory _pricing)
        internal
        virtual
        whenNotPaused
    {
        require(
            _pricing.rootAddress != address(0),
            "C:DP: root payment adress = zero address"
        );
        if (_pricing.ACTHaddress == address(0)) {
            //sets ACTHaddress to rootAddress if ACTHaddress is not set
            _pricing.ACTHaddress = _pricing.rootAddress;
        }
        //^^^^^^^checks^^^^^^^^^

        //UTIL_TKN.payForService(_msgSender(), _pricing); //-- NON LEGACY TOKEN CONTRACT

        UTIL_TKN.payForService( //LEGACY TOKEN CONTRACT
            _msgSender(),
            _pricing.rootAddress,
            _pricing.rootPrice,
            _pricing.ACTHaddress,
            _pricing.ACTHprice
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //----------------------------------------------------------------------STATUS CHECKS

    /**
     * @dev Check to see if record is lost or stolen
     * @param _assetStatus - status to check
     * returns 170 if true, otherise 0
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

    /**
     * @dev Check to see if record is in escrow status
     * @param _assetStatus - status to check
     * returns 170 if true, otherise 0
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

    /**
     * @dev Check to see if record needs imported
     * @param _assetStatus - status to check
     * returns 170 if true, otherise 0
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
