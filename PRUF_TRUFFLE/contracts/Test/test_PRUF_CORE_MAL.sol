/*--------------------------------------------------------PRüF0.8.7
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

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

// import "../Resources/RESOURCE_PRUF_INTERFACES.sol";
//import "../Imports/payment/PullPayment.sol";
import "../Imports/security/ReentrancyGuard.sol";
import "../Resources/PRUF_BASIC.sol";

contract CORE_MAL is BASIC {
    //--------------------------------------------------------------------------------------Storage Reading internal functions

    // /*
    //  * @dev retrieves costs from Storage and returns Costs struct
    //  */
    // function getCost(uint32 _node, ) internal returns (Costs memory) {
    //     //^^^^^^^checks^^^^^^^^^

    //     Costs memory cost;
    //     //^^^^^^^effects^^^^^^^^^
    //     (
    //         cost.serviceCost,
    //         cost.paymentAddress
    //     ) = NODE_MGR.retrieveCosts(_node);

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
        uint32 _node,
        uint32 _countDownStart
    ) internal virtual {
        uint256 tokenId = uint256(_idxHash);
        Node memory nodeInfo = getNodeinfo(_node);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "C:CR:Asset token already exists"
        );

        require(
            nodeInfo.custodyType != 3,
            "C:CR:Cannot create asset in a root node"
        );

        if (nodeInfo.custodyType == 1) {
            A_TKN.mintAssetToken(address(this), tokenId);
        }

        if ((nodeInfo.custodyType == 2) || (nodeInfo.custodyType == 4)) {
            A_TKN.mintAssetToken(_msgSender(), tokenId);
        }

        STOR.newRecord(_idxHash, _rgtHash, _node, _countDownStart);
    }

    /*
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        internal
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
        ); // Send data and writehash to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Write an content adressable storage Record to Storage @ idxHash
     */
    function writeMutableStorage(bytes32 _idxHash, Record memory _rec)
        internal
        whenNotPaused
    {
        //^^^^^^^Checks^^^^^^^^^

        STOR.modifyMutableStorage(
            _idxHash,
            _rec.mutableStorage1,
            _rec.mutableStorage2
        ); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    function writeNonMutableStorage(bytes32 _idxHash, Record memory _rec)
        internal
        whenNotPaused
    //isAuthorized(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^

        STOR.modifyNonMutableStorage(
            _idxHash,
            _rec.nonMutableStorage1,
            _rec.nonMutableStorage2,
            _rec.URIhash
        ); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Payment internal functions

    /*
     * @dev Send payment to appropriate pullPayment adresses for payable function
     */
    function deductServiceCosts(uint32 _node, uint16 _service)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        pricing = NODE_STOR.getInvoice(_node, _service);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------PAYMENT FUNCTIONS

    /*
     * @dev Deducts payment from transaction
     */
    function deductPayment(Invoice memory _pricing) internal whenNotPaused {
        if (_pricing.NTHaddress == address(0)) {
            _pricing.NTHaddress = _pricing.rootAddress;
        }
        //UTIL_TKN.payForService(_msgSender(), _pricing); //-- NON LEGACY TOKEN CONTRACT

        UTIL_TKN.payForService( //LEGACY TOKEN CONTRACT
            _msgSender(),
            _pricing.rootAddress,
            _pricing.rootPrice,
            _pricing.NTHaddress,
            _pricing.NTHprice
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
