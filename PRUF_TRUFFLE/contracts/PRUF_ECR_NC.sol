/*--------------------------------------------------------PRüF0.8.0
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
 *---------------------------------------------------------------*/

 //CTS:EXAMINE quick explainer for the contract

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_ECR_CORE.sol";

contract ECR_NC is ECR_CORE {
    

    /*
     * @dev Verify user credentials
     * Originating Address: //CTS:EXAMINE maybe make this a little less confusing
     *      holds asset token at idxHash
     * //CTS:EXAMINE param
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

    /*
     * @dev puts asset into an escrow status for a provided time period
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
        uint256 escrowTime = block.timestamp + _escrowTime;
        uint8 newEscrowStatus;
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "ENC:SE:Contract not auth for AC"
        );
        require(
            rec.assetStatus > 49,
            "ENC:SE: Only ACadmin authorized user can change status < 50" //CTS:EXAMINE is this still evident?
        );
        require( //REDUNDANT, THROWS CTS:PREFERRED
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
     * @dev takes asset out of excrow status if time period has resolved || is escrow issuer
     * //CTS:EXAMINE param
     */
    function endEscrow(bytes32 _idxHash) external nonReentrant {
        bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);
        Record memory rec = getRecord(_idxHash);
        escrowData memory escrow = getEscrowData(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "ENC:EE:Contract not auth for AC"
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
