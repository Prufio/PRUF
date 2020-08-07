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
pragma solidity ^0.6.7;

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
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54),
            "NPNC:CR: Cannot modify asset in lost or stolen status"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "NPNC:CR: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "NPNC:CR: Cannot modify asset in transferred-unregistered status"
        );
        require(
            (rec.assetStatus != 60),
            "NPNC:CR: Record is burned and must be reimported by ACadmin"
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
            "NPNC:MS: Specified Status is reserved."
        );
        require(
            _newAssetStatus != 70,
            "NPNC:MS: Use exportNC to export custodial assets"
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
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "NPNC:MS: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55) && (rec.assetStatus != 70),
            "NPNC:MS: Cannot change status of asset in transferred or exported status."
        );
        require(
            (rec.assetStatus != 60),
            "NPNC:MS: Record is burned and must be reimported by ACadmin"
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
            (_newAssetStatus == 3) ||
                (_newAssetStatus == 4) ||
                (_newAssetStatus == 53) ||
                (_newAssetStatus == 54),
            "NPNC:SLS: Must set to a lost or stolen status"
        );
        require(
            (_newAssetStatus > 49),
            "NPNC:SLS: Only custodial usertype can set status < 50"
        );
        require(
            (rec.assetStatus > 49) || (_newAssetStatus < 50),
            "NPNC:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "NPNC:SLS: Transferred asset cannot be set to lost or stolen after transfer."
        );
        require(
            (rec.assetStatus != 50),
            "NPNC:SLS: Asset in locked escrow cannot be set to lost or stolen"
        );
        require(
            (rec.assetStatus != 60),
            "NPNC:SLS: Record is burned and must be reimported by ACadmin"
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
        require( //------------------------------------------should the counter still work when an asset is in escrow?
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //If so, it must not erase the recorder, or escrow termination will be broken!
            "NPNC:DC: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "NPNC:DC: Record In Transferred-unregistered status"
        );
        require(
            (rec.assetStatus != 60),
            "NPNC:DC: Record is burned and must be reimported by ACadmin"
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
        require( //-------------------------------------Should an asset in escrow be modifiable?
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //Should it be contingent on the original recorder address?
            "NPNC:MI1: Cannot modify asset in Escrow" //If so, it must not erase the recorder, or escrow termination will be broken!
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "NPNC:MI1: Record In Transferred-unregistered status"
        );
        require(
            (rec.assetStatus != 60),
            "NPNC:MI1: Record is burned and must be reimported by ACadmin"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }
}
