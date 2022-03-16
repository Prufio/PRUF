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
 * DAO Specification V0.01
 * DAO THUNK LAYER - (ONE OF MANY)
 * //DPS:TEST MAJOR REVISIONS - added calls to DAO
 *---------------------------------------------------------------*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.7;

import "../Resources/PRUF_CORE.sol";
import "../Resources/RESOURCE_PRUF_EXT_INTERFACES.sol";
import "../Resources/RESOURCE_PRUF_DAO_INTERFACES.sol";

contract DAO_LAYER_B is BASIC {

    address internal DAO_CORE_Address;
    DAO_CORE_Interface internal DAO_CORE;

    address internal CLOCK_Address;
    CLOCK_Interface internal CLOCK;

    /**
     * @dev Resolve contract addresses from STOR
     */
    function resolveContractAddresses()
        external
        override
        nonReentrant
        isContractAdmin
    {
        //^^^^^^^checks^^^^^^^^^

        NODE_TKN_Address = STOR.resolveContractAddress("NODE_TKN");
        NODE_TKN = NODE_TKN_Interface(NODE_TKN_Address);

        // NODE_MGR_Address = STOR.resolveContractAddress("NODE_MGR");
        // NODE_MGR = NODE_MGR_Interface(NODE_MGR_Address);

        // NODE_STOR_Address = STOR.resolveContractAddress("NODE_STOR");
        // NODE_STOR = NODE_STOR_Interface(NODE_STOR_Address);

        // UTIL_TKN_Address = STOR.resolveContractAddress("UTIL_TKN");
        // UTIL_TKN = UTIL_TKN_Interface(UTIL_TKN_Address);

        // A_TKN_Address = STOR.resolveContractAddress("A_TKN");
        // A_TKN = A_TKN_Interface(A_TKN_Address);

        // ECR_MGR_Address = STOR.resolveContractAddress("ECR_MGR");
        // ECR_MGR = ECR_MGR_Interface(ECR_MGR_Address);

        // APP_Address = STOR.resolveContractAddress("APP");
        // APP = APP_Interface(APP_Address);

        // RCLR_Address = STOR.resolveContractAddress("RCLR");
        // RCLR = RCLR_Interface(RCLR_Address);

        // APP_NC_Address = STOR.resolveContractAddress("APP_NC");
        // APP_NC = APP_NC_Interface(APP_NC_Address);

       DAO_CORE_Address = STOR.resolveContractAddress("DAO_CORE");
        DAO_CORE = DAO_CORE_Interface(DAO_CORE_Address);

        CLOCK_Address = STOR.resolveContractAddress("CLOCK");
        CLOCK = CLOCK_Interface(CLOCK_Address);
    }

    //---------------------------------NODE_TKN

    /**
     * @dev Set storage contract to interface with
     * @param _nodeStorageAddress - Node storage contract address
     */
    function DAO_setNodeStorageContract(address _nodeStorageAddress)
        external
        
        nonReentrant
    {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setNodeStorageContract",
                address(this),
                _nodeStorageAddress
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        NODE_TKN.setNodeStorageContract(_nodeStorageAddress);
        //^^^^^^^Interactions^^^^^^^^^
    }

    //---------------------------------UD_721

    /**
     * @dev Set address of STOR contract to interface with
     * @param _erc721Address address of token contract to interface with
     * @param _UD_721ContractAddress address of UD_721 contract
     */
    function DAO_setUnstoppableDomainsTokenContract(
        address _erc721Address,
        address _UD_721ContractAddress
    ) external virtual  nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setUnstoppableDomainsTokenContract",
                address(this),
                _erc721Address,
                _UD_721ContractAddress
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        UD_721_Interface(_UD_721ContractAddress)
            .setUnstoppableDomainsTokenContract(_erc721Address);
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------EO_STAKING

    /**
     * @dev Setter for setting fractions of a day for minimum interval
     * @param _minUpgradeInterval in seconds
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_setMinimumPeriod(
        uint256 _minUpgradeInterval,
        address _EO_STAKING_Address
    ) external  nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setMinimumPeriod",
                address(this),
                _minUpgradeInterval,
                _EO_STAKING_Address
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        EO_STAKING_Interface(_EO_STAKING_Address).setMinimumPeriod(
            _minUpgradeInterval
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Kill switch for staking reward earning
     * @param _delay delay in seconds to end stake earning
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_endStaking(uint256 _delay, address _EO_STAKING_Address)
        external
        
        nonReentrant
    {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_endStaking",
                address(this),
                _delay,
                _EO_STAKING_Address
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        EO_STAKING_Interface(_EO_STAKING_Address).endStaking(_delay);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN(PRUF)
     * @param _stakeAddress address of STAKE_TKN
     * @param _stakeVaultAddress address of STAKE_VAULT
     * @param _rewardsVaultAddress address of REWARDS_VAULT
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_setTokenContractsEO(
        address _utilAddress,
        address _stakeAddress,
        address _stakeVaultAddress,
        address _rewardsVaultAddress,
        address _EO_STAKING_Address
    ) external  nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_endStaking",
                address(this),
                _utilAddress,
                _stakeAddress,
                _stakeVaultAddress,
                _rewardsVaultAddress,
                _EO_STAKING_Address
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        EO_STAKING_Interface(_EO_STAKING_Address).setTokenContracts(
            _utilAddress,
            _stakeAddress,
            _stakeVaultAddress,
            _rewardsVaultAddress
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Set stake tier parameters
     * @param _stakeTier Staking level to set
     * @param _min Minumum stake
     * @param _max Maximum stake
     * @param _interval staking interval, in dayUnits - set to the number of days that the stake and reward interval will be based on.
     * @param _bonusPercentage bonusPercentage in tenths of a percent: 15 = 1.5% or 15/1000 per interval. Calculated to a fixed amount of tokens in the actual stake
     * @param _EO_STAKING_Address address of EO_STAKING contract
     */
    function DAO_setStakeLevels(
        uint256 _stakeTier,
        uint256 _min,
        uint256 _max,
        uint256 _interval,
        uint256 _bonusPercentage,
        address _EO_STAKING_Address
    ) external  nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setStakeLevels",
                address(this),
                _stakeTier,
                _min,
                _max,
                _interval,
                _bonusPercentage,
                _EO_STAKING_Address
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        EO_STAKING_Interface(_EO_STAKING_Address).setStakeLevels(
            _stakeTier,
            _min,
            _max,
            _interval,
            _bonusPercentage
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------REWARDS_VAULT and STAKE_VAULT //DPS:TEST works for both?

    /**
     * @dev Set address of contracts to interface with
     * @param _utilAddress address of UTIL_TKN
     * @param _stakeAddress address of STAKE_TKN
     * @param vaultContractAddress address of REWARDS_VAULT or STAKE_VAULT contract
     */
    function DAO_setTokenContracts(
        address _utilAddress,
        address _stakeAddress,
        address vaultContractAddress
    ) external  nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setTokenContracts",
                address(this),
                _utilAddress,
                _stakeAddress,
                vaultContractAddress
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        REWARDS_VAULT_Interface(vaultContractAddress).setTokenContracts(
            _utilAddress,
            _stakeAddress
        );
        //^^^^^^^interactions^^^^^^^^^
    }

    //---------------------------------------------DAO SETTING FUNCTIONS
    
    /**
     * @dev Default param setter
     * @param _quorum new value for minimum required voters to create a quorum
     */
    function DAO_setQuorum(uint32 _quorum) external nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setQuorum",
                address(this),
                _quorum
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        DAO_CORE.setQuorum(_quorum);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Default param setter
     * @param _passingMargin new value for minimum required passing margin for votes, in whole percents
     */
    function DAO_setPassingMargin(uint32 _passingMargin) external nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setQuorum",
                address(this),
                _passingMargin
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        DAO_CORE.setPassingMargin(_passingMargin);
        //^^^^^^^interactions^^^^^^^^^
    }

    /**
     * @dev Default param setter
     * @param _max new value for maximum votees per node
     */
    function DAO_setMaxVote(uint32 _max) external nonReentrant {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setQuorum",
                address(this),
                _max
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        DAO_CORE.setMaxVote(_max);
        //^^^^^^^effects^^^^^^^^^
    }



    //---------------------------------------------EPOCH CLOCK FUNCTIONS

    /**
     * @dev Set storage contract to interface with
     * @param _epochSeconds - New period for EPOCHS in seconds
     */
    function DAO_setNewEpochInterval(uint256 _epochSeconds)
        external
        
        nonReentrant
    {
        bytes32 signature = keccak256(
            abi.encodePacked(
                "DAO_setNodeStorageContract",
                address(this),
                _epochSeconds
            )
        );
        DAO_CORE.verifyResolution(
            keccak256(abi.encodePacked(signature, CLOCK.thisEpoch())),
            _msgSender()
        );
        //^^^^^^^checks^^^^^^^^^

        CLOCK.setNewEpochInterval(_epochSeconds);
        //^^^^^^^Interactions^^^^^^^^^
    }

    //---------------------------------INTERNAL FUNCTIONS

    /**
     * @dev name resolver
     * @param _name name to resolve
     * returns address of (contract name)
     */
    function resolveName(string calldata _name) public view returns (address) {
        return STOR.resolveContractAddress(_name);
        //^^^^^^^interactions^^^^^^^^^
    }
}
