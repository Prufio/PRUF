/*--------------------------------------------------------PRüF0.8.6
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
 *PRUF Stake Vault
 *Holds staked PRUF that were placed into its care.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./RESOURCE_PRUF_INTERFACES.sol";
import "./RESOURCE_PRUF_TKN_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/security/Pausable.sol";
import "./Imports/security/ReentrancyGuard.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract STAKE_VAULT is ReentrancyGuard, AccessControl, Pausable {
    mapping(uint256 => uint256) private stake; // holds the stake parameters for each stake tokenId

    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant STAKE_ADMIN_ROLE = keccak256("STAKE_ADMIN_ROLE");

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
     * @dev Verify caller credentials
     * Originating Address:
     *      Has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "SV:MOD:-ICA: Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Verify caller credentials
     * Originating Address:
     *      Has STAKE_ADMIN_ROLE
     */
    modifier isStakeAdmin() {
        require(
            hasRole(STAKE_ADMIN_ROLE, _msgSender()),
            "SV:MOD:-ISA: Caller !STAKE_ADMIN_ROLE"
        );
        _;
    }

    /**
     * @dev Verify caller credentials
     * Originating Address:
     *      Has PAUSER_ROLE
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "SV:MOD-IP:Calling address !pauser"
        );
        _;
    }

    //----------------------External Admin functions / isContractAdmin----------------------//

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN contract
     * @param _stakeAddress address of STAKE_TKN contract
     */
    function setTokenContracts(address _utilAddress, address _stakeAddress)
        external
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^

        UTIL_TKN_Address = _utilAddress;
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        STAKE_TKN_Address = _stakeAddress;
        STAKE_TKN = STAKE_TKN_Interface(STAKE_TKN_Address);

        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//

    /**
     * @dev moves tokens(amount) from holder(tokenID) into itself using trustedAgentTransfer, records the amount in stake map
     * @param _tokenId stake token to take stake for
     * @param _amount amount of stake to pull
     */
    function takeStake(uint256 _tokenId, uint256 _amount)
        external
        nonReentrant
        whenNotPaused
        isStakeAdmin
    {
        //^^^^^^^checks^^^^^^^^^
        address staker = STAKE_TKN.ownerOf(_tokenId);
        //^^^^^^^effects^^^^^^^^^

        UTIL_TKN.trustedAgentTransfer(staker, address(this), _amount); // here so fails first
        stake[_tokenId] = stake[_tokenId] + _amount;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev sends stakedAmount[tokenId] tokens to ownerOf(tokenId), updates the stake map.
     * @param _tokenId stake token to release stake for
     */
    function releaseStake(uint256 _tokenId)
        external
        nonReentrant
        whenNotPaused
        isStakeAdmin
    {
        //^^^^^^^checks^^^^^^^^^

        uint256 amount = stake[_tokenId];
        delete stake[_tokenId];
        //^^^^^^^effects^^^^^^^^^

        address staker = STAKE_TKN.ownerOf(_tokenId);
        UTIL_TKN.transfer(staker, amount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Returns the amount of tokens staked on (tokenId)
     * @param _tokenId token to check
     * @return Stake of _tokenId
     */
    function stakeOfToken(uint256 _tokenId) external view returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        return stake[_tokenId];
    }

    /**
     * @dev Pauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_pause}.
     */
    function pause() external isPauser {
        //^^^^^^^checks^^^^^^^^^

        _pause();
    }

    /**
     * @dev Unpauses contract.
     *
     * See {ERC721Pausable} and {Pausable-_unpause}.
     */
    function unpause() external isPauser {
        _unpause();
    }
}
