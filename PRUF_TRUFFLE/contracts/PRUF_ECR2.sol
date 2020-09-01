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

contract ECR2 is ECR_CORE {
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

        require(
            contractInfo.contractType > 0,
            "E:SE: This contract not authorized for specified AC"
        );
        require((rec.assetClass != 0), "E:SE: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "E:SE: User not authorized to modify records in specified asset class"
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

        require(
            contractInfo.contractType > 0,
            "E:EE: This contract not authorized for specified AC"
        );

        require((rec.assetClass != 0), "E:EE: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "E:EE: User not authorized to modify records in specified asset class"
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
                (keccak256(abi.encodePacked(msg.sender)) == ownerHash),
            "E:EE: Escrow period not ended and caller is not escrow owner"
        );
        //^^^^^^^checks^^^^^^^^^

        ECR_MGR.endEscrow(_idxHash);
        //^^^^^^^interactions^^^^^^^^^
    }

    function _setEscrowDataLight(
        bytes32 _idxHash,
        uint8 _escrowData,
        uint8 _u8_1,
        uint8 _u8_2,
        uint8 _u8_3,
        uint16 _u16_1,
        uint16 _u16_2,
        uint32 _u32_1,
        address _addr_1
    ) external nonReentrant whenNotPaused {
        ECR_MGR.setEscrowDataLight(
            _idxHash,
            _escrowData,
            _u8_1,
            _u8_2,
            _u8_3,
            _u16_1,
            _u16_2,
            _u32_1,
            _addr_1
        );
        //^^^^^^^effects^^^^^^^^^
    }

    function _setEscrowDataHeavy(
        bytes32 _idxHash,
        uint32 _u32_2,
        uint32 _u32_3,
        uint32 _u32_4,
        address _addr_2,
        bytes32 _b32_1,
        bytes32 _b32_2,
        uint256 _u256_1,
        uint256 _u256_2
    ) external nonReentrant whenNotPaused {
        ECR_MGR.setEscrowDataHeavy(
            _idxHash,
            _u32_2,
            _u32_3,
            _u32_4,
            _addr_2,
            _b32_1,
            _b32_2,
            _u256_1,
            _u256_2
        );
        //^^^^^^^effects^^^^^^^^^
    }
}
