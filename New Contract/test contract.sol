// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.2;

import "./Ownable.sol";

interface erc721_tokenInterface {
    function ownerOf(uint256) external view returns (address);
}

contract test is Ownable {

    address erc721ContractAddress;
    erc721_tokenInterface erc721_tokenContract; //erc721_token prototype initialization

    function setErc721_tokenAddress(address contractAddress) public onlyOwner {
        require(contractAddress != address(0), "Invalid contract address");
        erc721ContractAddress = contractAddress;
        erc721_tokenContract = erc721_tokenInterface(contractAddress);
    }


    function atWhatAddress (uint256 tokenID) external onlyOwner returns (address){
        return erc721_tokenContract.ownerOf(tokenID);
    }

    function atMyAddress (uint256 tokenID) external returns (string){

    }

}


