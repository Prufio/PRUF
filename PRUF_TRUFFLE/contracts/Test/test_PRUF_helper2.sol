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

import "../Imports/access/Ownable.sol";
import "../Resources/PRUF_BASIC.sol";

interface erc721_tokenInterface2 {
    function ownerOf(uint256) external view returns (address);
}

contract Helper2 is Ownable, BASIC {
    address erc721ContractAddress;
    erc721_tokenInterface2 erc721_tokenContract; //erc721_token prototype initialization

    uint256 private nodeTokenIndex = 10000;
    uint256 private currentNodeTokenPrice = 5000;

    function setErc721_tokenAddress(address contractAddress) public onlyOwner {
        require(contractAddress != address(0), "Invalid contract address");
        erc721ContractAddress = contractAddress;
        erc721_tokenContract = erc721_tokenInterface2(contractAddress);
    }

    function atWhatAddress(uint256 tokenId)
        external
        view
        onlyOwner
        returns (address)
    {
        return erc721_tokenContract.ownerOf(tokenId);
    }

    function atWhatAddressTokenB32(bytes32 _tokenB32)
        external
        view
        onlyOwner
        returns (address)
    {
        uint256 tokenId = uint256(_tokenB32);
        return erc721_tokenContract.ownerOf(tokenId);
    }

    function atMyAddress(uint256 tokenId)
        external
        view
        returns (string memory)
    {
        if (erc721_tokenContract.ownerOf(tokenId) == _msgSender()) {
            return "token confirmed at sender address";
        } else {
            return "token not at sender address";
        }
    }

    function getBlock() external view returns (uint256) {
        return (block.number);
    }

    function getTime() external view returns (uint256) {
        return (block.timestamp);
    }

    function getStringHash(string calldata _idx)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_idx));
    }

    function getHashOfUint256AndAddress(uint256 _idx, address _address)
        external
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(_idx, _address));
    }

    function getB32Hash(bytes32 _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function getAddrHash(address _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function getAddrUint160(address _idx) external pure returns (uint160) {
        return uint160(_idx);
    }

    function getUint256Hash(uint256 _idx) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(_idx));
    }

    function b32_to_uint256(bytes32 b32) external pure returns (uint256) {
        return uint256(b32);
    }

    function uint256_to_b32(uint256 u256) external pure returns (bytes32) {
        return bytes32(u256);
    }

    function getIdxHash(
        string memory _idx_type,
        string memory _idx_mfg,
        string memory _idx_mod,
        string memory _idx_ser
    ) external pure returns (bytes32) {
        bytes32 idxHash;
        idxHash = keccak256(
            abi.encodePacked(_idx_type, _idx_mfg, _idx_mod, _idx_ser)
        );
        return (idxHash);
    }

    function getRgtHash(
        bytes32 _idxHash,
        string memory _rgt_first,
        string memory _rgt_mid,
        string memory _rgt_last,
        string memory _rgt_ID,
        string memory _rgt_secret
    ) external pure returns (bytes32, bytes32) {
        bytes32 rawRgtHash;

        rawRgtHash = keccak256(
            abi.encodePacked(
                _rgt_first,
                _rgt_mid,
                _rgt_last,
                _rgt_ID,
                _rgt_secret
            )
        );
        return (rawRgtHash, keccak256(abi.encodePacked(_idxHash, rawRgtHash)));
    }

    function getJustRgtHash(
        bytes32 _idxHash,
        string memory _rgt_first,
        string memory _rgt_mid,
        string memory _rgt_last,
        string memory _rgt_ID,
        string memory _rgt_secret
    ) external pure returns (bytes32) {
        bytes32 rawRgtHash;

        rawRgtHash = keccak256(
            abi.encodePacked(
                _rgt_first,
                _rgt_mid,
                _rgt_last,
                _rgt_ID,
                _rgt_secret
            )
        );
        return (keccak256(abi.encodePacked(_idxHash, rawRgtHash)));
    }

    function getFuckyRgtHash(
        bytes32 _idxHash,
        string memory _rgt_first,
        string memory _rgt_mid,
        string memory _rgt_last,
        string memory _rgt_ID,
        string memory _rgt_secret
    ) external pure returns (bytes32) {
        bytes32 rawRgtHash;

        rawRgtHash = keccak256(
            abi.encodePacked(
                _rgt_first,
                _rgt_mid,
                _rgt_last,
                _rgt_ID,
                _rgt_secret,
                _idxHash
            )
        );
        return rawRgtHash;
    }

    function getURIfromAuthcode(uint32 _node, string calldata _authCode)
        external
        pure
        returns (string memory)
    {
        bytes32 _hashedAuthCode = keccak256(abi.encodePacked(_authCode));
        bytes32 b32URI =
            keccak256(abi.encodePacked(_hashedAuthCode, _node));
        string memory authString = uint256toString(uint256(b32URI));

        return authString;
    }

    function getURIb32fromAuthcode(
        uint32 _node,
        string calldata _authCode
    ) external pure returns (bytes32) {
        bytes32 _hashedAuthCode = keccak256(abi.encodePacked(_authCode));
        bytes32 b32URI =
            keccak256(abi.encodePacked(_hashedAuthCode, _node));

        return b32URI;
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function uint256toString(uint256 value)
        internal
        pure
        returns (string memory)
    {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        // value = uint256(0x2ce8d04a9c35987429af538825cd2438cc5c5bb5dc427955f84daaa3ea105016);

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /*
     * @dev Retrieve node_data @ _node
     */
    function helper_getExtendedNodeData(uint32 _node)
        external view
        returns (Node memory)
    {
        //^^^^^^^checks^^^^^^^^^
        return NODE_MGR.getExtendedNodeData(_node);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve node_data @ _node
     */
    function helper_getExtendedNodeData_nostruct(uint32 _node)
        external view
        returns (
            uint8,
            address,
            uint8,
            bytes32,
            bytes32
        )
    {
        Node memory nodeData = NODE_MGR.getExtendedNodeData(_node);

        return (
            nodeData.storageProvider,
            nodeData.referenceAddress,
            nodeData.switches,
            nodeData.CAS1,
            nodeData.CAS2
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    function helper_payForService(
        //uint32 _node,
        //address _senderAddress,
        address _rootAddress,
        uint256 _rootPrice,
        address _NTHaddress,
        uint256 _NTHprice
    ) external {
        Invoice memory invoice;

        invoice.rootAddress = _rootAddress;
        invoice.rootPrice = _rootPrice;
        invoice.NTHaddress = _NTHaddress;
        invoice.NTHprice = _NTHprice;
        //invoice.node = _node;

        //UTIL_TKN.payForService(_msgSender(), invoice); //-- NON LEGACY TOKEN CONTRACT

        UTIL_TKN.payForService( //LEGACY TOKEN CONTRACT
            _msgSender(),
            invoice.rootAddress,
            invoice.rootPrice,
            invoice.NTHaddress,
            invoice.NTHprice
        );
    }

    // struct Invoice { //invoice struct to facilitate payment messaging in-contract
    // address rootAddress;
    // uint256 rootPrice;
    // address NTHaddress;
    // uint256 NTHprice;

    /*
    struct node {
    //Struct for holding and manipulating node data
    string name; // NameHash for node
    uint32 nodeRoot; // asset type root (bycyles - USA Bicycles)
    uint8 custodyType; // custodial or noncustodial, special asset types
    uint32 discount; // price sharing
    uint8 storageProvider; // Future Use
    uint8 switches; // Future Use
    uint8 byte3; // Future Use
    address referenceAddress; // Used with wrap / decorate
    bytes32 content adressable storage; //content adressable storage data for defining idxHash creation attribute fields
}
    */
}
