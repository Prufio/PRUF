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

 //CTS:EXAMINE quick explainer for the contract

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_ECR_CORE.sol";
import "./PRUF_CORE.sol";

contract RCLR is ECR_CORE, CORE {
    bytes32 public constant DISCARD_ROLE = keccak256("DISCARD_ROLE");

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev //gets item out of recycled status -- caller is assetToken contract
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
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

    /*
     * @dev reutilize a recycled asset //DPS:CHECK NEW REQUIRES!!!
     * //CTS:EXAMINE maybe describe the reqs in this one, back us up on the security
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function recycle(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint32 _node
    ) external nonReentrant whenNotPaused {
        uint256 tokenId = uint256(_idxHash);
        escrowDataExtLight memory escrowDataLight =
            getEscrowDataLight(_idxHash);
        Record memory rec = getRecord(_idxHash);
        Node memory node_info = getACinfo(_node);
        require(_rgtHash != 0, "R:R: New rights holder = zero");
        require(rec.assetStatus == 60, "R:R: Asset not discarded");
        require(
            NODE_MGR.isSameRootAC(_node, rec.node) == 170,
            "R:R: !Change node to new root"
        );
        require(
            (node_info.managementType < 6),
            "R:R: Contract does not support management types > 5 or node is locked"
        );
        if (
            (node_info.managementType == 1) ||
            (node_info.managementType == 2) ||
            (node_info.managementType == 5)
        ) {
            require(
                (NODE_TKN.ownerOf(_node) == _msgSender()),
                "R:R: Cannot create asset in node mgmt type 1||2||5 - caller does not hold node token"
            );
        } else if (node_info.managementType == 3) {
            require(
                NODE_MGR.getUserType(
                    keccak256(abi.encodePacked(_msgSender())),
                    _node
                ) == 1,
                "R:R: Cannot create asset - caller address !authorized"
            );
        } else if (node_info.managementType == 4) {
            require(
                ID_TKN.trustedLevelByAddress(_msgSender()) > 10,
                "R:R: Caller !trusted ID holder"
            );
        }
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        rec.numberOfTransfers = 170;
        //^^^^^^^effects^^^^^^^^^^^^

        A_TKN.mintAssetToken(_msgSender(), tokenId, "pruf.io"); //FIX TO MAKE REAL ASSET URL DPS / CTS
        ECR_MGR.endEscrow(_idxHash);
        STOR.changeAC(_idxHash, _node);
        deductRecycleCosts(_node, escrowDataLight.addr_1);
        rec.assetStatus = 58;
        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^^^^
    }
}
