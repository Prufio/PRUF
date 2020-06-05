// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721.sol";
import "./Ownable.sol";


contract AssetTokenlicense is ERC721, Ownable {
    constructor() public ERC721("BulletProof Asset Token", "BPXA") {}

    mapping(bytes32 => uint8) private registeredAdmins; // Authorized recorder database

    modifier isAdmin() {
        require(
            (registeredAdmins[keccak256(abi.encodePacked(msg.sender))] == 1) ||
                (owner() == msg.sender),
            "address does not belong to an Admin"
        );
        _;
    }

    function mintNewtokenA(
        address reciepientAddress,
        uint256 assetClass,
        string calldata tokenURI
    ) external isAdmin returns (uint256) {
        _safeMint(reciepientAddress, assetClass);
        _setTokenURI(assetClass, tokenURI);

        return assetClass;
    }

    function burnTokenA(uint256 tokenId) external isAdmin {
        _burn(tokenId);
    }

    function transferAssetA(
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

    event REPORT(string _msg);

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
