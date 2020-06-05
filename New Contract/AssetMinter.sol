// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721/IERC721Receiver.sol";
import "./Ownable.sol";


// function transferAssetToken(
//     address _from,
//     address _to,
//     bytes32 _idxHash
// ) external isAdmin {
//     safeTransferFrom(_from, _to, tokenId);
// }

//sets rgtHash in storage _to "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

//then transfers token

// only listens _to minter contract _to mint
// only listents _to minter contract _to burn
// _safeTransferFrom must be intenal not external,
///OO Functions

// interface erc721AC_tokenInterface {
//     function mintAssetClassToken(
//         address reciepientAddress,
//         uint256 assetClass,
//         string calldata _tokenURI
//     ) external;

//     function burnAssetClassToken(bytes32 _idxHash) external;

//     function transferAssetClassToken(
//         address _from,
//         address _to,
//         bytes32 _idxHash
//     ) external;
// }

interface StorageInterface {
    function newRecord(
        address message_origin,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external;

    function modifyRecord(
        address message_origin,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount
    ) external;

    function modifyIpfs(
        address message_origin,
        bytes32 _idxHash,
        bytes32 _Ipfs1,
        bytes32 _Ipfs2
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


interface AssetTokenInterface {
    function mintAssetToken(
        address reciepientAddress,
        bytes32 idxHash,
        string calldata _tokenURI
    ) external;

    function reMintAssetToken(
        address reciepientAddress,
        bytes32 idxHash,
        string calldata _tokenURI
    ) external;

    function transferAssetToken(
        address from,
        address to,
        bytes32 idxHash
    ) external;
}


interface AssetClassTokenInterface {
    function mintAssetClassToken(
        address reciepientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external;

    function reMintAssetClassToken(
        address reciepientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external;

    function transferAssetClassToken(
        address from,
        address to,
        uint256 tokenId
    ) external;
}


contract AssetMinter is IERC721Receiver, Ownable {

    address private mainWallet;
    address private storageAddress;
    address private assetClassTokenContractAddress;
    address private assetTokenContractAddress;

    StorageInterface private Storage;
    AssetClassTokenInterface private AssetClassTokenContract;
    AssetTokenInterface private AssetTokenContract;

    /*
     * @dev Admin functions
     */
    function OO_setAssetClassTokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        assetClassTokenContractAddress = _contractAddress;
        AssetClassTokenContract = AssetClassTokenInterface(_contractAddress);
    }

    function OO_setAssetTokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        assetTokenContractAddress = _contractAddress;
        AssetTokenContract = AssetTokenInterface(_contractAddress);
    }

    /*
     * @dev Set storage contract to interface with
     */
    function _setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "ADMIN: storage address cannot be zero"
        );

        Storage = StorageInterface(_storageAddress);
    }

    /*
     * @dev Set wallet for contract to direct payments to
     */
    function _setMainWallet(address _addr) external onlyOwner {
        mainWallet = _addr;
    }

    /*
     * @dev Token / storage interactions --------------------FINISH WITH STORAGE INTEGRATIONQ!!!!!!!!!!!!!!!
     asset class < 30000 dont need asset tokens
     asset classes 60000 + not permitted
     asset class tokens are payable at 1 eth
     create new record > 30k mints a coresponding asset class token

     functionality in minter for recovering lost assets and re-minting lost tokens.
     When an asset is generated and token is minted, a user can enter an optional passphrase.
     the paassphrase generates a hash H (off-chain) which is stored in a map (onchain), mapped to the tokenID / asset IDXhash.
     when re-minting is requested, the user must supply raw text that generates (in contract) an identical hash H.
     If H=H, the existing record @idxhash is overwritten, and the token @TokenID is burned, and a new one @tokenID is sent to the requester address.

     */

    function newRecord{}
    function burnRecord{} ////////////????????
    function reMintRecord{} //////////requires a secret in rgtHash, only for AC>30k, sets secret to 0XFF...
    function setSecret{} //sets RightsHolder if you hold the token (AC>30k)  ??place in storage? mod to FMR?


    function mintAssetToken(
        address _to,
        bytes32 _idxHash,
        string memory _tokenURI
    ) private {
        AssetTokenContract.mintAssetToken(_to, _idxHash, _tokenURI);
    }

    function reMintAssetToken(
        address _to,
        bytes32 _idxHash,
        string memory _tokenURI
    ) private {
        AssetTokenContract.mintAssetToken(_to, _idxHash, _tokenURI);
    }

    function mintAssetClassToken(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) private {
        AssetClassTokenContract.mintAssetClassToken(_to, _tokenId, _tokenURI);
    }

    function reMintAssetClassToken(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) private {
        AssetClassTokenContract.mintAssetClassToken(_to, _tokenId, _tokenURI);
    }

    function tranferAssetToken(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
    {
        AssetTokenContract.transferAssetToken(address(this), _to, _idxHash);
    }

    function transferAssetClassToken(address _to, uint256 _tokenId)
        external
        virtual
        onlyOwner
    {
        AssetClassTokenContract.transferAssetClassToken(
            address(this),
            _to,
            _tokenId
        );
    }

    ///Functionality Functions   //////////
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
