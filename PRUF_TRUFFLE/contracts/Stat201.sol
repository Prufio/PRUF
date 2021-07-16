/*--------------------------------------------------------PRüF0.8.0
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
 *  TO DO DPS:CHECK this requires this contract to be an authorized 1 in storage.
 *
 *---------------------------------------------------------------*/

 //CTS:EXAMINE quick explainer for the contract

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./PRUF_CORE.sol";

contract STAT201 is CORE {


    /*
     * @dev //Sets an item to reserved status 201 when called, if record links to an invalid storage type. Stat201 allows a rewrite of IPFS2
     * //CTS:EXAMINE param
     */
    function set201(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        isContractAdmin
    {
        Record memory rec = getRecord(_idxHash);
        AC memory AC_info = getACinfo(rec.assetClass);
        uint256 storageProviderStatus = AC_MGR.getStorageProviderStatus(AC_info.storageProvider);

        require
            (storageProviderStatus == 0,
            "S201:201: Record must have an invalid storage type to set stat 201"
        );
        //^^^^^^^checks^^^^^^^^^
        rec.assetStatus = 201;
        //^^^^^^^effects^^^^^^^^^

        writeRecord(_idxHash, rec);
        //^^^^^^^interactions^^^^^^^^^
        
    }


}
