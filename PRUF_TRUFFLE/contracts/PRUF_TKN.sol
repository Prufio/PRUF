/*--------------------------------------------------------PRuF0.7.1
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/token/ERC20/ERC20.sol";
import "./Imports/token/ERC20/ERC20Burnable.sol";
import "./Imports/token/ERC20/ERC20Pausable.sol";
import "./Imports/token/ERC20/ERC20Snapshot.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a MINTER_ROLE that allows for token minting (creation)
 *  - a PAUSER_ROLE that allows to stop all token transfers
 *  - a SNAPSHOT_ROLE that allows to take snapshots
 *  - a PAYABLE_ROLE role that allows authorized adresses to invoke the token splitting payment function (all paybale contracts)
 *  - a TRUSTED_AGENT_ROLE role that allows authorized adresses to transfer and burn tokens (AC_MGR)




 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract UTIL_TKN is
    Context,
    AccessControl,
    ERC20Burnable,
    ERC20Pausable,
    ERC20Snapshot
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant PAYABLE_ROLE = keccak256("PAYABLE_ROLE");
    bytes32 public constant TRUSTED_AGENT_ROLE = keccak256(
        "TRUSTED_AGENT_ROLE"
    );

    uint256 public constant maxSupply = 4000000000000000000000000000; //4billion max supply

    address private sharesAddress = address(0);

    struct Invoice {
        //invoice struct to facilitate payment messaging in-contract
        address rootAddress;
        uint256 rootPrice;
        address ACTHaddress;
        uint256 ACTHprice;
    }

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor() public ERC20("PRuF_TKN", "PRuF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(SNAPSHOT_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
        _setupRole(PAYABLE_ROLE, _msgSender());
    }

    /*
     * @dev Set adress of SHARES payment contract. by default contract will use root adress instead if set to zero.
     */
    function AdminSetSharesAddress(address _paymentAddress) external {
        require(
            _paymentAddress != address(0),
            "PRuF:SSA: payment address cannot be zero"
        );

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:SSA: must have DEFAULT_ADMIN_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        sharesAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Deducts token payment from transaction
     */
    function payForService(
        address _senderAddress,
        address _rootAddress,
        uint256 _rootPrice,
        address _ACTHaddress,
        uint256 _ACTHprice
    ) external {
        require(
            hasRole(PAYABLE_ROLE, _msgSender()),
            "PRuF:PPS: must have PAYABLE_ROLE"
        );
        require( //redundant? throws on transfer?
            balanceOf(_senderAddress) >= _rootPrice.add(_ACTHprice),
            "PRuF:PPS: insufficient balance"
        );
        //^^^^^^^checks^^^^^^^^^
        address _sharesAddress = sharesAddress;

        if (sharesAddress == address(0)) {
            _sharesAddress = _rootAddress;
        }

        uint256 sharesShare = _rootPrice.div(uint256(4)); //SHARES
        uint256 rootShare = _rootPrice.sub(sharesShare); //SHARES

        _transfer(_senderAddress, _rootAddress, rootShare);
        _transfer(_senderAddress, _sharesAddress, sharesShare);
        _transfer(_senderAddress, _ACTHaddress, _ACTHprice);

        //^^^^^^^effects^^^^^^^^^
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev arbitrary burn (requires TRUSTED_AGENT_ROLE)   ****USE WITH CAUTION
     */
    function trustedAgentburn(address _addr, uint256 _amount) public {
        require(
            hasRole(TRUSTED_AGENT_ROLE, _msgSender()),
            "PRuF:BRN: must have TRUSTED_AGENT_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^
        _burn(_addr, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev arbitrary transfer (requires TRUSTED_AGENT_ROLE)   ****USE WITH CAUTION
     */
    function trustedAgentTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) public {
        require(
            hasRole(TRUSTED_AGENT_ROLE, _msgSender()),
            "PRuF:TAT: must have TRUSTED_AGENT_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^
        _transfer(_from, _to, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Take a balance snapshot, returns snapshot ID
     */
    function takeSnapshot() external returns (uint256) {
        require(
            hasRole(SNAPSHOT_ROLE, _msgSender()),
            "ERC20PresetMinterPauser: must have snapshot role to take a snapshot"
        );
        return _snapshot();
    }

    /**
     * @dev Creates `amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to, uint256 amount) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "PRuF:M: must have minter role to mint"
        );
        require(
            amount.add(totalSupply()) <= maxSupply,
            "PRuF:M: mint request exceeds max supply"
        );
        //^^^^^^^checks^^^^^^^^^

        _mint(to, amount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Returns Max Supply
     *
     */
    function max_Supply() external pure returns (uint256) {
        return maxSupply;
    }

    /**
     * @dev Pauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_pause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function pause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PRuF:P: must have pauser role to pause"
        );
        //^^^^^^^checks^^^^^^^^^
        _pause();
        //^^^^^^^effects^^^^^^^^
    }

    /**
     * @dev Unpauses all token transfers.
     *
     * See {ERC20Pausable} and {Pausable-_unpause}.
     *
     * Requirements:
     *
     * - the caller must have the `PAUSER_ROLE`.
     */
    function unpause() public virtual {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PRuF:U: must have pauser role to unpause"
        );
        //^^^^^^^checks^^^^^^^^^
        _unpause();
        //^^^^^^^effects^^^^^^^^
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }
}
