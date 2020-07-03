// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "./_ERC721/ERC721.sol";
import "./_ERC721/Ownable.sol";
import "./PRUF_interfaces.sol";
import "./Imports/ReentrancyGuard.sol";

contract AssetToken is Ownable, ReentrancyGuard, ERC721 {

    constructor() public ERC721("BulletProof Asset Token", "BPXA") {}

    address internal PrufAppAddress;
    PrufAppInterface internal PrufAppContract; //erc721_token prototype initialization
    address internal storageAddress;
    StorageInterface internal Storage; // Set up external contract interface

    event REPORT(string _msg);

    modifier isAdmin() {
        require(
            (msg.sender == PrufAppAddress) || (msg.sender == owner()),
            "address does not belong to an Admin"
        );
        _;
    }

    function mintAssetToken(
        address _reciepientAddress,
        bytes32 _idxHash,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^checks^^^^^^^^^
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    function transferAssetToken(
        address from,
        address to,
        bytes32 _idxHash
    ) external onlyOwner {
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^checks^^^^^^^^^
        safeTransferFrom(from, to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    function reMintAssetToken(
        address _reciepientAddress,
        bytes32 _idxHash,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        uint256 tokenId = uint256(_idxHash);
        require(_exists(tokenId), "Cannot Remint nonexistant token");
        //^^^^^^^checks^^^^^^^^^
        _burn(tokenId);
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }
}
