// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC721Receiver.sol";
import "./Ownable.sol";


interface erc721AC_tokenInterface {
    function mintAssetClassToken(
        address reciepientAddress,
        uint256 assetClass,
        string calldata tokenURI
    ) external;

    function burnAssetClassToken(uint256 tokenId) external;

    function transferAssetClassToken(
        address from,
        address to,
        uint256 tokenId
    ) external;
}


interface erc721A_tokenInterface {
    function mintAssetToken(
        address reciepientAddress,
        uint256 assetClass,
        string calldata tokenURI
    ) external;

    function burnAssetToken(uint256 tokenId) external;

    function transferAssetToken(
        address from,
        address to,
        uint256 tokenId
    ) external;
}


contract BPMinter is IERC721Receiver, Ownable {
    address erc721ACContractAddress;
    erc721AC_tokenInterface private erc721AC_tokenContract;

    address erc721AContractAddress;
    erc721A_tokenInterface private erc721A_tokenContract;

    ///Admin Functions
    function OO_setErc721AC_tokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        erc721ACContractAddress = _contractAddress;
        erc721AC_tokenContract = erc721AC_tokenInterface(_contractAddress);
    }

    function OO_setErc721A_tokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        erc721AContractAddress = _contractAddress;
        erc721A_tokenContract = erc721A_tokenInterface(_contractAddress);
    }

    ///Functionality Functions
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    ///ACtoken Functions
    function mintAC(
        address to,
        uint256 tokenId,
        string calldata tokenURI
    ) external virtual {
        erc721AC_tokenContract.mintAssetClassToken(to, tokenId, tokenURI);
    }

    function transferAC(
        address from,
        address to,
        uint256 tokenId
    ) external virtual {
        erc721AC_tokenContract.transferAssetClassToken(from, to, tokenId);
    }

    function burnAC(uint256 tokenId) external virtual {
        erc721AC_tokenContract.burnAssetClassToken(tokenId);
    }

    ///Atoken Functions
    function mintA(
        address to,
        uint256 tokenId,
        string calldata tokenURI
    ) external virtual {
        erc721A_tokenContract.mintAssetToken(to, tokenId, tokenURI);
    }

    function transferA(
        address from,
        address to,
        uint256 tokenId
    ) external virtual {
        erc721A_tokenContract.transferAssetToken(from, to, tokenId);
    }

    function burnA(uint256 tokenId) external virtual {
        erc721A_tokenContract.burnAssetToken(tokenId);
    }
}
