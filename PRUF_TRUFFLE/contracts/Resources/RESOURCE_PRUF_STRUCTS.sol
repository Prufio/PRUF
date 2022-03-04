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
pragma solidity 0.8.7;

struct Record {
    uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
    uint8 modCount; // Number of times asset has been forceModded.
    uint16 numberOfTransfers; //number of transfers and forcemods
    uint32 node; // Type of asset
    uint32 countDown; // Variable that can only be decreased from countDownStart
    uint32 int32temp; // int32 for persisting transitional data
    //128 bits left in this packing)
    bytes32 URIhash; //hash of off chain content adressable storage ; unuiqe element of URI
    bytes32 mutableStorage1; // Publically viewable asset description
    bytes32 nonMutableStorage1; // Publically viewable immutable notes
    bytes32 mutableStorage2; // Publically viewable asset description
    bytes32 nonMutableStorage2; // Publically viewable immutable notes
    bytes32 rightsHolder; // KEK256 Registered owner
}

//     proposed ISO standardized
//     struct Record {
//     uint8 assetStatus; // Status - Transferrable, locked, in transfer, stolen, lost, etc.
//     uint32 node; // Type of asset
//     uint32 countDown; // Variable that can only be decreased from countDownStart
//     uint32 int32temp; // int32 for persisting transitional data
//     bytes32 mutableStorage1; // Publically viewable asset description
//     bytes32 nonMutableStorage1; // Publically viewable immutable notes
//     bytes32 mutableStorage2; // Publically viewable asset description
//     bytes32 nonMutableStorage2; // Publically viewable immutable notes
//     bytes32 rightsHolder; // KEK256  owner
// }

struct Node {
    //Struct for holding and manipulating node data
    uint8 custodyType; // custodial or noncustodial, special asset types       //immutable
    uint8 managementType; // type of management for asset creation, import, export //immutable
    uint8 storageProvider; // Storage Provider
    uint8 switches; // bitwise Flags for node control                          //immutable
    uint32 nodeRoot; // asset type root (bicyles - USA Bicycles)             //immutable
    uint32 discount; // price sharing //internal admin                                      //immutable
    address referenceAddress; // Used with wrap / decorate
    bytes32 CAS1; //content adressable storage pointer 1
    bytes32 CAS2; //content adressable storage pointer 1
    string name; // NameHash for node
}

struct ExtendedNodeData {
    uint8 u8a;
    uint8 u8b;
    uint16 u16c;
    uint32 u32d;
    uint32 u32e;
    address idProviderAddr;
    uint256 idProviderTokenId;
}

struct ContractDataHash {
    //Struct for holding and manipulating contract authorization data
    uint8 contractType; // Auth Level / type
    bytes32 nameHash; // Contract Name hashed
}

struct DefaultContract {
    //Struct for holding and manipulating contract authorization data
    uint8 contractType; // Auth Level / type
    string name; // Contract name
}

struct escrowData {
    bytes32 controllingContractNameHash; //hash of the name of the controlling escrow contract
    bytes32 escrowOwnerAddressHash; //hash of an address designated as an executor for the escrow contract
    uint256 timelock;
}

struct escrowDataExtLight {
    //used only in recycle
    //1 slot
    uint8 escrowData; //used by recycle
    uint8 u8_1;
    uint8 u8_2;
    uint8 u8_3;
    uint16 u16_1;
    uint16 u16_2;
    uint32 u32_1;
    address addr_1; //used by recycle
}

struct escrowDataExtHeavy {
    //specific uses not defined
    // 5 slots
    uint32 u32_2;
    uint32 u32_3;
    uint32 u32_4;
    address addr_2;
    bytes32 b32_1;
    bytes32 b32_2;
    string escrowStringData;
}

struct Costs {
    //make these require full epoch to change???
    uint256 serviceCost; // Cost in the given item category
    address paymentAddress; // 2nd-party fee beneficiary address
}

struct Invoice {
    //invoice struct to facilitate payment messaging in-contract
    //uint32 node;
    address rootAddress;
    address NTHaddress;
    uint256 rootPrice;
    uint256 NTHprice;
}

struct MarketFees {
    //data for PRUF_MARKET fees and commissions
    address listingFeePaymentAddress;
    address saleCommissionPaymentAddress;
    uint256 listingFee;
    uint256 saleCommission;
}

// struct PRUFID {
//     //ID struct for ID info
//     uint256 trustLevel; //admin only
//     bytes32 IdHash;
// }

struct Stake {
    uint256 stakedAmount; //tokens in stake
    uint256 mintTime; //blocktime of creation
    uint256 startTime; //blocktime of creation or most recent payout
    uint256 interval; //staking interval in seconds
    uint256 bonusPercentage; // % per reward period, in tenths of a percent, assigned to this stake on creation
    uint256 maximum; // maximum tokens allowed to be held by this stake
}

struct ConsignmentTag {
    uint256 tokenId;
    address tokenContract;
    address currency;
    uint256 price;
    uint32 node;
}

struct Block {
    bytes32 block1;
    bytes32 block2;
    bytes32 block3;
    bytes32 block4;
    bytes32 block5;
    bytes32 block6;
    bytes32 block7;
    bytes32 block8;
}
