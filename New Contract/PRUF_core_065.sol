/*-----------------------------------------------------------------
 *  TO DO
 * change costs struct to include deposit-cost and ??? to repace changeststus and remint
*-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_interfaces_065.sol";
import "./Imports/PullPayment.sol";
import "./Imports/ReentrancyGuard.sol";
import "./PRUF_basic_065.sol";

contract PRUF is PullPayment, PRUF_BASIC {

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
     * @dev Write a Record to Storage @ idxHash
     */
    function writeRecord(bytes32 _idxHash, Record memory _rec)
        internal
        isAuthorized(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging
        //^^^^^^^effects^^^^^^^^^
        Storage.modifyRecord(
            userHash,
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
        isAuthorized(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging
        //^^^^^^^effects^^^^^^^^^
        Storage.modifyIpfs1(userHash, _idxHash, _rec.Ipfs1); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------------------------------------------------Storage Writing internal functions

    function writeRecordIpfs2(bytes32 _idxHash, Record memory _rec)
        internal
        isAuthorized(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^
        bytes32 userHash = keccak256(abi.encodePacked(msg.sender)); // Get a userhash for authentication and recorder logging
        //^^^^^^^effects^^^^^^^^^
        Storage.modifyIpfs2(userHash, _idxHash, _rec.Ipfs2); // Send data to storage
        //^^^^^^^interactions^^^^^^^^^
    }

    function deductNewRecordCosts(uint16 _assetClass) internal {
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

    function deductTransferAssetCosts(uint16 _assetClass) internal {
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

    function deductCreateNoteCosts(uint16 _assetClass) internal {
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

    function deductReMintRecordCosts(uint16 _assetClass) internal {
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

    function deductChangeStatusCosts(uint16 _assetClass) internal {
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

    function deductForceModifyCosts(uint16 _assetClass) internal {
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
    function deductPayment(Invoice memory pricing) internal {
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
