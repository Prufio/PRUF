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
 *  TO DO --- complete test! DPS TEST NEW CONTRACT
 *  MUST BE TRUSTED AGENT IN A_TKN
 *
 *-----------------------------------------------------------------
 * Wraps and unwraps ERC721 compliant tokens in a PRUF Asset token
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract WRAP is CORE {
    struct WrappedToken {
        uint256 tokenID;
        address tokenContract;
    }

    mapping(uint256 => WrappedToken) private wrapped; // pruf tokenID -> original TokenID, ContractAddress

    modifier isTokenHolder(uint256 _tokenID, address _tokenContract) {
        //require that user holds token @ ID-Contract
        require(
            (IERC721(_tokenContract).ownerOf(_tokenID) == _msgSender()),
            "W:MOD-ITH: Caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Wraps a token, takes original from caller
     * Prerequisite: contract authorized for token txfr
     * Takes original 721
     * Makes a pruf record (exists?) if so does not change
     * Mints a pruf token to caller (exists?) if so ???????
     * Asset Class? must be type 5  / enabled for contract address
     *
     */
    function wrap721(
        uint256 _foreignTokenID,
        address _foreignTokenContract,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_foreignTokenID, _foreignTokenContract) // without this, the dark forest gets it!
    {
        bytes32 idxHash =
            keccak256(abi.encodePacked(_foreignTokenID, _foreignTokenContract));

        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(_assetClass);

        uint256 newTokenId = uint256(idxHash);
        // AC memory oldAC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 5,
            "W:W: Asset class.custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
            (AC_info.referenceAddress == _foreignTokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "W:W: Asset class extended data must be '0' or ERC721 contract address"
        );
        //^^^^^^^checks^^^^^^^^^

        wrapped[newTokenId].tokenID = _foreignTokenID;
        wrapped[newTokenId].tokenContract = _foreignTokenContract;
        //^^^^^^^effects^^^^^^^^^

        foreignTransfer(
            _foreignTokenContract,
            _msgSender(),
            address(this),
            _foreignTokenID
        ); // move token to this contract

        if (rec.assetClass == 0) {
            //record does not exist
            createRecord(idxHash, _rgtHash, _assetClass, _countDownStart);
        } else {
            //just mint the token, record already exists
            A_TKN.mintAssetToken(_msgSender(), newTokenId, "pruf.io");
        }
        deductServiceCosts(_assetClass, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Unwraps a token, returns original to caller
     * burns pruf token from caller wallet
     * Sends original 721 to caller
     */
    function unWrap721(uint256 _tokenID)
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenID, A_TKN_Address) //caller holds the wrapped token
    {
        bytes32 idxHash = bytes32(_tokenID);
        Record memory rec = getRecord(idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);
        address foreignTokenContract = wrapped[_tokenID].tokenContract;
        uint256 foreignTokenID = wrapped[_tokenID].tokenID;

        require(AC_info.custodyType == 5, "W:UW: Asset class.custodyType != 5");
        require( // CTS:PREFERRED, STAT UNREACHABLE WITH CURRENT CONTRACTS
            (AC_info.referenceAddress == foreignTokenContract) ||
                (AC_info.referenceAddress == address(0)),
            "W:UW: Asset class extended data must be '0' or ERC721 contract address"
        );
        require(
            rec.assetStatus == 51,
            "W:UW: Asset not in transferrable status"
        );
        //^^^^^^^checks^^^^^^^^^

        //^^^^^^^effects^^^^^^^^^

        A_TKN.trustedAgentBurn(_tokenID);

        foreignTransfer(
            foreignTokenContract,
            address(this),
            _msgSender(),
            foreignTokenID
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev transfer a foreign token
     */
    function foreignTransfer(
        address _tokenContract,
        address _from,
        address _to,
        uint256 _tokenID
    ) internal {
        IERC721(_tokenContract).transferFrom(_from, _to, _tokenID);
    }

    /*
     * @dev create a Record in Storage @ idxHash (SETTER)
     */
    function createRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _assetClass,
        uint32 _countDownStart
    ) internal override {
        uint256 tokenId = uint256(_idxHash);
        AC memory AC_info = getACinfo(_assetClass);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "W:CR: Asset token already exists"
        );
        require( //CTS:PREFERRED redundant/unreachable with current contract structure, throws in wrap.
            (AC_info.custodyType == 5),
            "W:CR: Cannot create asset - contract not authorized for asset class custody type"
        );
        require(
            (AC_info.managementType < 6),
            "W:CR: Contract does not support management types > 5 or AC is locked"
        );
        if (
            (AC_info.managementType == 1) ||
            (AC_info.managementType == 2) ||
            (AC_info.managementType == 5)
        ) {
            require(
                (AC_TKN.ownerOf(_assetClass) == _msgSender()),
                "W:CR: Cannot create asset in AC mgmt type 1||2||5 - caller does not hold AC token"
            );
        } else if (AC_info.managementType == 3) {
            require(
                AC_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _assetClass
                ) == 1,
                "W:CR:Cannot create asset - caller address not authorized"
            );
        } else if (AC_info.managementType == 4) {
            require(
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "W:CR:Caller does not hold sufficiently trusted ID"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        A_TKN.mintAssetToken(_msgSender(), tokenId, "pruf.io");
        STOR.newRecord(_idxHash, _rgtHash, _assetClass, _countDownStart);
        //^^^^^^^interactions^^^^^^^^^
    }
}
