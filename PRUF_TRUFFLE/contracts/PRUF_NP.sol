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

contract NP is CORE {
    /*
     * @dev Verify user credentials
     * Originating Address:
     */
    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenID = uint256(_idxHash);
        require(
            (AssetTokenContract.ownerOf(tokenID) == PrufAppAddress),
            "PNP:IA: Custodial contract does not hold token"
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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PNP:MS: Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "PNP:MS: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "PNP:MS: User not authorized to modify records in specified asset class"
        );
        require(_newAssetStatus < 100, "PNP:MS: user cannot set status > 99");
        require(
            _newAssetStatus != 70,
            "PNP:MS: Use pruf_app.exportAsset to export custodial assets"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "PNP:MS: Cannot change status of asset in Escrow until escrow is expired"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PNP:MS: Cannot change status of asset in transferred-unregistered status."
        );
        require(
            (rec.assetStatus > 49) || (userType < 5),
            "PNP:MS: Only usertype < 5 can change status < 49"
        );
        require(rec.assetStatus < 200, "PNP:MS: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "PNP:MS: Rightsholder does not match supplied data"
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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PNP:SLS: Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "PNP:SLS: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "PNP:SLS: User not authorized to modify records in specified asset class"
        );
        require(
            (_newAssetStatus == 3) ||
                (_newAssetStatus == 4) ||
                (_newAssetStatus == 53) ||
                (_newAssetStatus == 54),
            "PNP:SLS: Must set to a lost or stolen status"
        );
        require(
            (rec.assetStatus > 49) ||
                ((_newAssetStatus < 50) && (userType < 5)),
            "PNP:SLS: Only usertype <5 can change a <49 status asset to a >49 status"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PNP:SLS: Transferred asset cannot be set to lost or stolen after transfer."
        );
        require(
            (rec.assetStatus != 50),
            "PNP:SLS: Asset in locked escrow cannot be set to lost or stolen"
        );
        require(rec.assetStatus < 200, "PNP:SLS: Record locked");
        require(
            rec.rightsHolder == _rgtHash,
            "PNP:SLS: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^
        rec.assetStatus = _newAssetStatus;
        //bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        Storage.setStolenOrLost(_idxHash, rec.assetStatus);

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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PNP:DC: Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "PNP:DC: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "PNP:DC: User not authorized to modify records in specified asset class"
        );
        require( //------------------------------------------should the counter still work when an asset is in escrow?
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //If so, it must not erase the recorder, or escrow termination will be broken!
            "PNP:DC: Cannot modify asset in Escrow"
        );
        require(_decAmount > 0, "PNP:DC: cannot decrement by negative number");
        require(rec.assetStatus < 200, "PNP:DC: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PNP:DC: Record In Transferred-unregistered status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "PNP:DC: Rightsholder does not match supplied data"
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
        AC memory AC_info = getACinfo(rec.assetClass);

        require(
            AC_info.custodyType == 1,
            "PNP:MI1 Contract not authorized for non-custodial assets"
        );

        require((rec.rightsHolder != 0), "PNP:MI1: Record does not exist");
        require(
            (userType > 0) && (userType < 10),
            "PNP:MI1: User not authorized to modify records in specified asset class"
        );

        require(rec.Ipfs1 != _IpfsHash, "PNP:MI1: New data same as old");
        require( //-------------------------------------Should an asset in escrow be modifiable?
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56), //Should it be contingent on the original recorder address?
            "PNP:MI1: Cannot modify asset in Escrow" //If so, it must not erase the recorder, or escrow termination will be broken!
        );
        require(rec.assetStatus < 200, "PNP:MI1: Record locked");
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "PNP:MI1: Record In Transferred-unregistered status"
        );
        require(
            rec.rightsHolder == _rgtHash,
            "PNP:MI1: Rightsholder does not match supplied data"
        );
        //^^^^^^^checks^^^^^^^^^

        rec.Ipfs1 = _IpfsHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecordIpfs1(_idxHash, rec);

        return rec.Ipfs1;
        //^^^^^^^interactions^^^^^^^^^
    }
}
