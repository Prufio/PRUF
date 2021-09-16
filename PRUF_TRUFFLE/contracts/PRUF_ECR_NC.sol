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
 *  TO DO
 *  Inheritable core functioanlity for sattelite escrow contracts
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./PRUF_ECR_CORE.sol";

contract ECR_NC is ECR_CORE {
    /**
     * @dev Verify user credentials
     * Originating Address must hold referenced asset token
     * @param _idxHash indexHash of asset
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == _msgSender()), //_msgSender() is token holder
            "ENC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /**
     * @dev puts asset into an escrow status for a provided time period
     * @param _idxHash Asset index to place in escrow
     * @param _escrowOwnerHash escrow controller address hash
     * @param _escrowTime Expiration time of escrow
     * @param _escrowStatus Type of escrow
     */
    function setEscrow(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint256 escrowTime = block.timestamp + _escrowTime;
        uint8 newEscrowStatus;
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.node
        );

        require(
            contractInfo.contractType > 0,
            "ENC:SE:Contract not auth for node"
        );
        require(rec.assetStatus > 49, "ENC:SE: Escrow type not permitted");
        require( //REDUNDANT PREFERRED
            escrowTime >= block.timestamp,
            "ENC:SE:Escrow must be set to a time in the future"
        );
        require(
            (_escrowStatus == 50) || (_escrowStatus == 56),
            "ENC:SE:Must specify a valid escrow status >49"
        );

        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        _setEscrowData(_idxHash, newEscrowStatus, _escrowOwnerHash, escrowTime);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev takes asset out of excrow status if time period has resolved || is escrow issuer
     * @param _idxHash Asset to end escrow on
     */
    function endEscrow(bytes32 _idxHash) external nonReentrant {
        bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);
        Record memory rec = getRecord(_idxHash);
        escrowData memory escrow = getEscrowData(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.node
        );

        require(
            contractInfo.contractType > 0,
            "ENC:EE:Contract not auth for node"
        );
        require(
            (rec.assetStatus == 50) || (rec.assetStatus == 56),
            "ENC:EE: Record must be in escrow status > 49"
        );
        require(
            (escrow.timelock < block.timestamp) ||
                (keccak256(abi.encodePacked(_msgSender())) == ownerHash),
            "ENC:EE: Escrow period not ended and caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        ECR_MGR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
