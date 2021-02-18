// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "../introspection/ERC165Storage.sol";

contract ERC165StorageMock is ERC165Storage {
    function registerInterface(bytes4 interfaceId) public {
        _registerInterface(interfaceId);
    }
}
