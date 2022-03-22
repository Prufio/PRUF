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

/**-----------------------------------------------------------------
 * DAO Specification V0.01
 * DAO THUNK LAYER - (ONE OF MANY)
 * //DPS:TEST MAJOR REVISIONS - added calls to DAO
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Resources/RESOURCE_PRUF_EXT_INTERFACES.sol";
import "../Resources/RESOURCE_PRUF_DAO_INTERFACES.sol";

contract DAO_LAYER_A is BASIC {
    address internal DAO_STOR_Address;
    DAO_STOR_Interface internal DAO_STOR;

    address internal CLOCK_Address;
    CLOCK_Interface internal CLOCK;

    /**
     * @dev Resolve contract addresses from STOR
     */
    function resolveContractAddresses()
        external
        override
        nonReentrant
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^

        NODE_TKN_Address = STOR.resolveContractAddress("NODE_TKN");
        NODE_TKN = NODE_TKN_Interface(NODE_TKN_Address);

        NODE_MGR_Address = STOR.resolveContractAddress("NODE_MGR");
        NODE_MGR = NODE_MGR_Interface(NODE_MGR_Address);

        NODE_STOR_Address = STOR.resolveContractAddress("NODE_STOR");
        NODE_STOR = NODE_STOR_Interface(NODE_STOR_Address);

        // UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        // UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        A_TKN_Address = STOR.resolveContractAddress("A_TKN");
        A_TKN = A_TKN_Interface(A_TKN_Address);

        // ECR_MGR_Address = STOR.resolveContractAddress("ECR_MGR");
        // ECR_MGR = ECR_MGR_Interface(ECR_MGR_Address);

        // APP_Address = STOR.resolveContractAddress("APP");
        // APP = APP_Interface(APP_Address);

        // RCLR_Address = STOR.resolveContractAddress("RCLR");
        // RCLR = RCLR_Interface(RCLR_Address);

        // APP_NC_Address = STOR.resolveContractAddress("APP_NC");
        // APP_NC = APP_NC_Interface(APP_NC_Address);

        DAO_STOR_Address = STOR.resolveContractAddress("DAO_STOR");
        DAO_STOR = DAO_STOR_Interface(DAO_STOR_Address);

        CLOCK_Address = STOR.resolveContractAddress("CLOCK");
        CLOCK = CLOCK_Interface(CLOCK_Address);
    }

    //---------------------------------NODE_TKN

    /**
     * @dev Set storage contract to interface with
     * @param _nodeStorageAddress - Node storage contract address
     */
    function DAO_setNodeStorageContract(address _nodeStorageAddress)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_setNodeStorageContract",
                address(this),
                _nodeStorageAddress
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_TKN.setNodeStorageContract(_nodeStorageAddress);
        //^^^^^^^Interactions^^^^^^^^^
    }

    //-------------------------A_TKN
    /**
     * @dev Sets the baseURI for a storage provider.
     * @param _storageProvider - storage provider number
     * @param _URI - baseURI to add
     */
    function DAO_setBaseURIforStorageType(
        uint8 _storageProvider,
        string calldata _URI
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_setBaseURIforStorageType",
                address(this),
                _storageProvider,
                _URI
            )
        );

        //^^^^^^^checks^^^^^^^^^

        A_TKN.setBaseURIforStorageType(_storageProvider, _URI);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev !!! PERMANENTLY !!!  Kills trusted agent and payable functions
     * this will break the functionality of current payment mechanisms.
     *
     * The workaround for this is to create an allowance for pruf contracts for a single or multiple payments,
     * either ahead of time "loading up your PRUF account" or on demand with an operation. On demand will use quite a bit more gas.
     * "preloading" should be pretty gas efficient, but will add an extra step to the workflow, requiring users to have sufficient
     * PRuF "banked" in an allowance for use in the system.
     * @param _key - set to 170 to PERMENANTLY REMOVE TRUSTED AGENT CAPABILITY
     */
    function DAO_A_TKN_killTrustedAgent(uint256 _key) external nonReentrant {
        verifySig(
            abi.encodePacked("DAO_A_TKN_killTrustedAgent", address(this), _key)
        );

        //^^^^^^^checks^^^^^^^^^

        A_TKN.killTrustedAgent(_key);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------NODE_MGR--------------------------

    /**
     * @dev Set pricing for Nodes
     * @param _newNodePrice - cost per node (18 decimals)
     * @param _newNodeBurn - burn per node (18 decimals)
     */
    function DAO_setNodePricing(uint256 _newNodePrice, uint256 _newNodeBurn)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_setNodePricing",
                address(this),
                _newNodePrice,
                _newNodeBurn
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_MGR.setNodePricing(_newNodePrice, _newNodeBurn);
        //^^^^^^^interactions^^^^^^^^^
    }

    //--------------------------------------------NODE_STOR--------------------------

    /**
     * @dev Sets the valid storage type providers.
     * @param _storageProvider - uint position for storage provider
     * @param _status - uint position for custody type status
     */
    function DAO_setStorageProviders(uint8 _storageProvider, uint8 _status)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_setStorageProviders",
                address(this),
                _storageProvider,
                _status
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.setStorageProviders(_storageProvider, _status);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Sets the valid management types.
     * @param _managementType - uint position for management type
     * @param _status - uint position for custody type status
     */
    function DAO_setManagementTypes(uint8 _managementType, uint8 _status)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_setManagementTypes",
                address(this),
                _managementType,
                _status
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.setManagementTypes(_managementType, _status);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Sets the valid custody types.
     * @param _custodyType - uint position for custody type
     * @param _status - uint position for custody type status
     */
    function DAO_setCustodyTypes(uint8 _custodyType, uint8 _status)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_setCustodyTypes",
                address(this),
                _custodyType,
                _status
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.setCustodyTypes(_custodyType, _status);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * !! to be used with great caution !!
     * This potentially breaks decentralization and must eventually be given over to DAO.
     * @dev Increases (but cannot decrease) price share for a given node
     * @param _node - node in which cost share is being modified
     * @param _newDiscount - discount(1% == 100, 10000 == max)
     */
    function DAO_changeShare(uint32 _node, uint32 _newDiscount)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked(
                "DAO_changeShare",
                address(this),
                _node,
                _newDiscount
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.changeShare(_node, _newDiscount);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution and only as a result of community governance action -----------
     * @dev Transfers a name from one node to another
     *   -Designed to remedy brand infringement issues. This breaks decentralization and must eventually be given
     *   -over to DAO.
     * @param _fromNode - source node
     * @param _toNode - destination node
     * @param _thisName - name to be transferred
     */
    function DAO_transferName(
        uint32 _fromNode,
        uint32 _toNode,
        string calldata _thisName
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_transferName",
                address(this),
                _fromNode,
                _toNode,
                _thisName
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.transferName(_fromNode, _toNode, _thisName);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * !! -------- to be used with great caution -----------
     * @dev Modifies an Node with minimal controls
     * @param _node - node to be modified
     * @param _nodeRoot - root of node
     * @param _custodyType - custodyType of node (see docs)
     * @param _managementType - managementType of node (see docs)
     * @param _storageProvider - storageProvider of node (see docs)
     * @param _discount - discount of node (100 == 1%, 10000 == max)
     * @param _refAddress - referance address associated with an node
     * @param _CAS1 - any external data attatched to node 1/2
     * @param _CAS2 - any external data attatched to node 2/2
     */
    function DAO_modifyNode(
        uint32 _node,
        uint32 _nodeRoot,
        uint8 _custodyType,
        uint8 _managementType,
        uint8 _storageProvider,
        uint32 _discount,
        address _refAddress,
        bytes32 _CAS1,
        bytes32 _CAS2
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_modifyNode",
                address(this),
                _node,
                _nodeRoot,
                _custodyType,
                _managementType,
                _storageProvider,
                _discount,
                _refAddress,
                _CAS1,
                _CAS2
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.modifyNode(
            _node,
            _nodeRoot,
            _custodyType,
            _managementType,
            _storageProvider,
            _discount,
            _refAddress,
            _CAS1,
            _CAS2
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Administratively Deauthorize address be permitted to mint or modify records
     * @dev only useful for custody types that designate user adresses (type1...)
     * @param _node - node that user is being deauthorized in
     * @param _addrHash - hash of address to deauthorize
     */
    function DAO_blockUser(uint32 _node, bytes32 _addrHash)
        external
        nonReentrant
    {
        verifySig(
            abi.encodePacked("DAO_blockUser", address(this), _node, _addrHash)
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.blockUser(_node, _addrHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev DAO set an external erc721 token as ID verification (when bit 6 set to 1)
     * @param _node - node being configured
     * @param _tokenContractAddress  token contract used to verify id
     * @param _tokenId token ID used to verify id
     */
    function DAO_setExternalId(
        uint32 _node,
        address _tokenContractAddress,
        uint256 _tokenId
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_setExternalId",
                address(this),
                _node,
                _tokenContractAddress,
                _tokenId
            )
        );

        //^^^^^^^checks^^^^^^^^^

        NODE_STOR.daoSetExternalId(_node, _tokenContractAddress, _tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------STOR

    /**
     * @dev Authorize / Deauthorize ADRESSES permitted to make record modifications, per node
     * populates contract name resolution and data mappings
     * @param _contractName - String name of contract
     * @param _contractAddr - address of contract
     * @param _node - node to authorize in
     * @param _contractAuthLevel - auth level to assign
     */
    function DAO_authorizeContract(
        string calldata _contractName,
        address _contractAddr,
        uint32 _node,
        uint8 _contractAuthLevel
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_authorizeContract",
                address(this),
                _contractName,
                _contractAddr,
                _node,
                _contractAuthLevel
            )
        );

        //^^^^^^^checks^^^^^^^^^

        STOR.authorizeContract(
            _contractName,
            _contractAddr,
            _node,
            _contractAuthLevel
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev set the default list of 11 contracts (zero index) to be applied to Noees
     * @param _contractNumber - 0-10
     * @param _name - name
     * @param _contractAuthLevel - authLevel
     */
    function DAO_addDefaultContracts(
        uint256 _contractNumber,
        string calldata _name,
        uint8 _contractAuthLevel
    ) external nonReentrant {
        verifySig(
            abi.encodePacked(
                "DAO_addDefaultContracts",
                address(this),
                _contractNumber,
                _name,
                _contractAuthLevel
            )
        );
        //^^^^^^^checks^^^^^^^^^

        STOR.addDefaultContracts(_contractNumber, _name, _contractAuthLevel);
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------INTERNAL FUNCTIONS

    /**
     * @dev Makes signature hash and verifies against DAO_STOR
     * @param _sigArray signature of call to approve
     */
    function verifySig(bytes memory _sigArray) internal {
        DAO_STOR.verifyResolution(
            keccak256(
                abi.encodePacked(keccak256(_sigArray), CLOCK.thisEpoch())
            ),
            _msgSender()
        );
    }

    /**
     * @dev name resolver
     * @param _name name to resolve
     * returns address of (contract name)
     */
    function resolveName(string calldata _name) public view returns (address) {
        return STOR.resolveContractAddress(_name);
        //^^^^^^^interactions^^^^^^^^^
    }
}
