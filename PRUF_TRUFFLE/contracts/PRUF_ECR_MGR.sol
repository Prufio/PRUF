/*-----------------------------------------------------------V0.6.8
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\../\\ ___/\\\\\\\\\\\\\\\
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//..\//____\/\\\///////////__
  _\/\\\.......\/\\\.\/\\\.....\/\\\ ________________\/\\\ ____________
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\.\/\\\\\\\\\\\ ____
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\.\/\\\///////______
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\.\/\\\ ____________
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\.\/\\\ ____________
       _\/\\\ ____________\/\\\ _____\//\\\.\//\\\\\\\\\ _\/\\\ ____________
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

/*-----------------------------------------------------------------
 *  TO DO
 *
 *-----------------------------------------------------------------
 */

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_BASIC.sol";
import "./Imports/Safemath.sol";

contract ECR_MGR is BASIC {
    using SafeMath for uint256;

    struct escrowData {
        uint8 data;
        bytes32 controllingContractNameHash; //hash of the name of the controlling escrow contract
        bytes32 escrowOwnerAddressHash; //hash of an address designated as an executor for the escrow contract
        uint256 timelock;
        bytes32 ex1;
        bytes32 ex2;
        address addr1;
        address addr2;
    }

    mapping(bytes32 => escrowData) escrows;

    function isLostOrStolen(uint8 _assetStatus) private pure returns (uint8) {
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

    function isEscrow(uint8 _assetStatus) private pure returns (uint8) {
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
    ) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            msg.sender,
            rec.assetClass
        );
        bytes32 controllingContractNameHash = contractInfo.nameHash;

        require(
            contractInfo.contractType == 3,
            "EM:SE: Escrow can only be set by an authorized escrow contract"
        );
        //^^^^^^^checks^^^^^^^^^
        delete escrows[_idxHash];

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

        STOR.setEscrow(_idxHash, _newAssetStatus);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev remove an asset from escrow status
     */
    function endEscrow(bytes32 _idxHash) external nonReentrant whenNotPaused {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            msg.sender,
            rec.assetClass
        );

        require(
            (contractInfo.nameHash ==
                escrows[_idxHash].controllingContractNameHash),
            "EM:EE:Only contract with same name as setter can end escrow"
        );

        //^^^^^^^checks^^^^^^^^^

        delete escrows[_idxHash];
        //^^^^^^^effects^^^^^^^^^

        STOR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Permissive removal of asset from escrow status after time-out
     */
    function permissiveEndEscrow(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
    {
        require(
            escrows[_idxHash].timelock < block.timestamp,
            "EM:PEE:Escrow not expired"
        );
        require( // do not allow escrows with escrow.data > 199 to be ended by this function     //STATE UNREACHABLE CTS:PREFERRED
            escrows[_idxHash].data < 200,
            "EM:PEE:Escrow not endable with permissiveEndEscrow"
        );
        //^^^^^^^checks^^^^^^^^^

        delete escrows[_idxHash];
        //^^^^^^^effects^^^^^^^^^

        STOR.endEscrow(_idxHash);
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
