const PRUF_HELPER = artifacts.require('Helper');
const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
const PRUF_PRESALE = artifacts.require('PRESALE');

let PRESALE;
let UTIL_TKN;
let Helper;

let account000 = '0x0000000000000000000000000000000000000000'

let airdropRoleB32;
let minterRoleB32;

contract('PRESALE', accounts => {

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


    it('Should deploy UTIL_TKN', async () => {
        const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: account1 });
        console.log(PRUF_UTIL_TKN_TEST.address);
        assert(PRUF_UTIL_TKN_TEST.address !== '')
        UTIL_TKN = PRUF_UTIL_TKN_TEST;
    })


    it('Should deploy PRESALE', async () => {
        const PRUF_PRESALE_TEST = await PRUF_PRESALE.deployed({ from: account1 });
        console.log(PRUF_PRESALE_TEST.address);
        assert(PRUF_PRESALE_TEST.address !== '');
        PRESALE = PRUF_PRESALE_TEST;
    })

    
    it('Should build all variables with Helper', async () => {

        airdropRoleB32 = await Helper.getStringHash(
        'AIRDROP_ROLE'
    )
    
        minterRoleB32 = await Helper.getStringHash(
        'MINTER_ROLE'
    )

    })


    it('Should give PRESALE MINTER_ROLE', async () => {
        return UTIL_TKN.grantRole(
            minterRoleB32,
            PRESALE.address,
            { from: account1 })
    })

    //1
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************END BOOTSTRAP**************************//')
        console.log('//**************************BEGIN PRESALE FAIL BATCH (27)**************************//')
        console.log('//**************************BEGIN ADMIN_setTokenContract FAIL BATCH**************************//')
        return PRESALE.ADMIN_setTokenContract(
            UTIL_TKN.address,
            { from: account2 })
    })

    //2
    it('Should fail because ADMIN_setTokenContract cannot = 0', async () => {
        return PRESALE.ADMIN_setTokenContract(
            account000,
            { from: account1 })
    })


    it('Should set ADMIN_setTokenContract to UTIL_TKN', async () => {
        return PRESALE.ADMIN_setTokenContract(
            UTIL_TKN.address,
            { from: account1 })
    })

    //3
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************END ADMIN_setTokenContract FAIL BATCH**************************//')
        console.log('//**************************BEGIN ADMIN_setPaymentAddress FAIL BATCH**************************//')
        return PRESALE.ADMIN_setPaymentAddress(
            account2,
            { from: account2 })
    })

    //4
    it('Should fail because payment address cannot = 0', async () => {
        return PRESALE.ADMIN_setPaymentAddress(
            account000,
            { from: account1 })
    })

    //5
    it('Should fail because caller is not whitelist authorized', async () => {
        console.log('//**************************END ADMIN_setPaymentAddress FAIL BATCH**************************//')
        console.log('//**************************BEGIN whitelist FAIL BATCH**************************//')
        return PRESALE.whitelist(
            account2,
            "100000",
            "100000000000000000",
            "10",
            { from: account2 })
    })


    it('Should whitelist account2', async () => {
        return PRESALE.whitelist(
            account2,
            "100000000000000000000000",
            "100000000000000000",
            "1000000000000000000000",
            { from: account1 })
    })


    it('Should whitelist account4', async () => {
        return PRESALE.whitelist(
            account4,
            "100000000000000000000000",
            "100000000000000000",
            "160000000000000000000000",
            { from: account1 })
    })


    it("Should checkWhitelist on account2", async () => {
        
        console.log('//**************************END whitelist FAIL BATCH**************************//')
        var Balance = [];

        return await PRESALE.checkWhitelist(account2, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //6
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************BEGIN ADMIN_setAirDropAmount FAIL BATCH**************************//')
        return PRESALE.ADMIN_setAirDropAmount(
            "100000",
            { from: account2 })
    })

    //7
    it('Should fail because airdropAmount cannot = 0', async () => {
        return PRESALE.ADMIN_setAirDropAmount(
            "0",
            { from: account1 })
    })


    it('Should set airdropAmount to 20000', async () => {
        return PRESALE.ADMIN_setAirDropAmount(
            "20000000000000000000000",
            { from: account1 })
    })

    //8
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************BEGIN ADMIN_setAirDropAmount FAIL BATCH**************************//')
        console.log('//**************************BEGIN ADMIN_setPresaleLimit FAIL BATCH**************************//')
        return PRESALE.ADMIN_setPresaleLimit(
            "1600000000",
            { from: account2 })
    })


    it('Should set PresaleLimit to 1600000000', async () => {
        return PRESALE.ADMIN_setPresaleLimit(
            "1600000000000000000000000000",
            { from: account1 })
    })

    //9
    it('Should fail because caller is not airdrop authorized', async () => {
        console.log('//**************************END ADMIN_setPresaleLimit FAIL BATCH**************************//')
        console.log('//**************************BEGIN AIRDROP_Mint14 FAIL BATCH**************************//')
        return PRESALE.AIRDROP_Mint14(
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            { from: account2 })
    })


    it('Should pause PRESALE', async () => {
        return PRESALE.pause(
            { from: account1 })
    })

    //10
    it('Should fail because PRESALE is paused', async () => {
        return PRESALE.AIRDROP_Mint14(
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            { from: account1 })
    })


    it('Should unpause PRESALE', async () => {
        return PRESALE.unpause(
            { from: account1 })
    })


    it('Should airdrop 280000 PRuF to account3', async () => {
        return PRESALE.AIRDROP_Mint14(
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            { from: account1 })
    })


    it("Should check balanceOf account3 (280000)", async () => {
        
        console.log('//**************************END AIRDROP_Mint14 FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //11
    it('Should fail because caller is not airdrop authorized', async () => {
        console.log('//**************************BEGIN AIRDROP_Mint10 FAIL BATCH**************************//')
        return PRESALE.AIRDROP_Mint10(
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            { from: account2 })
    })


    it('Should pause PRESALE', async () => {
        return PRESALE.pause(
            { from: account1 })
    })

    //12
    it('Should fail because PRESALE is paused', async () => {
        return PRESALE.AIRDROP_Mint10(
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            account2,
            { from: account1 })
    })


    it('Should unpause PRESALE', async () => {
        return PRESALE.unpause(
            { from: account1 })
    })


    it('Should airdrop 200000 PRuF to account3', async () => {
        return PRESALE.AIRDROP_Mint10(
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            account3,
            { from: account1 })
    })


    it("Should check balanceOf account3 (480000)", async () => {
        
        console.log('//**************************END AIRDROP_Mint10 FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //13
    it('Should fail because caller is not airdrop authorized', async () => {
        console.log('//**************************BEGIN AIRDROP_Mint5 FAIL BATCH**************************//')
        return PRESALE.AIRDROP_Mint5(
            account2,
            account2,
            account2,
            account2,
            account2,
            { from: account2 })
    })


    it('Should pause PRESALE', async () => {
        return PRESALE.pause(
            { from: account1 })
    })

    //14
    it('Should fail because PRESALE is paused', async () => {
        return PRESALE.AIRDROP_Mint5(
            account2,
            account2,
            account2,
            account2,
            account2,
            { from: account1 })
    })


    it('Should unpause PRESALE', async () => {
        return PRESALE.unpause(
            { from: account1 })
    })


    it('Should airdrop 100000 PRuF to account3', async () => {
        return PRESALE.AIRDROP_Mint5(
            account3,
            account3,
            account3,
            account3,
            account3,
            { from: account1 })
    })


    it("Should check balanceOf account3 (580000)", async () => {
        
        console.log('//**************************END AIRDROP_Mint5 FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //15
    it('Should fail because caller is not airdrop authorized', async () => {
        console.log('//**************************BEGIN AIRDROP_Mint3 FAIL BATCH**************************//')
        return PRESALE.AIRDROP_Mint3(
            account2,
            account2,
            account2,
            { from: account2 })
    })


    it('Should pause PRESALE', async () => {
        return PRESALE.pause(
            { from: account1 })
    })

    //16
    it('Should fail because PRESALE is paused', async () => {
        return PRESALE.AIRDROP_Mint3(
            account2,
            account2,
            account2,
            { from: account1 })
    })


    it('Should unpause PRESALE', async () => {
        return PRESALE.unpause(
            { from: account1 })
    })


    it('Should airdrop 60000 PRuF to account3', async () => {
        return PRESALE.AIRDROP_Mint3(
            account3,
            account3,
            account3,
            { from: account1 })
    })


    it("Should check balanceOf account3 (640000)", async () => {
        
        console.log('//**************************END AIRDROP_Mint3 FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //17
    it('Should fail because caller is not airdrop authorized', async () => {
        console.log('//**************************BEGIN AIRDROP_Mint2 FAIL BATCH**************************//')
        return PRESALE.AIRDROP_Mint2(
            account2,
            account2,
            { from: account2 })
    })


    it('Should pause PRESALE', async () => {
        return PRESALE.pause(
            { from: account1 })
    })

    //18
    it('Should fail because PRESALE is paused', async () => {
        return PRESALE.AIRDROP_Mint2(
            account2,
            account2,
            { from: account1 })
    })


    it('Should unpause PRESALE', async () => {
        return PRESALE.unpause(
            { from: account1 })
    })


    it('Should airdrop 40000 PRuF to account3', async () => {
        return PRESALE.AIRDROP_Mint2(
            account3,
            account3,
            { from: account1 })
    })


    it("Should check balanceOf account3 (680000)", async () => {
        
        console.log('//**************************END AIRDROP_Mint2 FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //19
    it('Should fail because caller is not airdrop authorized', async () => {
        console.log('//**************************BEGIN AIRDROP_Mint1 FAIL BATCH**************************//')
        return PRESALE.AIRDROP_Mint1(
            account2,
            { from: account2 })
    })


    it('Should pause PRESALE', async () => {
        return PRESALE.pause(
            { from: account1 })
    })

    //20
    it('Should fail because PRESALE is paused', async () => {
        return PRESALE.AIRDROP_Mint1(
            account2,
            { from: account1 })
    })


    it('Should unpause PRESALE', async () => {
        return PRESALE.unpause(
            { from: account1 })
    })


    it('Should airdrop 20000 PRuF to account3', async () => {
        return PRESALE.AIRDROP_Mint1(
            account3,
            { from: account1 })
    })


    it("Should check balanceOf account3 (700000)", async () => {
        
        console.log('//**************************END AIRDROP_Mint1 FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should pause PRESALE', async () => {
        
        console.log('//**************************BEGIN PRUF_PRESALE FAIL BATCH**************************//')
        return PRESALE.pause(
            { from: account1 })
    })

    //21
    it('Should fail because PRESALE is paused', async () => {
        return PRESALE.PRUF_PRESALE(
            { from: account1 })
    })


    it('Should unpause PRESALE', async () => {
        return PRESALE.unpause(
            { from: account1 })
    })

    //22
    it('Should fail because amountToMint = 0', async () => {
        return PRESALE.PRUF_PRESALE(
            { from: account2 })
    })

    //23
    it('Should fail because minEth req was not met', async () => {
        return PRESALE.PRUF_PRESALE(
            { from: account2, value: 90000000000000000 })
    })

    //24
    it('Should fail because maxEth req was not met', async () => {
        return PRESALE.PRUF_PRESALE(
            { from: account2, value: "1000100000000000000000" })
    })

    //25
    it('Should fail because purchase request exceeds total presale limit', async () => {
        return PRESALE.PRUF_PRESALE(
            { from: account4, value: "16000000000000000000001" })
    })


    it('Should purchase 100000 PRuF to account3', async () => {
        return PRESALE.PRUF_PRESALE(
            { from: account3, value: 1000000000000000000})
    })


    it("Should check balanceOf account3 (800000)", async () => {
        
        console.log('//**************************END PRUF_PRESALE FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //26
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************BEGIN withdraw FAIL BATCH**************************//')
        return PRESALE.withdraw(
            { from: account2 })
    })

    //27
    it('Should fail because payment address cannot = 0', async () => {
        return PRESALE.withdraw(
            { from: account1 })
    })


    it('Should set ADMIN_setPaymentAddress to account9', async () => {
        return PRESALE.ADMIN_setPaymentAddress(
            account9,
            { from: account1 })
    })


    it("Should check balanceOf PRESALE (1ETH)", async () => {
        
        console.log('//**************************END PRUF_PRESALE FAIL BATCH**************************//')
        var Balance = [];

        return await PRESALE.balance({ from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should withdraw ETH to account9', async () => {
        console.log('//**************************END PRESALE FAIL BATCH**************************//')
        return PRESALE.withdraw(
            { from: account1 })
    })

})