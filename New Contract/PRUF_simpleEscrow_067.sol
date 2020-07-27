/*-----------------------------------------------------------------
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

import "./PRUF_core_067.sol";

contract PRUF_simpleEscrow is PRUF {
    using SafeMath for uint256;

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 to 9
     *      Is authorized for asset class
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
            AssetTokenContract.ownerOf(tokenID) == PrufAppAddress,
            "PSE:IA: Custodial contract does not hold token"
        );
        _;
    }

    /*
     * @dev puts asset into an escrow status for a certain time period
     */
    function setEscrow(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant whenNotPaused isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        uint256 escrowTime = now.add(_escrowTime);
        uint8 newEscrowStatus;
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PSE:SE: Contract not authorized for non-custodial assets"
        );
        require((rec.rightsHolder != 0), "SE: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "TPNP:MI1: User not authorized to modify records in specified asset class"
        );
        require(
            (escrowTime >= now),
            "PSE:SE: Escrow must be set to a time in the future"
        );
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "PSE:SE: Transferred, lost, or stolen status cannot be set to escrow."
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "PSE:SE: Asset already in escrow status."
        );
        require(
            (userType < 5) || ((userType > 4) && (_escrowStatus > 49)),
            "PSE:SE: Non supervisored agents must set asset status within scope."
        );
        require(
            (_escrowStatus == 6) ||
                (_escrowStatus == 50) ||
                (_escrowStatus == 56),
            "PSE:SE: Must specify an valid escrow status"
        );
        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        escrowMGRcontract.setEscrow(
            _idxHash,
            newEscrowStatus,
            0,
            _escrowOwnerHash,
            escrowTime,
            0x0,
            0x0,
            address(0),
            address(0)
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
        //Record memory shortRec = getShortRecord(_idxHash);
        escrowData memory escrow = getEscrowData(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        AC memory AC_info = getACinfo(rec.assetClass);
        bytes32 ownerHash = escrowMGRcontract.retrieveEscrowOwner(_idxHash);

        require(
            AC_info.custodyType == 1,
            "PSE:EE: Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "EE: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "TPNP:MI1: User not authorized to modify records in specified asset class"
        );
        require(
            (rec.assetStatus == 6) ||
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "EE:ERR- record must be in escrow status"
        );
        require(
            ((rec.assetStatus > 49) || (userType < 5)),
            "PSE:EE: Usertype less than 5 required to end this escrow"
        );
        require(
            (escrow.timelock < now) ||
                (keccak256(abi.encodePacked(msg.sender)) == ownerHash),
            "PSE:EE: Escrow period not ended and caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        escrowMGRcontract.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
