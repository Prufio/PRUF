// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "./ERC721.sol";
import "./Ownable.sol";

contract AssetToken is ERC721, Ownable {
    mapping(bytes32 => uint8) private registeredAdmins; // Authorized recorder database

    constructor() public ERC721("BulletProof Asset Token", "BPXA") {}

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
        //^^^^^^^checks^^^^^^^^^
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    function transferAssetToken(
         address from,
        address to,
        uint256 tokenId
    ) external onlyOwner {
        //^^^^^^^checks^^^^^^^^^
        safeTransferFrom(from, to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    function reMintAssetToken(
         address _reciepientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        require(_exists(tokenId), "Cannot Remint nonexistant token");
        //^^^^^^^checks^^^^^^^^^
        _burn(tokenId);
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    function OO_addAssetTokenAdmin(
        address _authAddr,
        uint8 _addAdmin // must make this indelible / permenant???????? SECURITY / trustless goals
    ) external onlyOwner {
        bytes32 addrHash = keccak256(abi.encodePacked(_authAddr));
        require(
            (_addAdmin == 1) || (_addAdmin == 0),
            "Admin status must be 1 or 0"
        );
        //^^^^^^^checks^^^^^^^^^
        registeredAdmins[addrHash] = _addAdmin;
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("internal user database access!"); //report access to the internal user database
        //^^^^^^^interactions^^^^^^^^^
    }
}
