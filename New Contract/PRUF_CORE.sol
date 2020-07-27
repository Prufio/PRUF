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

import "./PRUF_INTERFACES.sol";
import "./Imports/PullPayment.sol";
import "./Imports/ReentrancyGuard.sol";
import "./PRUF_BASIC.sol";

contract CORE is PullPayment, BASIC {
    using SafeMath for uint256;
    using SafeMath for uint16;
    using SafeMath for uint8;

    struct Costs {
        uint256 newRecordCost; // Cost to create a new record
        uint256 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        uint256 createNoteCost; // Cost to add a static note to an asset
        uint256 reMintRecordCost; // Extra
        uint256 changeStatusCost; // Extra
        uint256 forceModifyCost; // Cost to brute-force a record transfer
        address paymentAddress; // 2nd-party fee beneficiary address
    }

    struct Invoice {
        address rootAddress;
        uint256 rootPrice;
        address ACTHaddress;
        uint256 ACTHprice;
    }

    //--------------------------------------------------------------------------------------Storage Reading internal functions

    /*
     * @dev retrieves costs from Storage and returns Costs struct
     */
    function getCost(uint16 _assetClass) internal returns (Costs memory) {
        //^^^^^^^checks^^^^^^^^^

        Costs memory cost;
        //^^^^^^^effects^^^^^^^^^
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.reMintRecordCost,
            cost.changeStatusCost,
            cost.forceModifyCost,
            cost.paymentAddress
        ) = AssetClassTokenManagerContract.retrieveCosts(_assetClass);

        return (cost);
        //^^^^^^^interactions^^^^^^^^^
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
        ) = escrowMGRcontract.retrieveEscrowData(_idxHash);

        return (escrow);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Storage Writing internal functions

    /*
     * @dev create a Record in Storage @ idxHash
     */
    function createRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart
    ) internal {
        uint256 tokenId = uint256(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);

        require (AssetTokenContract.tokenExists(tokenId) == 0, "PC:CR:Asset token already exists");

        if (AC_info.custodyType == 1){
            AssetTokenContract.mintAssetToken(address(this), tokenId, "pruf.io");
        }
        
        if (AC_info.custodyType == 2){
            AssetTokenContract.mintAssetToken(msg.sender, tokenId, "pruf.io");
        }

        Storage.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
    }

    /*
     * @dev create a Record in Storage @ idxHash
     */
    function actualizeRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart
    ) internal {
        uint256 tokenId = uint256(_idxHash);

        require (AssetTokenContract.tokenExists(tokenId) == 170, "PC:AR:Asset token not found");

        Storage.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
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

        Storage.modifyRecord(
            //userHash,
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

        Storage.modifyIpfs1(_idxHash, _rec.Ipfs1); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    function writeRecordIpfs2(bytes32 _idxHash, Record memory _rec)
        internal
        whenNotPaused
    //isAuthorized(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^

        Storage.modifyIpfs2(_idxHash, _rec.Ipfs2); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Payment internal functions

    function deductNewRecordCosts(uint16 _assetClass) internal whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AssetClassTokenManagerContract.getNewRecordCosts(_assetClass);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    function deductRecycleCosts(uint16 _assetClass, address _oldOwner)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AssetClassTokenManagerContract.getNewRecordCosts(_assetClass);
        pricing.ACTHaddress = _oldOwner;
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    function deductTransferAssetCosts(uint16 _assetClass)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AssetClassTokenManagerContract.getTransferAssetCosts(_assetClass);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    function deductCreateNoteCosts(uint16 _assetClass) internal whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AssetClassTokenManagerContract.getCreateNoteCosts(_assetClass);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    function deductReMintRecordCosts(uint16 _assetClass)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AssetClassTokenManagerContract.getReMintRecordCosts(_assetClass);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    function deductChangeStatusCosts(uint16 _assetClass)
        internal
        whenNotPaused
    {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AssetClassTokenManagerContract.getChangeStatusCosts(_assetClass);
        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^^^
    }

    function deductForceModifyCosts(uint16 _assetClass) internal whenNotPaused {
        //^^^^^^^checks^^^^^^^^^
        Invoice memory pricing;
        //^^^^^^^effects^^^^^^^^^
        (
            pricing.rootAddress,
            pricing.rootPrice,
            pricing.ACTHaddress,
            pricing.ACTHprice
        ) = AssetClassTokenManagerContract.getForceModifyCosts(_assetClass);
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
        require(msg.value >= total, "PC:DP: TX value too low.");
        //^^^^^^^checks^^^^^^^^^
        change = messageValue.sub(total);
        _asyncTransfer(pricing.rootAddress, pricing.rootPrice);
        _asyncTransfer(pricing.ACTHaddress, pricing.ACTHprice);
        _asyncTransfer(msg.sender, change);
        //^^^^^^^interactions^^^^^^^^^
    }
}
