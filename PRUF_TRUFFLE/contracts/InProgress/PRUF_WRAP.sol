/**--------------------------------------------------------PRüF0.8.7
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

/**-----------------------------------------------------------------
 *  TO DO ---
 *
 *-----------------------------------------------------------------
 * Wraps and unwraps ERC721 compliant tokens in a PRUF Asset token
 *  MUST BE TRUSTED AGENT IN A_TKN
 *----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Imports/token/ERC721/IERC721.sol";

contract WRAP is CORE {
    struct WrappedToken {
        uint256 tokenID;
        address tokenContract;
    }

    mapping(uint256 => WrappedToken) private wrapped; // pruf tokenID -> original TokenID, ContractAddress

    /**
     * @dev Verify user credentials
     * @param _tokenId tokenID of token
     * @param _tokenContract Contract to check
     * Originating Address:
     *    require that user holds token @ ID-Contract
     */
    modifier isTokenHolder(uint256 _tokenId, address _tokenContract) {
        require(
            (IERC721(_tokenContract).ownerOf(_tokenId) == _msgSender()),
            "W:MOD-ITH: Caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Wraps a token, takes original from caller
     * @param _foreignTokenID tokenID of token to wrap
     * @param _foreignTokenContract contract address for token to wrap
     * @param _rgtHash - hash of rightsholder information created by frontend inputs
     * @param _node - node the asset will be created in
     * @param _countDownStart - decremental counter for an assets lifecycle
     * Prerequisite: contract authorized for token txfr
     * Takes original 721
     * Makes a pruf record (exists?) if so does not change
     * Mints a pruf token to caller (exists?) if so ???????
     * Node.custodyType must be 5 (wrapped/decorated erc721) / enabled for contract address
     * referenceAddress must be '0' or ERC721 contract address
     *
     */
    function wrap721(
        uint256 _foreignTokenID,
        address _foreignTokenContract,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart ///DPS:TEST
    )
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_foreignTokenID, _foreignTokenContract) // without this, the dark forest gets it!
    {
        bytes32 idxHash = keccak256(
            abi.encodePacked(_foreignTokenID, _foreignTokenContract)
        );

        Record memory rec = getRecord(idxHash);
        Node memory nodeInfo = getNodeinfo(_node);

        uint256 newTokenId = uint256(idxHash);

        require(
            nodeInfo.custodyType == 5,
            "W:W:custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
            (nodeInfo.referenceAddress == _foreignTokenContract) ||
                (nodeInfo.referenceAddress == address(0)),
            "W:W:referenceAddress must be '0' or ERC721 contract address"
        );
        require( //DPS:TEST NEW
            NODE_STOR.getManagementTypeStatus(nodeInfo.managementType) > 0,
            "W:W: Invalid management type"
        );
        if (
            //DPS:TEST NEW
            (nodeInfo.managementType == 1) ||
            (nodeInfo.managementType == 2) ||
            (nodeInfo.managementType == 5)
        ) {
            require( //DPS:TEST NEW
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "W:W: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (nodeInfo.managementType == 3) {
            require( //DPS:TEST NEW
                NODE_STOR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "W:W: Cannot create asset - caller address !authorized"
            );
        } else {
            revert(
                "W:W: Contract does not support management type or node is locked"
            );
        }
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

        if (rec.node == 0) {
            //record does not exist
            createRecord(idxHash, _rgtHash, _node, _countDownStart);
        } else {
            //DPS:TEST
            //just mint the token, record already exists
            if (NODE_STOR.getSwitchAt(_node, 2) == 0) {
                //if switch at bit 2 is not set, set the mint to address to the node holder
                A_TKN.mintAssetToken(NODE_TKN.ownerOf(_node), newTokenId);
            } else {
                //if switch at bit 2 is set, send the token to the caller.
                //caller might be a custodial contract, or it might be an individual.
                A_TKN.mintAssetToken(_msgSender(), newTokenId);
            }
        } //DPS:TEST end

        deductServiceCosts(_node, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Unwraps a token, returns original to caller
     * @param _tokenId tokenID of PRUF token being unwrapped
     * burns pruf asset from caller wallet
     * Sends original 721 to caller
     */
    function unWrap721(uint256 _tokenId)
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_tokenId, A_TKN_Address) //caller holds the wrapped token
    {
        bytes32 idxHash = bytes32(_tokenId);
        Record memory rec = getRecord(idxHash);
        Node memory nodeInfo = getNodeinfo(rec.node);
        address foreignTokenContract = wrapped[_tokenId].tokenContract;
        uint256 foreignTokenID = wrapped[_tokenId].tokenID;

        require(nodeInfo.custodyType == 5, "W:UW: Node.custodyType != 5");
        require(
            (nodeInfo.referenceAddress == foreignTokenContract) ||
                (nodeInfo.referenceAddress == address(0)),
            "W:UW: Node extended data must be '0' or ERC721 contract address"
        );
        require(
            rec.assetStatus == 51,
            "W:UW: Asset not in transferrable status"
        );
        //^^^^^^^checks^^^^^^^^^
        delete wrapped[_tokenId];
        A_TKN.trustedAgentBurn(_tokenId);

        foreignTransfer(
            foreignTokenContract,
            address(this),
            _msgSender(),
            foreignTokenID
        );

        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev reveals core tokenContract address and token ID for a wrapped token.
     * @param _tokenId tokenID of PRUF token being inspected
     * Returns tokenContractAddress, tokenId of wrapped token //DPS:TEST
     */
    function getCoreTokenInfo(uint256 _tokenId)
        external
        view
        returns (address, uint256)
    {
        require(
            wrapped[_tokenId].tokenContract != address(0),
            "W:GCT:tokenId does not refer to a wrapped token"
        );
        //^^^^^^^checks^^^^^^^^^

        return (wrapped[_tokenId].tokenContract, wrapped[_tokenId].tokenID);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev transfer a foreign token
     * @param _tokenContract Address of foreign token contract
     * @param _from origin
     * @param _to destination
     * @param _tokenId Token ID
     */
    function foreignTransfer(
        address _tokenContract,
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        IERC721(_tokenContract).transferFrom(_from, _to, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev create a Record in Storage @ idxHash (SETTER)
     * @param _idxRaw Asset ID
     * @param _rgtHash Hash or user data
     * @param _node Node ID
     * @param _countDownStart Initial counter value
     * Asset token already exists
     * depending on custody type/management type, caller ID token or address myst be authorized
     */
    function createRecord(
        bytes32 _idxRaw,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) internal override {
        bytes32 idxHash = keccak256(abi.encodePacked(_idxRaw, _node)); //hash idxRaw with node to get idxHash DPS:TEST
        uint256 tokenId = uint256(idxHash);
        Node memory nodeInfo = getNodeinfo(_node);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "W:CR: Asset token already exists"
        );
        require( //DPS:TEST NEW
            NODE_STOR.getManagementTypeStatus(nodeInfo.managementType) > 0,
            "W:CR: Invalid management type"
        );
        require(
            (nodeInfo.managementType < 6),
            "W:CR: Contract does not support management types > 5 or node is locked"
        );
        if (
            (nodeInfo.managementType == 1) ||
            (nodeInfo.managementType == 2) ||
            (nodeInfo.managementType == 5)
        ) {
            require(
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "W:CR: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (nodeInfo.managementType == 3) {
            require(
                NODE_STOR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "W:CR:Cannot create asset - caller address not authorized"
            );
        } else {
            revert(
                "W:CR: Contract does not support management type or node is locked"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        if (NODE_STOR.getSwitchAt(_node, 2) == 0) {
            //DPS:TEST
            //if switch at bit 2 is not set, set the mint to address to the node holder
            A_TKN.mintAssetToken(NODE_TKN.ownerOf(_node), tokenId);
        } else {
            //if switch at bit 2 is set, send the token to the caller.
            //caller might be a custodial contract, or it might be an individual.
            A_TKN.mintAssetToken(_msgSender(), tokenId);
        } //DPS:TEST end

        STOR.newRecord(idxHash, _rgtHash, _node, _countDownStart);
        //^^^^^^^interactions^^^^^^^^^
    }
}
