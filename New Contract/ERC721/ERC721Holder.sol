// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721.sol";
import "./IERC721Receiver.sol";

contract BPMinter is IERC721Receiver, ERC721 {
    function onERC721Received(address, address, uint256, bytes memory) public virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
    constructor() ERC721("BulletproofToken", "BPT") public { }

    function mint(address to, uint256 tokenId) public virtual {
        _safeMint(to, tokenId, "");
    }

    function transfer(
        address from,
        address to,
        uint256 tokenId
    ) public virtual {
        safeTransferFrom(from, to, tokenId, "");
    }
}