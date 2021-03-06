const PRUF_HELPER = artifacts.require('Helper');
const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
const PRUF_SPLITTEST = artifacts.require('SPLITTEST');
const PRUF_SPLITTEST2 = artifacts.require('SPLITTEST2');

let UTIL_TKN;
let Helper;
let SPLITTEST;
let SPLITTEST2;

let account000 = '0x0000000000000000000000000000000000000000'

let airdropRoleB32;
let minterRoleB32;
let trustedAgentRoleB32;
let payableRoleB32;
let pauserRoleB32;

contract('SPLIT', accounts => {

    console.log('//**************************BEGIN SPLIT**************************//')

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


    it('Should deploy PRUF_SPLIT', async () => {
        const PRUF_SPLITTER_TEST = await PRUF_SPLITTEST.deployed({ from: account1 });
        console.log(PRUF_SPLITTER_TEST.address);
        assert(PRUF_SPLITTER_TEST.address !== '')
        SPLIT = PRUF_SPLITTER_TEST;
    })


    it('Should deploy PRUF_SPLIT2', async () => {
        const PRUF_SPLITTER2_TEST = await PRUF_SPLITTEST2.deployed({ from: account1 });
        console.log(PRUF_SPLITTER2_TEST.address);
        assert(PRUF_SPLITTER2_TEST.address !== '')
        SPLIT2 = PRUF_SPLITTER2_TEST;
    })


    it('Should build all variables with Helper', async () => {

        airdropRoleB32 = await Helper.getStringHash(
            'AIRDROP_ROLE'
        )

        minterRoleB32 = await Helper.getStringHash(
            'MINTER_ROLE'
        )

        trustedAgentRoleB32 = await Helper.getStringHash(
            'TRUSTED_AGENT_ROLE'
        )

        payableRoleB32 = await Helper.getStringHash(
            'PAYABLE_ROLE'
        )

        snapshotRoleB32 = await Helper.getStringHash(
            'SNAPSHOT_ROLE'
        )

        pauserRoleB32 = await Helper.getStringHash(
            'PAUSER_ROLE'
        )

    })

    it('Should authorize SPLIT with snapshotRoleB32 in UTIL_TKN', async () => {
        console.log("//**************************************BEGIN SPLIT SETUP**********************************************/")
        return UTIL_TKN.grantRole(snapshotRoleB32, SPLIT.address, { from: account1 })
    })


    it('Should authorize SPLIT with minterRoleB32 in UTIL_TKN', async () => {
        return UTIL_TKN.grantRole(minterRoleB32, SPLIT.address, { from: account1 })
    })


    it('Should authorize SPLIT with minterRoleB32 in UTIL_TKN', async () => {
        return UTIL_TKN.grantRole(pauserRoleB32, SPLIT.address, { from: account1 })
    })


    it('Should authorize SPLIT2 with snapshotRoleB32 in UTIL_TKN', async () => {
        return UTIL_TKN.grantRole(snapshotRoleB32, SPLIT2.address, { from: account1 })
    })


    it('Should pause UTIL_TKN', async () => {
        return UTIL_TKN.pause(
            { from: account1 }
        )
    })


    it('Should mint 10000 tokens to account1', async () => {
        return UTIL_TKN.mint(
            account1,
            '10000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(10000) Pruf tokens @account1", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })
    it('Should mint 20000 tokens to account2', async () => {
        return UTIL_TKN.mint(
            account2,
            '20000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(20000) Pruf tokens @account2", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account2, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    it('Should mint 30000 tokens to account3', async () => {
        return UTIL_TKN.mint(
            account3,
            '30000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(30000) Pruf tokens @account3", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    it('Should mint 40000 tokens to account4', async () => {
        return UTIL_TKN.mint(
            account4,
            '40000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(40000) Pruf tokens @account4", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account4, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    it('Should mint 50000 tokens to account5', async () => {
        return UTIL_TKN.mint(
            account5,
            '50000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(50000) Pruf tokens @account5", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account5, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should ADMIN_setTokenContract to A_TKN', async () => {
        return SPLIT.ADMIN_setTokenContract(
            UTIL_TKN.address,
            { from: account1 })
    })


    it('Should ADMIN_setTokenContract to A_TKN', async () => {
        return SPLIT2.ADMIN_setTokenContract(
            UTIL_TKN.address,
            { from: account1 })
    })


    it('Should take snapshot and pause', async () => {
        return SPLIT2.ADMIN_setSnapshotID(
            '1',
            { from: account1 })
    })


    it('Should take snapshot and pause', async () => {
        return SPLIT2.ADMIN_takeSnapshot(
            { from: account1 })
    })


    it('Should transfer 10000 PRUF to account5', async () => {
        return UTIL_TKN.transfer(
            account5,
            "10000000000000000000000",
            { from: account1 })
    })


    it("Should retrieve balanceOf(0) Pruf tokens @account1", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should splitMyPruf for account1', async () => {
        return SPLIT.splitMyPruf(
            { from: account1 })
    })


    it("Should retrieve balanceOf(10000) Pruf tokens @account1", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should splitMyPruf for account2', async () => {
        return SPLIT.splitMyPruf(
            { from: account2 })
    })


    it("Should retrieve balanceOf(40000) Pruf tokens @account2", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account2, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should splitMyPruf for account3', async () => {
        return SPLIT.splitMyPruf(
            { from: account3 })
    })


    it("Should retrieve balanceOf(60000) Pruf tokens @account3", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should splitMyPruf for account4', async () => {
        return SPLIT.splitMyPruf(
            { from: account4 })
    })


    it("Should retrieve balanceOf(80000) Pruf tokens @account4", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account4, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should splitMyPruf for account5', async () => {
        return SPLIT.splitPrufAtAddress(
            account5,
            { from: account4 })
    })


    it("Should retrieve balanceOf(110000) Pruf tokens @account5", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account5, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })



})