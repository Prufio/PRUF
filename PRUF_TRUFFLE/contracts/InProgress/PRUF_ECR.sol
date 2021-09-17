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
 *  Sample basic time-escrow contract
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_ECR_CORE.sol";

contract ECR is ECR_CORE {
    /**
     * @dev Verify user credentials
     * @param _idxHash asset to check
     * Custodial contract must hold token
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            A_TKN.ownerOf(tokenId) == APP_Address,
            "E:MOD-IA: APP contract does not hold token"
        );
        _;
    }

    /**
     * @dev Puts asset into an escrow status for a provided time period
     * @param _idxHash Asset
     * @param _escrowOwnerHash Escrow Owner adress hash
     * @param _escrowTime Expiarion time of escrow
     * @param _escrowStatus Escrow type
     */
    function setEscrow(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.node);
        uint256 escrowTime = block.timestamp + _escrowTime;
        uint8 newEscrowStatus;
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.node
        );

        require(
            contractInfo.contractType > 0,
            "E:SE: Contract not auth in node"
        );
        require(
            (userType > 0) && (userType < 10),
            "E:SE: User not auth in node"
        );
        require( //REDUNDANT PREFERRED
            (escrowTime >= block.timestamp),
            "E:SE: Escrow must be set to a time in the future"
        );
        require(
            (userType < 5) ||
                ((userType > 4) && (userType < 10) && (_escrowStatus > 49)),
            "E:SE: Non supervisored agents must set escrow status within scope > 49."
        );
        require(_escrowStatus != 60, "E:SE: Cannot set to recycled status.");
        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        _setEscrowData(_idxHash, newEscrowStatus, _escrowOwnerHash, escrowTime);
        //^^^^^^^interactions^^^^^^^^^
    }

    // /*
    //  * @dev Example for setting data
    //  */
    // function setEscrowExtendedData(
    //     bytes32 _idxHash,
    //     bytes32 _escrowOwnerHash,
    //     uint256 _escrowTime,
    //     uint8 _escrowStatus
    // ) external nonReentrant isAuthorized(_idxHash) {
    //     Record memory rec = getRecord(_idxHash);
    //     uint8 userType = getCallingUserType(rec.node);
    //     uint256 escrowTime = block.timestamp + _escrowTime;
    //     uint8 newEscrowStatus;
    //     ContractDataHash memory contractInfo = getContractInfo(
    //         address(this),
    //         rec.node
    //     );

    //     require(
    //         contractInfo.contractType > 0,
    //         "E:SEED: Contract not auth in node"
    //     );
    //     require(
    //         (userType > 0) && (userType < 10),
    //         "E:SEED: User not auth in node"
    //     );
    //     require(
    //         (escrowTime >= block.timestamp),
    //         "E:SEED: Escrow must be set to a time in the future"
    //     );
    //     require(
    //         (userType < 5) ||
    //             ((userType > 4) && (userType < 10) && (_escrowStatus > 49)),
    //         "E:SEED: Unsupervised agents must set escrow status within scope > 49."
    //     );
    //     require(
    //         (_escrowStatus != 60),
    //         "E:SEED: Cannot set to stat 60 (recycled)."
    //     );
    //     //^^^^^^^checks^^^^^^^^^

    //     newEscrowStatus = _escrowStatus;

    //     escrowDataExtLight memory escrowDataLight; //demo for setting "light" struct data
    //     escrowDataLight.escrowData = 5;
    //     escrowDataLight.addr_1 = _msgSender();

    //     escrowDataExtHeavy memory escrowDataHeavy; //demo for setting "Heavy" struct data
    //     escrowDataHeavy.u256_1 = 9999;
    //     //^^^^^^^effects^^^^^^^^^

    //     _setEscrowData(_idxHash, newEscrowStatus, _escrowOwnerHash, escrowTime);
    //     _setEscrowDataLight(_idxHash, escrowDataLight); //Sets "light" EXT data
    //     _setEscrowDataHeavy(_idxHash, escrowDataHeavy); //Sets "Heavy" EXT data
    //     //^^^^^^^interactions^^^^^^^^^
    // }

    /**
     * @dev Takes asset out of excrow status if time period has resolved || is escrow issuer
     * @param _idxHash asset to end escrow on
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        escrowData memory escrow = getEscrowData(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.node
        );
        uint8 userType = getCallingUserType(rec.node);
        bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        require(
            contractInfo.contractType > 0,
            "E:EE: Contract not auth in node"
        );
        require(
            (userType > 0) && (userType < 10),
            "E:EE: User not auth in node"
        );
        require( //STATE UNREACHABLE PREFERRED
            (rec.assetStatus != 60),
            "E:EE: Asset is discarded, use Recycle"
        );
        require(
            ((rec.assetStatus > 49) || (userType < 5)),
            "E:EE: Usertype less than 5 required to end this escrow"
        );
        require(
            (escrow.timelock < block.timestamp) ||
                (keccak256(abi.encodePacked(_msgSender())) == ownerHash),
            "E:EE: Escrow period not ended or caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        ECR_MGR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
