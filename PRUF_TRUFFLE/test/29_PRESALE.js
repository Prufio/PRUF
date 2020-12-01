const PRUF_HELPER = artifacts.require('Helper');
const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
const PRUF_PRESALE = artifacts.require('PRESALE');

let PRESALE;
let UTIL_TKN;
let Helper;

let airdropRoleB32;

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

    })


    it('Should fail because caller is not admin', async () => {
        console.log('//**************************END BOOTSTRAP**************************//')
        console.log('//**************************BEGIN ADMIN_setTokenContract FAIL BATCH**************************//')
        return PRESALE.ADMIN_setTokenContract(
            UTIL_TKN.address,
            { from: account2 })
    })


    it('Should fail because ADMIN_setTokenContract cannot = 0', async () => {
        return PRESALE.ADMIN_setTokenContract(
            "0",
            { from: account1 })
    })


    it('Should set ADMIN_setTokenContract to UTIL_TKN', async () => {
        return PRESALE.ADMIN_setTokenContract(
            UTIL_TKN.address,
            { from: account1 })
    })


    it('Should fail because caller is not admin', async () => {
        console.log('//**************************END ADMIN_setTokenContract FAIL BATCH**************************//')
        console.log('//**************************BEGIN ADMIN_setPaymentAddress FAIL BATCH**************************//')
        return PRESALE.ADMIN_setPaymentAddress(
            account2,
            { from: account2 })
    })


    it('Should fail because payment address cannot = 0', async () => {
        return PRESALE.ADMIN_setPaymentAddress(
            "0",
            { from: account1 })
    })


    it('Should set ADMIN_setPaymentAddress to account9', async () => {
        return PRESALE.ADMIN_setPaymentAddress(
            account9,
            { from: account1 })
    })


    it('Should fail because caller is not whitelist authorized', async () => {
        console.log('//**************************END ADMIN_setPaymentAddress FAIL BATCH**************************//')
        console.log('//**************************BEGIN whitelist FAIL BATCH**************************//')
        return PRESALE.whitelist(
            account2,
            "100000",
            "0.1",
            "10",
            { from: account2 })
    })


    it('Should whitelist account2', async () => {
        return PRESALE.whitelist(
            account2,
            "100000",
            "0.1",
            "10",
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


    it('Should fail because caller is not admin', async () => {
        console.log('//**************************BEGIN ADMIN_setAirDropAmount FAIL BATCH**************************//')
        return PRESALE.ADMIN_setAirDropAmount(
            "100000",
            { from: account2 })
    })


    it('Should fail because airdropAmount cannot = 0', async () => {
        return PRESALE.ADMIN_setAirDropAmount(
            "0",
            { from: account1 })
    })


    it('Should set airdropAmount to 20000', async () => {
        return PRESALE.ADMIN_setAirDropAmount(
            "20000",
            { from: account1 })
    })


    it('Should fail because caller is not admin', async () => {
        console.log('//**************************BEGIN ADMIN_setAirDropAmount FAIL BATCH**************************//')
        console.log('//**************************BEGIN ADMIN_setPresaleLimit FAIL BATCH**************************//')
        return PRESALE.ADMIN_setPresaleLimit(
            "1600000000",
            { from: account2 })
    })


    it('Should set PresaleLimit to 1600000000', async () => {
        return PRESALE.ADMIN_setPresaleLimit(
            "1600000000",
            { from: account1 })
    })


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


    it('Should airdrop 280000 PRuF to account2', async () => {
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


    it("Should check balanceOf account2", async () => {
        
        console.log('//**************************END AIRDROP_Mint14 FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account2, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


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


})