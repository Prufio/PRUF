pragma solidity ^0.6.0;
 
 import "./BulletProof_0_1_2.sol";
 
 contract Wrapper is BulletProof {
    /**
     * @dev Wrapper for create new record
     */
     
    function NEW_RECORD (uint256 idx, string calldata reg, uint8 stat) external {
        newRecord(idx, keccak256(abi.encodePacked(reg)), stat);
    }

    /**
     * @dev Wrapper for comparing records
     */
     
    function COMPARE_REGISTRANT (uint256 idx, string calldata reg) external view returns(string memory) {
         
        if (keccak256(abi.encodePacked(reg)) == database[idx].registrant){
            return "Registrant match confirmed";
        } else {
            return "Registrant does not match";
        }
    }

    /**
     * @dev Wrapper for force changing record status
     */
    
    function FORCE_MOD_STATUS(uint idx, uint8 stat) external {
        forceModifyStatus(idx,stat);
    }
    
    /**
     * @dev Wrapper for force changing the record without tests
     */
     
    function FORCE_MOD_REGISTRANT (uint256 idx, string calldata reg) external {
        modifyRegistrant(idx, keccak256(abi.encodePacked(reg)));
    }
    
    
    /**
     * @dev Wrapper for changing record status with tests
     */
    
    function MOD_STATUS(uint idx, string calldata regstrnt, uint8 stat) external {
        modifyStatus(idx,keccak256(abi.encodePacked(regstrnt)),stat);
    }

    /**
     * @dev Wrapper for Asset transfer with tests
     */
    
    function TRANSFER_ASSET (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public {
        transferAsset(idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat);
     }


     /**
     * @dev Wrapper for automated Asset transfer with tests
     */

    function PRIVATE_SALE (uint256 idx, string memory oldreg, string memory newreg, uint8 newstat) public {
        robotTransferAsset(idx, keccak256(abi.encodePacked(oldreg)), keccak256(abi.encodePacked(newreg)),newstat);
     }
}