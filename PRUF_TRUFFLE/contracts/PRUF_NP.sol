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

contract NP is CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == APP_Address),
            "NP:MOD-IA: Custodial contract does not hold token"
        );
        _;
    }

    //--------------------------------------------External Functions--------------------------

    /*
     * @dev Modify **Record**.assetStatus with confirmation required
     */
    function _modStatus(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NP:MS: This contract not authorized for specified AC"
        );
        require(
            (userType > 0) && (userType < 10),
            "NP:MS: User not authorized to modify records in specified asset class"
        );

        require(
            isLostOrStolen(_newAssetStatus) == 0,
            "NP:MS: Cannot place asset in lost or stolen status using modStatus"
        );
        require(
            isEscrow(_newAssetStatus) == 0,
            "NP:MS: Cannot place asset in Escrow using modStatus"
        );
        require(
            needsImport(_newAssetStatus) == 0,
            "NP:MS: Cannot place asset in unregistered, exported, or discarded status using modStatus"
        );
        require(
            (_newAssetStatus < 100) &&
                (_newAssetStatus != 7) &&
                (_newAssetStatus != 57) &&
                (_newAssetStatus != 58),
            "NP:MS: Specified Status is reserved."
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "NP:MS: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NP:MS: Record in unregistered, exported, or discarded status"
        );
        require(
            (rec.assetStatus > 49) || (userType < 5),
            "NP:MS: Only usertype < 5 can change status < 49"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:MS: Rightsholder does not match supplied data"
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
    function _setLostOrStolen(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint8 _newAssetStatus
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NP:SLS: This contract not authorized for specified AC"
        );
        require(
            (rec.rightsHolder != 0),
            "NP:SLS: Record unclaimed: import required. "
        );
        require(
            (userType > 0) && (userType < 10),
            "NP:SLS: User not authorized to modify records in specified asset class"
        );
        require(
            isLostOrStolen(_newAssetStatus) == 170,
            "NP:SLS: Must set to a lost or stolen status"
        );
        require(
            (rec.assetStatus > 49) ||
                ((_newAssetStatus < 50) && (userType < 5)),
            "NP:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "NP:SLS: Transferred asset cannot be set to lost or stolen after transfer."
        );
        require(
            (rec.assetStatus != 50),
            "NP:SLS: Asset in locked escrow cannot be set to lost or stolen"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:SLS: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.assetStatus = _newAssetStatus;
        //^^^^^^^effects^^^^^^^^^

        STOR.setStolenOrLost(_idxHash, rec.assetStatus);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Decrement **Record**.countdown with confirmation required
     */
    function _decCounter(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint256 _decAmount
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint256)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NP:DC: This contract not authorized for specified AC"
        );

        require(
            (rec.rightsHolder != 0),
            "NP:DC: Record unclaimed: import required. "
        );
        require(
            (userType > 0) && (userType < 10),
            "NP:DC: User not authorized to modify records in specified asset class"
        );
        require(
            isEscrow(rec.assetStatus) == 0,
            "NP:DC: Cannot modify asset in Escrow"
        );
        require(_decAmount > 0, "NP:DC: cannot decrement by negative number");

        require(
            needsImport(rec.assetStatus) == 0,
            "NP:DC Record in unregistered, exported, or discarded status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:DC: Rightsholder does not match supplied data"
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
    function _modIpfs1(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        bytes32 _IpfsHash
    )
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (bytes32)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );

        require(
            contractInfo.contractType > 0,
            "NP:MI1: This contract not authorized for specified AC"
        );
        require(
            (rec.rightsHolder != 0),
            "NP:MI1: Record unclaimed: import required. "
        );
        require(
            (userType > 0) && (userType < 10),
            "NP:MI1: User not authorized to modify records in specified asset class"
        );
        require(rec.Ipfs1 != _IpfsHash, "NP:MI1: New data same as old");
        
        require(
            isEscrow(rec.assetStatus) == 0,
           "NP:MI1: Cannot modify asset in Escrow"
        );
        require(
            needsImport(rec.assetStatus) == 0,
            "NP:MI1: Record in unregistered, exported, or discarded status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "NP:MI1: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     *     @dev Export FROM Custodial:
     */
    function exportAsset(bytes32 _idxHash, address _addr)
        external
        nonReentrant
        whenNotPaused
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        uint8 userType = getUserType(rec.assetClass);
        ContractDataHash memory contractInfo = getContractInfo(
            address(this),
            rec.assetClass
        );
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            contractInfo.contractType > 0,
            "A:MS: This contract not authorized for specified AC"
        );
        require(
            (userType > 0) && (userType < 10),
            "A:EA: User not authorized to modify records in specified asset class"
        );
        require( // require transferrable (51) status
            rec.assetStatus == 51,
            "A:EA: Asset status must be 51 to export"
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }
        rec.assetStatus = 70; // Set status to 70 (exported)
        //^^^^^^^effects^^^^^^^^^

        APP.OO_TX_asset_Token(_addr, _idxHash);
        writeRecord(_idxHash, rec);
        STOR.changeAC(_idxHash, AC_info.assetClassRoot);

        return rec.assetStatus;
        //^^^^^^^interactions^^^^^^^^^
    }
}
