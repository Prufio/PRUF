/*-----------------------------------------------------------V0.6.8
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
    function getUserType(bytes32 _userHash, uint32 _assetClass)
        external
        view
        returns (uint8 userTypeInAssetClass);

    function getAC_data(uint32 _assetClass)
        external
        returns (
            uint32 assetClassRoot,
            uint8 custodyType,
            uint32 extendedData
        );

    function isSameRootAC(uint32 _assetClass1, uint32 _assetClass2)
        external
        returns (uint8 uint8_Bool_type_0_170);

    function getAC_name(uint32 _tokenId)
        external
        view
        returns (string memory ACname);

    function resolveAssetClass(string calldata _name)
        external
        returns (uint32 assetClass);

    function ContractAC_auth(uint32 _assetClass, bytes32 _authContractNameHash)
        external
        returns (uint8 contractTypeInAssetClass);

    function retrieveCosts(uint32 _assetClass)
        external
        returns (
            uint256 newRecordCost,
            uint256 transferAssetCost,
            uint256 createNoteCost,
            uint256 reMintRecordCost,
            uint256 changeStatusCost,
            uint256 forceModifyCost,
            address paymentAddress
        );

    function retrieveBaseCosts()
        external
        returns (
            uint256 newRecordCost,
            uint256 transferAssetCost,
            uint256 createNoteCost,
            uint256 reMintRecordCost,
            uint256 changeStatusCost,
            uint256 forceModifyCost,
            address paymentAddress
        );

    function getNewRecordCosts(uint32 _assetClass)
        external
        returns (
            address rootPaymentAddress,
            uint256 rootFunctionCost,
            address paymentAddress,
            uint256 functionCost
        );

    function getTransferAssetCosts(uint32 _assetClass)
        external
        returns (
            address rootPaymentAddress,
            uint256 rootFunctionCost,
            address paymentAddress,
            uint256 functionCost
        );

    function getCreateNoteCosts(uint32 _assetClass)
        external
        returns (
            address rootPaymentAddress,
            uint256 rootFunctionCost,
            address paymentAddress,
            uint256 functionCost
        );

    function getReMintRecordCosts(uint32 _assetClass)
        external
        returns (
            address rootPaymentAddress,
            uint256 rootFunctionCost,
            address paymentAddress,
            uint256 functionCost
        );

    function getChangeStatusCosts(uint32 _assetClass)
        external
        returns (
            address rootPaymentAddress,
            uint256 rootFunctionCost,
            address paymentAddress,
            uint256 functionCost
        );

    function getForceModifyCosts(uint32 _assetClass)
        external
        returns (
            address rootPaymentAddress,
            uint256 rootFunctionCost,
            address paymentAddress,
            uint256 functionCost
        );
}

interface AC_TKN_Interface {
    function ownerOf(uint256 tokenId)
        external
        view
        returns (address tokenHolderAdress);

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function mintACToken(
        address _recipientAddress,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external returns (uint256 tokenId);

    function reMintACToken(
        address _recipientAddress,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external returns (uint256 tokenId);

    function name() external view returns (string memory tokenName);

    function symbol() external view returns (string memory tokenSymbol);

    function tokenURI(uint256 tokenId)
        external
        view
        returns (string memory URI);
}

interface A_TKN_Interface {
    function ownerOf(uint256 tokenId)
        external
        returns (address tokenHolderAdress);

    function discard(uint256 tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function mintAssetToken(
        address _recipientAddress,
        uint256 _tokenId,
        string calldata _tokenURI
    ) external returns (uint256 tokenId);

    function reMintAssetToken(address _recipientAddress, uint256 _tokenId)
        external
        returns (uint256 tokenId);

    function validateNakedToken(  //throws if authcode does not match
        uint256 tokenId,
        uint32 _assetClass,
        string calldata _authCode
    ) external;

    function tokenExists(uint256 tokenId)
        external
        returns (uint8 uint8_Bool_type_0_170);

    function name() external view returns (string memory tokenName);

    function symbol() external view returns (string memory tokenSymbol);

    function setURI(uint256 tokenId, string memory _tokenURI) external;
}

interface STOR_Interface {
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgt,
        uint32 _assetClass,
        uint32 _countDownStart
    ) external;

    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _assetStatus,
        uint32 _countDown,
        uint256 _incrementForceCount,
        uint256 _incrementNumberOfTransfers
    ) external;

    function changeAC(bytes32 _idxHash, uint32 _newAssetClass) external;

    function setEscrow(bytes32 _idxHash, uint8 _newAssetStatus) external;

    function endEscrow(bytes32 _idxHash) external;

    function setStolenOrLost(bytes32 _idxHash, uint8 _newAssetStatus) external;

    function modifyIpfs1(bytes32 _idxHash, bytes32 _Ipfs1) external;

    function modifyIpfs2(bytes32 _idxHash, bytes32 _Ipfs2) external;

    function retrieveRecord(bytes32 _idxHash)
        external
        returns (
            bytes32 rightsHolder,
            uint8 assetStatus,
            uint32 assetClass,
            uint32 countDown,
            uint32 countDownStart,
            bytes32 Ipfs1,
            bytes32 Ipfs2
        );

    function resolveContractAddress(string calldata _name)
        external
        returns (address addressOfNamedContract);

    function ContractInfoHash(address _addr, uint32 _assetClass)
        external
        returns (uint8 contractTypeInAssetClass, bytes32 hashOfContractName);
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

    function permissiveEndEscrow(bytes32 _idxHash) external;

    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        returns (bytes32 hashOfEscrowOwnerAdress);

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

interface APP_Interface {
    function transferAssetToken(address _to, bytes32 _idxHash) external;
}
