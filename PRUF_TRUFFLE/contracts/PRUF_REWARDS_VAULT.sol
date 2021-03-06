/*--------------------------------------------------------PRüF0.8.0
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
 *PRUF Rewards Vault holds PRUF to send to stakers.
 *It is funded by the team with the stake rewards amount as needed
 *---------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract REWARDS_VAULT is ReentrancyGuard, AccessControl, Pausable {
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant STAKE_PAYER_ROLE = keccak256("STAKE_PAYER_ROLE");
    bytes32 public constant ASSET_TXFR_ROLE = keccak256("ASSET_TXFR_ROLE");

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address internal STAKE_TKN_Address;
    STAKE_TKN_Interface internal STAKE_TKN;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    // --------------------------------------Modifiers--------------------------------------------//

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      Has appropriate role
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "RV:MOD:-ICA Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "RV:MOD-IP: Caller !PAUSER_ROLE"
        );
        _;
    }
    modifier isStakePayer() {
        require(
            hasRole(STAKE_PAYER_ROLE, _msgSender()),
            "RV:MOD-ISP: Caller !STAKE_PAYER_ROLE"
        );
        _;
    }

    //----------------------External Admin functions / isContractAdmin----------------------//

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     */
    function Admin_setTokenContracts(
        address _utilAddress,
        address _stakeAddress
    ) external virtual isContractAdmin {
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _utilAddress;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        STAKE_TKN_Address = _stakeAddress;
        STAKE_TKN = STAKE_TKN_Interface(STAKE_TKN_Address);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /**
     * @dev Sends (amount) pruf to ownerOf(tokenId)
     * @param _tokenId - token ID
     * @param _amount - amount to pay to owner of (tokenId)
     */
    function payRewards(uint256 _tokenId, uint256 _amount)
        external
        whenNotPaused
        nonReentrant
        isStakePayer
    {
        //^^^^^^^checks^^^^^^^^^

        address recipient = STAKE_TKN.ownerOf(_tokenId);
        UTIL_TKN.transfer(recipient, _amount);
        //^^^^^^^interactions^^^^^^^^
    }

    /**
     * @dev Transfer any specified ERC721 Token from contract
     * @param _to - address to send to
     * @param _tokenId - token ID
     * @param _ERC721Contract - token contract address
     */
    function transferERC721Token(
        address _to,
        uint256 _tokenId,
        address _ERC721Contract
    ) external virtual nonReentrant {
        require(
            hasRole(ASSET_TXFR_ROLE, _msgSender()),
            "RV:TET:Must have ASSET_TXFR_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        IERC721(_ERC721Contract).safeTransferFrom(address(this), _to, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /***
     * @dev Triggers stopped state.
     */
    function pause() external isPauser {
        _pause();
    }

    /***
     * @dev Returns to normal state.
     */

    function unpause() external isPauser {
        _unpause();
    }
}
