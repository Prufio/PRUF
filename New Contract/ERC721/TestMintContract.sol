// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721.sol";
import "./Ownable.sol";


contract BulletProofMinter is ERC721, Ownable {

constructor() ERC721("BulletproofToken", "BPT") public { }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external virtual returns (bytes4) {

    }

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
