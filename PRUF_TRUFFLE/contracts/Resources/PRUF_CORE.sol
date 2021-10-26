/*--------------------------------------------------------PRüF0.8.8
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 * PRUF core provides switches core functionality covering cost getters, payment processing, withdrawls, common test conditionals, and setters for data in storage
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Imports/security/ReentrancyGuard.sol";
import "../Resources/PRUF_BASIC.sol";

contract CORE is BASIC {
    /** 
     * @dev create a Record in Storage @ idxHash (SETTER) and mint an asset token (may mint to node holder depending on flags)
     * @param _idxHash - Asset Index
     * @param _rgtHash - Owner ID Hash
     * @param _node - node to create asset in
     * @param _countDownStart - initial value for decrement only register
     * @param _URIsuffix - suffix for URI
     */
    function createRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart,
        string calldata _URIsuffix
    ) internal virtual {
        uint256 tokenId = uint256(_idxHash);
        Node memory nodeInfo = getNodeinfo(_node);
        bytes32 URIhash = keccak256(abi.encodePacked(_URIsuffix));

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "C:CR:Asset token already exists"
        );
        require(
            nodeInfo.custodyType != 3,
            "C:CR:Cannot create asset in a root node"
        );
        
        require( //check custody types for this contract CTS:EXAMIMNE ?
        // ??THIS NEEDS TO BE MOVED INTO THE APP LAYER??? maybe not since the minting is below?
            (nodeInfo.custodyType == 1) ||
                (nodeInfo.custodyType == 2) ||
                (nodeInfo.custodyType == 4),
            "C:CR:Cannot create asset - contract not authorized for node custody type"
        );


        require(
            NODE_STOR.getManagementTypeStatus(nodeInfo.managementType) > 0,
            "C:CR: Invalid management type"
        );
        if (
            (nodeInfo.managementType == 1) ||
            (nodeInfo.managementType == 2) ||
            (nodeInfo.managementType == 5)
        ) {
            require(
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "C:CR:Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (nodeInfo.managementType == 3) {
            require(
                NODE_STOR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "C:CR:Cannot create asset - caller not authorized"
            );
        } else {
            revert(
                "C:CR: Contract does not support management type or node is locked"
            );
        }

        //^^^^^^^Checks^^^^^^^^

        address recipient;
        if (NODE_STOR.getSwitchAt(_node, 8) == 0) {
            //if switch at bit 8 is not set, set the mint to address to the node holder
            recipient = NODE_TKN.ownerOf(_node);
        } else if (nodeInfo.custodyType == 1) {
            //if switch at bit 8 is set, and and the custody type is 1, send the token to this contract.
            recipient = address(this);
        } else {
            //if switch at bit 8 is set, and and the custody type is not 1, send the token to the caller.
            recipient = _msgSender();
        }

        A_TKN.mintAssetToken(recipient, tokenId, _URIsuffix);

        STOR.newRecord(_idxHash, _rgtHash, URIhash, _node, _countDownStart);
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
        Node memory nodeInfo = getNodeinfo(_rec.node);

        require(
            (nodeInfo.managementType < 6),
            "C:WMS:Contract does not support management types > 5 or node is locked"
        );
        if ((nodeInfo.custodyType != 1) && (nodeInfo.managementType == 5)) {
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

        STOR.setNonMutableStorage(
            _idxHash,
            _rec.nonMutableStorage1,
            _rec.nonMutableStorage2
        ); // Send NonMutableStorage data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

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
        uint256 nodeNetPercent = uint256(NODE_STOR.getNodeDiscount(_node)) /
            uint256(100);
        require( //IMPOSSIBLE TO REACH unless stuff is really broken, still ensures sanity
            (nodeNetPercent >= 0) && (nodeNetPercent <= 100),
            "C:DSC:invalid discount value for price calculation"
        );
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing = NODE_STOR.getInvoice(_node, _service);

        uint256 percent = pricing.NTHprice / uint256(100); //calculate 1% of listed NTH price
        uint256 _NTHprice = nodeNetPercent * percent; //calculate the share proprotrion% * 1%
        uint256 prufShare = pricing.NTHprice - _NTHprice;

        pricing.NTHprice = _NTHprice;
        pricing.rootPrice = pricing.rootPrice + prufShare;

        deductPayment(pricing);
        //^^^^^^^effects^^^^^^^^^
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

        pricing = NODE_STOR.getInvoice(_node, 1);
        pricing.rootAddress = _prevOwner;

        half = pricing.NTHprice / 2;
        pricing.rootPrice = pricing.rootPrice + half;
        pricing.NTHprice = pricing.NTHprice - half;

        deductPayment(pricing);
        //^^^^^^^effects^^^^^^^^^
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

        UTIL_TKN.payForService( //LEGACY TOKEN CONTRACT
            _msgSender(),
            _pricing.rootAddress,
            _pricing.rootPrice,
            _pricing.NTHaddress,
            _pricing.NTHprice
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Check to see if record is lost or stolen
     * @param _assetStatus - status to check
     * @return 170 if true, otherise 0
     */
    function isLostOrStolen(uint8 _assetStatus) internal pure returns (uint8) {
        //^^^^^^^checks^^^^^^^^^

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
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Check to see if record is in escrow status
     * @param _assetStatus - status to check
     * @return 170 if true, otherise 0
     */
    function isEscrow(uint8 _assetStatus) internal pure returns (uint8) {
        //^^^^^^^checks^^^^^^^^^

        if (
            (_assetStatus != 6) && (_assetStatus != 50) && (_assetStatus != 56)
        ) {
            return 0;
        } else {
            return 170;
        }
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Check to see if record needs imported
     * @param _assetStatus - status to check
     * @return 170 if true, otherise 0
     */
    function needsImport(uint8 _assetStatus) internal pure returns (uint8) {
        //^^^^^^^checks^^^^^^^^^

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
        //^^^^^^^interactions^^^^^^^^^
    }
}
