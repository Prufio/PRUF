/*-----------------------------------------------------------V0.7.0
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
contract UTIL_TKN is
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

    uint256 internal ACtokenIndex = 1000000; //asset tokens created in sequence at 1,000,000 +
    uint256 internal currentACtokenPrice = 10000;

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
            "PRuF:SPA: payment address cannot be zero"
        );

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:SPA: must have DEFAULT_ADMIN_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        paymentAddress = _paymentAddress;
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

        //^^^^^^^effects/interactions^^^^^^^^^
    }


    /*
     * @dev return current AC token index pointer
     */
    function currentACtokenInfo() external view returns (uint256, uint256) {
        //^^^^^^^checks^^^^^^^^^

        uint256 numberOfTokensSold = ACtokenIndex.sub(uint256(1000000));
        return (numberOfTokensSold, currentACtokenPrice);
        //^^^^^^^effects/interactions^^^^^^^^^
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
        uint256 _amount
    ) public returns (bool) {
        require(
            balanceOf(msg.sender) >= _amount,
            "PRuf:IS:Insufficient PRuF token Balance for transaction"
        );
        require(
            _amount > 199,
            "PRuf:IS:amount < 200 will not increase price share"
        );

        //^^^^^^^checks^^^^^^^^^

        uint256 oldShare = uint256(AC_MGR.getAC_discount(_assetClass));

        uint256 maxPayment = (uint256(9000).sub(oldShare)).mul(uint256(2)); //max payment percentage never goes over 90%
        if (_amount > maxPayment) _amount = maxPayment;

        _transfer(_msgSender(), paymentAddress, _amount);

        AC_MGR.increasePriceShare(_assetClass, _amount.div(uint256(2)));
        return true;
        //^^^^^^^effects/interactions^^^^^^^^^
    }

    /**
     * @dev Burns (amout) tokens and mints a new asset class token to the caller address
     *
     * Requirements:
     * - the caller must have a balance of at least `amount`.
     */
    function purchaseACtoken(
        string memory _name,
        uint32 _assetClassRoot,
        uint8 _custodyType
    ) public returns (bool) {

        require(
            balanceOf(msg.sender) >= currentACtokenPrice,
            "PRuf:IS:Insufficient PRuF token Balance for transaction"
        );
        require(               //Impossible to test??
            ACtokenIndex < 4294000000,
            "PRuf:IS:Only 4294000000 AC tokens allowed"
        );
        //^^^^^^^checks^^^^^^^^^

        if (ACtokenIndex < 4294000000) ACtokenIndex++; //increment ACtokenIndex up to last one

        uint256 newACtokenPrice;
        uint256 numberOfTokensSold = ACtokenIndex.sub(uint256(1000000));

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
        //^^^^^^^effects^^^^^^^^^

        //mint an asset class token to msg.sender, at tokenID ACtokenIndex, with URI = root asset Class #
        AC_MGR.createAssetClass(
            msg.sender,
            _name,
            uint32(ACtokenIndex), //safe because ACtokenIndex <  4294000000 required
            _assetClassRoot,
            _custodyType
        );

        _burn(_msgSender(), currentACtokenPrice);

        currentACtokenPrice = newACtokenPrice;

        return true;
        //^^^^^^^effects/interactions^^^^^^^^^
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
         //^^^^^^^checks^^^^^^^^^

        _mint(to, amount);
        //^^^^^^^interactions^^^^^^^^^
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
