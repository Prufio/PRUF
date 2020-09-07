/*-----------------------------------------------------------V0.6.8
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
 *
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
 *  - a minter role that allows for token minting (creation)
 *  - a pauser role that allows to stop all token transfers
 *
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract PRUF_TKN is
    Context,
    AccessControl,
    ERC20Burnable,
    ERC20Pausable,
    ERC20Snapshot
{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    address internal AC_MGR_Address;
    AC_MGR_Interface internal AC_MGR;

    address internal STOR_Address;
    STOR_Interface internal STOR;

    address internal paymentAddress;

    uint256 internal ACtokenIndex = 10000;
    uint256 internal currentACtokenPrice = 5000;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor() public ERC20("PRuf_Tkn", "PRuF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /*
     * @dev Set adress of STOR contract to interface with
     */
    function AdminSetStorageContract(address _storageAddress) external {
        require(
            _storageAddress != address(0),
            "PRuF:SSC: storage address cannot be zero"
        );

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:SSC: must have DEFAULT_ADMIN_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        STOR = STOR_Interface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Set adress of payment contract
     */
    function AdminSetPaymentAddress(address _paymentAddress) external {
        require(
            _paymentAddress != address(0),
            "PRuF:SPA: storage address cannot be zero"
        );

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:SPA: must have DEFAULT_ADMIN_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        paymentAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev See {IERC20-transfer}. Increase payment share of an asset class
     *
     * Requirements:
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function increaseShare(
        uint32 _assetClass,
        uint256 _amount //DS:TEST the fuck out of this
    ) public returns (bool) {
        require(
            balanceOf(msg.sender) >= _amount,
            "PRuf:IS:Insufficient PRuF token Balance for transaction"
        );
        require(
            _amount > 99,
            "PRuf:IS:amount < 100 will not increase price share"
        );

        require(_amount <= 6000, "PRuf:IS:amount > 10000 exceeds max"); // 3k-9k is 6K - 10K is more than possibly required in any forseeable circumstance

        uint256 oldShare = uint256(AC_MGR.getAC_discount(_assetClass));

        uint256 maxPayment = uint256(9000).sub(oldShare); //max payment percentage never goes over 90%

        if (_amount > maxPayment) _amount = maxPayment;

        _transfer(_msgSender(), paymentAddress, _amount);

        AC_MGR.increasePriceShare(_assetClass, _amount);
        return true;
    }

    /**
     * @dev Burns (amout) tokens and mints a new asset class token to the caller address
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function purchaseACtoken(
        uint32 _assetClassRoot,
        uint8 _custodyType //DS:TEST the fuck out of this
    ) public returns (bool) {

        if (ACtokenIndex < 4294000001) ACtokenIndex++; //increment ACtokenIndex up to last one

        require(
            balanceOf(msg.sender) >= currentACtokenPrice,
            "PRuf:IS:Insufficient PRuF token Balance for transaction"
        );
        require(
            ACtokenIndex < 4294000000,
            "PRuf:IS:Only 4294000000 AC tokens allowed"
        );

        _burn(_msgSender(), currentACtokenPrice);

        //mint an asset class token to msg.sender, at tokenID ACtokenIndex, with URI = root asset Class #
        AC_MGR.createAssetClass(
            msg.sender,
            uint256toString(uint256(_assetClassRoot)),
            uint32(ACtokenIndex), //safe because ACtokenIndex <  4294000000 required
            _assetClassRoot,
            _custodyType
        );

        uint256 newACtokenPrice;
        uint256 numberOfTokensSold = ACtokenIndex.sub(uint256(10000));

        if (numberOfTokensSold >= 4000) {
            newACtokenPrice = 100000;
        } else if (numberOfTokensSold >= 2000) {
            newACtokenPrice = 75937;
        } else if (numberOfTokensSold >= 1000) {
            newACtokenPrice = 50625;
        } else if (numberOfTokensSold >= 500) {
            newACtokenPrice = 33750;
        } else if (numberOfTokensSold >= 250) {
            newACtokenPrice = 22500;
        } else if (numberOfTokensSold >= 125) {
            newACtokenPrice = 15000;
        } else {
            newACtokenPrice = 10000;
        }

        currentACtokenPrice = newACtokenPrice;

        return true;
    }

    /*
     * @dev return current AC token index pointer
     */
    function currentACtokenInfo() external view returns (uint256, uint256) {
        //^^^^^^^checks^^^^^^^^^

        uint256 numberOfTokensSold = uint256(10000).sub(ACtokenIndex);
        return (numberOfTokensSold, currentACtokenPrice);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Resolve Contract Addresses from STOR
     */
    function AdminResolveContractAddresses() external virtual {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:RCA: must have DEFAULT_ADMIN_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        AC_MGR_Address = STOR.resolveContractAddress("AC_MGR");
        AC_MGR = AC_MGR_Interface(AC_MGR_Address);

        //^^^^^^^effects^^^^^^^^^
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
        _mint(to, amount);
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
        _pause();
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
        _unpause();
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Pausable, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);
    }

    function uint256toString(uint256 number)
        private
        pure
        returns (string memory)
    {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        // shamelessly jacked straight outa OpenZepplin  openzepplin.org

        if (number == 0) {
            return "0";
        }
        uint256 temp = number;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = number;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }
}
