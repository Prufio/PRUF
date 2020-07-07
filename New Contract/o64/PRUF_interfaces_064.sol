// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

interface PrufAppInterface {
    function getUserExt(bytes32 _userHash)
        external
        view
        returns (uint8, uint16);
}

interface AssetClassTokenManagerInterface {
    function retrieveCosts(uint16 _assetClass)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function retrieveBaseCosts()
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            address
        );

    function createAssetClass(
        uint256 _tokenId,
        address _recipientAddress,
        string calldata _name,
        uint16 _assetClass,
        uint16 _assetClassRoot,
        uint8 _custodyType
    ) external;

    function getAC_data(uint16 _assetClass)
        external
        returns (
            uint16,
            uint8,
            uint256
        );

    function resolveAssetClass(string memory _name)
        external
        view
        returns (uint16);
}

interface AssetClassTokenInterface {
    function ownerOf(uint256) external view returns (address);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function mintACToken(
        address _recipientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external returns (uint256);

    function reMintACToken(
        address _recipientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external returns (uint256);
}

interface AssetTokenInterface {
    function ownerOf(uint256) external view returns (address);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function mintAssetToken(
        address _recipientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external returns (uint256);

    function reMintAssetToken(
        address _recipientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external returns (uint256);
}

interface StorageInterface {
    function newRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external;

    function modifyRecord(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount,
        uint16 _numberOfTransfers
    ) external;

    function setEscrow(
        bytes32 _userHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        uint256 _escrowTime
    ) external;

    function endEscrow(bytes32 _userHash, bytes32 _idxHash) external;

    function setStolenOrLost(
        bytes32 _userHash,
        bytes32 _idxHash,
        uint8 _newAssetStatus
    ) external;

    function modifyIpfs1(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs1
    ) external;

    function modifyIpfs2(
        bytes32 _userHash,
        bytes32 _idxHash,
        bytes32 _Ipfs2
    ) external;

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
            bytes32,
            uint16
        );

    function retrieveShortRecord(bytes32 _idxHash)
        external
        returns (
            bytes32,
            bytes32,
            uint8,
            uint8,
            uint16,
            uint256,
            uint256,
            bytes32,
            bytes32,
            uint16,
            uint256
        );

    function resolveContractAddress(string calldata _name)
        external
        returns (address);
}