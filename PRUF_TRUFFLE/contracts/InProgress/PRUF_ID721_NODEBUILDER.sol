/*--------------------------------------------------------PRüF0.8.8
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
 * PRUF UD_NODES
 * Identity provider for minting new nodes using posession of corresponding 721 token for verification.
 *
 * !!!! CONTRACT MUST BE GIVEN ID_PROVIDER_ROLE IN NODE_MGR !!!!
 *
 *
 * STATEMENT OF TERMS OF SERVICE (TOS):
 * User agrees not to intentionally claim any namespace that is a recognized or registered brand name, trade mark,
 * or other Intellectual property not belonging to the user, and agrees to voluntarily remove any name or brand found to be
 * infringing from any record that the user controls, within 30 days of notification. If notification is not possible or
 * there is no response to notification, the user agrees that the name record may be changed without their permission or cooperation.
 * Use of this software constitutes consent to the terms above.
 -----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_BASIC.sol";
//import "../Imports/token/ERC721/IERC721.sol";
import "../Imports/security/ReentrancyGuard.sol";

contract ID_721 is BASIC {
    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");

    constructor() {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
    }

    //address internal TOKEN_Address;
    IERC721 internal UD_TOKEN_CONTRACT;

    //--------------------------------------------Modifiers--------------------------

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has NODE_MINTER_ROLE
     */
    modifier isNodeMinter() {
        require(
            hasRole(NODE_MINTER_ROLE, _msgSender()),
            "NB:MOD-INM: Must have NODE_MINTER_ROLE"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * @param _tokenId tokenID of token
     * Originating Address:
     *    require that user holds token @ ID-Contract
     */
    modifier isTokenHolder(uint256 _tokenId) {
        require(
            (UD_TOKEN_CONTRACT.ownerOf(_tokenId) == _msgSender()),
            "NB:MOD-ITH: Caller does not hold specified token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Set address of STOR contract to interface with
     * @param _erc721Address address of token contract to interface with
     */
    function setTokenContract(address _erc721Address)
        external
        virtual
        isContractAdmin
    {
        require(_erc721Address != address(0), "B:SSC: Address = 0");
        //^^^^^^^checks^^^^^^^^^

        UD_TOKEN_CONTRACT = IERC721(_erc721Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Burns (amount) tokens and mints a new Node token to the calling address
     * @param _name - chosen name of node
     * @param _nodeRoot - chosen root of node
     * @param _custodyType - chosen custodyType of node (see docs)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     * @param _TokenIdToVerify - Token ID of token being used to verify that calling adress holds the xyz.tld domain
     */
    function purchaseNode(
        string calldata _name,
        uint32 _nodeRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2,
        uint256 _TokenIdToVerify  // NEEDS TO BE IMPLEMENTED
    ) external nonReentrant isNodeMinter returns (uint256) {
        //^^^^^^^checks^^^^^^^^^

        uint256 mintedNode = NODE_MGR.purchaseNode(
            _name,
            _nodeRoot,
            _custodyType,
            _CAS1,
            _CAS2,
            _msgSender()
        );

        return mintedNode;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev reverts if caller does not hold referenced token or if token does not represent the supplied domain
     * where '_name' is xyz.tld
     * @param _name - chosen name for node (will be the same as xyz.tld)
     * @param _udTokenIdToVerify - Token ID of token being used to verify that calling adress holds the xyz.tld domain
     */
    function domainMatchesNode(
        string calldata _name,
        uint256 _udTokenIdToVerify
    ) internal nonReentrant isTokenHolder(_udTokenIdToVerify) {
        require(
            _childId(_udTokenIdToVerify, _name) == // your child ID generator
                uint256(
                    keccak256(
                        abi.encodePacked(
                            UD_TOKEN_CONTRACT.tokenURI(_udTokenIdToVerify)
                        )
                    )
                ), //obviously this wont work but you get the idea
            "Supplied node name does not match tokenURI of reference token"
        );
        //^^^^^^^checks^^^^^^^^^

        //^^^^^^^interactions^^^^^^^^^
    }

    //     /** /** LEAVE AS BOILERPLATE
    //      * @dev transfer a foreign token
    //      * @param _tokenContract Address of foreign token contract
    //      * @param _from origin
    //      * @param _to destination
    //      * @param _tokenId Token ID
    //      */
    //     function foreignTransfer(
    //         address _tokenContract,
    //         address _from,
    //         address _to,
    //         uint256 _tokenId
    //     ) internal {
    //         IERC721(_tokenContract).transferFrom(_from, _to, _tokenId);
    //         //^^^^^^^interactions^^^^^^^^^
    //     }

    function _childId(uint256 tokenId, string memory label)
        internal
        pure
        returns (uint256)
    {
        require(bytes(label).length != 0, "Registry: LABEL_EMPTY");
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        tokenId,
                        keccak256(abi.encodePacked(label))
                    )
                )
            );
    }
}
// Their stuff
// contract C {
//     UNS internal _uns;
//     mapping (uint256 => bool) internal _tlds;

//     function isValidTldHash(uint256 tldHash) pure returns (bool) {
//         return _tlds[tldHash];
//     }

//     function isValid(uint256 tokenId, uint256 tldHash, string calldata label) pure returns (bool) {
//         return isValidTldHash(tldHash) && tokenId == uns.childIdOf(tldHash, label);
//     }
//}