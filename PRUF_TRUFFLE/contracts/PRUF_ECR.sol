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

contract ECR is ECR_CORE {
    
    /*
     * @dev Verify user credentials
     * //CTS:EXAMINE param
     * //CTS:EXAMINE explain req
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            A_TKN.ownerOf(tokenId) == APP_Address,
            "E:MOD-IA: APP contract does not hold token"
        );
        _;
    }

    /*
     * @dev Puts asset into an escrow status for a provided time period
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     */
    function setEscrow(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);
        uint256 escrowTime = block.timestamp + _escrowTime;
        uint8 newEscrowStatus;
        ContractDataHash memory contractInfo =
            getContractInfo(address(this), rec.assetClass);

        require(contractInfo.contractType > 0, "E:SE: Contract not auth in AC");
        require((userType > 0) && (userType < 10), "E:SE: User not auth in AC");
        require( //REDUNDANT, THROWS IN SAFEMATH CTS:PREFERRED
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

    /*
     * @dev Puts asset into an escrow status for a provided time period //CTS:EXAMINE put the examples in setEscrow's comment section?
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * //CTS:EXAMINE param
     * Includes sample code for setting extended data
     */
    function setEscrowExtendedData(
        bytes32 _idxHash,
        bytes32 _escrowOwnerHash,
        uint256 _escrowTime,
        uint8 _escrowStatus
    ) external nonReentrant isAuthorized(_idxHash) {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getCallingUserType(rec.assetClass);
        uint256 escrowTime = block.timestamp + _escrowTime;
        uint8 newEscrowStatus;
        ContractDataHash memory contractInfo =
            getContractInfo(address(this), rec.assetClass);

        require(contractInfo.contractType > 0, "E:SEED: Contract not auth in AC");
        require((userType > 0) && (userType < 10), "E:SEED: User not auth in AC");
        require( //REDUNDANT, THROWS IN SAFEMATH CTS:PREFERRED
            (escrowTime >= block.timestamp),
            "E:SEED: Escrow must be set to a time in the future"
        );
        require(
            (userType < 5) ||
                ((userType > 4) && (userType < 10) && (_escrowStatus > 49)),
            "E:SEED: Unsupervised agents must set escrow status within scope > 49."
        );
        require((_escrowStatus != 60), "E:SEED: Cannot set to stat 60 (recycled).");
        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;

        escrowDataExtLight memory escrowDataLight; //demo for setting "light" struct data
        escrowDataLight.escrowData = 5;
        escrowDataLight.addr_1 = _msgSender();

        escrowDataExtHeavy memory escrowDataHeavy; //demo for setting "Heavy" struct data
        escrowDataHeavy.u256_1 = 9999;
        //^^^^^^^effects^^^^^^^^^

        _setEscrowData(_idxHash, newEscrowStatus, _escrowOwnerHash, escrowTime);
        _setEscrowDataLight(_idxHash, escrowDataLight); //Sets "light" EXT data
        _setEscrowDataHeavy(_idxHash, escrowDataHeavy); //Sets "Heavy" EXT data
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev A standard function for all escrow contracts which returns all relevant data about an escrow
     * //CTS:EXAMINE is this neccessary? Maybe put a note in getEscrowData. We're not trying to teach people how to code in solidity here
     * //CTS:EXAMINE param
     * //CTS:EXAMINE returns
     * in this case only the relevant escrowData struct DPS:TEST
     */
    function getEscrowParameters (bytes32 _idxHash) external returns (escrowData memory){
        return(getEscrowData(_idxHash));
    }

    /*
     * @dev Takes asset out of excrow status if time period has resolved || is escrow issuer
     * //CTS:EXAMINE param
     */
    function endEscrow(bytes32 _idxHash)
        external
        nonReentrant
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        escrowData memory escrow = getEscrowData(_idxHash);
        ContractDataHash memory contractInfo =
            getContractInfo(address(this), rec.assetClass);
        uint8 userType = getCallingUserType(rec.assetClass);
        bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        require(contractInfo.contractType > 0, "E:EE: Contract not auth in AC");
        require((userType > 0) && (userType < 10), "E:EE: User not auth in AC");
        require( //STATE UNREACHABLE CTS:PREFERRED
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
