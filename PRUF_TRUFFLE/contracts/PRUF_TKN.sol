// SPDX-License-Identifier: MIT

pragma solidity ^0.6.7;

import "./PRUF_INTERFACES.sol";
import "./imports/access/AccessControl.sol";
import "./imports/GSN/Context.sol";
import "./imports/token/ERC20/ERC20.sol";
import "./imports/token/ERC20/ERC20Burnable.sol";
import "./imports/token/ERC20/ERC20Pausable.sol";
import "./imports/token/ERC20/ERC20Snapshot.sol";

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
            "B:SSC: storage address cannot be zero"
        );

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:M: must have DEFAULT_ADMIN_ROLE"
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
            "B:SSC: storage address cannot be zero"
        );

        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:M: must have DEFAULT_ADMIN_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        paymentAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function increaseShare(uint32 _assetClass, uint256 _amount) //DS:TEST the fuck out of this
        public
        returns (bool)
    {
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

    /*
     * @dev Resolve Contract Addresses from STOR
     */
    function AdminResolveContractAddresses() external virtual {
        require(
            hasRole(DEFAULT_ADMIN_ROLE, _msgSender()),
            "PRuF:M: must have DEFAULT_ADMIN_ROLE"
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
}
