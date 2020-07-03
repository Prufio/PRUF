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
            "Calling address does not belong to an Admin"
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
     * must be isAdmin
     *
     */
    function mintAssetToken(
        address _reciepientAddress,
        bytes32 _idxHash,
        string calldata _tokenURI
    ) external isAdmin returns (uint256) {
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^checks^^^^^^^^^
                                            //MAKE URI ASSET SPECIFIC- has to incorporate the token ID
        _safeMint(_reciepientAddress, tokenId);
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * must hold token
     * @dev transfer Asset Token
     * verify is in transferrable status
     * set rgt to nonremintable 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
     *
     */
    function transferAssetToken(
        address from,
        address to,
        bytes32 _idxHash
    ) external isAdmin {
        uint256 tokenId = uint256(_idxHash);
        //^^^^^^^checks^^^^^^^^^
        safeTransferFrom(from, to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }


    /*
     * Authorizations?
     * @dev remint Asset Token
     * must set a new and unuiqe rgtHash
     * burns old token
     * Sends new token to original Caller
     */
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
