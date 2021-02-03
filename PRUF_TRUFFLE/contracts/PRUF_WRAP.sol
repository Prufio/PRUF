/*--------------------------------------------------------PRuF0.7.1
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
 *  TO DO --- complete test! DPS TEST NEW CONTRACT
 *  UNFINISHED!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 *
 *----------------------------------------------------------------*/



// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract WRAP is CORE {
    // modifier isAuthorized(bytes32 _idxHash) override {
    //     //require that user is authorized and token is held by contract
    //     uint256 tokenId = uint256(_idxHash);
    //     require(
    //         (A_TKN.ownerOf(tokenId) == address(this)),
    //         "A:MOD-IA: EXTEND contract does not hold token"
    //     );
    //     _;
    // }

    modifier isTokenHolder(uint256 _tokenID, address _tokenContract) {
        //require that user holds token @ ID-Contract
        require(
            (IERC721(_tokenContract).ownerOf(_tokenID) == _msgSender()),
            "A:MOD-IA: caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Wraps a token, takes original from caller
     */
    function wrap721(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "E:DEC:Asset class.custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
            (AC_info.extendedData == uint160(_tokenContract)) || (AC_info.extendedData == 0) ,
            "E:DEC:Asset class extended data must be '0' or uint160(ERC721 contract address)"
        );

        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) { //if record has existed before
            createRecord(
                idxHash,
                _rgtHash,
                _assetClass,
                rec.countDownStart
            );
        } else {
            createRecord(idxHash, _rgtHash, _assetClass, _countDownStart);
        }
        deductServiceCosts(_assetClass, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Unwraps a token, returns original to caller
     */
    function unWrap721(
        uint256 _tokenID,
        address _tokenContract,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, _tokenContract)
    {
        bytes32 idxHash = keccak256(abi.encodePacked(_tokenID, _tokenContract));
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(_assetClass);
        AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "E:DEC:Asset class.custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
            (AC_info.extendedData == uint160(_tokenContract)) || (AC_info.extendedData == 0) ,
            "E:DEC:Asset class extended data must be '0' or uint160(ERC721 contract address)"
        );

        //^^^^^^^effects^^^^^^^^^

        if (AC_info.assetClassRoot == oldAC_info.assetClassRoot) { //if record has existed before
            createRecord(
                idxHash,
                _rgtHash,
                _assetClass,
                rec.countDownStart
            );
        } else {
            createRecord(idxHash, _rgtHash, _assetClass, _countDownStart);
        }
        deductServiceCosts(_assetClass, 1);

        //^^^^^^^interactions^^^^^^^^^
    }

 

}
