/**--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

/**-----------------------------------------------------------------
 *  TO DO ---
 *
 *-----------------------------------------------------------------
 * Wraps and unwraps ERC721 compliant tokens in a PRUF Asset token
 *  MUST BE TRUSTED AGENT IN CNSGN_TKN
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract Market is CORE {
    struct ConsignmentTags {
        uint256 tokenID;
        address tokenContract;
        address currency;
        uint256 price;
    }

    address internal CNSGN_TKN_Address;
    CNSGN_TKN_Interface internal CNSGN_TKN;

    mapping(uint256 => ConsignmentTags) private wrapped; // pruf tokenID -> original TokenID, ContractAddress

    /**
     * @dev Verify user credentials
     * @param _tokenID tokenID of token
     * @param _tokenContract Contract to check
     * Originating Address:
     *    require that user holds token @ ID-Contract
     */
    modifier isTokenHolder(uint256 _tokenID, address _tokenContract) {
        require(
            (IERC721(_tokenContract).ownerOf(_tokenID) == _msgSender()),
            "W:MOD-ITH: Caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Wraps a token, takes original from caller
     * @param _foreignTokenID tokenID of token to wrap
     * @param _foreignTokenContract contract address for token to wrap
     * @param _currency currency to make transaction in
     * @param _price price in _currency to require for transfer
     * Prerequisite: contract authorized for token txfr
     * Takes original 721
     * Makes a pruf record (exists?) if so does not change
     * Mints a pruf token to caller (exists?) if so ???????
     * Node.custodyType must be 5 (wrapped/decorated erc721) / enabled for contract address
     * referenceAddress must be '0' or ERC721 contract address
     *
     */
    function consign(uint256 _foreignTokenID, address _foreignTokenContract, address _currency, uint256 _price)
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_foreignTokenID, _foreignTokenContract) 
    { // without this, the dark forest gets it!
        bytes32 consignmentTag = keccak256(
            abi.encodePacked(_foreignTokenID, _foreignTokenContract)
        );

        if (_foreignTokenContract == A_TKN_Address) {
            bytes32 idxHash = bytes32(_foreignTokenID);
            Record memory rec = getRecord(idxHash);
            require(
                rec.assetStatus == 51,
                "CM:C:PRUF asset is not status 51 (transferrable)"
            );
            A_TKN.trustedAgentTransferFrom(_msgSender(), address(this), _foreignTokenID); //takes PRUF asset usint TRUSTED_AGENT_ROLE
        }

        uint256 newTokenId = uint256(consignmentTag);

        //^^^^^^^checks^^^^^^^^^

        wrapped[newTokenId].tokenID = _foreignTokenID;
        wrapped[newTokenId].tokenContract = _foreignTokenContract;
        wrapped[newTokenId].currency = _currency;
        wrapped[newTokenId].price = _price;
        //^^^^^^^effects^^^^^^^^^

        foreignTransfer(
            _foreignTokenContract,
            _msgSender(),
            address(this),
            _foreignTokenID
        ); // move token to this contract

        CNSGN_TKN.mintConsignmentToken(
            _msgSender(),
            newTokenId,
            "pruf.io/consign"
        );

        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Unwraps a token, returns original to caller
     * @param _tokenID tokenID of PRUF token being unwrapped
     * burns pruf asset from caller wallet
     * Sends original 721 to caller
     */
    function withdrawFromConsignment(uint256 _tokenID)
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, CNSGN_TKN_Address)
    {    //caller holds the consignment ticket
        address foreignTokenContract = wrapped[_tokenID].tokenContract;
        uint256 foreignTokenID = wrapped[_tokenID].tokenID;
        //^^^^^^^checks^^^^^^^^^

        CNSGN_TKN.trustedAgentBurn(_tokenID);

        foreignTransfer(
            foreignTokenContract,
            address(this),
            _msgSender(),
            foreignTokenID
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    // /**
    //  * @dev Purchse an item in transferrable status with price and currency set to pruf
    //  * @param _idxHash asset ID
    //  */
    // function purchaseWithPRUF(
    //     bytes32 _idxHash
    // ) external whenNotPaused
    // {
    //     Record memory rec = getRecord(_idxHash);
    //     (rec.price, rec.currency) = STOR.getPriceData(_idxHash);

    //     uint256 tokenId = uint256(_idxHash);
    //     address assetHolder = A_TKN.ownerOf(tokenId);

    //     require(
    //         rec.assetStatus == 51,
    //         "PP:P: Must be in transferrable status (51)"
    //     );
    //     require(
    //         rec.currency == 2,
    //         "PP:P: Payment must be in PRUF tokens for this contract"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     // --- transfer the PRUF tokens
    //     if (rec.price > 0) {
    //         // allow for freeCycling
    //         UTIL_TKN.trustedAgentTransfer(_msgSender(), assetHolder, rec.price);
    //     }
    //     // --- transfer the asset token
    //     A_TKN.trustedAgentTransferFrom(assetHolder, _msgSender(), tokenId);
    //     deductServiceCosts(rec.node, 2);
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    /**
     * @dev transfer a foreign token
     * @param _tokenContract Address of foreign token contract
     * @param _from origin
     * @param _to destination
     * @param _tokenID Token ID
     */
    function foreignTransfer(
        address _tokenContract,
        address _from,
        address _to,
        uint256 _tokenID
    ) internal {
        IERC721(_tokenContract).transferFrom(_from, _to, _tokenID);
    }
}
