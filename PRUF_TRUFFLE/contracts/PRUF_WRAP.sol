/**--------------------------------------------------------PRüF0.8.6
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
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";
import "./Imports/token/ERC721/IERC721.sol";

contract WRAP is CORE {
    struct WrappedToken {
        uint256 tokenID;
        address tokenContract;
    }

    mapping(uint256 => WrappedToken) private wrapped; // pruf tokenID -> original TokenID, ContractAddress

    /**
     * @dev Verify user credentials
     * @param _tokenID tokenID of token
     * @param _tokenContract Contract to check
     * Originating Address:
     *    require that user holds token @ ID-Contract
     */
    modifier isTokenHolder(uint256 _tokenID, address _tokenContract) {
        require(
            (IERC721(_tokenContract).ownerOf(_tokenID) == _msgSender()),
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
     * Asset class.custodyType must be 5 (wrapped/decorated erc721) / enabled for contract address
     * referenceAddress must be '0' or ERC721 contract address
     *
     */
    function wrap721(
        uint256 _foreignTokenID,
        address _foreignTokenContract,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) ///DPS:TEST
        external
        nonReentrant
        whenNotPaused
        isTokenHolder(_foreignTokenID, _foreignTokenContract) // without this, the dark forest gets it!
    {
        bytes32 idxHash =
            keccak256(abi.encodePacked(_foreignTokenID, _foreignTokenContract));

        Record memory rec = getRecord(idxHash);
        Node memory node_info =getNodeinfo(_node);

        uint256 newTokenId = uint256(idxHash);

        require(
            node_info.custodyType == 5,
            "W:W:custodyType must be 5 (wrapped/decorated erc721)"
        );
        require(
            (node_info.referenceAddress == _foreignTokenContract) ||
                (node_info.referenceAddress == address(0)),
            "W:W:referenceAddress must be '0' or ERC721 contract address"
        );
        require( //DPS:TEST NEW
            (node_info.managementType < 6),
            "ANC:IA: Contract does not support management types > 5 or node is locked"
        );
        if (    //DPS:TEST NEW
            (node_info.managementType == 1) ||
            (node_info.managementType == 2) ||
            (node_info.managementType == 5)
        ) {
            require(    //DPS:TEST NEW
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "ANC:IA: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (node_info.managementType == 3) {
            require(    //DPS:TEST NEW
                NODE_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "ANC:IA: Cannot create asset - caller address !authorized"
            );
        } else if (node_info.managementType == 4) {
            require(    //DPS:TEST NEW
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "ANC:IA: Caller !trusted ID holder"
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
            //just mint the token, record already exists
            A_TKN.mintAssetToken(_msgSender(), newTokenId, "pruf.io");
        }
        deductServiceCosts(_node, 1);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Unwraps a token, returns original to caller
     * @param _tokenID tokenID of PRUF token being unwrapped
     * burns pruf asset from caller wallet
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
        Node memory node_info =getNodeinfo(rec.node);
        address foreignTokenContract = wrapped[_tokenID].tokenContract;
        uint256 foreignTokenID = wrapped[_tokenID].tokenID;

        require(node_info.custodyType == 5, "W:UW: Asset class.custodyType != 5");
        require(
            (node_info.referenceAddress == foreignTokenContract) ||
                (node_info.referenceAddress == address(0)),
            "W:UW: Asset class extended data must be '0' or ERC721 contract address"
        );
        require(
            rec.assetStatus == 51,
            "W:UW: Asset not in transferrable status"
        );
        //^^^^^^^checks^^^^^^^^^

        A_TKN.trustedAgentBurn(_tokenID);

        foreignTransfer(
            foreignTokenContract,
            address(this),
            _msgSender(),
            foreignTokenID
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev transfer a foreign token
     * @param _tokenContract Address of foreign token contract
     * @param _from origin
     * @param _to destination
     * @param _tokenID Token ID
     */
    function foreignTransfer(
        address _tokenContract,
        address _from,
        address _to,
        uint256 _tokenID
    ) internal {
        IERC721(_tokenContract).transferFrom(_from, _to, _tokenID);
    }

    /**
     * @dev create a Record in Storage @ idxHash (SETTER)
     * @param _idxHash Asset ID
     * @param _rgtHash Hash or user data
     * @param _node Node ID
     * @param _countDownStart Initial counter value
     * Asset token already exists
     * depending on custody type/management type, caller ID token or address myst be authorized
     */
    function createRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) internal override {
        uint256 tokenId = uint256(_idxHash);
        Node memory node_info =getNodeinfo(_node);

        require(
            A_TKN.tokenExists(tokenId) == 0,
            "W:CR: Asset token already exists"
        );
        require(
            (node_info.custodyType == 5),
            "W:CR: Cannot create asset - contract not authorized for asset class custody type"
        );
        require(
            (node_info.managementType < 6),
            "W:CR: Contract does not support management types > 5 or node is locked"
        );
        if (
            (node_info.managementType == 1) ||
            (node_info.managementType == 2) ||
            (node_info.managementType == 5)
        ) {
            require(
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "W:CR: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (node_info.managementType == 3) {
            require(
                NODE_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "W:CR:Cannot create asset - caller address not authorized"
            );
        } else if (node_info.managementType == 4) {
            require(
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "W:CR:Caller does not hold sufficiently trusted ID"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        A_TKN.mintAssetToken(_msgSender(), tokenId, "pruf.io"); //CTS:EXAMINE better URI
        STOR.newRecord(_idxHash, _rgtHash, _node, _countDownStart);
        //^^^^^^^interactions^^^^^^^^^
    }
}
