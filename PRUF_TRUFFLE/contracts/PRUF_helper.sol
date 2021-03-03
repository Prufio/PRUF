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
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Imports/access/Ownable.sol";
import "./PRUF_BASIC.sol";

interface erc721_tokenInterface {
    function ownerOf(uint256) external view returns (address);
}

contract Helper is Ownable, BASIC {
    address erc721ContractAddress;
    erc721_tokenInterface erc721_tokenContract; //erc721_token prototype initialization

    uint256 private ACtokenIndex = 10000;
    uint256 private currentACtokenPrice = 5000;

    function setErc721_tokenAddress(address contractAddress) public onlyOwner {
        require(contractAddress != address(0), "Invalid contract address");
        erc721ContractAddress = contractAddress;
        erc721_tokenContract = erc721_tokenInterface(contractAddress);
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

    function getURIfromAuthcode(uint32 _assetClass, string calldata _authCode)
        external
        pure
        returns (string memory)
    {
        bytes32 _hashedAuthCode = keccak256(abi.encodePacked(_authCode));
        bytes32 b32URI =
            keccak256(abi.encodePacked(_hashedAuthCode, _assetClass));
        string memory authString = uint256toString(uint256(b32URI));

        return authString;
    }

    function getURIb32fromAuthcode(
        uint32 _assetClass,
        string calldata _authCode
    ) external pure returns (bytes32) {
        bytes32 _hashedAuthCode = keccak256(abi.encodePacked(_authCode));
        bytes32 b32URI =
            keccak256(abi.encodePacked(_hashedAuthCode, _assetClass));

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
     * @dev Retrieve AC_data @ _assetClass
     */
    function helper_getExtAC_data(uint32 _assetClass)
        external
        view
        returns (AC memory)
    {
        //^^^^^^^checks^^^^^^^^^
        return AC_MGR.getExtAC_data(_assetClass);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Retrieve AC_data @ _assetClass
     */
    function helper_getExtAC_data_nostruct(uint32 _assetClass)
        external
        view
        returns (
            uint8,
            uint8,
            address,
            bytes32
        )
    {
        AC memory asset_data;
        //^^^^^^^checks^^^^^^^^^
        (
            asset_data.byte1,
            asset_data.byte2,
            asset_data.referenceAddress,
            asset_data.IPFS
        ) = AC_MGR.getExtAC_data_nostruct(_assetClass);

        return (
            asset_data.byte1,
            asset_data.byte2,
            asset_data.referenceAddress,
            asset_data.IPFS
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    function helper_payForService(
        uint32 _assetClass,
        address _senderAddress,
        address _rootAddress,
        uint256 _rootPrice,
        address _ACTHaddress,
        uint256 _ACTHprice
    ) external {
        Invoice memory invoice;

        invoice.rootAddress = _rootAddress;
        invoice.rootPrice = _rootPrice;
        invoice.ACTHaddress = _ACTHaddress;
        invoice.ACTHprice = _ACTHprice;
        invoice.assetClass = _assetClass;

        UTIL_TKN.payForService(_senderAddress, invoice);
    }

    // struct Invoice { //invoice struct to facilitate payment messaging in-contract
    // address rootAddress;
    // uint256 rootPrice;
    // address ACTHaddress;
    // uint256 ACTHprice;

    /*
    struct AC {
    //Struct for holding and manipulating assetClass data
    string name; // NameHash for assetClass
    uint32 assetClassRoot; // asset type root (bycyles - USA Bicycles)
    uint8 custodyType; // custodial or noncustodial, special asset types
    uint32 discount; // price sharing
    uint8 byte1; // Future Use
    uint8 byte2; // Future Use
    uint8 byte3; // Future Use
    address referenceAddress; // Used with wrap / decorate
    bytes32 IPFS; //IPFS data for defining idxHash creation attribute fields
}
    */
}
