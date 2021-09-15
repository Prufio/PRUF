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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "./PRUF_ECR_CORE.sol";

contract ECR2 is ECR_CORE {
    
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 to 9
     *      Is authorized for node
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            A_TKN.ownerOf(tokenId) == APP_Address,
            "E:MOD-IA: Custodial contract does not hold token"
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
        uint8 userType = getCallingUserType(rec.node);
        uint256 escrowTime = block.timestamp + _escrowTime;
        uint8 newEscrowStatus;
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.node
        );

        require(
            contractInfo.contractType > 0,
            "E:SE: This contract not authorized for specified node"
        );
        require((rec.node != 0), "E:SE: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "E:SE: User not authorized to modify records in specified node"
        );
        require(
            (escrowTime >= block.timestamp),
            "E:SE: Escrow must be set to a time in the future"
        );
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54) &&
                (rec.assetStatus != 5) &&
                (rec.assetStatus != 55),
            "E:SE: Transferred, lost, or stolen status cannot be set to escrow."
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "E:SE: Asset already in escrow status."
        );
        require(
            (userType < 5) ||
                ((userType > 4) && (userType < 10) && (_escrowStatus > 49)),
            "E:SE: Non supervisored agents must set escrow status within scope."
        );
        require(
            (_escrowStatus == 6) ||
                (_escrowStatus == 50) ||
                (_escrowStatus == 56),
            "E:SE: Must specify an valid escrow status"
        );
        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        ECR_MGR.setEscrow(
            _idxHash,
            newEscrowStatus,
            _escrowOwnerHash,
            escrowTime
        );
        //^^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev A standard function for all escrow contracts which returns all relevant data about an escrow
     * in this case only the relevant escrowData struct DPS:TEST
     */
    function getEscrowParameters (bytes32 _idxHash) external returns (escrowData memory){
        return(getEscrowData(_idxHash));
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
        escrowData memory escrow = getEscrowData(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.node
        );
        uint8 userType = getCallingUserType(rec.node);
        bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        require(
            contractInfo.contractType > 0,
            "E:EE: This contract not authorized for specified node"
        );

        require((rec.node != 0), "E:EE: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "E:EE: User not authorized to modify records in specified node"
        );
        require(
            (rec.assetStatus == 6) ||
                (rec.assetStatus == 50) ||
                (rec.assetStatus == 56),
            "E:EE- record must be in escrow status"
        );
        require(
            ((rec.assetStatus > 49) || (userType < 5)),
            "E:EE: Usertype less than 5 required to end this escrow"
        );
        require(
            (escrow.timelock < block.timestamp) ||
                (keccak256(abi.encodePacked(_msgSender())) == ownerHash),
            "E:EE: Escrow period not ended and caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        ECR_MGR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

}
