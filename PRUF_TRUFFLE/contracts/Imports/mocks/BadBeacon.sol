// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

contract BadBeaconNoImpl {
}

contract BadBeaconNotContract {
    function implementation() external pure returns (address) {
        return address(0x1);
    }
}
