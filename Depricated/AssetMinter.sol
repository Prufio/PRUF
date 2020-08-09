// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721/IERC721Receiver.sol";
import "./Ownable.sol";


// function transferAssetToken(
//     address _from,
//     address _to,
//     bytes32 _idxHash
// ) external isAdmin {
//     safeTransferFrom(_from, _to, tokenId);
// }

//sets rgtHash in storage _to "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF"

//then transfers token

// only listens _to minter contract _to mint
// only listents _to minter contract _to burn
// _safeTransferFrom must be intenal not external,
///OO Functions

// interface erc721AC_tokenInterface {
//     function mintAssetClassToken(
//         address reciepientAddress,
//         uint256 assetClass,
//         string calldata _tokenURI
//     ) external;

//     function burnAssetClassToken(bytes32 _idxHash) external;

//     function transferAssetClassToken(
//         address _from,
//         address _to,
//         bytes32 _idxHash
//     ) external;
// }

interface StorageInterface {
    function newRecord(
        address message_origin,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs1
    ) external;

    function modifyRecord(
        address message_origin,
        bytes32 _idxHash,
        bytes32 _rgt,
        uint8 _assetStatus,
        uint256 _countDown,
        uint8 _forceCount
    ) external;

    function modifyIpfs(
        address message_origin,
        bytes32 _idxHash,
        bytes32 _Ipfs1,
        bytes32 _Ipfs2
    ) external;

    function retrieveCosts(uint16 _assetClass)
        external
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        );

    function retrieveRecord(bytes32 _idxHash)
        external
        returns (
            bytes32,
            bytes32,
            bytes32,
            uint8,
            uint8,
            uint16,
            uint256,
            uint256,
            bytes32,
            bytes32
        );
}


interface AssetTokenInterface {
    function mintAssetToken(
        address reciepientAddress,
        bytes32 idxHash,
        string calldata _tokenURI
    ) external;

    function reMintAssetToken(
        address reciepientAddress,
        bytes32 idxHash,
        string calldata _tokenURI
    ) external;

    function transferAssetToken(
        address from,
        address to,
        bytes32 idxHash
    ) external;
}


interface AssetClassTokenInterface {
    function mintAssetClassToken(
        address reciepientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external;

    function reMintAssetClassToken(
        address reciepientAddress,
        uint256 tokenId,
        string calldata _tokenURI
    ) external;

    function transferAssetClassToken(
        address from,
        address to,
        uint256 tokenId
    ) external;
}


contract AssetMinter is IERC721Receiver, Ownable {

    address private mainWallet;
    address private storageAddress;
    address private assetClassTokenContractAddress;
    address private assetTokenContractAddress;

    StorageInterface private Storage;
    AssetClassTokenInterface private AssetClassTokenContract;
    AssetTokenInterface private AssetTokenContract;

    /*
     * @dev Admin functions
     */
    function OO_setAssetClassTokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        assetClassTokenContractAddress = _contractAddress;
        AssetClassTokenContract = AssetClassTokenInterface(_contractAddress);
    }

