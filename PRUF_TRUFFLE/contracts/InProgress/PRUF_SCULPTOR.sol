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

/**-----------------------------------------------------------------
 *
 *
 * Rodin Protocol Specification V0.1
 *
 * the Rodin Protocol stores data in the following manner: The idxHash hashed is the (default) first storage location.
 * this will be passed to the writeData function with data (struct or string), which will write the
 * data to [idxhash][location]. The data, hashed, with its [location] k256(data, location) will be the new [location] used to
 * store the next piece of data. The final data in the series will contain only a hash of its own [location].
 *
 * in the case that the data to be written is a struct, the first element of the struct will be used as the hash seed k256(data.1st, location)
 *
 * (Other storage locations could be derived for each volatile and nonvolatile storage B32 (4 more in all))
 *
 *
 * 1. To retrieve the data, the idxHash and keccak256(idxHash) are given for the initial [idxHash] and [location].
 * 2. The data retrieved is hashed along with its [location], supplying the next location to retrieve data from.
 * 3. (2) is repeated until the data retrieved is a hash of the [location] it was retrieved from, signifying EOF.
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.7;

import "../Resources/PRUF_CORE.sol";

contract SCULPTOR is CORE {
    bytes32 public constant DAO_ROLE = keccak256("DAO_ROLE");

    mapping(bytes32 => mapping(bytes32 => string)) internal foundry; // idxHash=>location=>data
    mapping(bytes32 => mapping(bytes32 => Block)) internal quarry; // idxHash=>location=>data

    /**
     * Checks that contract holds token
     * @param _idxHash - idxHash of asset to compare to caller for authority
     */
    modifier isAssetHolder(bytes32 _idxHash) {
        uint256 tokenId = uint256(_idxHash);
        require( //require that user is authorized and token is held by contract
            (A_TKN.ownerOf(tokenId) == address(this)),
            "S:MOD-IAH: Asset !token holder"
        );
        _;
    }

    /**
     * @dev Verify caller holds Nodetoken of passed node
     * @param _idxHash - idxHash of asset to compare to caller for authority
     */
    modifier isNodeHolderForAsset(bytes32 _idxHash) {
        Record memory rec = getRecord(_idxHash);
        require(
            (NODE_TKN.ownerOf(rec.node) == _msgSender()),
            "S:MOD-INHFA: _msgSender() not authorized in Node"
        );
        _;
    }

    // /**
    //  * Function to naively write data -god mode
    //  * @dev Verify caller holds Nodetoken of passed node
    //  * @param _idxHash - idxHash of asset to write data for
    //  * @param _location - map key to write data to
    //  * @param _data - data to be written
    //  */
    // function writeData(
    //     bytes32 _idxHash,
    //     bytes32 _location,
    //     string calldata _data
    // ) external isAssetHolder(_idxHash) isNodeHolderForAsset(_idxHash) {
    //     foundry[_idxHash][_location] = _data;
    // }

    /** //!!!!!!!!!!!!!!!!!!!!!DO WE NEED THIS????!!!!!!!!!!!!!!!!!!
     * @dev Delete blocks for an asset, making its data inaccessible
     * @param _idxHash - idxHash of asset data to delete
     * @param _location - location of data to delete
     */
    function DAOdelete(bytes32 _idxHash, bytes32 _location) external {
        require(hasRole("DAO_ROLE", _msgSender()));
        //^^^^^^^Checks^^^^^^^^^

        delete foundry[_idxHash][_location];
        delete quarry[_idxHash][_location];
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * Function to write data
     * @dev Verify caller holds Nodetoken of passed node
     * @param _idxHash - idxHash of asset to write data for
     * @param _lastLocation - last map location that data was written to. (write location will be computed from this)
     *                      If this is the first chunk to write, set to k256(_idxHash)
     * @param _data - data to be written
     */
    function writeString(
        bytes32 _idxHash,
        bytes32 _lastLocation,
        string calldata _data
    ) external isAssetHolder(_idxHash) isNodeHolderForAsset(_idxHash) {
        //^^^^^^^Checks^^^^^^^^^

        bytes32 thisLocation;
        bytes32 hashedIdxHash = keccak256(abi.encodePacked(_idxHash)); //default starting location

        bytes32 hashedData = keccak256(
            abi.encodePacked(foundry[_idxHash][hashedIdxHash])
        ); //get the hash of the data stored at the default starting location

        if (hashedData == keccak256("")) {
            //if nothing is stored at the default location....
            require( //do we want to omit this check?
                _lastLocation == hashedIdxHash || _lastLocation == 0,
                "S:WS:Invalid first write location"
            );
            thisLocation = hashedIdxHash; //use the default starting location
        } else {
            thisLocation = keccak256(abi.encodePacked(_data, _lastLocation)); //THIS ORDER MATTERS IN WEB3!
            //get the new storage location derived from the stored data
        }
        foundry[_idxHash][thisLocation] = _data;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Read a string from the foundry
     * @param _idxHash - idxHash of asset to read
     * @param _location - location to read
     */
    function readString(bytes32 _idxHash, bytes32 _location)
        external
        view
        returns (string memory)
    {
        return (foundry[_idxHash][_location]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Delete the keyblock for an asset, making its data inaccessible
     * @param _idxHash - idxHash of asset data to delete
     */
    function deleteString(bytes32 _idxHash)
        external
        isAssetHolder(_idxHash)
        isNodeHolderForAsset(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^

        delete foundry[_idxHash][keccak256(abi.encodePacked(_idxHash))];
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * Stack saver for _writeBlock
     * @dev Verify caller holds Nodetoken of passed node
     * @param _idxHash - idxHash of asset to write data for
     * @param _lastLocation - last map location that data was written to. (write location will be computed from this)
     *                      If this is the first chunk to write, set to k256(_idxHash)
     * @param _block1 to 8 - data to be written
     */
    function writeBlock(
        bytes32 _idxHash,
        bytes32 _lastLocation,
        bytes32 _block1,
        bytes32 _block2,
        bytes32 _block3,
        bytes32 _block4,
        bytes32 _block5,
        bytes32 _block6,
        bytes32 _block7,
        bytes32 _block8
    ) external isAssetHolder(_idxHash) isNodeHolderForAsset(_idxHash) {
        //^^^^^^^Checks^^^^^^^^^

        Block memory data;
        data.block1 = _block1;
        data.block2 = _block2;
        data.block3 = _block3;
        data.block4 = _block4;
        data.block5 = _block5;
        data.block6 = _block6;
        data.block7 = _block7;
        data.block8 = _block8;
        //^^^^^^^effects^^^^^^^^^

        _writeBlock(_idxHash, _lastLocation, data);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * Function to write data
     * @dev Verify caller holds Nodetoken of passed node
     * @param _idxHash - idxHash of asset to write data for
     * @param _lastLocation - last map location that data was written to. (write location will be computed from this)
     *                      If this is the first chunk to write, set to k256(_idxHash)
     * @param _data - data to be written
     */
    function _writeBlock(
        bytes32 _idxHash,
        bytes32 _lastLocation,
        Block memory _data
    ) private {
        bytes32 thisLocation;
        bytes32 hashedIdxHash = keccak256(abi.encodePacked(_idxHash)); //default starting location

        bytes32 hashedData = keccak256(
            abi.encodePacked(quarry[_idxHash][hashedIdxHash].block1)
        ); //get the hash of the data stored at the default starting location

        if (hashedData == keccak256("")) {
            //if nothing is stored at the default location....
            require(
                _lastLocation == hashedIdxHash || _lastLocation == 0,
                "S:WB:Invalid first write location"
            );
            thisLocation = hashedIdxHash; //use the default starting location
        } else {
            thisLocation = keccak256(
                abi.encodePacked(_data.block1, _lastLocation)
            ); //THIS ORDER MATTERS IN WEB3!
            //get the new storage location derived from the stored data
        }
        quarry[_idxHash][thisLocation] = _data;
        //^^^^^^^effects^^^^^^^^^
    }

    /**
     * @dev Read a Block from the quarry
     * @param _idxHash - idxHash of asset to read
     * @param _location - location to read
     */
    function readBlock(bytes32 _idxHash, bytes32 _location)
        external
        view
        returns (Block memory)
    {
        return (quarry[_idxHash][_location]);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Delete the keyblock for an asset, making its data inaccessible
     * @param _idxHash - idxHash of asset data to delete
     */
    function deleteBlock(bytes32 _idxHash)
        external
        isAssetHolder(_idxHash)
        isNodeHolderForAsset(_idxHash)
    {
        //^^^^^^^checks^^^^^^^^^

        delete quarry[_idxHash][keccak256(abi.encodePacked(_idxHash))];
        //^^^^^^^effects^^^^^^^^^
    }
}
