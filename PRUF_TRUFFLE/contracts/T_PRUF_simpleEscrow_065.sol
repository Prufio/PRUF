/*-----------------------------------------------------------------
 *  TO DO
 *
*-----------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_basic_065.sol";
import "./Imports/Safemath.sol";


contract T_PRUF_simpleEscrow is PRUF_BASIC {
    using SafeMath for uint256;

    mapping(bytes32 => bytes32) private escrows;
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
        bytes32 escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint256 escrowTime = now.add(_escrowTime);
        uint8 newAssetStatus;
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
            (_escrowStatus == 6) ||
                (_escrowStatus == 50) ||
                (_escrowStatus == 56),
            "TPSE:SE:Must specify an valid escrow status"
        );
        require(
            (_escrowStatus > 49),
            "TPSE:SE:Only custodial usertype can set escrow < 50"
        );
        //^^^^^^^checks^^^^^^^^^

        escrows[_idxHash] = escrowOwnerHash;
        newAssetStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        Storage.setEscrow(_idxHash, newAssetStatus, escrowTime);
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
        User memory callingUser = getUser();
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 2,
            "TPSE:EE:Contract not authorized for custodial assets"
        );

        require((rec.rightsHolder != 0), "EE: Record does not exist");
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "TPSE:EE:User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 6) ||
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "TPSE:EE:record must be in escrow status"
        );
        require(
            (rec.assetStatus > 49),
            "TPSE:EE:Custodial usertype required to end this escrow"
        );
        require(
            (shortRec.timeLock < now) ||
                (keccak256(abi.encodePacked(msg.sender)) == escrows[_idxHash]),
            "PSE:EE: Escrow period not ended and caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        Storage.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
