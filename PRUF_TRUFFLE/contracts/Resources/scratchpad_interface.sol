// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;
import "./RESOURCE_PRUF_STRUCTS.sol";

interface STOR_Interface {
    //--------------------------------Public Functions---------------------------------//

    /**
     * @dev Authorize / Deauthorize contract NAMES permitted to make record modifications, per node
     * allows ACtokenHolder to Authorize / Deauthorize specific contracts to work within their node
     * @param   _name -  Name of contract being authed
     * @param   _node - affected node
     * @param   _contractAuthLevel - auth level to set for thae contract, in that node
     */
    function enableContractForNode(
        string memory _name,
        uint32 _node,
        uint8 _contractAuthLevel
    ) external;

    //--------------------------------External Functions---------------------------------//

    /**
     * @dev Triggers stopped state. (pausable)
     */
    function pause() external;

    /**
     * @dev Returns to normal state. (pausable)
     */
    function unpause() external;

    /**
     * @dev Authorize / Deauthorize ADRESSES permitted to make record modifications, per node
     * populates contract name resolution and data mappings
     * @param _contractName - String name of contract
     * @param _contractAddr - address of contract
     * @param _node - node to authorize in
     * @param _contractAuthLevel - auth level to assign
     */
    function OO_addContract(
        string calldata _contractName,
        address _contractAddr,
        uint32 _node,
        uint8 _contractAuthLevel
    ) external;

    /**
     * @dev set the default list of 11 contracts (zero index) to be applied to Noees
     * @param _contractNumber - 0-10
     * @param _name - name
     * @param _contractAuthLevel - authLevel
     */
    function addDefaultContracts(
        uint256 _contractNumber,
        string calldata _name,
        uint8 _contractAuthLevel
    ) external;

    /**
     * @dev retrieve a record from the default list of 11 contracts to be applied to Nodees
     * @param _contractNumber to look up (0-10)
     * @return the name and auth level of indexed contract
     */
    function getDefaultContract(uint256 _contractNumber)
        external
        returns (DefaultContract memory);

    /**
     * @dev Set the default 11 authorized contracts
     * @param _node the Node which will be enabled for the default contracts
     */
    function enableDefaultContractsForNode(uint32 _node) external;

    /**
     * @dev Make a new record, writing to the 'database' mapping with basic initial asset data
     * calling contract must be authorized in relevant node
     * @param   _idxHash - asset ID
     * @param   _rgtHash - rightsholder id hash
     * @param   _node - node in which to create the asset
     * @param   _countDownStart - initial value for decrement-only value
     */
    function newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node,
        uint32 _countDownStart
    ) external;

    /**
     * @dev Modify a record, writing to the 'database' mapping with updates to multiple fields
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * @param _newAssetStatus - New Status to set
     * @param _countDown - New countdown value (must be <= old value)
     * @param _int32temp - temp value
     * @param _incrementModCount - 0 = no 170 = yes
     * @param _incrementNumberOfTransfers - 0 = no 170 = yes
     */
    function modifyRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus,
        uint32 _countDown,
        uint32 _int32temp,
        uint256 _incrementModCount,
        uint256 _incrementNumberOfTransfers
    ) external;

    /**
     * @dev Change node of an asset - writes to node in the 'Record' struct of the 'database' at _idxHash
     * @param _idxHash - record asset ID
     * @param _newNode - Aseet Class to change to
     */
    function changeNode(bytes32 _idxHash, uint32 _newNode) external;

    /**
     * @dev Set an asset to Lost Or Stolen. Allows narrow modification of status 6/12 assets, normally locked
     * @param _idxHash - record asset ID
     * @param _newAssetStatus - Status to change to
     */
    function setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /**
     * @dev Set an asset to escrow locked status (6/50/56).
     * @param _idxHash - record asset ID
     * @param _newAssetStatus - New Status to set
     */
    function setEscrow(bytes32 _idxHash, uint8 _newAssetStatus) external;

    /**
     * @dev remove an asset from escrow status. Implicitly trusts escrowManager ECR_MGR contract
     * @param _idxHash - record asset ID
     */
    function endEscrow(bytes32 _idxHash) external;

    /**
     * @dev Modify record MutableStorage data
     * @param  _idxHash - record asset ID
     * @param  _mutableStorage1 - first half of content adressable storage location
     * @param  _mutableStorage2 - second half of content adressable storage location
     */
    function modifyMutableStorage(
        bytes32 _idxHash,
        bytes32 _mutableStorage1,
        bytes32 _mutableStorage2
    ) external;

    /**
     * @dev Modify NonMutableStorage data
     * @param _idxHash - record asset ID
     * @param _nonMutableStorage1 - first half of content adressable storage location
     * @param _nonMutableStorage2 - second half of content adressable storage location
     */
    function modifyNonMutableStorage(
        bytes32 _idxHash,
        bytes32 _nonMutableStorage1,
        bytes32 _nonMutableStorage2
    ) external;

    /**
     * @dev return a record from the database
     * @param  _idxHash - record asset ID
     * returns a complete Record struct (see interfaces for struct definitions)
     */
    function retrieveRecord(bytes32 _idxHash) external returns (Record memory);

    /**
     * @dev return a record from the database w/o rgt
     * @param _idxHash - record asset ID
     * @return rec.assetStatus,
                rec.modCount,
                rec.node,
                rec.countDown,
                rec.countDownStart,
                rec.mutableStorage1,
                rec.mutableStorage2,
                rec.nonMutableStorage1,
                rec.nonMutableStorage2,
     */
    function retrieveShortRecord(bytes32 _idxHash)
        external
        returns (
            uint8,
            uint8,
            uint32,
            uint32,
            uint32,
            bytes32,
            bytes32,
            bytes32,
            bytes32,
            uint16
        );

    /**
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * @return 170 if matches, 0 if not
     */
    function _verifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint256);

    /**
     * @dev Compare record.rightsholder with supplied bytes32 rightsholder (writes an emit in blockchain for independant verification)
     * @param _idxHash - record asset ID
     * @param _rgtHash - record owner ID hash
     * @return 170 if matches, 0 if not
     */
    function blockchainVerifyRightsHolder(bytes32 _idxHash, bytes32 _rgtHash)
        external
        returns (uint256);

    /**
     * @dev returns the address of a contract with name _name. This is for web3 implementations to find the right contract to interact with
     * example :  Frontend = ****** so web 3 first asks storage where to find frontend, then calls for frontend functions.
     * @param _name - contract name
     * @return contract address
     */
    function resolveContractAddress(string calldata _name)
        external
        returns (address);

    /**
     * @dev returns the contract type of a contract with address _addr.
     * @param _addr - contract address
     * @param _node - node to look up contract type-in-class
     * @return contractType of given contract
     */
    function ContractInfoHash(address _addr, uint32 _node)
        external
        returns (uint8, bytes32);
}
