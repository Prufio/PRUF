// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Ownable.sol";


interface BPMinterInterface {
    function transferA(address from, address to, uint256 tokenId) external;
}


contract TESTfrontend is Ownable {
    address BPMinterContractAddress;
    BPMinterInterface private BPMinterContract;

    function OO_setBPMinterContractAddress(address _contractAddress)
        external
        onlyOwner
    {
        require(_contractAddress != address(0), "Invalid contract address");
        BPMinterContractAddress = _contractAddress;
        BPMinterContract = BPMinterInterface(_contractAddress);
    }

    function $transfer(
        address from,
        address to,
        uint256 tokenId
    ) external {
        BPMinterContract.transferA(from, to, tokenId);
    }
}
