/*--------------------------------------------------------PRüF0.8.6
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
*  TO DO
*
* IMPORTANT!!! EXTERNAL OR PUBLIC FUNCTIONS WITHOUTSTRICT PERMISSIONING NEED 
* TO BE CLOSELY EXAMINED IN THIS CONTRACT AS THEY WILL BE INHERITED NEARLY GLOBALLY
*-----------------------------------------------------------------
*-----------------------------------------------------------------
*PRUF basic provides core data structures and functionality to PRUF contracts.
*Features include contract name resolution, and getters for records, users, and node information.
*---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_INTERFACES.sol";
import "./Imports/access/AccessControl.sol";
import "./Imports/utils/Pausable.sol";
import "./Imports/utils/ReentrancyGuard.sol";
import "./Imports/token/ERC721/IERC721Receiver.sol";

abstract contract BASIC is
    ReentrancyGuard,
    AccessControl,
    IERC721Receiver,
    Pausable
{
    bytes32 public constant CONTRACT_ADMIN_ROLE =
        keccak256("CONTRACT_ADMIN_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");
    bytes32 public constant ASSET_TXFR_ROLE = keccak256("ASSET_TXFR_ROLE");

    address internal STOR_Address;
    STOR_Interface internal STOR;

    address internal NODE_MGR_Address;
    NODE_MGR_Interface internal NODE_MGR;

    address internal UTIL_TKN_Address;
    UTIL_TKN_Interface internal UTIL_TKN;

    address internal A_TKN_Address;
    A_TKN_Interface internal A_TKN;

    address internal NODE_TKN_Address;
    NODE_TKN_Interface internal NODE_TKN;

    address internal ID_TKN_Address;
    ID_TKN_Interface internal ID_TKN;

    address internal ECR_MGR_Address;
    ECR_MGR_Interface internal ECR_MGR;

    address internal RCLR_Address;
    RCLR_Interface internal RCLR;

    address internal APP_Address;
    APP_Interface internal APP;

    address internal APP_NC_Address;
    APP_NC_Interface internal APP_NC;

    address internal NAKED_Address;
    address internal NP_Address;

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    // --------------------------------------REPORTING--------------------------------------------//

    event REPORT(string _msg);

    // --------------------------------------Modifiers--------------------------------------------//
    /**
     * @dev Verify user credentials
     * modifier should always be overridden!!! will always throw.
     * @param _idxHash - asset index hash
     */
    modifier isAuthorized(bytes32 _idxHash) virtual {
        require(
            _idxHash == 0,
            "B:MOD-IAUTH: Modifier must be overridden"
        );
        _;
    }

    /**
     * @dev Verify user credentials
     * Originating Address:
     *      has CONTRACT_ADMIN_ROLE
     */
    modifier isContractAdmin() {
        require(
            hasRole(CONTRACT_ADMIN_ROLE, _msgSender()),
            "B:MOD:-IADM Caller !CONTRACT_ADMIN_ROLE"
        );
        _;
    }

    modifier isPauser() {
        require(
            hasRole(PAUSER_ROLE, _msgSender()),
            "B:MOD-IP:Calling address is not pauser"
        );
        _;
    }

    //----------------------External Admin functions / isContractAdmin----------------------//
    /**
     * @dev Resolve Contract Addresses from STOR 
     */
    function Admin_resolveContractAddresses()
        external
        virtual
        nonReentrant
        isContractAdmin 
    {
        //^^^^^^^checks^^^^^^^^^
        NODE_TKN_Address = STOR.resolveContractAddress("NODE_TKN");
        NODE_TKN = NODE_TKN_Interface(NODE_TKN_Address);

        NODE_MGR_Address = STOR.resolveContractAddress("NODE_MGR");
        NODE_MGR = NODE_MGR_Interface(NODE_MGR_Address);

        UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        A_TKN_Address = STOR.resolveContractAddress("A_TKN");
        A_TKN = A_TKN_Interface(A_TKN_Address);

        ID_TKN_Address = STOR.resolveContractAddress("ID_TKN");
        ID_TKN = ID_TKN_Interface(ID_TKN_Address);

        ECR_MGR_Address = STOR.resolveContractAddress("ECR_MGR");
        ECR_MGR = ECR_MGR_Interface(ECR_MGR_Address);

        APP_Address = STOR.resolveContractAddress("APP");
        APP = APP_Interface(APP_Address);

        RCLR_Address = STOR.resolveContractAddress("RCLR");
        RCLR = RCLR_Interface(RCLR_Address);

        APP_NC_Address = STOR.resolveContractAddress("APP_NC");
        NP_Address = STOR.resolveContractAddress("NP");

        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Transfer any specified assetToken from contract
     * @param _to - address to send to
     * @param _idxHash - asset index
     */
    function transferAssetToken(address _to, bytes32 _idxHash)
        external
        virtual
        nonReentrant
    {
        require( 
            hasRole(ASSET_TXFR_ROLE, _msgSender()),
            "B:TX:Must have ASSET_TXFR_ROLE"
        );
        //^^^^^^^checks^^^^^^^^^

        uint256 tokenId = uint256(_idxHash);

        A_TKN.safeTransferFrom(address(this), _to, tokenId);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Transfer any specified assetClassToken from contract
     * @param _to - address to send to
     * @param _tokenID - node token ID
     */
    function Admin_transferACToken(address _to, uint256 _tokenID)
        external
        virtual
        isContractAdmin 
        nonReentrant
    {
        //^^^^^^^checks^^^^^^^^^
        NODE_TKN.safeTransferFrom(address(this), _to, _tokenID);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set address of STOR contract to interface with 
     * @param _storageAddress address of PRUF_STOR
     */
    function Admin_setStorageContract(address _storageAddress)
        external
        virtual
        isContractAdmin 
    {
        require(_storageAddress != address(0), "B:SSC: Address = 0");
        //^^^^^^^checks^^^^^^^^^

        STOR = STOR_Interface(_storageAddress);
        //^^^^^^^effects^^^^^^^^^
    }

    //--------------------------------------External functions--------------------------------------------//
    /**
     * @dev Compliance for erc721 reciever
     * See OZ documentation 
     */
    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external virtual override returns (bytes4) {
        //^^^^^^^checks^^^^^^^^^
        return this.onERC721Received.selector;
        //^^^^^^^interactions^^^^^^^^^
    }

    /***
     * @dev Triggers stopped state. (pausable)
     *
     */
    function pause() external isPauser {
        _pause();
    }

    /***
     * @dev Returns to normal state. (pausable)
     */

    function unpause() external isPauser {
        _unpause();
    }

    //--------------------------------------------------------------------------------------INTERNAL functions

    /**
     * @dev Get a User type Record from AC_manager for _msgSender(), by node
     * @param _node - to check user type in
     * @return user authorization type of caller, from NODE_MGR user mapping
     */
    function getCallingUserType(uint32 _node)
        internal
        virtual
        returns (uint8)
    {
        //^^^^^^^checks^^^^^^^^^

        uint8 userTypeInNode =
            NODE_MGR.getUserType(
                keccak256(abi.encodePacked(_msgSender())),
                _node
            );

        return userTypeInNode;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Get node information from AC_manager and return an node Struct
     * @param _node - to retrireve info about
     * @return entire node struct (see interfaces for struct definitions)
     */
    function getNodeinfo(uint32 _node)
        internal
        virtual
        returns (Node memory)
    {
        //^^^^^^^checks^^^^^^^^^

        // Node memory node_info;
        // //^^^^^^^effects^^^^^^^^^

        // (
        //     node_info.nodeRoot,
        //     node_info.custodyType,
        //     node_info.managementType,
        //     node_info.discount,
        //     node_info.referenceAddress
        // ) = NODE_MGR.getAC_data(_node);

        // return node_info;
        return NODE_MGR.getExtAC_data(_node);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Get contract information from STOR and return a ContractDataHash Struct
     * @param _addr address of contract to check
     * @param _node node to check 
     * @return ContractDataHash struct, containing the authorization level and hashed name of a given contract X in node Y
     */
    function getContractInfo(address _addr, uint32 _node)
        internal
        view
        returns (ContractDataHash memory)
    {
        //^^^^^^^checks^^^^^^^^^

        ContractDataHash memory contractInfo;
        (contractInfo.contractType, contractInfo.nameHash) = STOR
            .ContractInfoHash(_addr, _node);
        return contractInfo;
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Get a Record from Storage @ idxHash and return a Record Struct
    function getRecord(bytes32 _idxHash) internal returns (Record memory) {
     * @param _idxHash - asset index
     * @return entire record struct form PRUF_STOR (see interfaces for struct definitions)
     */
    function getRecord(bytes32 _idxHash) internal returns (Record memory) {
        //^^^^^^^checks^^^^^^^^^

        Record memory rec = STOR.retrieveRecord(_idxHash);

        return rec; // Returns Record struct rec
        //^^^^^^^effects/interactions^^^^^^^^^
    }
}
