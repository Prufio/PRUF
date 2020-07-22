/*-----------------------------------------------------------------
 *  TO DO
 Audit this contract!!!!!
 * Fix Escrow contracts
 *-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_basic_067.sol";
import "./Imports/Safemath.sol";

contract PRUF_escrowManager is PRUF_BASIC {
    using SafeMath for uint256;

    // struct escrowData {
    //     uint8 data;
    //     bytes32 controllingContractNameHash;
    //     bytes32 escrowOwnerAddressHash;
    //     uint256 timelock;
    //     bytes32 ex1;
    //     bytes32 ex2;
    //     address addr1;
    //     address addr2;
    // }

    mapping(bytes32 => escrowData) escrows;

    /*
     * Originating Address is escrow contract
     */
    modifier isEscrowContract() {
        require(
            Storage.ContractAuthType(msg.sender) == 3, //caller contract is type3 (escrow) and exists in database
            "PEM:IEC:Calling address is not an authorized escrow contract"
        );
        _;
    }

    function isLostOrStolen(uint16 _assetStatus) private pure returns (uint8) {
        if (
            (_assetStatus != 3) &&
            (_assetStatus != 4) &&
            (_assetStatus != 53) &&
            (_assetStatus != 54)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    function isEscrow(uint16 _assetStatus) private pure returns (uint8) {
        if (
            (_assetStatus != 6) &&
            (_assetStatus != 50) &&
            (_assetStatus != 56) &&
            (_assetStatus != 60)
        ) {
            return 0;
        } else {
            return 170;
        }
    }

    /*
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     */
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        uint8 _data,
        bytes32 _escrowOwnerAddressHash,
        uint256 _timelock,
        bytes32 _ex1,
        bytes32 _ex2,
        address _addr1,
        address _addr2
    ) external nonReentrant isEscrowContract {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo;
        (contractInfo.contractType, contractInfo.nameHash) = Storage
            .ContractInfoHash(msg.sender);
        bytes32 controllingContractNameHash = contractInfo.nameHash;

        require(
            contractInfo.contractType == 3,
            "PEM:SE: Escrow can only be set by an escrow contract"
        );
        require(rec.rightsHolder != 0, "PS:SE:Record does not exist");
        require(
            isEscrow(_newAssetStatus) == 170,
            "PEM:SE: Must set to an escrow status"
        );
        require(
            (isLostOrStolen(rec.assetStatus) == 0) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "PEM:SE: Txd, L/S status cannot be set to escrow."
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "PEM:SE: Asset already in escrow status."
        );
        //^^^^^^^checks^^^^^^^^^

        escrows[_idxHash].data = 0; //initialize escrow data
        escrows[_idxHash].controllingContractNameHash = 0;
        escrows[_idxHash].escrowOwnerAddressHash = 0;
        escrows[_idxHash].timelock = 0;
        escrows[_idxHash].ex1 = 0;
        escrows[_idxHash].ex2 = 0;
        escrows[_idxHash].addr1 = address(0);
        escrows[_idxHash].addr1 = address(0);

        escrows[_idxHash].data = _data;
        escrows[_idxHash]
            .controllingContractNameHash = controllingContractNameHash;
        escrows[_idxHash].escrowOwnerAddressHash = _escrowOwnerAddressHash;
        escrows[_idxHash].timelock = _timelock;
        escrows[_idxHash].ex1 = _ex1;
        escrows[_idxHash].ex2 = _ex2;
        escrows[_idxHash].addr1 = _addr1;
        escrows[_idxHash].addr2 = _addr2;

        //^^^^^^^effects^^^^^^^^^

        Storage.setEscrow(_idxHash, _newAssetStatus, contractInfo.nameHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isEscrowContract
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo;
        (contractInfo.contractType, contractInfo.nameHash) = Storage
            .ContractInfoHash(msg.sender);

        require(rec.rightsHolder != 0, "PEM:EE:Record does not exist");
        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "PEM:EE:Only contract with same name as setter can end escrow"
        );
        require(isEscrow(rec.assetStatus) == 170, "PEM:EE:Asset not in escrow");

        //^^^^^^^checks^^^^^^^^^

        escrows[_idxHash].data = 0;
        escrows[_idxHash].controllingContractNameHash = 0;
        escrows[_idxHash].escrowOwnerAddressHash = 0;
        escrows[_idxHash].timelock = 0;
        escrows[_idxHash].ex1 = 0;
        escrows[_idxHash].addr1 = address(0);
        escrows[_idxHash].addr1 = address(0);
        //^^^^^^^effects^^^^^^^^^

        Storage.endEscrow(_idxHash, contractInfo.nameHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Permissive removal of asset from escrow status after time-out
     */
    function PermissiveEndEscrow(bytes32 _idxHash) external nonReentrant {
        require(escrows[_idxHash].timelock < now, "PEM:PEE:Escrow not expired");
        require( // do not allow escrows with escrow.data > 199 to be ended by this function
            escrows[_idxHash].data < 200,
            "PEM:PEE:Escrow not endable with permissiveEndEscrow"
        );
        //^^^^^^^checks^^^^^^^^^

        escrows[_idxHash].data = 0;
        escrows[_idxHash].controllingContractNameHash = 0;
        escrows[_idxHash].escrowOwnerAddressHash = 0;
        escrows[_idxHash].timelock = 0;
        escrows[_idxHash].ex1 = 0;
        escrows[_idxHash].ex2 = 0;
        escrows[_idxHash].addr1 = address(0);
        escrows[_idxHash].addr1 = address(0);
        //^^^^^^^effects^^^^^^^^^

        Storage.endEscrow(_idxHash, keccak256(abi.encodePacked(msg.sender)));
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev return escrow OwnerHash
     */
    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        view
        returns (bytes32)
    {
        return escrows[_idxHash].escrowOwnerAddressHash;
        //^^^^^^^checks/interactions^^^^^^^^^
    }

    /*
     * @dev return complete escrow data
     */
    function retrieveEscrowData(bytes32 _idxHash)
        external
        view
        returns (
            uint8,
            bytes32,
            bytes32,
            uint256,
            bytes32,
            bytes32,
            address,
            address
        )
    {
        escrowData memory escrow = escrows[_idxHash];
        return (
            escrow.data,
            escrow.controllingContractNameHash,
            escrow.escrowOwnerAddressHash,
            escrow.timelock,
            escrow.ex1,
            escrow.ex2,
            escrow.addr1,
            escrow.addr2
        );
        //^^^^^^^checks/interactions^^^^^^^^^
    }
}
