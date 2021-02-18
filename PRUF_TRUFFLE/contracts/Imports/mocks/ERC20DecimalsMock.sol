// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "../token/ERC20/ERC20.sol";

contract ERC20DecimalsMock is ERC20 {
    uint8 immutable private _decimals;

    constructor (string memory name_, string memory symbol_, uint8 decimals_) ERC20(name_, symbol_) {
        _decimals = decimals_;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
