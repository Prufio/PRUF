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

import "./PRUF_CORE.sol";

contract NP_NC is CORE {
    using SafeMath for uint256;

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == msg.sender), //msg.sender is token holder
            "NPNC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Modify rgtHash (like forceModify)
     * must be tokenholder or A_TKN
     *
     */
    function _changeRgt(bytes32 _idxHash, bytes32 _newRgtHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NPNC:CR: This contract not authorized for specified AC"
        );
        require((rec.assetClass != 0), "NPNC:CR: Record does not exist");
        require(_newRgtHash != 0, "NPNC:CR: rights holder cannot be zero");
        require(
            isLostOrStolen(rec.assetStatus) == 0,
            "NPNC:CR: Cannot modify asset in lost or stolen status"
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "NPNC:CR: Cannot modify asset in Escrow"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:CR: Cannot modify asset in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.rightsHolder = _newRgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        return _idxHash;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     *     @dev Export FROM nonCustodial - sets asset to status 70 (importable)
     */
    function _exportNC(bytes32 _idxHash)
        external
        whenNotPaused
        isAuthorized(_idxHash)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            rec.assetStatus == 51,
            "NPNC:EX: Must be in transferrable status (51)"
        );

        require(
            contractInfo.contractType > 0,
            "NPNC:EX: This contract not authorized for specified AC"
        );

        rec.assetStatus = 70; // Set status to 70 (exported)
        writeRecord(_idxHash, rec);
        STOR.changeAC(_idxHash, AC_info.assetClassRoot); //set assetClass to the root AC of the assetClass
    }

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function _modStatus(bytes32 _idxHash, uint8 _newAssetStatus)
        public
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NPNC:MS: This contract not authorized for specified AC"
        );
        require((rec.assetClass != 0), "NPNC:MS: Record does not exist");
        require(
            isLostOrStolen(_newAssetStatus) == 0,
            "NPNC:MS: Cannot place asset in lost or stolen status using modStatus"
        );
        require(
            isEscrow(_newAssetStatus) == 0,
            "NPNC:MS: Cannot place asset in Escrow using modStatus"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "NPNC:MS: Cannot place asset in unregistered, exported, or discarded status using modStatus"
        );
        require(
            (_newAssetStatus < 100) &&
                (_newAssetStatus != 7) &&
                (_newAssetStatus != 57) &&
                (_newAssetStatus != 58),
            "NPNC:MS: Specified Status is reserved."
        );
        require(
            (_newAssetStatus > 49),
            "NPNC:MS: Only custodial usertype can set status < 50"
        );
        require(
            (rec.assetStatus > 49),
            "NPNC:MS: Only custodial usertype can change status < 50"
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "NPNC:MS: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:MS: Asset is in ann unregistered, exported, or discarded status."
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev set **Record**.assetStatus to lost or stolen, with confirmation required.
     */
    function _setLostOrStolen(bytes32 _idxHash, uint8 _newAssetStatus)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NPNC:SLS: This contract not authorized for specified AC"
        );
        require((rec.assetClass != 0), "NPNC:SLS: Record does not exist");
        require(
            isLostOrStolen(_newAssetStatus) == 170,
            "NPNC:SLS: Must set to a lost or stolen status"
        );
        require(
            (_newAssetStatus > 49) && (rec.assetStatus > 49),
            "NPNC:SLS: Only custodial usertype can set or change status < 50"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:SLS: Transferred,exported,or discarded asset cannot be set to lost or stolen"
        );
        require(
            (rec.assetStatus != 50),
            "NPNC:SLS: Asset in locked escrow cannot be set to lost or stolen"
        );

        //^^^^^^^checks^^^^^^^^^
        rec.assetStatus = _newAssetStatus;
        //bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        STOR.setStolenOrLost(_idxHash, rec.assetStatus);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function _decCounter(bytes32 _idxHash, uint256 _decAmount)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint256)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NPNC:DC: This contract not authorized for specified AC"
        );
        require(_decAmount > 0, "NPNC:DC: cannot decrement by negative number");
        require((rec.assetClass != 0), "NPNC:DC: Record does not exist");
        require(
            isEscrow(rec.assetStatus) == 0,
            "NPNC:DC: Cannot modify asset in Escrow"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:DC: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.countDown > _decAmount) {
            rec.countDown = rec.countDown.sub(_decAmount);
        } else {
            rec.countDown = 0;
        }
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        return (rec.countDown);
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.Ipfs1 with confirmation
     */
    function _modIpfs1(bytes32 _idxHash, bytes32 _IpfsHash)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NPNC:MI1: This contract not authorized for specified AC"
        );
        require((rec.assetClass != 0), "NPNC:MI1: Record does not exist");
        require(rec.Ipfs1 != _IpfsHash, "NPNC:MI1: New data same as old");
        require(
            isEscrow(rec.assetStatus) == 0,
            "NPNC:MI1: Cannot modify asset in Escrow"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NPNC:MI1: Record in unregistered, exported, or discarded status"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }
}
