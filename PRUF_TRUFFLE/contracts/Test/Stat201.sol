/*--------------------------------------------------------PRüF0.8.7
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
 *  TO DO
 * Sets asset status to 201 in the case that a storage provider becomes invalid, 
 * to proviion for the rescuing of assets whose storage provider is no longer valid
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";

contract STAT201 is CORE {


    /**
     * @dev //Sets an item to reserved status 201 when called, if record links to an invalid storage type. Stat201 allows a rewrite of NonMutableStorage
     * @param _idxHash asset ID of the asset being rescued 
     */
    function set201(bytes32 _idxHash)
        external
        nonReentrant
        whenNotPaused
        isContractAdmin
    {
        Record memory rec = getRecord(_idxHash);
        Node memory node_info =getNodeinfo(rec.node);
        uint256 storageProviderStatus = NODE_STOR.getStorageProviderStatus(node_info.storageProvider);

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
