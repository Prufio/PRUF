// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721.sol";
import "./Ownable.sol";


contract AssetClasslicense is ERC721, Ownable {
    constructor() public ERC721("BulletProof Asset Class License", "BPXAC") {}

    function mintNewtokenAC(
        address reciepientAddress,
        uint256 assetClass,
        string calldata tokenURI
    ) external onlyOwner returns (uint256) {
        _safeMint(reciepientAddress, assetClass);
        _setTokenURI(assetClass, tokenURI);

        return assetClass;
    }

    function burnTokenAC(uint256 tokenId) external onlyOwner {
        _burn(tokenId);
    }

    function transferAssetAC(
        address from,
        address to,
        uint256 tokenId
    ) external onlyOwner {
        safeTransferFrom(from, to, tokenId);
    } //sets rgtHash in storage to "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
    //then transfers token

    // only listens to minter contract to mint
    // only listents to minter contract to burn
    // _safeTransferFrom must be intenal not external,
}
