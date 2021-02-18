// SPDX-License-Identifier: MIT

pragma solidity ^0.7.1;

import "../utils/Pausable.sol";

contract PausableMock is Pausable {
    bool public drasticMeasureTaken;
    uint256 public count;

    constructor () {
        drasticMeasureTaken = false;
        count = 0;
    }

    function normalProcess() external whenNotPaused {
        count++;
    }

    function drasticMeasure() external whenPaused {
        drasticMeasureTaken = true;
    }

    function pause() external {
        _pause();
    }

    function unpause() external {
        _unpause();
    }
}
