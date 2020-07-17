/*-----------------------------------------------------------------
 *  TO DO
 *
 *-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_basic_066.sol";
import "./Imports/Safemath.sol";

contract PRUF_escrowManager is PRUF_BASIC {
    using SafeMath for uint256;

    struct escrowData {
        uint8 data;
        bytes32 ControllingContractNameHash;
        bytes32 EscrowOwnerAddressHash;
        bytes32 EXT1;
        bytes32 EXT2;
    }

    mapping(bytes32 => bytes32) private escrows;
    mapping(bytes32 => escrowData) Escrows;

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 to 9
     *      Is authorized for asset class
     */
    modifier isEscrowContract() {
        require(
            Storage.ContractAuthType(msg.sender) == 3, //caller contract is type3 (escrow) and exists in database
            "PAT:IA:Calling address is not an authorized escrow contract"
        );
        _;
    }

        function isLostOrStolen (uint16 _assetStatus) private pure returns (uint8){
        if ((_assetStatus != 3) &&
                (_assetStatus != 4) &&
                (_assetStatus != 53) &&
                (_assetStatus != 54)){
                    return 0;
                } else {
                    return 170;
                }
    }

    function isEscrow (uint16 _assetStatus) private pure returns (uint8){
        if ((_assetStatus != 6) &&
                (_assetStatus != 50) &&
                (_assetStatus != 56)){
                    return 0;
                } else {
                    return 170;
                }
    }

    //-----------------------------------------------Events------------------------------------------------//

    event REPORT(string _msg, bytes32 b32);

   

    /*
     * @dev Set an asset to escrow status (6/50/56). Sets timelock for unix timestamp of escrow end.
     */
    function setEscrow(
        bytes32 _idxHash,
        uint8 _newAssetStatus,
        uint256 _escrowTime,
        bytes32 _escrowOwner
    ) external nonReentrant isEscrowContract //exists(_idxHash)
    //notEscrow(_idxHash)
    //notBlockLocked(_idxHash)
    {
        Record memory rec = getShortRecord(_idxHash);
        ContractDataHash memory contractInfo;
        (contractInfo.contractType, contractInfo.nameHash) = Storage.ContractInfoHash(
            msg.sender
        );

        require(
            contractInfo.contractType == 3,
            "PS:SE: Escrow can only be set by an escrow contract"
        );
        require(escrows[_idxHash] == 0, "Already listed in escrow table"); //FIX BECAUSE STRUCT---------------------------------or rremove?
        require(
            (_newAssetStatus == 6) ||
                (_newAssetStatus == 50) ||
                (_newAssetStatus == 56),
            "PS:SE: Must set to an escrow status"
        );
        require(
            (isLostOrStolen(rec.assetStatus) == 0) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "PS:SE: Txd, L/S status cannot be set to escrow."
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "PS:SE: Asset already in escrow status."
        );
        //^^^^^^^checks^^^^^^^^^

        
        rec.assetStatus = _newAssetStatus;
        rec.timeLock = _escrowTime;
        escrows[_idxHash] = _escrowOwner;

         //database[_idxHash] = rec; ----------------------------------send updated data to storage
        //^^^^^^^effects^^^^^^^^^
        emit REPORT("Record locked for escrow", contractInfo.nameHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isEscrowContract
    //notBlockLocked(_idxHash)
    //exists(_idxHash)
    {
        Record memory rec = getShortRecord(_idxHash);
        ContractDataHash memory contractInfo;
        (contractInfo.contractType, contractInfo.nameHash) = Storage.ContractInfoHash(
            msg.sender
        );

        require(
            (contractInfo.nameHash == rec.recorder) || (rec.timeLock < now),
            "PS:EE:Only contract with same name as setter can end early"
        );
        require(
            (rec.assetStatus == 6) ||
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "PS:EE:Asset not in escrow"
        );

        //^^^^^^^checks^^^^^^^^^

        if (rec.assetStatus == 6) {
            rec.assetStatus = 7;
        }
        if (rec.assetStatus == 56) {
            rec.assetStatus = 57;
        }
        if (rec.assetStatus == 50) {
            rec.assetStatus = 58;
        }

        // (rec.lastRecorder, rec.recorder) = Storage.storeRecorder(
        //     _idxHash,
        //     contractInfo.NameHash
        // );
        //escrows[_idxHash] = 0;  //FIX BECAUSE STRUCT---------------------------------or rremove?
        //database[_idxHash] = rec; ----------------------------------send updated data to storage
        //^^^^^^^effects^^^^^^^^^

        emit REPORT("Escrow Ended by", contractInfo.nameHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function retrieveEscrowOwner(bytes32 _idxHash)
        external
        view
        returns (bytes32)
    {
        return escrows[_idxHash];
        //^^^^^^^checks/interactions^^^^^^^^^
    }


    //----------------------Internal Admin functions / onlyowner or isAdmin----------------------//
}
