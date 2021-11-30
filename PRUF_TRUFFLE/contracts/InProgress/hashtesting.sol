// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title hashtest
 * Tested and working
 */
contract hashName {
    function hashK256(
        string memory _subDomain,
        string memory _domain,
        string memory _tld
    ) public pure returns (bytes32, string memory) {
        bytes32 namehash = 0;
        if (bytes(abi.encodePacked(_domain, _tld)).length != 0) {
            namehash = keccak256(
                abi.encodePacked(namehash, keccak256(abi.encodePacked(_tld)))
            );

            if (bytes(abi.encodePacked(_domain)).length != 0) {
                namehash = keccak256(
                    abi.encodePacked(
                        namehash,
                        keccak256(abi.encodePacked(_domain))
                    )
                );
            }

            if (bytes(abi.encodePacked(_subDomain)).length != 0) {
                namehash = keccak256(
                    abi.encodePacked(
                        namehash,
                        keccak256(abi.encodePacked(_subDomain))
                    )
                );
            }
        }

        string memory nodeName = string(abi.encodePacked(_domain,".",_tld));
        return (namehash, nodeName);
    }
}
