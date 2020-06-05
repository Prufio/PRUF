// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721.sol";
import "./Ownable.sol";


contract AssetTokenlicense is ERC721, Ownable {
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
        address reciepientAddress,
        uint256 assetClass,
        string calldata tokenURI
    ) external isAdmin returns (uint256) {
        _safeMint(reciepientAddress, assetClass);
        _setTokenURI(assetClass, tokenURI);

        return assetClass;
    }

    function burnAssetToken(uint256 tokenId) external isAdmin {
        _burn(tokenId);
    }

    function transferAssetToken(
        address from,
        address to,
        uint256 tokenId
    ) external isAdmin {
        safeTransferFrom(from, to, tokenId);
    } //sets rgtHash in storage to "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

    //then transfers token

    // only listens to minter contract to mint
    // only listents to minter contract to burn
    // _safeTransferFrom must be intenal not external,
    ///OO Functions

    function OO_addAdmin(address _authAddr, uint8 _addAdmin)
        external
        onlyOwner
    {
        bytes32 addrHash = keccak256(abi.encodePacked(_authAddr));

        require(_addAdmin == 1, "Admin not added");

        registeredAdmins[addrHash] = _addAdmin;
        emit REPORT("internal user database access!"); //report access to the internal user database
    }
}
