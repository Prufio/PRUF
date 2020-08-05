/*-----------------------------------------------------------V0.6.7
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
pragma solidity ^0.7.0;

import "./PRUF_CORE.sol";

contract NP_NC is CORE {
    using SafeMath for uint256;
    using SafeMath for uint8;

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenID) == msg.sender), //msg.sender is token holder
            "TPNP:IA: Caller does not hold token"
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
            "PNP:MS: Contract not authorized for this asset class"
        );

        require((rec.rightsHolder != 0), "PA:FMR: Record does not exist");

        require(_newRgtHash != 0, "TPNP:CR: rights holder cannot be zero");

        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54),
            "TPNP:CR: Cannot modify asset in lost or stolen status"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "TPNP:CR: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "TPNP:CR: Cannot modify asset in transferred-unregistered status"
        );
        require(
            (rec.assetStatus != 60),
            "TPNP:CR: Record is burned and must be reimported by ACadmin"
        );
        require(rec.assetStatus < 200, "TPNP:CR: Record locked");
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
            contractInfo.contractType > 0,
            "TPNP:EX: Contract not authorized for this asset class"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "TPNP:EX: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "TPNP:EX: Cannot change status of asset in transferred-unregistered status."
        );
        require(
            (rec.assetStatus != 60),
            "TPNP:EX: Record is burned and must be reimported by ACadmin"
        );
        require(rec.assetStatus < 200, "TPNP:EX: Record locked");

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
            "PNP:MS: Contract not authorized for this asset class"
        );

        require((rec.rightsHolder != 0), "TPNP:MS: Record does not exist");

        require(
            (_newAssetStatus < 100) &&
                (_newAssetStatus != 3) &&
                (_newAssetStatus != 4) &&
                (_newAssetStatus != 5) &&
                (_newAssetStatus != 6) &&
                (_newAssetStatus != 7) &&
                (_newAssetStatus != 50) &&
                (_newAssetStatus != 53) &&
                (_newAssetStatus != 54) &&
                (_newAssetStatus != 55) &&
                (_newAssetStatus != 56) &&
                (_newAssetStatus != 57) &&
                (_newAssetStatus != 58),
            "PNP:MS: Specified Status is reserved."
        );
        require(
            _newAssetStatus != 70,
            "PNP:MS: Use exportNC to export custodial assets"
        );
        require(
            (_newAssetStatus > 49),
            "TPNP:MS: Only custodial usertype can set status < 50"
        );

        require(
            (rec.assetStatus > 49),
            "TPNP:MS: Only custodial usertype can change status < 50"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "TPNP:MS: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "TPNP:MS: Cannot change status of asset in transferred-unregistered status."
        );
        require(
            (rec.assetStatus != 60),
            "TPNP:MS: Record is burned and must be reimported by ACadmin"
        );
        require(rec.assetStatus < 200, "TPNP:MS: Record locked");
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
            "PNP:MS: Contract not authorized for this asset class"
        );

        require((rec.rightsHolder != 0), "TPNP:SLS: Record does not exist");
        require(
            (_newAssetStatus == 3) ||
                (_newAssetStatus == 4) ||
                (_newAssetStatus == 53) ||
                (_newAssetStatus == 54),
            "TPNP:SLS: Must set to a lost or stolen status"
        );
        require(
            (_newAssetStatus > 49),
            "TPNP:SLS: Only custodial usertype can set status < 50"
        );
        require(
            (rec.assetStatus > 49) || (_newAssetStatus < 50),
            "TPNP:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        );

        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "TPNP:SLS: Transferred asset cannot be set to lost or stolen after transfer."
        );
        require(
            (rec.assetStatus != 50),
            "TPNP:SLS: Asset in locked escrow cannot be set to lost or stolen"
        );
        require(
            (rec.assetStatus != 60),
            "TPNP:SLS: Record is burned and must be reimported by ACadmin"
        );
        require(rec.assetStatus < 200, "TPNP:SLS: Record locked");

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
            "PNP:MS: Contract not authorized for this asset class"
        );
        require(_decAmount > 0, "TPNP:DC: cannot decrement by negative number");

        require((rec.rightsHolder != 0), "TPNP:DC: Record does not exist");
        require( //------------------------------------------should the counter still work when an asset is in escrow?
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //If so, it must not erase the recorder, or escrow termination will be broken!
            "TPNP:DC: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "TPNP:DC: Record In Transferred-unregistered status"
        );
        require(
            (rec.assetStatus != 60),
            "TPNP:DC: Record is burned and must be reimported by ACadmin"
        );
        require(rec.assetStatus < 200, "TPNP:DC: Record locked");
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
            "PNP:MS: Contract not authorized for this asset class"
        );

        require((rec.rightsHolder != 0), "TPNP:MI1: Record does not exist");

        require(rec.Ipfs1 != _IpfsHash, "TPNP:MI1: New data same as old");
        require( //-------------------------------------Should an asset in escrow be modifiable?
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //Should it be contingent on the original recorder address?
            "TPNP:MI1: Cannot modify asset in Escrow" //If so, it must not erase the recorder, or escrow termination will be broken!
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "TPNP:MI1: Record In Transferred-unregistered status"
        );
        require(
            (rec.assetStatus != 60),
            "TPNP:MI1: Record is burned and must be reimported by ACadmin"
        );
        require(rec.assetStatus < 200, "TPNP:MI1: Record locked");
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }
}
