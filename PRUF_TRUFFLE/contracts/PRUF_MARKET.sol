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
 *  TO DO --- Find more needed requires?
 *
 *-----------------------------------------------------------------
 * Wraps and unwraps ERC721 compliant tokens in a PRUF Asset token  DPS:NEW CONTRACT DPS:CHECK
 *  MUST BE TRUSTED AGENT IN MARKET_TKN, A_tkn, Util_Tkn
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";
import "./Imports/token/ERC20/IERC20.sol";

contract Market is CORE {
    uint32 defaultNode;
    address internal MARKET_TKN_Address;
    address public charityAddress;
    MARKET_TKN_Interface internal MARKET_TKN;

    //mapping(uint256 => ConsignmentTag) private tag; // pruf tokenID -> original TokenID, ContractAddress

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
            "M:MOD-ITH: Caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------
    /**
     * @dev sets the charity donation address
     * @param _charityAddress charity erc20 address
     */

    function setCharityAddress(address _charityAddress)
        external
        isContractAdmin
    {
        charityAddress = _charityAddress;
    }

    /**
     * @dev sets the default PRüF node
     * @param _node default PRüF node
     */

    function setDefaultNode(uint32 _node) external isContractAdmin {
        defaultNode = _node;
    }

    /**
     * @dev Wraps a token, takes original from caller (holds it in contract)
     * @param _tokenId tokenID of token to wrap
     * @param _ERC721TokenContract contract address for token to wrap
     * @param _currency currency to make transaction in
     * @param _price price in _currency to require for transfer
     * Prerequisite: contract authorized for token txfr
     * Takes original 721
     */
    function consignPrufAsset(
        uint256 _tokenId,
        address _currency,
        uint256 _price
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, A_TKN_Address)
    {
        // without this, the dark forest gets it!
        //^^^^^^^checks^^^^^^^^^

        ConsignmentTag memory thisTag;
        bytes32 consignmentTag = keccak256(
            abi.encodePacked(_tokenId, A_TKN_Address)
        );
        uint256 newTokenId = uint256(consignmentTag);
        bytes32 idxHash = bytes32(_tokenId);
        Record memory rec = getRecord(idxHash);

        thisTag.tokenId = _tokenId;
        thisTag.tokenContract = A_TKN_Address;
        thisTag.currency = _currency;
        thisTag.price = _price;
        thisTag.node = rec.node;
        //^^^^^^^effects^^^^^^^^^

        require(
            rec.assetStatus == 51,
            "M:C:PRUF asset is not status 51 (transferrable)"
        );
        A_TKN.trustedAgentTransferFrom(_msgSender(), address(this), _tokenId); //move token to this contract using TRUSTED_AGENT_ROLE
        thisTag.node = rec.node;

        MARKET_TKN.mintConsignmentToken(_msgSender(), newTokenId, A_TKN.tokenURI(_tokenId), thisTag);
    }

    /**
     * @dev Wraps a token, takes original from caller (holds it in contract)
     * @param _tokenId tokenID of token to wrap
     * @param _ERC721TokenContract contract address for token to wrap
     * @param _currency currency to make transaction in
     * @param _price price in _currency to require for transfer
     * Prerequisite: contract authorized for token txfr
     * Takes original 721
     */
    function consignItem(
        uint256 _tokenId,
        address _ERC721TokenContract,
        address _currency,
        uint256 _price
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, _ERC721TokenContract)
    {
        // without this, the dark forest gets it!
        //^^^^^^^checks^^^^^^^^^

        ConsignmentTag memory thisTag;
        bytes32 consignmentTag = keccak256(
            abi.encodePacked(_tokenId, _ERC721TokenContract)
        );
        uint256 newTokenId = uint256(consignmentTag);

        thisTag.tokenId = _tokenId;
        thisTag.tokenContract = _ERC721TokenContract;
        thisTag.currency = _currency;
        thisTag.price = _price;
        thisTag.node = defaultNode;
        //^^^^^^^effects^^^^^^^^^

        if (_ERC721TokenContract == A_TKN_Address) {
            bytes32 idxHash = bytes32(_tokenId);
            Record memory rec = getRecord(idxHash);
            require(
                rec.assetStatus == 51,
                "M:C:PRUF asset is not status 51 (transferrable)"
            );
            A_TKN.trustedAgentTransferFrom(
                _msgSender(),
                address(this),
                _tokenId
            ); //move token to this contract using TRUSTED_AGENT_ROLE
            thisTag.node = rec.node;

            MARKET_TKN.mintConsignmentToken(_msgSender(), newTokenId, thisTag);
        } else {
            foreign721Transfer(
                _ERC721TokenContract,
                _msgSender(),
                address(this),
                _tokenId
            ); // move token to this contract using allowance
            thisTag.node = defaultNode;
            MARKET_TKN.mintConsignmentToken(_msgSender(), newTokenId, thisTag);
        }

        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Unwraps a token, burns the MARKET_TKN, returns original to caller
     * @param _tokenId tokenID of consignment token being redeemed
     * burns consignment token from caller wallet
     * Sends original consigned 721 to caller
     */
    function withdrawFromConsignment(uint256 _tokenId)
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, MARKET_TKN_Address)
    {
        //caller holds the consignment ticket ^^
        ConsignmentTag memory thisTag = MARKET_TKN.getTag(_tokenId);
        address tag721TokenContract = thisTag.tokenContract;
        uint256 tagTokenId = thisTag.tokenId;
        //^^^^^^^checks^^^^^^^^^

        MARKET_TKN.trustedAgentBurn(_tokenId);

        foreign721Transfer(
            tag721TokenContract,
            address(this),
            _msgSender(),
            tagTokenId
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Purchse an item from the consignment contract
     * @param _tokenId consignment ID
     */
    function purchaseItem(
        uint256 _tokenId //consignment token ID
    ) external nonReentrant whenNotPaused {
        // require( // this is redundant, will throw upon transfer attempt
        //     (IERC721(tag[_tokenId].tokenContract).ownerOf(
        //         tag[_tokenId].tokenId
        //     ) == address(this)),
        //     "CM:P: Market contract does not hold specified token"
        // );

        address paymentAddress;

        if (MARKET_TKN.tokenExists(_tokenId) != 0) {
            //if ticket !exist, sale will go through and proceeds will go to the charity address.
            MARKET_TKN.trustedAgentBurn(_tokenId); //burn the consignment tag, consignment is over as sale is being completed
            paymentAddress = MARKET_TKN.ownerOf(tag[_tokenId].tokenId); //set payment address to the holder of the consignment ticket
        } else {
            //otherwise
            paymentAddress = charityAddress; //set payment address to the charity address
        }

        if (
            //if payment currency is PRUF and wallet is permitted for TAT
            (tag[_tokenId].currency == UTIL_TKN_Address) &&
            (UTIL_TKN.isColdWallet(_msgSender()) == 0)
        ) {
            //Pay in PRüF using TAT
            UTIL_TKN.trustedAgentTransfer(
                _msgSender(),
                paymentAddress,
                tag[_tokenId].price
            );
        } else {
            //otherwise
            foreign20Transfer( //Pay using allowance
                tag[_tokenId].currency, //send this erc20
                _msgSender(), //from the purchase caller
                paymentAddress, //to the payment address
                tag[_tokenId].price //amount of tokens to send
            );
        }

        foreign721Transfer( //Deliver token to buyer
            tag[_tokenId].tokenContract, //using this token contract
            address(this), //from this address
            _msgSender(), //to the purchase caller
            tag[_tokenId].tokenId //send this (native) tokenId
        );
    }

    //-------------------------------------------------------------------------
    /**
     * @dev transfer a foreign token
     * @param _tokenContract Address of foreign token contract
     * @param _from origin
     * @param _to destination
     * @param _tokenID Token ID
     */
    function foreign721Transfer(
        address _tokenContract,
        address _from,
        address _to,
        uint256 _tokenID
    ) internal {
        IERC721(_tokenContract).transferFrom(_from, _to, _tokenID);
    }

    /**
     * @dev transfer a foreign token
     * @param _tokenContract Address of foreign token contract
     * @param _from origin
     * @param _to destination
     * @param _amount amount to transfer
     */
    function foreign20Transfer(
        address _tokenContract,
        address _from,
        address _to,
        uint256 _amount
    ) internal {
        IERC20(_tokenContract).transferFrom(_from, _to, _amount);
    }
}
