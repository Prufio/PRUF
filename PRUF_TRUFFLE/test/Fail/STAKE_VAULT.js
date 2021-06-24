/*--------------------------------------------------------PRuF0.8.0
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

        const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
        const PRUF_STAKE_TKN = artifacts.require('STAKE_TKN');
        const PRUF_STAKE_VAULT = artifacts.require('STAKE_VAULT');
        const PRUF_REWARD_VAULT = artifacts.require('REWARD_VAULT');
        
        let UTIL_TKN;
        let STAKE_TKN;
        let STAKE_VAULT;
        let REWARD_VAULT;
        
        let account1Hash;
        let account2Hash;
        let account3Hash;
        let account4Hash;
        let account5Hash;
        let account6Hash;
        let account7Hash;
        let account8Hash;
        let account9Hash;
        let account10Hash;
        
        let account000 = '0x0000000000000000000000000000000000000000'
        
        let payableRoleB32;
        let minterRoleB32;
        let trustedAgentRoleB32;
        let assetTransferRoleB32;
        let discardRoleB32;
        
        contract('TheWorks', accounts => {
        
            console.log('//**************************BEGIN BOOTSTRAP**************************//')
        
            const account1 = accounts[0];
            const account2 = accounts[1];
            const account3 = accounts[2];
            const account4 = accounts[3];
            const account5 = accounts[4];
            const account6 = accounts[5];
            const account7 = accounts[6];
            const account8 = accounts[7];
            const account9 = accounts[8];
            const account10 = accounts[9];
        
        
            it('Should deploy PRUF_HELPER', async () => {
                const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: account1 });
                console.log(PRUF_HELPER_TEST.address);
                assert(PRUF_HELPER_TEST.address !== '')
                Helper = PRUF_HELPER_TEST;
            })
        
        
            it('Should deploy PRUF_UTIL_TKN', async () => {
                const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: account1 });
                console.log(PRUF_UTIL_TKN_TEST.address);
                assert(PRUF_UTIL_TKN_TEST.address !== '')
                UTIL_TKN = PRUF_UTIL_TKN_TEST;
            })
        
        
            it('Should deploy PRUF_STAKE_TKN', async () => {
                const PRUF_STAKE_TKN_TEST = await PRUF_STAKE_TKN.deployed({ from: account1 });
                console.log(PRUF_STAKE_TKN_TEST.address);
                assert(PRUF_STAKE_TKN_TEST.address !== '')
                STAKE_TKN = PRUF_STAKE_TKN_TEST;
            })
        
        
            it('Should deploy PRUF_STAKE_VAULT', async () => {
                const PRUF_STAKE_VAULT_TEST = await PRUF_STAKE_VAULT.deployed({ from: account1 });
                console.log(PRUF_STAKE_VAULT_TEST.address);
                assert(PRUF_STAKE_VAULT_TEST.address !== '')
                STAKE_VAULT = PRUF_STAKE_VAULT_TEST;
            })
        
        
            it('Should deploy PRUF_REWARD_VAULT', async () => {
                const PRUF_REWARD_VAULT_TEST = await PRUF_REWARD_VAULT.deployed({ from: account1 });
                console.log(PRUF_REWARD_VAULT_TEST.address);
                assert(PRUF_REWARD_VAULT_TEST.address !== '')
                REWARD_VAULT = PRUF_REWARD_VAULT_TEST;
            })
        
        
            it('Should build variables', async () => {
        
                account1Hash = await Helper.getAddrHash(
                    account1
                )
        
                account2Hash = await Helper.getAddrHash(
                    account2
                )
        
                account3Hash = await Helper.getAddrHash(
                    account3
                )
        
                account4Hash = await Helper.getAddrHash(
                    account4
                )
        
                account5Hash = await Helper.getAddrHash(
                    account5
                )
        
                account6Hash = await Helper.getAddrHash(
                    account6
                )
        
                account7Hash = await Helper.getAddrHash(
                    account7
                )
        
                account8Hash = await Helper.getAddrHash(
                    account8
                )
        
                account9Hash = await Helper.getAddrHash(
                    account9
                )
        
                account10Hash = await Helper.getAddrHash(
                    account10
                )
        
        
                ECR_MGRHASH = await Helper.getStringHash(
                    'ECR_MGR'
                )
        
                payableRoleB32 = await Helper.getStringHash(
                    'PAYABLE_ROLE'
                )
        
                minterRoleB32 = await Helper.getStringHash(
                    'MINTER_ROLE'
                )
        
                trustedAgentRoleB32 = await Helper.getStringHash(
                    'TRUSTED_AGENT_ROLE'
                )
        
                assetTransferRoleB32 = await Helper.getStringHash(
                    'ASSET_TXFR_ROLE'
                )
        
                discardRoleB32 = await Helper.getStringHash(
                    'DISCARD_ROLE'
                )
            })
        
            it('Should authorize all minter contracts for minting A_TKN(s)', () => {
        
                console.log("Authorizing NP")
                return A_TKN.grantRole(minterRoleB32, NP.address, { from: account1 })
        
                    .then(() => {
                        console.log("Authorizing APP_NC")
                        return A_TKN.grantRole(minterRoleB32, APP_NC.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing APP")
                        return A_TKN.grantRole(minterRoleB32, APP.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing RCLR")
                        return A_TKN.grantRole(minterRoleB32, RCLR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing PURCHASE")
                        return A_TKN.grantRole(trustedAgentRoleB32, PURCHASE.address, { from: account1 })
                    })
            })
        
});