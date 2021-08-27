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
 *  MUST BE TRUSTED AGENT IN CNSGN_TKN, A_tkn, Util_Tkn
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";
import "./Imports/token/ERC20/IERC20.sol";

contract Market is CORE {
    struct ConsignmentTags {
        uint256 tokenId;
        address tokenContract;
        address currency;
        address benificiaryAddress;
        uint256 holderShare;
        uint256 benificiaryShare;
    }

    address internal CNSGN_TKN_Address;
    address public charityAddress;
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
     * @dev Wraps a token, takes original from caller (holds it in contract)
     * @param _foreignTokenId tokenID of token to wrap
     * @param _foreignTokenContract ERC721 contract address for token to wrap
     * @param _currency currency to make transaction in (ERC20 token contract address)
     * @param _benificiaryAddress price in _currency to require for transfer
     * @param _holderShare price in _currency --> seller share
     * @param _benificiaryShare price in _currency to -->charity share
     * Prerequisite: contract authorized for token txfr
     * Takes original 721
     */
    function consignItem(
        uint256 _foreignTokenId,
        address _foreignTokenContract,
        address _currency,
        address _benificiaryAddress,
        uint256 _holderShare,
        uint256 _benificiaryShare
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_foreignTokenId, _foreignTokenContract)
    {
        // without this, the dark forest gets it!
        //^^^^^^^checks^^^^^^^^^

        bytes32 consignmentTag = keccak256(
            abi.encodePacked(_foreignTokenId, _foreignTokenContract)
        );
        uint256 newTokenId = uint256(consignmentTag);
        wrapped[newTokenId].tokenId = _foreignTokenId;
        wrapped[newTokenId].tokenContract = _foreignTokenContract;
        wrapped[newTokenId].currency = _currency;
        wrapped[newTokenId].benificiaryAddress = _benificiaryAddress;
        wrapped[newTokenId].holderShare = _holderShare;
        wrapped[newTokenId].benificiaryShare = _benificiaryShare;
        //^^^^^^^effects^^^^^^^^^

        if (_foreignTokenContract == A_TKN_Address) {
            bytes32 idxHash = bytes32(_foreignTokenId);
            Record memory rec = getRecord(idxHash);
            require(
                rec.assetStatus == 51,
                "M:C:PRUF asset is not status 51 (transferrable)"
            );
            A_TKN.trustedAgentTransferFrom(
                _msgSender(),
                address(this),
                _foreignTokenId
            ); //move token to this contract using TRUSTED_AGENT_ROLE
        } else {
            foreign721Transfer(
                _foreignTokenContract,
                _msgSender(),
                address(this),
                _foreignTokenId
            ); // move token to this contract using allowance
        }

        CNSGN_TKN.mintConsignmentToken(_msgSender(), newTokenId, "pruf.io/mkt");

        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Unwraps a token, burns the CNSGN_TKN, returns original to caller
     * @param _tokenId tokenID of consignment token being redeemed
     * burns consignment token from caller wallet
     * Sends original consigned 721 to caller
     */
    function withdrawFromConsignment(uint256 _tokenId)
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, CNSGN_TKN_Address)
    {
        //caller holds the consignment ticket ^^
        address foreignTokenContract = wrapped[_tokenId].tokenContract;
        uint256 foreignTokenID = wrapped[_tokenId].tokenId;
        //^^^^^^^checks^^^^^^^^^

        CNSGN_TKN.trustedAgentBurn(_tokenId);

        foreign721Transfer(
            foreignTokenContract,
            address(this),
            _msgSender(),
            foreignTokenID
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
        //     (IERC721(wrapped[_tokenId].tokenContract).ownerOf(
        //         wrapped[_tokenId].tokenId
        //     ) == address(this)),
        //     "CM:P: Market contract does not hold specified token"
        // );

        address paymentAddress;

        if (CNSGN_TKN.tokenExists(_tokenId) != 0) {
            //if ticket !exist, sale will go through and proceeds will go to the charity address.
            CNSGN_TKN.trustedAgentBurn(_tokenId); //burn the consignment tag, consignment is over as sale is being completed
            paymentAddress = CNSGN_TKN.ownerOf(wrapped[_tokenId].tokenId); //set payment address to the holder of the consignment ticket
        } else {
            //otherwise
            paymentAddress = charityAddress; //set payment address to the charity address
        }

        if (
            //if payment currency is PRUF and wallet is permitted for TAT
            (wrapped[_tokenId].currency == UTIL_TKN_Address) &&
            (UTIL_TKN.isColdWallet(_msgSender()) == 0)
        ) {
            UTIL_TKN.trustedAgentTransfer( //Pay in PRüF using TAT
                _msgSender(), //from the purchase caller
                paymentAddress, //to the payment address
                wrapped[_tokenId].holderShare //amount of tokens to send
            );
            UTIL_TKN.trustedAgentTransfer( //Pay in PRüF using TAT
                _msgSender(),//from the purchase caller
                wrapped[_tokenId].benificiaryAddress, //to the benificiary address
                wrapped[_tokenId].benificiaryShare //amount of tokens to send
            );
        } else {
            //otherwise
            foreign20Transfer( //Pay using allowance
                wrapped[_tokenId].currency, //send this erc20
                _msgSender(), //from the purchase caller
                paymentAddress, //to the payment address
                wrapped[_tokenId].holderShare //amount of tokens to send
            );
            foreign20Transfer( //Pay using allowance
                wrapped[_tokenId].currency, //send this erc20
                _msgSender(), //from the purchase caller
                wrapped[_tokenId].benificiaryAddress, //to the benificiary address
                wrapped[_tokenId].benificiaryShare //amount of tokens to send
            );
        }

        foreign721Transfer( //Deliver token to buyer
            wrapped[_tokenId].tokenContract, //using this token contract
            address(this), //from this address
            _msgSender(), //to the purchase caller
            wrapped[_tokenId].tokenId //send this (native) tokenId
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
