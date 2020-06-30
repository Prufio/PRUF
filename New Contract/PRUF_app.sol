// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.7;

import "./PRUF_interfaces.sol";
import "./Imports/PullPayment.sol";
import "./Imports/ReentrancyGuard.sol";
import "./_ERC721/IERC721Receiver.sol";
import "./PRUF_core.sol";

contract PRUF_APP is
    ReentrancyGuard,
    PullPayment,
    Ownable,
    IERC721Receiver,
    PRUF
{
    using SafeMath for uint256;

    // --------------------------------------Events--------------------------------------------//

    // event REPORT(string _msg);

    // --------------------------------------Modifiers--------------------------------------------//

    /*
     * @dev Wrapper for newRecord
     */
    function $newRecord(
        bytes32 _idxHash,
        bytes32 _rgtHash,
        uint16 _assetClass,
        uint256 _countDownStart,
        bytes32 _Ipfs
    ) external payable nonReentrant isAuthorized(_idxHash) {
        User memory callingUser = getUser();
        Costs memory cost = getCost(_assetClass);
        Costs memory baseCost = getBaseCost();

        require(
            callingUser.userType < 5,
            "NR: User not authorized to create records"
        );
        require(
            callingUser.authorizedAssetClass == _assetClass,
            "NR: User not authorized to create records in specified asset class"
        );
        require(_rgtHash != 0, "NR: rights holder cannot be zero");
        require(
            msg.value >= cost.newRecordCost,
            "NR: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        bytes32 userHash = keccak256(abi.encodePacked(msg.sender));
        //^^^^^^^effects^^^^^^^^^

        Storage.newRecord(
            userHash,
            _idxHash,
            _rgtHash,
            _assetClass,
            _countDownStart,
            _Ipfs
        );
        deductPayment(
            baseCost.paymentAddress,
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /*
     * @dev Modify **Record**.rightsHolder without confirmation required
     */
    function $forceModRecord(bytes32 _idxHash, bytes32 _rgtHash)
        external
        payable
        nonReentrant
        isAuthorized(_idxHash)
        returns (uint8)
    {
        Record memory rec = getRecord(_idxHash);
        User memory callingUser = getUser();
        Costs memory cost = getCost(rec.assetClass);
        Costs memory baseCost = getBaseCost();

        require((rec.rightsHolder != 0), "FMR: Record does not exist");

        require(
            callingUser.userType == 1,
            "FMR: User not authorized to force modify records"
        );
        require(
            callingUser.authorizedAssetClass == rec.assetClass,
            "FMR: User not authorized to modify records in specified asset class"
        );

        require(_rgtHash != 0, "FMR: rights holder cannot be zero");
        require(
            (rec.assetStatus != 3) &&
                (rec.assetStatus != 4) &&
                (rec.assetStatus != 53) &&
                (rec.assetStatus != 54),
            "FMR: Cannot modify asset in lost or stolen status"
        );
        require(
            (rec.assetStatus != 6) &&
                (rec.assetStatus != 50) &&
                (rec.assetStatus != 56),
            "FMR: Cannot modify asset in Escrow"
        );
        require(
            (rec.assetStatus != 5) && (rec.assetStatus != 55),
            "DC: Record In Transferred-unregistered status"
        );
        require(rec.assetStatus < 200, "FMR: Record locked");
        require(
            msg.value >= cost.forceModifyCost,
            "FMR: tx value too low. Send more eth."
        );
        //^^^^^^^checks^^^^^^^^^

        if (rec.forceModCount < 255) {
            rec.forceModCount++;
        }

        if (rec.numberOfTransfers < 65335) {
            rec.numberOfTransfers++;
        }

        rec.assetStatus = 0;
        rec.rightsHolder = _rgtHash;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);

        deductPayment(
            baseCost.paymentAddress,
            baseCost.newRecordCost,
            cost.paymentAddress,
            cost.newRecordCost
        );

        return rec.forceModCount;
        //^^^^^^^interactions^^^^^^^^^
    }
}
