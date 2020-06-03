// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC721Receiver.sol";
import "./Ownable.sol";


interface erc721AC_tokenInterface {
    function _safeMint(address to, uint256 tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function _approve(address to, uint256 tokenId) external;
}


interface erc721A_tokenInterface {
    function _safeMint(address to, uint256 tokenId) external;

    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function _approve(address to, uint256 tokenId) external;
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
        bytes memory
    ) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    ///ACtoken Functions
    function mintAC(address to, uint256 tokenId) public virtual {
        erc721AC_tokenContract._safeMint(to, tokenId);
    }

    function transferAC(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        erc721AC_tokenContract.safeTransferFrom(from, to, tokenId);
    }

    function approveAC(address to, uint256 tokenId) public virtual {
        erc721AC_tokenContract._approve(to, tokenId);
    }

    ///Atoken Functions
    function mintA(address to, uint256 tokenId) public virtual {
        erc721A_tokenContract._safeMint(to, tokenId);
    }

    function transferA(
        address from,
        address to,
        uint256 tokenId
    ) external virtual {
        erc721A_tokenContract.safeTransferFrom(from, to, tokenId);
    }

    function approveA(address to, uint256 tokenId) public virtual {
        erc721A_tokenContract._approve(to, tokenId);
    }

}