    function OO_setAssetTokenAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        assetTokenContractAddress = _contractAddress;
        AssetTokenContract = AssetTokenInterface(_contractAddress);
    }

    /*
     * @dev Set storage contract to interface with
     */
    function _setStorageContract(address _storageAddress) external onlyOwner {
        require(
            _storageAddress != address(0),
            "ADMIN: storage address cannot be zero"
        );

        Storage = StorageInterface(_storageAddress);
    }

    /*
     * @dev Set wallet for contract to direct payments to
     */
    function _setMainWallet(address _addr) external onlyOwner {
        mainWallet = _addr;
    }

    /*
     * @dev Token / storage interactions --------------------FINISH WITH STORAGE INTEGRATIONQ!!!!!!!!!!!!!!!
     asset class < 30000 dont need asset tokens
     asset classes 60000 + not permitted
     asset class tokens are payable at 1 eth
     create new record > 30k mints a coresponding asset class token
     */

    //magic numbers
    // 0x0 is not allowed, record with idxHash == 0x0 is considered nonexistant
    // 0xFF.... is not usable, but is settable to a usable rgtHash by the token holder only
    // 0x0000000...1 is locked and cannot be reminted, rgtholder cannot be changed.

    function newRecord{}// creates new record, 
                        // mints token if AC>30k. 
                        // caller must hold ACtoken for specified assetclass or AC>60k
                        // set rgtHash to 0xFF //hardcoded
                        // record must not exist 

    function setSecret{} // Changes rightsHolder for tokenized assets 
                            // AC >= 30k only
                            // caller must hold assetToken
                            // Cannot be modified if rgtHash = 0x000...1 (tokenized asset locked and not remintable)
                            // in minter (or storage)
                            // rgtHash can be set to 0xFF.... (changable in the future)or the rgtHash can be set to 0x00...1,
                            // which prevents rgthash change or reminting
                            // The paassphrase generates a hash H (off-chain) which is stored in the rgtHash mapped to the asset IDXhash.

    function reMintRecord{} // Mint a new token and generate a new record on an existing idxHash
                            // msg.sender can be anyone
                            // idx must refer to an exisitng tokenized asset (>30k)
                            // Caller must supply plaintext that will generate the existing rghtHash (secret)
                            // burns existing token
                            // issues a new token at tokenId = idxHash to msg.sender address
                            // set rgtHash to 0xFF
                            // direct to minter

    //function burnRecord{} //  sets rghtholder to 0x0, burns token if token exists. Only can be executed by token holder
    
    function assetImport{}  // brings an existing asset into a new asset class. 
                            // passed messageOrigin address must hold the assetToken
                            // import request must include the plaintext secret that generates the rgtHash 
                            IF NOT DIRECT INTERACTION WITH MINTER, CONTRACT CAN STEAL HIS RGTHASH PASSWORD
                            // if new AC < 30k burns token (asset classes < 30k have no token)
                            // Requires that asset status is set to exportable (status 100?) 
                            // caller must hold ACtoken for new assetClass 
                            // not available > 60k (no ACtokens over 60k anyway)


    function assetExport{}  // set asset status to exportable (100?)
                            // 
                            // If no token exists : creates a token at tokenId = idxHash that must have a secret rgtHash (generated clientside)
                            IF NOT DIRECT INTERACTION WITH MINTER, hostile CONTRACT CAN MITM HIS RGTHASH PASSWORD
                            // how do protect from serbian bobs malicious contract for assets with no token?
                            // 
                    
                 


    function mintAssetToken(  //allow minting for existing assets
        address _to,
        bytes32 _idxHash,
        string memory _tokenURI
    ) private {
        AssetTokenContract.mintAssetToken(_to, _idxHash, _tokenURI);
    }

    function reMintAssetToken(
        address _to,
        bytes32 _idxHash,
        string memory _tokenURI
    ) private {
        AssetTokenContract.mintAssetToken(_to, _idxHash, _tokenURI);
    }

    function mintAssetClassToken(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) private {
        AssetClassTokenContract.mintAssetClassToken(_to, _tokenId, _tokenURI);
    }

    function reMintAssetClassToken(
        address _to,
        uint256 _tokenId,
        string memory _tokenURI
    ) private {
        AssetClassTokenContract.mintAssetClassToken(_to, _tokenId, _tokenURI);
    }

    function tranferAssetToken(address _to, bytes32 _idxHash)
        external
        virtual
        onlyOwner
    {
        AssetTokenContract.transferAssetToken(address(this), _to, _idxHash);
    }

    function transferAssetClassToken(address _to, uint256 _tokenId)
        external
        virtual
        onlyOwner
    {
        AssetClassTokenContract.transferAssetClassToken(
            address(this),
            _to,
            _tokenId
        );
    }

    ///Functionality Functions   //////////
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
