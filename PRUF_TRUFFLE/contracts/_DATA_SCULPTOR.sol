// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;

import "./Imports/access/AccessControl.sol";
import "./PRUF_BASIC.sol";

/**
 * @dev {ERC721} token, including:
 * This contract uses {AccessControl} to lock permissioned functions using the
 * different roles - head to its documentation for details.
 *
 * The account that deploys the contract will be granted the minter and pauser
 * roles, as well as the default admin role, which will let it grant both minter
 * and pauser roles to other accounts.
 */
contract SCULPTOR is AccessControl, BASIC{

    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }

    /*
     * @dev Verify user credentials
     * Originating Address:
     *      holds asset token at idxHash
     */

    modifier isAuthorized(bytes32 _idxHash) override {
        uint256 tokenId = uint256(_idxHash);
        require(
            (A_TKN.ownerOf(tokenId) == _msgSender()), //_msgSender() is token holder
            "NPNC:MOD-IA: Caller does not hold token"
        );
        _;
    }

    // /*
    //  * @dev Verify caller holds ACtoken of passed node
    //  */
    // modifier isACtokenHolderOfClass(uint32 _node) {
    //     require(
    //         (NODE_TKN.ownerOf(_node) == _msgSender()),
    //         "ACM:MOD-IACTHoC:_msgSender() not authorized in node"
    //     );
    //     _;
    // }

    /*
     * @dev Creates a contract for a new artifact for A_token(unit256(idxHash))
     * caller must hod the asset token and the node token
     */
    function createArtiifact(bytes32 _idxHash) external isAuthorized(_idxHash) {
        Record memory rec = getRecord( _idxHash);
        require(
            (NODE_TKN.ownerOf(rec.node) == _msgSender()),
            "ACM:MOD-IACTHoC:_msgSender() not authorized in node"
        );

        /*  create a new contract for the arifiact
        *   map the address to the artifact's asset token (set the token NonMutableStorage to contract address of artifact)
        *       
        *   artifact has structure:
        *       key 0 : EOF key number (5 in this case)
        *       key 1 : NonMutableStorage reference (IPFS file to reference - should ideally be the same hex file, less keys 0,1,and X))
        *       key 2 : start of Data
        *       key 3 : Data
        *       key 4 : end of Data
        *       key 5 : 0xFFF....  EOF (arbitrarily high key)
        *       key 6 : 0x0000... not set (arbitrarily high key + 1)
        *   

        */

        


    } 
}

contract ARTIFACT is AccessControl, BASIC{
    /**
     * @dev Grants `DEFAULT_ADMIN_ROLE`, `MINTER_ROLE` and `PAUSER_ROLE` to the
     * account that deploys the contract.
     *
     * Token URIs will be autogenerated based on `baseURI` and their token IDs.
     * See {ERC721-tokenURI}.
     */
    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(CONTRACT_ADMIN_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
    }
}
