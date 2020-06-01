// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./PullPayment.sol";
import "./ERC721/IERC721Receiver.sol";


interface ACtokenInterface {
    function ownerOf(uint256) external view returns (address);
    //function mint(uint256) external view returns (address);
    //function transfer(uint256,address) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}

interface assetTokenInterface {
    function ownerOf(uint256) external view returns (address);
    //function mint(uint256) external view returns (address);
    //function transfer(uint256,address) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
}



interface StorageInterface {
    function newRecord(
        address message_origin,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external;

    function retrieveCosts(uint16 _assetClass)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function retrieveRecord(bytes32 _idxHash)
        external
        returns (
            bytes32,
            bytes32,
            bytes32,
            uint8,
            uint8,
            uint16,
            uint256,
            uint256,
            bytes32,
            bytes32
        );
}


contract recordMinter is PullPayment, Ownable, IERC721Receiver {
    using SafeMath for uint256;

    struct Record {
        bytes32 recorder; // Address hash of recorder
        bytes32 rightsHolder; // KEK256 Registered  owner
        bytes32 lastRecorder; // Address hash of last non-automation recorder
        uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
        uint8 forceModCount; // Number of times asset has been forceModded.
        uint16 assetClass; // Type of asset
        uint256 countDown; // Variable that can only be dencreased from countDownStart
        uint256 countDownStart; // Starting point for countdown variable (set once)
        bytes32 Ipfs1; // Publically viewable asset description
        bytes32 Ipfs2; // Publically viewable immutable notes
        uint256 timeLock; // Time sensitive mutex
    }

    struct User {
        uint8 userType; // User type: 1 = human, 9 = automated
        uint16 authorizedAssetClass; // Asset class in which user is permitted to transact
    }

    struct Costs {
        uint256 newRecordCost; // Cost to create a new record
        uint256 transferAssetCost; // Cost to transfer a record from known rights holder to a new one
        uint256 createNoteCost; // Cost to add a static note to an asset
        uint256 cost4; // Extra
        uint256 cost5; // Extra
        uint256 forceModifyCost; // Cost to brute-force a record transfer
    }

    address internal mainWallet;

    StorageInterface private Storage; // Set up external contract interface

    address storageAddress;

    address assetContractAddress;
    assetTokenInterface assetTokenContract; //erc721_token prototype initialization
    address ACcontractAddress;
    ACtokenInterface ACtokenContract; //erc721_token prototype initialization

    /*
     * @dev Wrapper for newRecord
     */
    function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs
    ) external payable {
        Costs memory cost = getCost(_assetClass);

        // require(
        //     _assetClass < 32768,
        //     "NR: Asset classes 32768 or above not writable through this contract"
        // );
        require(
            msg.value >= cost.newRecordCost,
            "NR: tx value too low. Send more eth."
        );

        address message_origin = msg.sender;

        Storage.newRecord(
            message_origin,
            _idxHash,
            _rgtHash,
            _assetClass,
            _countDownStart,
            _Ipfs
        );

        deductPayment(cost.newRecordCost);
    }

    /*--------------------------------------------------------------------------------------PAYMENT FUNCTIONS
     * @dev Deducts payment from transaction
     */
    function deductPayment(uint256 _amount) private {
        uint256 messageValue = msg.value;
        uint256 change;

        change = messageValue.sub(_amount);

        _asyncTransfer(mainWallet, _amount);
        _asyncTransfer(msg.sender, change);
    }

    /*
     * @dev Withdraws user's Escrow amount
     */
    function $withdraw() external virtual payable {
        withdrawPayments(msg.sender);
    }

    /*
     * @dev Returns cost from database and returns Costs struct
     */
    function getCost(uint16 _class) private returns (Costs memory) {
        Costs memory cost;
        (
            cost.newRecordCost,
            cost.transferAssetCost,
            cost.createNoteCost,
            cost.cost4,
            cost.cost5,
            cost.forceModifyCost
        ) = Storage.retrieveCosts(_class);

        return (cost);
    }

}