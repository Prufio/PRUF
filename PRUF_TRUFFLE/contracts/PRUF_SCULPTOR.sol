/*--------------------------------------------------------PRüF0.8.6
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

/**-----------------------------------------------------------------
 * TODO: Implement security requiring the token and node to be held to write data, as well as reverting????? no?
 * if data already exists. Implement struct writing instead of strings. Alternative protocols are possible.
 *
 *
 * Sculptor Specification V0.1
 * Sculptor stores data in the following manner: The idxHash hashed is the (default) first storage location.
 * this will be passed to the writeData function with data (struct or string), which will write the
 * data to [idxhash][location]. The data, hashed, with its [location] will be the new [location] used to
 * store the next piece of data. The final data in the series will contain only a hash of its own [location].
 *
 * (Other storage locations could be derived for each volatile and nonvolatile storage B32 (4 more in all))
 *
 *
 * 1. To retrieve the data, the idxHash and keccak256(idxHash) are given for the initial [idxHash] and [location].
 * 2. The data retrieved is hashed along with its [location], supplying the next location to retrieve data from.
 * 3. (2) is repeated until the data retrieved is a hash of the [location] it was retrieved from, signifying EOF.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.6;

import "./PRUF_CORE.sol";

contract SCULPTOR is CORE {
    mapping(bytes32 => mapping(bytes32 => string)) internal quarry; // name=>node=>authorization level

    function writeData(
        bytes32 _idxHash,
        bytes32 _location,
        string calldata _data
    ) external {
        //!!!!!!!!!!!!!!!!!!!!!!!!!require holds the node and token!!!!!!!!!!!!!!!!!!!!!!!!!!!
        quarry[_idxHash][_location] = _data;
    }

    function writeDataEnforced( //enforced protocol
        bytes32 _idxHash,
        bytes32 _lastLocation,
        string calldata _data
    ) external {
        //!!!!!!!!!!!!!!!!!!!!!!!!!require holds the node and token!!!!!!!!!!!!!!!!!!!!!!!!!!!
        bytes32 thisLocation;
        bytes32 hashedIdxHash = keccak256(abi.encodePacked(_idxHash)); //default starting location

        bytes32 hashedData = keccak256(
            abi.encodePacked(quarry[_idxHash][hashedIdxHash])
        ); //get the hash of the data stored at the default starting location

        if (hashedData == keccak256("")) {
            //if nothing is stored at the default location....
            thisLocation = hashedIdxHash; //use the default starting location
        } else {
            thisLocation = keccak256(abi.encodePacked(_lastLocation, _data));
            //get the new storage location derived from the stored data
        }
        quarry[_idxHash][thisLocation] = _data;
    }

    function getData(bytes32 _idxHash, bytes32 _location)
        external
        view
        returns (string memory)
    {
        return (quarry[_idxHash][_location]);
    }

    function deleteData(bytes32 _idxHash, bytes32 _location) external {
        //!!!!!!!!!!!!!!!!!!!!!!!!!require holds the node!!!!!!!!!!!!!!!!!!!!!!!!!!!
        delete quarry[_idxHash][_location];
    }
}
