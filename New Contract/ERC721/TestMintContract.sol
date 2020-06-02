
pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./IERC721Receiver.sol";
import "./ERC165.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./Strings.sol";
import "./ERC721.sol";
import "./Ownable.sol";

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://eips.ethereum.org/EIPS/eip-721
 */
contract BulletProofMinter is ERC721, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using Strings for uint256;

   
    function mint(address to, uint256 tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }
   
    function safeTransferFrom(address from, address to, uint256 tokenId) public virtual override {
        safeTransferFrom(from, to, tokenId, "");
    }

}