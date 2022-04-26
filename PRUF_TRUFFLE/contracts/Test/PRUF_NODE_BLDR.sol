/*--------------------------------------------------------PRüF0.9.0
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
pragma solidity 0.8.7;

import "../Resources/PRUF_BASIC.sol";
import "../Imports/security/ReentrancyGuard.sol";

contract UD_721 is BASIC {
    bytes32 public constant NODE_MINTER_ROLE = keccak256("NODE_MINTER_ROLE");
    bytes32 private constant B320X =
        0x0000000000000000000000000000000000000000000000000000000000000000;

    constructor() {
        _setupRole(NODE_MINTER_ROLE, _msgSender());
    }

    //address internal TOKEN_Address;
    IERC721 internal UD_TOKEN_CONTRACT;
    address public UD_token_address;

    //--------------------------------------------Modifiers--------------------------

    /**
     * @dev Verify caller holds Nodetoken of passed node and holds verifying token if applicable (bit6=1)
     * @param _node - node for which caller is queried for ownership
     */
    modifier isNodeHolderAndHasIdRootToken(uint32 _node) {
        require(
            (NODE_TKN.ownerOf(_node) == _msgSender()),
            "NM:MOD-INHAHIRT: _msgSender() does not hold node token"
        );
        Node memory nodeInfo = getNodeinfo(_node);
        ExtendedNodeData memory extendedNodeInfo = NODE_STOR
            .getExtendedNodeData(_node);

        require(
            (NODE_TKN.ownerOf(_node) ==
                IERC721(extendedNodeInfo.idProviderAddr).ownerOf(
                    extendedNodeInfo.idProviderTokenId
                )), // if switch6 = 1 verify that IDroot token and Node token are held in the same address
            "NM:MOD-INHAHIRT: Node and root of identity are separated. Function is disabled"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev Set address of STOR contract to interface with
     * @param _erc721Address address of token contract to interface with
     */
    function setUnstoppableDomainsTokenContract(address _erc721Address)
        external
        virtual
        isContractAdmin
    {
        require(_erc721Address != address(0), "B:SSC: Address = 0");
        //^^^^^^^checks^^^^^^^^^
        UD_token_address = _erc721Address;
        UD_TOKEN_CONTRACT = IERC721(_erc721Address);
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Burns (amount) tokens and mints a new Node token to the calling address
     * @param _domain - chosen domain of node
     * @param _tld - chosen tld of node
     * @param _nodeRoot - chosen root of node
     * @param _custodyType - chosen custodyType of node (see docs)
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function purchaseNode(
        string calldata _domain,
        string calldata _tld,
        uint32 _nodeRoot,
        uint8 _custodyType,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external nonReentrant whenNotPaused returns (uint256) {
        uint256 tokenId = getTokenIdFromDomain(_domain, _tld);

        require( //throws if caller does not hod the appropriate UD token
            UD_TOKEN_CONTRACT.ownerOf(tokenId) == _msgSender(),
            "UDNB:PN:Supplied node name does not match tokenID held by caller"
        );
        //^^^^^^^checks^^^^^^^^^

        string memory nodeName = string(abi.encodePacked(_domain, ".", _tld));

        uint32 mintedNode = NODE_MGR.purchaseNode( 
            nodeName,
            _nodeRoot,
            _custodyType,
            _CAS1,
            _CAS2,
            _msgSender()
        );

        // write UD contract, tokenId of UD domain token to node extended data
        NODE_MGR.setExternalIdToken(
            mintedNode, 
            UD_token_address,
            tokenId
        );

        return mintedNode;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Authorize / Deauthorize users for an address be permitted to make record modifications
     * @dev only useful for custody types that designate user adresses (type1...)
     * @param _node - node that user is being authorized in
     * @param _addrHash - hash of address belonging to user being authorized
     * @param _userType - authority level for user (see docs)
     */
    function addUser(
        uint32 _node,
        bytes32 _addrHash,
        uint8 _userType
    ) external whenNotPaused isNodeHolderAndHasIdRootToken(_node) {
        //^^^^^^^checks^^^^^^^^^

        NODE_MGR.addUser(_node, _addrHash, _userType);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set import status for foreign nodes
     * @param _thisNode - node to dis/allow importing into
     * @param _otherNode - node to be imported
     * @param _newStatus - importability status (0=not importable, 1=importable >1 =????)
     */
    function updateImportStatus(
        uint32 _thisNode,
        uint32 _otherNode,
        uint256 _newStatus
    ) external whenNotPaused isNodeHolderAndHasIdRootToken(_thisNode) {
        NODE_STOR.updateImportStatus(_thisNode, _otherNode, _newStatus);
    }

    /**
     * @dev Modifies an node Node content adressable storage data pointer
     * @param _node - node being modified
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function updateNodeCAS(
        uint32 _node,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external whenNotPaused isNodeHolderAndHasIdRootToken(_node) {
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.updateNodeCAS(_node, _CAS1, _CAS2);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set function costs and payment address per Node, in PRUF(18 decimals)
     * @param _node - node to set service costs
     * @param _service - service type being modified (see service types in ZZ_PRUF_DOCS)
     * @param _serviceCost - 18 decimal fee in PRUF associated with specified service
     * @param _paymentAddress - address to have _serviceCost paid to
     */
    function setOperationCosts(
        uint32 _node,
        uint16 _service,
        uint256 _serviceCost,
        address _paymentAddress
    ) external whenNotPaused isNodeHolderAndHasIdRootToken(_node) {
        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.setOperationCosts(
            _node,
            _service,
            _serviceCost,
            _paymentAddress
        );
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Configure the immutable data in an Node one time
     * @param _node - node being modified
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _refAddress - address permanently tied to node
     */
    function setNonMutableData(
        uint32 _node,
        uint8 _managementType,
        uint8 _storageProvider,
        address _refAddress,
        uint8 _switches
    ) external whenNotPaused isNodeHolderAndHasIdRootToken(_node) {
        NODE_STOR.setNonMutableData(
            _node,
            _managementType,
            _storageProvider,
            _refAddress,
            _switches
        );
    }

    /**
     * @dev extended node data setter
     * @param _node - node being configured
     * @param _u8a ExtendedNodeData
     * @param _u8b ExtendedNodeData
     * @param _u16c ExtendedNodeData
     * @param _u32d ExtendedNodeData
     * @param _u32e ExtendedNodeData
     */
    function setExtendedNodeData(
        uint32 _node,
        uint8 _u8a,
        uint8 _u8b,
        uint16 _u16c,
        uint32 _u32d,
        uint32 _u32e
    ) external whenNotPaused isNodeHolderAndHasIdRootToken(_node) {
        NODE_STOR.setExtendedNodeData(_node, _u8a, _u8b, _u16c, _u32d, _u32e);
    }

    function getTokenIdFromDomain(string memory _domain, string memory _tld)
        public
        pure
        returns (uint256)
    {
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
        }
        return uint256(namehash);
    }
}
