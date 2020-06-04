pragma solidity ^0.6.0;

import "./ERC721.sol";
import "./Ownable.sol";

contract AClicense is ERC721 {


    constructor() ERC721("BulletProof Asset Class License", "BPXAC") public {
    }

    function mintNewACtoken(address reciepientAddress, uint256 assetClass, string memory tokenURI) public returns (uint256) {

        _safeMint(reciepientAddress, assetClass);
        _setTokenURI(assetClass, tokenURI);

        return newItemId;
    }

    function burnToken {}
    function transferAsset{} //sets rhtHash in storage to "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"
    //then transfers token

    // only listens to minter contract to mint
    // only listents to minter contract to burn
    // _safeTransferFrom must be intenal not external, 
}