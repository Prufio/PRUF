/*--------------------------------------------------------PRüF0.8.0
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
 * sharesShare is 0.25 share of root costs- when we transition networks this should be rewritten to become a variable share.
 *-----------------------------------------------------------------
 * PRUF UTILITY TOKEN CONTRACT
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/token/ERC20/ERC20Burnable.sol";
import "./Imports/utils/Pausable.sol";
 
import "./Imports/token/ERC20/ERC20Snapshot.sol";

/**
 * @dev {ERC20} token, including:
 *
 *  - ability for holders to burn (destroy) their tokens
 *  - a MINTER_ROLE that allows for token minting (creation)
 *  - a PAUSER_ROLE that allows to stop all token transfers
 *  - a SNAPSHOT_ROLE that allows to take snapshots
 *  - a PAYABLE_ROLE role that allows authorized addresses to invoke the token splitting payment function (all paybale contracts)
 *  - a TRUSTED_AGENT_ROLE role that allows authorized addresses to transfer and burn tokens (AC_MGR)


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
    Pausable,
    ERC20Snapshot
{
    bytes32 public constant CONTRACT_ADMIN_ROLE = keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    bytes32 public constant PAYABLE_ROLE = keccak256("PAYABLE_ROLE");
    bytes32 public constant TRUSTED_AGENT_ROLE = keccak256(
        "TRUSTED_AGENT_ROLE"
    );

    

    uint256 private _cap = 4000000000000000000000000000; //4billion max supply

    address private sharesAddress = address(0);

    uint256 trustedAgentEnabled = 1;

    mapping(address => uint256) private coldWallet;

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `CONTRACT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * See {ERC20-constructor}.
     */
    constructor() ERC20("PRUF Network", "PRUF") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    //------------------------------------------------------------------------MODIFIERS

    /*
     * @dev Verify user credentials //CTS:EXAMINE comment kinda weak
     * Originating Address:
     *      is Admin //CTS:EXAMINE "is Contract Admin"
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "PRUF:MOD-IADM: Must have CONTRACT_ADMIN_ROLE" //CTS:EXAMINE "PRUF:MOD-ICA"
        );
        _;
    }

    /*
     * @dev Verify user credentials //CTS:EXAMINE comment kinda weak
     * Originating Address:
     *      is Pauser
     */
    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "PRUF:MOD-IP: Must have PAUSER_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials //CTS:EXAMINE comment kinda weak
     * Originating Address:
     *      is Minter
     */
    modifier isMinter() {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "PRUF:MOD-IM: Must have MINTER_ROLE"
        );
        _;
    }

    /*
     * @dev Verify user credentials //CTS:EXAMINE comment kinda weak
     * Originating Address:
     *      is Payable in PRUF
     */
    modifier isPayable() {
        require(
            hasRole(PAYABLE_ROLE, _msgSender()),
            "PRUF:MOD-IPAY: Must have PAYABLE_ROLE"
        );
        require(
            trustedAgentEnabled == 1,
            "PRUF:MOD-IPAY: Trusted Payable Function permanently disabled - use allowance / transferFrom pattern"
        );
        _;
    }

    /*
     * @dev Verify user credentials //CTS:EXAMINE comment kinda weak
     * Originating Address:
     *      is Trusted Agent
     */
    modifier isTrustedAgent() {
        require(
            hasRole(TRUSTED_AGENT_ROLE, _msgSender()),
            "PRUF:MOD-ITA: Must have TRUSTED_AGENT_ROLE"
        );
        require(
            trustedAgentEnabled == 1,
            "PRUF:MOD-ITA: Trusted Agent function permanently disabled - use allowance / transferFrom pattern"
        );
        _;
    }

    /*
     * @dev ----------------------------------------PERMANANTLY !!!  Kills trusted agent and payable functions
     * this will break the functionality of current payment mechanisms.
     *
     * The workaround for this is to create an allowance for pruf contracts for a single or multiple payments,
     * either ahead of time "loading up your PRUF account" or on demand with an operation. On demand will use quite a bit more gas.
     * "preloading" should be pretty gas efficient, but will add an extra step to the workflow, requiring users to have sufficient
     * PRUF "banked" in an allowance for use in the system.
     * //CTS:EXAMINE param
     */
    function adminKillTrustedAgent(uint256 _key) external isContractAdmin {
        if (_key == 170) {
            trustedAgentEnabled = 0; //-------------------THIS IS A PERMANENT ACTION AND CANNOT BE UNDONE
        }
    }

    /*
     * @dev Set calling wallet to a "cold Wallet" that cannot be manipulated by TRUSTED_AGENT or PAYABLE permissioned functions
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS and must be unset from cold before it can interact with
     * contract functions.
     */
    function setColdWallet() external {
        coldWallet[_msgSender()] = 170;
    }

    /*
     * @dev un-set calling wallet to a "cold Wallet", enabling manipulation by TRUSTED_AGENT and PAYABLE permissioned functions
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS and must be unset from cold before it can interact with
     * contract functions.
     */
    function unSetColdWallet() external {
        coldWallet[_msgSender()] = 0;
    }

    /*
     * @dev return an adresses "cold wallet" status //CTS:EXAMINE adress->address
     * WALLET ADDRESSES SET TO "Cold" DO NOT WORK WITH TRUSTED_AGENT FUNCTIONS
     * //CTS:EXAMINE param
     * //CTS:EXAMINE return
     */
    function isColdWallet(address _addr) external view returns (uint256) {
        return coldWallet[_addr];
    }

    /*
     * @dev Set address of SHARES payment contract. by default contract will use root address instead if set to zero.
     * //CTS:EXAMINE param
     */
    function AdminSetSharesAddress(address _paymentAddress) external isContractAdmin {
        require(
            _paymentAddress != address(0),
            "PRUF:ASSA: Payment address cannot be zero"
        );

        //^^^^^^^checks^^^^^^^^^

        sharesAddress = _paymentAddress;
        //^^^^^^^effects^^^^^^^^^
    }

    /* //CTS:EXAMINE what is this?
     * @dev Deducts token payment from transaction
     * address rootAddress;
       uint256 rootPrice;
       address ACTHaddress;
       uint256 ACTHprice;
       uint32 asset class ----this will be built out to enable staking.
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
     //------------------------- NON-LEGACY
    function payForService(
        address _senderAddress,
        Invoice calldata invoice
    ) external isPayable { //PREFERRED unreachable with current contracts
        require(
            coldWallet[_senderAddress] == 0,
            "PRUF:PFS: Cold Wallet - Trusted payable functions prohibited"
        );
        require( //redundant? throws on transfer?
            balanceOf(_senderAddress) >= (invoice.rootPrice + invoice.ACTHprice),
            "PRUF:PFS: Insufficient balance"
        );
        //^^^^^^^checks^^^^^^^^^

        if (sharesAddress == address(0)) {
            //IF SHARES ADDRESS IS NOT SET
            _transfer(_senderAddress, invoice.rootAddress, invoice.rootPrice);
            _transfer(_senderAddress, invoice.ACTHaddress, invoice.ACTHprice);
        } else {
            //IF SHARES ADDRESS IS SET
            uint256 sharesShare = invoice.rootPrice / 4; // sharesShare is 0.25 share of root costs when we transition networks this should be a variable share.
            uint256 rootShare = invoice.rootPrice - sharesShare; // adjust root price to be root price - 0.25 share

            _transfer(_senderAddress, invoice.rootAddress, rootShare);
            _transfer(_senderAddress, sharesAddress, sharesShare);
            _transfer(_senderAddress, invoice.ACTHaddress, invoice.ACTHprice);
        }
        //^^^^^^^effects / interactions^^^^^^^^^ //CTS:EXAMINE just interactions
    }

    //------------------------------ LEGACY //CTS:EXAMINE remove?
    // function payForService(
    //     address _senderAddress,
    //     address _rootAddress,
    //     uint256 _rootPrice,
    //     address _ACTHaddress,
    //     uint256 _ACTHprice
    // ) external isPayable {
    //     require(
    //         coldWallet[_senderAddress] == 0,
    //         "PRUF:PFS: Cold Wallet - Trusted payable functions prohibited"
    //     );
    //     require( //redundant? throws on transfer?
    //         balanceOf(_senderAddress) >= (_rootPrice + _ACTHprice),
    //         "PRUF:PFS: insufficient balance"
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     if (sharesAddress == address(0)) {
    //         //IF SHARES ADDRESS IS NOT SET
    //         _transfer(_senderAddress, _rootAddress, _rootPrice);
    //         _transfer(_senderAddress, _ACTHaddress, _ACTHprice);
    //     } else {
    //         //IF SHARES ADDRESS IS SET
    //         uint256 sharesShare = _rootPrice / 4; // sharesShare is 0.25 share of root costs when we transition networks this should be a variable share.
    //         uint256 rootShare = _rootPrice - sharesShare; // adjust root price to be root price - 0.25 share

    //         _transfer(_senderAddress, _rootAddress, rootShare);
    //         _transfer(_senderAddress, sharesAddress, sharesShare);
    //         _transfer(_senderAddress, _ACTHaddress, _ACTHprice);
    //     }
    //     //^^^^^^^effects / interactions^^^^^^^^^
    // }

    /*
     * @dev arbitrary burn (requires TRUSTED_AGENT_ROLE)   ****USE WITH CAUTION
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function trustedAgentBurn(address _addr, uint256 _amount)
        external
        isTrustedAgent
    {
        require(
            coldWallet[_addr] == 0,
            "PRUF:TAB: Cold Wallet - Trusted functions prohibited"
        );
        //^^^^^^^checks^^^^^^^^^
        _burn(_addr, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev arbitrary transfer (requires TRUSTED_AGENT_ROLE)   ****USE WITH CAUTION
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function trustedAgentTransfer(
        address _from,
        address _to,
        uint256 _amount
    ) external isTrustedAgent {
        require(
            coldWallet[_from] == 0,
            "PRUF:TAT: Cold Wallet - Trusted functions prohibited"
        );
        //^^^^^^^checks^^^^^^^^^
        _transfer(_from, _to, _amount);
        //^^^^^^^effects^^^^^^^^^
    }

    /*
     * @dev Take a balance snapshot, returns snapshot ID
     * //CTS:EXAMINE return
     */
    function takeSnapshot() external returns (uint256) {
        require(
            hasRole(SNAPSHOT_ROLE, _msgSender()),
            "PRUF:TS: ERC20PresetMinterPauser: must have snapshot role to take a snapshot"
        );
        return _snapshot();
    }

    /**
     * @dev Creates `_amount` new tokens for `to`.
     *
     * See {ERC20-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function mint(address to, uint256 _amount) public virtual {
        require(
            hasRole(MINTER_ROLE, _msgSender()),
            "PRUF:M: Must have MINTER_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        _mint(to, _amount);
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
    function pause() public virtual isPauser {
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
    function unpause() public virtual isPauser {
        //^^^^^^^checks^^^^^^^^^
        _unpause();
        //^^^^^^^effects^^^^^^^^
    }

    /**
     * @dev Returns the cap on the token's total supply.
     * //CTS:EXAMINE return
     */
    function cap() public view returns (uint256) {
        return _cap;
    }

    /**
     * @dev all paused functions are blocked here, unless caller has "pauser" role
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20, ERC20Snapshot) {
        super._beforeTokenTransfer(from, to, amount);

        require(
            (!paused()) || hasRole(PAUSER_ROLE, _msgSender()),
            "PRUF:BTT: Function unavailble while contract is paused"
        );
        if (from == address(0)) {
            // When minting tokens
            require(
                (totalSupply() + amount) <= _cap,
                "PRUF:BTT: Cap exceeded"
            );
        }
    }
}
