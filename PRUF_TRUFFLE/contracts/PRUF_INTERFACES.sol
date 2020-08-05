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

interface AC_MGR_Interface {
    function getUserType(bytes32 _userHash, uint16 _assetClass)
        external
        view
        returns (uint8);

    function getAC_data(uint16 _assetClass)
        external
        returns (
            uint16,
            uint8,
            uint256
        );

    function isSameRootAC(uint16 _assetClass1, uint16 _assetClass2)
        external
        returns (uint8);

    function getAC_name(uint256 _tokenId) external view returns (string memory);

    function resolveAssetClass(string memory _name) external returns (uint16);

    function ContractAC_auth(uint16 _assetClass, bytes32 _authContractNameHash)
        external
        returns (uint8);

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

    function getNewRecordCosts(uint16 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        );

    function getTransferAssetCosts(uint16 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        );

    function getCreateNoteCosts(uint16 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        );

    function getReMintRecordCosts(uint16 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        );

    function getChangeStatusCosts(uint16 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        );

    function getForceModifyCosts(uint16 _assetClass)
        external
        returns (
            address,
            uint256,
            address,
            uint256
        );
}

interface AC_TKN_Interface {
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

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface A_TKN_Interface {
    function ownerOf(uint256) external returns (address);

    function discard(uint256) external;

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

    function reMintAssetToken(address _recipientAddress, uint256 tokenId)
        external
        returns (uint256);

    function tokenExists(uint256 tokenId) external returns (uint8);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface STOR_Interface {
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart
    ) external;

    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount,
        uint16 _numberOfTransfers
    ) external;

    function changeAC(bytes32 _idxHash, uint16 _newAssetClass) external;

    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        bytes32 _contractNameHash
    ) external;

    function endEscrow(bytes32 _idxHash, bytes32 _contractNameHash) external;

    function setStolenOrLost(bytes32 _idxHash, uint8 _newAssetStatus) external;

    function modifyIpfs1(bytes32 _idxHash, bytes32 _Ipfs1) external;

    function modifyIpfs2(bytes32 _idxHash, bytes32 _Ipfs2) external;

    function retrieveRecord(bytes32 _idxHash)
        external
        returns (
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

    function retrieveShortRecord(
        bytes32 _idxHash //all but rgtHash
    )
        external
        returns (
            uint8,
            uint8,
            uint16,
            uint256,
            uint256,
            bytes32,
            bytes32,
            uint16
        );

    function resolveContractAddress(string calldata _name)
        external
        returns (address);

    function ContractAuthType(address _addr, uint16 _assetClass)
        external
        returns (uint8);

    function ContractInfoHash(address _addr, uint16 _assetClass)
        external
        returns (uint8, bytes32);
}

interface ECR_MGR_Interface {
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        uint8 _data,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock,
        bytes32 _ex1,
        bytes32 _ex2,
        address _addr1,
        address _addr2
    ) external;

    function endEscrow(bytes32 _idxHash) external;

    function PermissiveEndEscrow(bytes32 _idxHash) external;

    function retrieveEscrowOwner(bytes32 _idxHash) external returns (bytes32);

    function retrieveEscrowData(bytes32 _idxHash)
        external
        returns (
            uint8 data,
            bytes32 controllingContractNameHash,
            bytes32 escrowOwnerAddressHash,
            uint256 timelock,
            bytes32 ex1,
            bytes32 ex2,
            address addr1,
            address addr2
        );
}

interface RCLR_Interface {
    function discard(bytes32 _idxHash) external;

    function recycle(bytes32 _idxHash) external;
}
