/**--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 *  TO DO
 *-----------------------------------------------------------------
 * IMPORTANT!!! NO EXTERNAL OR PUBLIC FUNCTIONS ALLOWED IN THIS CONTRACT!!!!!!!!
 *-----------------------------------------------------------------
 * PRUF core provides switches core functionality covering cost getters, payment processing, withdrawls, common test conditionals, and setters for data in storage
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./Imports/utils/ReentrancyGuard.sol";
import "./PRUF_BASIC.sol";

contract CORE is BASIC {
    //--------------------------------------------------------------------------------------Storage Writing internal functions

    /**
     * @dev create a Record in Storage @ idxHash (SETTER)
     * @param _idxHash - Asset Index
     * @param _rgtHash - Owner ID Hash
     * @param _node - node to create asset in
     * @param _countDownStart - initial value for decrement only register
     */
    function createRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) internal virtual {
        uint256 tokenId = uint256(_idxHash);
        Node memory node_info = getNodeinfo(_node);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "C:CR:Asset token already exists"
        );
        require(
            node_info.custodyType != 3,
            "C:CR:Cannot create asset in a root node"
        );
        require(
            (node_info.managementType < 6),
            "C:CR:Contract does not support management types > 5 or node is locked"
        );
        if (node_info.custodyType != 1) {
            if (
                (node_info.managementType == 1) ||
                (node_info.managementType == 2) ||
                (node_info.managementType == 5)
            ) {
                require(
                    (NODE_TKN.ownerOf(_node) == _msgSender()),
                    "C:CR:Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
                );
            } else if (node_info.managementType == 3) {
                require(
                    NODE_MGR.getUserType(
                        keccak256(abi.encodePacked(_msgSender())),
                        _node
                    ) == 1,
                    "C:CR:Cannot create asset - caller not authorized"
                );
            } else if (node_info.managementType == 4) {
                require(
                    ID_TKN.trustedLevelByAddress(_msgSender()) > 9,
                    "C:CR:Caller does not hold sufficiently trusted ID"
                );
            }
        }
        require(
            (node_info.custodyType == 1) ||
                (node_info.custodyType == 2) ||
                (node_info.custodyType == 4),
            "C:CR:Cannot create asset - contract not authorized for node custody type"
        );
        //^^^^^^^Checks^^^^^^^^

        if (node_info.custodyType == 1) {
            A_TKN.mintAssetToken(address(this), tokenId, "");
        }

        if ((node_info.custodyType == 2) || (node_info.custodyType == 4)) {
            A_TKN.mintAssetToken(_msgSender(), tokenId, "");
        }

        STOR.newRecord(_idxHash, _rgtHash, _node, _countDownStart);
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
            _rec.int32temp,
            _rec.modCount,
            _rec.numberOfTransfers
        ); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Write an Mutable Storage Record to Storage @ idxHash (SETTER)
     * @param _idxHash - Asset Index
     * @param _rec - a Record Struct (see interfaces for struct definitions)
     */
    function writeMutableStorage(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
        whenNotPaused
    {
        Node memory node_info = getNodeinfo(_rec.node);

        require(
            (node_info.managementType < 6),
            "C:WMS:Contract does not support management types > 5 or node is locked"
        );
        if ((node_info.custodyType != 1) && (node_info.managementType == 5)) {
            require(
                (NODE_TKN.ownerOf(_rec.node) == _msgSender()),
                "C:WMS: Caller must hold node (management type 5)"
            );
        }
        //^^^^^^^Checks^^^^^^^^^

        STOR.modifyMutableStorage(
            _idxHash,
            _rec.mutableStorage1,
            _rec.mutableStorage2
        ); // Send MutableStorage data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Write an NonMutableStorage Record to Storage @ idxHash (SETTER)
     * @param _idxHash - Asset Index
     * @param _rec - a Record Struct (see interfaces for struct definitions)
     */
    function writeNonMutableStorage(bytes32 _idxHash, Record memory _rec)
        internal
        virtual
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        STOR.modifyNonMutableStorage(
            _idxHash,
            _rec.nonMutableStorage1,
            _rec.nonMutableStorage2
        ); // Send NonMutableStorage data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Payment internal functions

    /**
     * @dev Send payment to appropriate adresseses for payable function
     * @param _node - selected node for payment
     * @param _service - selected service for payment
     */
    function deductServiceCosts(uint32 _node, uint16 _service)
        internal
        virtual
        whenNotPaused
    {
        uint256 nodeNetPercent = uint256(NODE_MGR.getNodeDiscount(_node)) /
            uint256(100);
        require( //IMPOSSIBLE TO REACH unless stuff is really broken, still ensures sanity
            (nodeNetPercent >= 0) && (nodeNetPercent <= 100),
            "C:DSC:invalid discount value for price calculation"
        );
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing = NODE_MGR.getServiceCosts(_node, _service);

        uint256 percent = pricing.NTHprice / uint256(100); //calculate 1% of listed NTH price
        uint256 _NTHprice = nodeNetPercent * percent; //calculate the share proprotrion% * 1%
        uint256 prufShare = pricing.NTHprice - _NTHprice;

        pricing.NTHprice = _NTHprice;
        pricing.rootPrice = pricing.rootPrice + prufShare;
        //^^^^^^^effects^^^^^^^^^

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Send payment to appropriate adresses for recycle operation
     * @param _node - selected node for payment
     * @param _prevOwner - adddress to pay recycle bonus to
     */
    function deductRecycleCosts(uint32 _node, address _prevOwner)
        internal
        virtual
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^

        Invoice memory pricing;
        uint256 half;

        pricing = NODE_MGR.getServiceCosts(_node, 1);
        pricing.rootAddress = _prevOwner;

        half = pricing.NTHprice / 2;
        pricing.rootPrice = pricing.rootPrice + half;
        pricing.NTHprice = pricing.NTHprice - half;
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
            "C:DP: root payment address = zero address"
        );
        if (_pricing.NTHaddress == address(0)) {
            //sets NTHaddress to rootAddress if NTHaddress is not set
            _pricing.NTHaddress = _pricing.rootAddress;
        }
        //^^^^^^^checks^^^^^^^^^

        //UTIL_TKN.payForService(_msgSender(), _pricing); //-- NON LEGACY TOKEN CONTRACT

        UTIL_TKN.payForService( //LEGACY TOKEN CONTRACT
            _msgSender(),
            _pricing.rootAddress,
            _pricing.rootPrice,
            _pricing.NTHaddress,
            _pricing.NTHprice
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
