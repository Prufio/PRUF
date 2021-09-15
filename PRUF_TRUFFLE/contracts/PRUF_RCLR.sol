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

/*-----------------------------------------------------------------
 *  TO DO
 *
 *---------------------------------------------------------------*/

//RCLR allows discarded items to be re-onboarded to a new holder

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./PRUF_ECR_CORE.sol";
import "./PRUF_CORE.sol";

contract RCLR is ECR_CORE, CORE {
    bytes32 public constant DISCARD_ROLE = keccak256("DISCARD_ROLE");

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev discards item -- caller is assetToken contract
     * @param _idxHash asset ID
     * @param _sender discarder
     * Caller Must have DISCARD_ROLE
     */
    function discard(bytes32 _idxHash, address _sender)
        external
        nonReentrant
        whenNotPaused
    {
        Record memory rec = getRecord(_idxHash);

        require(
            hasRole(DISCARD_ROLE, _msgSender()),
            "R:D: Caller does not have DISCARD_ROLE"
        );
        require(rec.assetStatus == 59, "R:D: Asset !in recyclable status");
        //^^^^^^^checks^^^^^^^^^

        uint256 escrowTime = block.timestamp + 31536000000; //1,000 years in the FUTURE.........
        bytes32 escrowOwnerHash = keccak256(abi.encodePacked(_msgSender()));
        escrowDataExtLight memory escrowDataLight;
        escrowDataLight.escrowData = 255;
        escrowDataLight.addr_1 = _sender;
        //^^^^^^^effects^^^^^^^^^

        _setEscrowData(
            _idxHash,
            60, //recycled status
            escrowOwnerHash,
            escrowTime
        );
        _setEscrowDataLight(_idxHash, escrowDataLight);
        //^^^^^^^interactions^^^^^^^^^
    }

    /** 
     * @dev reutilize a recycled asset
     * maybe describe the reqs in this one, back us up on the security
     * @param _idxHash asset ID
     * @param _rgtHash rights holder hash to set
     */
    function recycle(
        bytes32 _idxHash,
        bytes32 _rgtHash
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);
        escrowDataExtLight memory escrowDataLight = getEscrowDataLight(
            _idxHash
        );
        Record memory rec = getRecord(_idxHash);
        //Node memory node_info = getNodeinfo(_node);
        require(_rgtHash != 0, "R:R: New rights holder = zero");
        require(rec.assetStatus == 60, "R:R: Asset not discarded");

        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        rec.numberOfTransfers = 170;
        //^^^^^^^effects^^^^^^^^^^^^

        A_TKN.mintAssetToken(_msgSender(), tokenId, "pruf.io/asset"); //FIX TO MAKE REAL ASSET URL DPS / CTS
        ECR_MGR.endEscrow(_idxHash);
        deductRecycleCosts(rec.node, escrowDataLight.addr_1);
        rec.assetStatus = 58;
        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^^^^
    }
}
