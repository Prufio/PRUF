// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "./_ERC721/ERC721.sol";
import "./_ERC721/Ownable.sol";
import "./PRUF_interfaces.sol";
import "./Imports/ReentrancyGuard.sol";

contract AssetClassToken is Ownable, ReentrancyGuard, ERC721 {
    constructor() public ERC721("BulletProof Asset Class Token", "BPXAC") {}

    address internal PrufAppAddress;
    PrufAppInterface internal PrufAppContract; // prototype initialization  //change to the acadmin contract
    address internal storageAddress;
    StorageInterface internal Storage; // Set up external contract interface

    event REPORT(string _msg);

    modifier isAdmin() {
        require(
            msg.sender == owner(), //add token admins here
            "address does not belong to an Admin"
        );
        _;
    }

    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//

    /*
     * @dev Set storage contract to interface with
     */
    function OO_setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "PC:SSC: storage address cannot be zero"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage = StorageInterface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Address Setters
     */
    function OO_ResolveContractAddresses() external nonReentrant onlyOwner {
        //^^^^^^^checks^^^^^^^^^

        PrufAppAddress = Storage.resolveContractAddress("PRUF_APP");
        PrufAppContract = PrufAppInterface(PrufAppAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev MINT
     */
    function mintAssetClassToken(
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

    /*
     * @dev Transfer
     */
    function transferAssetClassToken(
        address from,
        address to,
        uint256 tokenId
    ) external onlyOwner {
        //^^^^^^^checks^^^^^^^^^
        safeTransferFrom(from, to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev reMINT
     */
    function reMintAssetClassToken(
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
}
