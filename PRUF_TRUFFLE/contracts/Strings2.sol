// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
contract Strings2 {
    // bytes16 private constant alphabet = "0123456789abcdef";

    string public tempVal = "unchanged";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     *0x2ce8d04a9c35987429af538825cd2438cc5c5bb5dc427955f84daaa3ea105016
     */
    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function setTempVal() external {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        uint256 value = uint256(0x2ce8d04a9c35987429af538825cd2438cc5c5bb5dc427955f84daaa3ea105016);

        if (value == 0) {
            tempVal = "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        tempVal = string(buffer);
    }

    // function setTempVal() external {
    //     tempVal = "changed";
    // }

    function getTempVal() external view returns (string memory) {
        return tempVal;
    }

    // /**
    //  * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
    //  */
    // function toHexString(uint256 value) internal pure returns (string memory) {
    //     if (value == 0) {
    //         return "0x00";
    //     }
    //     uint256 temp = value;
    //     uint256 length = 0;
    //     while (temp != 0) {
    //         length++;
    //         temp >>= 8;
    //     }
    //     return toHexString(value, length);
    // }

    // /**
    //  * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
    //  */
    // function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
    //     bytes memory buffer = new bytes(2 * length + 2);
    //     buffer[0] = "0";
    //     buffer[1] = "x";
    //     for (uint256 i = 2 * length + 1; i > 1; --i) {
    //         buffer[i] = alphabet[value & 0xf];
    //         value >>= 4;
    //     }
    //     require(value == 0, "Strings: hex length insufficient");
    //     return string(buffer);
    // }
}
