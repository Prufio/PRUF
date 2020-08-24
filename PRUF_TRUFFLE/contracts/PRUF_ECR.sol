/*-----------------------------------------------------------V0.6.8
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

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_ECR_CORE.sol";

contract ECR is ECR_CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     *      Exists in registeredUsers as a usertype 1 to 9
     *      Is authorized for asset class
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
        uint8 userType = getUserType(rec.assetClass);
        uint256 escrowTime = block.timestamp.add(_escrowTime);
        uint8 newEscrowStatus;
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(contractInfo.contractType > 0, "E:SE: contract not auth in AC");
        require((userType > 0) && (userType < 10), "E:SE: user not auth in AC");
        require( //REDUNDANT, THROWS IN SAFEMATH CTS:PREFERRED
            (escrowTime >= block.timestamp),
            "E:SE: Escrow must be set to a time in the future"
        );
        require(
            (userType < 5) ||
                ((userType > 4) && (userType < 10) && (_escrowStatus > 49)),
            "E:SE: Non supervisored agents must set escrow status within scope."
        );
        require((_escrowStatus != 60), "E:SE: Cannot set to recycled status.");
        //^^^^^^^checks^^^^^^^^^

        newEscrowStatus = _escrowStatus;
        //^^^^^^^effects^^^^^^^^^

        ECR_MGR.setEscrow(
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
        escrowData memory escrow = getEscrowData(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );
        uint8 userType = getUserType(rec.assetClass);
        bytes32 ownerHash = ECR_MGR.retrieveEscrowOwner(_idxHash);

        require(contractInfo.contractType > 0, "E:EE: contract not auth in AC");
        require((userType > 0) && (userType < 10), "E:EE: user not auth in AC");
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
                (keccak256(abi.encodePacked(msg.sender)) == ownerHash),
            "E:EE: Escrow period not ended or caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        ECR_MGR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }
}
