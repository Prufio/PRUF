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
 *  Extra Interfaces
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

//---------------------------------------------------------------------------------------------------------------
/*
 * @dev Interface for Market
 * INHERITANCE:
    import "./Imports/access/Ownable.sol";
    import "./Imports/security/Pausable.sol";
    import "./Imports/security/ReentrancyGuard.sol";
 */

interface MarketInterface {
    //--------------------------------------------External Functions--------------------------

    /**
     * @dev sets the MARKET_TKN contract address
     * @param _address MARKET_TKN contract address
     */

    function setTokenAddress(address _address) external;

    /**
     * @dev sets the charity donation address
     * @param _charityAddress charity erc20 address
     */

    function setCharityAddress(address _charityAddress) external;

    /**
     * @dev sets the default cost in PRüF of listing a non-PRüF NFT
     * @param _price cost in PRüF(18) of listing a non-PRüF NFT
     */

    function setListingPrice(uint32 _price) external;

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
    ) external;

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
    ) external;

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
    ) external;

    /**
     * @dev Unwraps a token, burns the MARKET_TKN, returns original to caller
     * @param _tokenId tokenID of consignment token being redeemed
     * burns consignment token from caller wallet
     * Sends original consigned 721 to caller
     */
    function withdrawFromConsignment(uint256 _tokenId) external;

    /**
     * @dev Purchse an item from the consignment contract
     * @param _tokenId consignment ID
     */
    function purchaseItem(
        uint256 _tokenId //consignment token ID
    ) external;
}
