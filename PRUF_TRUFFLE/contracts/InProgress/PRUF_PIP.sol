/*--------------------------------------------------------PRüF0.8.7
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 * PIP IS VULNERABLE TO THE DARK FOREST, needs to be completely rewritten
 * PIP NEEDS TO BE DONE BY A SERVER USING AUTH MINTER IN node ADDRESS, USING content adressable storage FOR DATA STORAGE.
 * Perhaps this can work with some kind of ZK auth? Doubt?
 *
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";

contract PIP is CORE {
    uint256 importDiscount = 2;

    /*
     * @dev Sets import discount for this contract
     */
    function setImportDiscount(uint256 _importDiscount)
        external
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^
        if (_importDiscount < 1) {
            importDiscount = 1;
        } else {
            importDiscount = _importDiscount;
        }
        //^^^^^^^effects^^^^^^^^^^^^
    }

    function mintPipAsset(
        bytes32 _idxHash,
        bytes32 _hashedAuthCode, // token URI needs to be K256(packed( uint32 node, string authCode)) supplied off chain
        uint32 _node
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(_node);

        require(
            (NODE_TKN.ownerOf(_node) == _msgSender()), //_msgSender() is node token holder
            "P:MPA: Caller does not hold node token"
        );
        require(
            userType == 10,
            "P:MPA: User not authorized to mint PIP assets"
        );
        require(
            rec.node == 0, //verified as VALID
            "P:MPA: Asset already registered in system"
        );
        // //^^^^^^^checks^^^^^^^^^

        string memory tokenURI;
        bytes32 b32URI = keccak256(abi.encodePacked(_hashedAuthCode, _node));
        tokenURI = uint256toString(uint256(b32URI));
        //^^^^^^^effects^^^^^^^^^^^^

        A_TKN.mintAssetToken(address(this), tokenId); //mint a PIP token...this needs to send it to the right address, its dumb right now
        A_TKN.setURI(tokenId, tokenURI); 
    }

    /*
     * @dev Import a record into a new node
     */
    function claimPipAsset(
        bytes32 _idxHash,
        //String calldata _authCode,
        uint32 _newNode,
        bytes32 _rgtHash,
        uint32 _countDownStart
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);

        require(
            A_TKN.ownerOf(tokenId) == address(this),
            "P:CPA: Token not found in PRUF_PIP"
        );
        //^^^^^^^checks^^^^^^^^^

        //A_TKN.validatePipToken(tokenId, _newNode, _authCode); //check supplied data matches tokenURI
        STOR.newRecord(_idxHash, _rgtHash, _newNode, _countDownStart); // Make a new record at the tokenId b32
        A_TKN.setURI(tokenId, "pruf.io/PIP"); // set URI
        A_TKN.safeTransferFrom(address(this), _msgSender(), tokenId); // sends token from this holding contract to caller wallet
        deductImportRecordCosts(_newNode);

        //^^^^^^^interactions^^^^^^^^
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function uint256toString(uint256 value)
        internal
        pure
        returns (string memory)
    {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        // value = uint256(0x2ce8d04a9c35987429af538825cd2438cc5c5bb5dc427955f84daaa3ea105016);

        if (value == 0) {
            return "0";
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
        return string(buffer);
    }

    function deductImportRecordCosts(uint32 _node) internal whenNotPaused {
        //^^^^^^^checks^^^^^^^^^

        Invoice memory pricing = NODE_MGR.getInvoice(_node, 1);

        pricing.rootPrice = pricing.rootPrice / importDiscount;
        pricing.NTHprice = pricing.NTHprice / importDiscount;
        //^^^^^^^effects^^^^^^^^^

        deductPayment(pricing);
        //^^^^^^^interactions^^^^^^^
    }
}
