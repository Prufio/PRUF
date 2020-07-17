/*-----------------------------------------------------------------
 *  TO DO
 * Point to escrow manager instead of storage
*-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_basic_066.sol";
import "./Imports/Safemath.sol";


contract T_PRUF_simpleEscrow is PRUF_BASIC {
    using SafeMath for uint256;

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
            (AssetTokenContract.ownerOf(tokenID) == msg.sender), //msg.sender is token holder
            "TPSE:IA: Caller does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev puts asset into an escrow status for a certain time period
     */
    function setEscrow(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint256 escrowTime = now.add(_escrowTime);
        uint8 newEscrowStatus;
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 2,
            "TPSE:SE: Contract not authorized for custodial assets"
        );

        require((rec.rightsHolder != 0), "SE: Record does not exist");
        require(
            (rec.assetStatus > 49),
            "TPSE:SE: Only ACadmin authorized user can change status < 50"
        );
        require(
            (escrowTime >= now),
            "TPSE:SE:Escrow must be set to a time in the future"
        );
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "TPSE:SE:Transferred, lost, or stolen status cannot be set to escrow."
        );
        require(
                (_escrowStatus == 50) ||
                (_escrowStatus == 56),
            "TPSE:SE:Must specify a valid escrow status >49"
        );

        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        Storage.setEscrow(
            _idxHash,
            newEscrowStatus,
            escrowTime,
            _escrowOwnerHash
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev takes asset out of excrow status if time period has resolved || is escrow issuer
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        Record memory shortRec = getShortRecord(_idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);
        bytes32 ownerHash = Storage.retrieveEscrowOwner(_idxHash);

        require(
            AC_info.custodyType == 2,
            "TPSE:EE:Contract not authorized for custodial assets"
        );

        require((rec.rightsHolder != 0), "EE: Record does not exist");
        require(
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "TPSE:EE:record must be in escrow status <49"
        );
        require(
            (shortRec.timeLock < now) ||
                (keccak256(abi.encodePacked(msg.sender)) == ownerHash),
            "PSE:EE: Escrow period not ended and caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
