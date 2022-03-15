/**--------------------------------------------------------PRüF0.8.7
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
 * NEED TO ADD NODE APPROVAL CHECKS FOR ALL RELEVANT OPERATIONS
 *
 *-----------------------------------------------------------------
 * Wraps and unwraps ERC721 compliant tokens in a PRUF market token  DPS:NEW CONTRACT DPS:CHECK
 *  MUST BE TRUSTED AGENT IN MARKET_TKN, A_tkn, Util_Tkn
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_BASIC.sol";

contract Market is BASIC {
    address internal MARKET_TKN_Address;
    address public charityAddress;

    MARKET_TKN_Interface internal MARKET_TKN;

    mapping(uint256 => ConsignmentTag) private tag; // pruf tokenID -> original TokenID, ContractAddress
    mapping(uint256 => MarketFees) private tagFees; // pruf tokenID -> original TokenID, ContractAddress
    mapping(bytes32 => uint256) private approvedConsignments; //consignments approved by node

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
     * @dev sets the MARKET_TKN contract address
     * @param _address MARKET_TKN contract address
     */

    function setMarketTokenAddress(address _address) external isContractAdmin {
        MARKET_TKN_Address = _address;
        MARKET_TKN = MARKET_TKN_Interface(MARKET_TKN_Address);
    }

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
     * @dev Lets a node submit approval to list items in its marketspace
     * @param _node, //node issuing approval
     * @param _tokenId //zero if all from contract / node
     * @param _ERC721TokenContract contract address for token to wrap
     * @param _nodeToApprove //zero if all pruf nodes (using PRUF contract address)
     * @param _approved approval status ( 0 = not)
     */
    function approveForConsignment(
        uint32 _node, //node issuing approval
        uint256 _tokenId, //zero if all from contract
        address _ERC721TokenContract,
        uint32 _nodeToApprove, //zero if all pruf nodes (using PRUF contract address)
        uint256 _approved // zero to unaprove. Any other = approved.
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_node, NODE_TKN_Address)
    {
        bytes32 consignmentHash = keccak256(
            abi.encodePacked(_tokenId, _ERC721TokenContract, _nodeToApprove, _node)
        );
        approvedConsignments[consignmentHash] = _approved;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Wraps a pruf asset, takes original from caller (holds it in contract)
     * @param _tokenId tokenID of token to wrap
     * @param _currency currency to make transaction in
     * @param _price price in _currency to require for transfer
     * @param _node node doing the consignment
     */
    function consignPrufAsset(
        uint256 _tokenId,
        address _currency,
        uint256 _price,
        uint32 _node
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, A_TKN_Address)
    {
        // without this, the dark forest gets it!
        bytes32 idxHash = bytes32(_tokenId);
        Record memory rec = getRecord(idxHash);
        require(
            rec.assetStatus == 51,
            "M:CPA:PRUF asset is not status 51 (transferrable)"
        );
        require(
            ADD NODE APPROVAL CHECKS FOR ALL RELEVANT OPERATIONS,
            "M:CPA:Asset not approved for consignment by node"
        );
        //^^^^^^^checks^^^^^^^^^

        ConsignmentTag memory thisTag;
        bytes32 consignmentTag = keccak256(
            abi.encodePacked(_tokenId, A_TKN_Address)
        );
        uint256 newTokenId = uint256(consignmentTag);

        string memory uri = A_TKN.tokenURI(_tokenId);

        thisTag.tokenId = _tokenId;
        thisTag.tokenContract = A_TKN_Address;
        thisTag.currency = _currency;
        thisTag.price = _price;

        tag[newTokenId] = thisTag;
        tagFees[newTokenId] = getNodeMarketFees(_node);
        //^^^^^^^effects^^^^^^^^^

        A_TKN.trustedAgentTransferFrom(_msgSender(), address(this), _tokenId); //move token to this contract using TRUSTED_AGENT_ROLE

        MARKET_TKN.mintConsignmentToken(_msgSender(), newTokenId, uri);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Wraps a token, takes original from caller (holds it in contract)
     * @param _tokenId tokenID of token to wrap
     * @param _ERC721TokenContract contract address for token to wrap
     * @param _currency currency to make transaction in
     * @param _price price in _currency to require for transfer
     * @param _node node doing the consignment
     * @param uri string for URI
     * Prerequisite: contract authorized for token txfr
     * Takes original 721
     */
    function consignToken(
        uint256 _tokenId,
        address _ERC721TokenContract,
        address _currency,
        uint256 _price,
        uint32 _node,
        string memory uri
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, _ERC721TokenContract)
    {
        require(
            ADD NODE APPROVAL CHECKS FOR ALL RELEVANT OPERATIONS,
            "M:CT:Asset not approved for consignment by node"
        );
        //^^^^^^^checks^^^^^^^^^

        ConsignmentTag memory thisTag;

        bytes32 consignmentTag = keccak256(
            abi.encodePacked(_tokenId, _ERC721TokenContract)
        );

        uint256 newTokenId = uint256(consignmentTag);

        MarketFees memory fees = getNodeMarketFees(_node);

        thisTag.tokenId = _tokenId;
        thisTag.tokenContract = _ERC721TokenContract;
        thisTag.currency = _currency;
        thisTag.price = _price;

        tag[newTokenId] = thisTag;
        tagFees[newTokenId] = fees;
        //^^^^^^^effects^^^^^^^^^

        foreign721Transfer( // move token to this contract using allowance
            _ERC721TokenContract,
            _msgSender(),
            address(this),
            _tokenId
        );

        if (fees.listingFee != 0) {
            UTIL_TKN.trustedAgentTransfer( //Pay listing fee in PRüF using TAT
                _msgSender(),
                fees.listingFeePaymentAddress,
                fees.listingFee
            );
        }

        MARKET_TKN.mintConsignmentToken(_msgSender(), newTokenId, uri);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Updates pricing information for an active consignment
     * @param _tokenId ID of consignment
     * @param _currency currency to make transaction in
     * @param _price price in _currency to require for transfer
     */
    function updateConsignment(
        uint256 _tokenId,
        address _currency,
        uint256 _price
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, MARKET_TKN_Address)
    {
        ADD NODE APPROVAL CHECKS FOR ALL RELEVANT OPERATIONS
        //^^^^^^^checks^^^^^^^

        tag[_tokenId].currency = _currency;
        tag[_tokenId].price = _price;

        //^^^^^^^effects^^^^^^^^^
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
        //^^^^^^^checks^^^^^^^^^

        ConsignmentTag memory thisTag = tag[_tokenId];
        delete tag[_tokenId];
        delete tagFees[_tokenId];
        MARKET_TKN.tagAdminBurn(_tokenId);
        //^^^^^^^effects^^^^^^^^^

        foreign721Transfer(
            thisTag.tokenContract,
            address(this),
            _msgSender(),
            thisTag.tokenId
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
        ADD NODE APPROVAL CHECKS FOR ALL RELEVANT OPERATIONS
        //^^^^^^^checks^^^^^^^^^

        //collect relevant information for this consignement
        ConsignmentTag memory thisTag = tag[_tokenId];
        MarketFees memory theseFees = tagFees[_tokenId];
        if (theseFees.listingFeePaymentAddress == address(0)) {
            theseFees.listingFeePaymentAddress = charityAddress;
        }
        if (theseFees.saleCommissionPaymentAddress == address(0)) {
            theseFees.saleCommissionPaymentAddress = charityAddress;
        }

        //calculate payable amount less commission
        uint256 commission;
        if (theseFees.saleCommission > 0) {
            commission = thisTag.price / theseFees.saleCommission; //amount to go to listing node
        }
        uint256 payableAmount = thisTag.price - commission; //amount to go to ticket holder

        //Set the payment address from the tokenholder. if ticket !exist or no address set, set to the charity address.
        address paymentAddress;
        if (MARKET_TKN.tokenExists(_tokenId) != 0) {
            paymentAddress = MARKET_TKN.ownerOf(thisTag.tokenId); //set payment address to the holder of the consignment ticket
        } else {
            paymentAddress = charityAddress; // otherwise set payment address to the charity address
        }

        delete tag[_tokenId]; //delete the consignmentTag struct from the tag mapping
        //^^^^^^^effects^^^^^^^^^

        //if payment currency is PRUF && wallet is permitted for TAT, Pay in PRüF using TAT
        if (
            (thisTag.currency == UTIL_TKN_Address) &&
            (UTIL_TKN.isColdWallet(_msgSender()) == 0)
        ) {
            if (payableAmount > 0) {
                UTIL_TKN.trustedAgentTransfer( //Pay payableAmount using TAT
                    _msgSender(),
                    paymentAddress,
                    payableAmount
                );
            }
            if (commission > 0) {
                UTIL_TKN.trustedAgentTransfer( //Pay commission using TAT
                    _msgSender(),
                    theseFees.saleCommissionPaymentAddress,
                    commission
                );
            }
            // otherwise Pay using ERC20 allowance
        } else {
            if (payableAmount > 0) {
                foreign20Transfer( //Pay payableAmount using ERC20 allowance
                    thisTag.currency, //send this erc20
                    _msgSender(), //from the purchase caller
                    paymentAddress, //to the payment address
                    payableAmount //amount of tokens to send
                );
            }
            if (commission > 0) {
                foreign20Transfer( //Pay commission using ERC20 allowance
                    thisTag.currency, //send this erc20
                    _msgSender(), //from the purchase caller
                    theseFees.saleCommissionPaymentAddress, //to the payment address
                    commission //amount of tokens to send
                );
            }
        }

        MARKET_TKN.tagAdminBurn(_tokenId); //burn the consignment tag, consignment is over as sale has been completed

        foreign721Transfer( //Deliver token to buyer , PRUF or Foreign
            thisTag.tokenContract, //using this token contract
            address(this), //from this address
            _msgSender(), //to the purchase caller
            thisTag.tokenId //send this (native) tokenId
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /** DPS:CHECK
     * @dev Get Market fees struct
     * @param _node node to get Market fees for
     */
    function getNodeMarketFees(uint32 _node)
        private
        view
        returns (MarketFees memory)
    {
        //^^^^^^^checks^^^^^^^^^

        MarketFees memory theseFees;

        Costs memory listingFee = NODE_STOR.getPaymentData(_node, 1000);
        Costs memory comission = NODE_STOR.getPaymentData(_node, 1001);

        theseFees.listingFeePaymentAddress = listingFee.paymentAddress;
        theseFees.listingFee = listingFee.serviceCost;
        theseFees.saleCommissionPaymentAddress = comission.paymentAddress;
        theseFees.saleCommission = comission.serviceCost;
        //^^^^^^^effects^^^^^^^^^

        return theseFees;
        //^^^^^^^interactions^^^^^^^^^
    }

    //-------------------------------------------------------------------------

    /**
     * @dev transfer a foreign token
     * @param _tokenContract Address of foreign token contract
     * @param _from origin
     * @param _to destination
     * @param _tokenID Token ID to transfer
     */
    function foreign721Transfer(
        address _tokenContract,
        address _from,
        address _to,
        uint256 _tokenID
    ) internal {
        IERC721(_tokenContract).safeTransferFrom(_from, _to, _tokenID);
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

    /**  
     * @dev get consignment approval
     * @param _tokenId tokenId or zero if all approved for address / node
     * @param _ERC721TokenContract contract address
     * @param _approvedNode node approved by _byNode, or zero for all nodes or non-PRüF asset
     * @param _byNode node to check approval for 
     */
    function getApproval(uint256 _tokenId, address _ERC721TokenContract, uint32 _approvedNode, uint _byNode)
        public
        view
        returns (uint256)

        BROKEN BECAUSE DOES NOT CHECK FOR VARIATIONS (approved for node but I give tokenID, etc. Need to check all scenarios)
    {
        return (approvedConsignments[keccak256(
            abi.encodePacked(_tokenId, _ERC721TokenContract, _approvedNode, _byNode)
        )]);
    }
}
