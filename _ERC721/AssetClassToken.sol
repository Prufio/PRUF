// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721.sol";
import "./Ownable.sol";


contract AssetClassToken is ERC721, Ownable {
    mapping(bytes32 => uint8) private registeredAdmins; // Authorized recorder database

    constructor() public ERC721("BulletProof Asset Class Token", "BPXAC") {}

    event REPORT(string _msg);

    modifier isAdmin() {
        require(
            (registeredAdmins[keccak256(abi.encodePacked(msg.sender))] == 1) ||
                (owner() == msg.sender),
            "address does not belong to an Admin"
        );
        _;
    }

    function mintAssetToken(
        address _reciepientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        return tokenId;
    }

    function transferAssetToken(
        address from,
        address to,
        uint256 tokenId
    ) external onlyOwner {
        safeTransferFrom(from, to, tokenId);
    }

    function reMintAssetToken(
        address _reciepientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        require(_exists(tokenId), "Cannot Remint nonexistant token");
        _burn(tokenId);
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);

        return tokenId;
    }

    function OO_addAdmin(
        address _authAddr,
        uint8 _addAdmin // must make this indelible / permenant???????? SECURITY / trustless goals
    ) external onlyOwner {
        bytes32 addrHash = keccak256(abi.encodePacked(_authAddr));

        require(_addAdmin == 1, "Admin not added");

        registeredAdmins[addrHash] = _addAdmin;
        emit REPORT("internal user database access!"); //report access to the internal user database
    }
}
