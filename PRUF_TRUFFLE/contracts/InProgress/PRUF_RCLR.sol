/*--------------------------------------------------------PRüF0.8.7
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
 *  TO DO Examine . Import/export rules are different to allow multichain.
 *
 *---------------------------------------------------------------*/

//RCLR allows discarded items to be re-onboarded to a new holder

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_ECR_CORE.sol";
import "../Resources/PRUF_CORE.sol";

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
     * @param _URIsuffix //CTS:CHECK - where does this get the URI Suffix?
     */
    function recycle(bytes32 _idxHash, bytes32 _rgtHash, string memory _URIsuffix) 
        external
        nonReentrant
        whenNotPaused
    {
        uint256 tokenId = uint256(_idxHash);
        escrowDataExtLight memory escrowDataLight = getEscrowDataLight(
            _idxHash
        );
        Record memory rec = getRecord(_idxHash);

        require(_rgtHash != 0, "R:R: New rights holder = zero");
        require(rec.assetStatus == 60, "R:R: Asset not discarded");

        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _rgtHash;
        rec.numberOfTransfers = 170;
        //^^^^^^^effects^^^^^^^^^^^^

        A_TKN.mintAssetToken(_msgSender(), tokenId, _URIsuffix); //only sends to caller. Noneed to mint to node, custodial does not recycle

        ECR_MGR.endEscrow(_idxHash);
        deductRecycleCosts(rec.node, escrowDataLight.addr_1);
        rec.assetStatus = 58;
        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^^^^
    }

     // /** //import & export have been slated for reevaluation
    //  * @dev exportTo - sets asset to status 70 (importable) and defines the node that the item can be imported into
    //  * @param _idxHash idx of asset to Modify
    //  * @param _exportTo node target for export
    //  */
    // function exportAssetTo(bytes32 _idxHash, uint32 _exportTo)
    //     external
    //     whenNotPaused
    //     isAuthorized(_idxHash)
    // {
    //     Record memory rec = getRecord(_idxHash);
    //     Node memory nodeInfo = getNodeinfo(rec.node);

    //     require(
    //         (rec.assetStatus == 51) || (rec.assetStatus == 70),
    //         "APP_NC:EXT: Must be in transferrable status (51)"
    //     );
    //     require(
    //         NODE_STOR.isSameRootNode(_exportTo, rec.node) == 170,
    //         "APP_NC:EXT: Cannot change node to new root"
    //     );
    //     require(
    //         (nodeInfo.managementType < 6),
    //         "APP_NC:EXT: Contract does not support management types > 5 or node is locked"
    //     );
    //     if (
    //         (nodeInfo.managementType == 1) || (nodeInfo.managementType == 5)
    //     ) {
    //         require(
    //             (NODE_TKN.ownerOf(rec.node) == _msgSender()),
    //             "APP_NC:EXT: Restricted from exporting assets from this node - does not hold NodeToken"
    //         );
    //     }
    //     //^^^^^^^checks^^^^^^^^^

    //     rec.assetStatus = 70; // Set status to 70 (exported)
    //     rec.int32temp = _exportTo; //set permitted node for import

    //     writeRecord(_idxHash, rec);
    //     //^^^^^^^effects^^^^^^^^^
    // }

    // /** //import & export have been slated for reevaluation
    //  * @dev Import a record into a new node
    //  * @param _idxHash - hash of asset information created by frontend inputs
    //  * @param _newNode - node the asset will be imported into
    //  */
    // function importAsset(bytes32 _idxHash, uint32 _newNode)
    //     external
    //     nonReentrant
    //     whenNotPaused
    //     isAuthorized(_idxHash)
    // {
    //     Record memory rec = getRecord(_idxHash);
    //     Node memory nodeInfo = getNodeinfo(_newNode);

    //     require(rec.assetStatus == 70, "ANC:IA: Asset !exported");
    //     require(
    //         _newNode == rec.int32temp,
    //         "ANC:IA: Cannot change node except to specified node"
    //     );
    //     require(
    //         NODE_STOR.isSameRootNode(_newNode, rec.node) == 170,
    //         "ANC:IA: Cannot change node to new root"
    //     );
    //     require(
    //         (nodeInfo.managementType < 6),
    //         "ANC:IA: Contract does not support management types > 5 or node is locked"
    //     );
    //     if (
    //         (nodeInfo.managementType == 1) ||
    //         (nodeInfo.managementType == 2) ||
    //         (nodeInfo.managementType == 5)
    //     ) {
    //         require(
    //             (NODE_TKN.ownerOf(_newNode) == _msgSender()),
    //             "ANC:IA: Cannot import asset in node mgmt type 1||2||5 - caller does not hold node token"
    //         );
    //     } else if (nodeInfo.managementType == 3) {
    //         require(
    //             NODE_STOR.getUserType(
    //                 keccak256(abi.encodePacked(_msgSender())),
    //                 _newNode
    //             ) == 1,
    //             "ANC:IA: Cannot create asset - caller address !authorized"
    //         );
    //     } else if (nodeInfo.managementType == DEPRICATED) {
    //         require(
    //             DEPRICATEDID_MGR.trustLevel(_msgSender()) > 10,
    //             "ANC:IA: Caller !trusted ID holder"
    //         );
    //     }
    //     //^^^^^^^checks^^^^^^^^^

    //     rec.assetStatus = 51; //transferrable status
    //     STOR.changeNode(_idxHash, _newNode);

    //     writeRecord(_idxHash, rec);
    //     deductServiceCosts(_newNode, 1);
    //     //^^^^^^^effects/interactions^^^^^^^^^^^^
    // }å
}
