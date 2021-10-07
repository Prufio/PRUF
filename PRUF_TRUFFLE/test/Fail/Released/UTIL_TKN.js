const PRUF_HELPER = artifacts.require('Helper');
const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
const PRUF_STOR = artifacts.require('STOR');

let UTIL_TKN;
let Helper;
let STOR;

let account000 = '0x0000000000000000000000000000000000000000'

let airdropRoleB32;
let minterRoleB32;
let trustedAgentRoleB32;
let payableRoleB32;

contract('UTIL_TKN', accounts => {

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


    it('Should deploy Storage', async () => {
        const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: account1 });
        console.log(PRUF_STOR_TEST.address);
        assert(PRUF_STOR_TEST.address !== '');
        STOR = PRUF_STOR_TEST;
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

    })

    it('Should authorize Helper', async () => {
        console.log("Adding in Helper")
        return Helper.OO_setStorageContract(STOR.address, { from: account1 })

            .then(() => {
                console.log("Authorizing Helper")
                return UTIL_TKN.grantRole(payableRoleB32, Helper.address, { from: account1 })
            })

            .then(() => {
                console.log("Adding UTIL_TKN to storage for use in Node 0")
                return STOR.authorizeContract("UTIL_TKN", UTIL_TKN.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Resolving in Helper")
                return Helper.OO_resolveContractAddresses({ from: account1 })
            })
    })


    it('Should mint 30000 tokens to account1', async () => {
             console.log("//**************************************BEGIN UTIL_TKN**********************************************/")
        return UTIL_TKN.mint(
            account1,
            '30000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(30000) Pruf tokens @account1", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //1
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************END BOOTSTRAP**************************//')
        console.log('//**************************BEGIN UTIL_TKN FAIL BATCH (9)**************************//')
        console.log('//**************************BEGIN killTrustedAgent FAIL BATCH**************************//')
        return UTIL_TKN.AdminSetSharesAddress(
            account9,
            { from: account2 })
    })

    //2
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************END killTrustedAgent FAIL BATCH**************************//')
        console.log('//**************************BEGIN AdminSetSharesAddress FAIL BATCH**************************//')
        return UTIL_TKN.AdminSetSharesAddress(
            account9,
            { from: account2 })
    })

    //3
    it('Should fail because sharesAddress cannot = 0', async () => {
        return UTIL_TKN.AdminSetSharesAddress(
            account000,
            { from: account1 })
    })


    it('Should set sharesAddress to account9', async () => {
        return UTIL_TKN.AdminSetSharesAddress(
            account9,
            { from: account1 })
    })

    //4
    // it('Should fail because caller is not payable', async () => {
    //     console.log('//**************************END AdminSetSharesAddress FAIL BATCH**************************//')
    //     console.log('//**************************BEGIN payForService FAIL BATCH**************************//')
    //     return Helper.helper_payForService(
    //         account1,
    //         account2,
    //         "200000000000000000",
    //         account2,
    //         "200000000000000000",
    //         { from: account1 })
    // })


    // it('Should give account1 PAYABLE_ROLE', async () => {
    //     return UTIL_TKN.grantRole(
    //         payableRoleB32,
    //         account1,
    //         { from: account1 })
    // })


    // it('Should set account1 as coldWallet', async () => {
    //     return UTIL_TKN.setColdWallet(
    //         { from: account1 })
    // })


    // it("Should account1 as coldWallet", async () => {
    //     var Balance = [];

    //     return await UTIL_TKN.isColdWallet(account1, { from: account1 }, function (_err, _result) {
    //         if (_err) { }
    //         else {
    //             Balance = Object.values(_result)
    //             console.log(Balance)
    //         }
    //     })
    // })

    // //5
    // it('Should fail because caller is coldWallet', async () => {
    //     return Helper.helper_payForService(
    //         account1,
    //         account2,
    //         "200000000000000000",
    //         account2,
    //         "200000000000000000",
    //         { from: account1 })
    // })


    // it('Should unset account1 as coldWallet', async () => {
    //     return UTIL_TKN.unSetColdWallet(
    //         { from: account1 })
    // })

    // //6
    // it('Should fail because caller has insufficient balance', async () => {
    //     return Helper.helper_payForService(
    //         account1,
    //         account2,
    //         "50000000000000000000",
    //         account2,
    //         "50000000000000000000000",
    //         { from: account1 })
    // })

    //4
    it('Should fail because caller is not a trusted agent', async () => {
        console.log('//**************************END AdminSetSharesAddress FAIL BATCH**************************//')
        console.log('//**************************BEGIN trustedAgentBurn FAIL BATCH**************************//')
        return UTIL_TKN.trustedAgentBurn(
            account1,
            "10000000000000000000000",
            { from: account2 })
    })


    it('Should set account1 as coldWallet', async () => {
        return UTIL_TKN.setColdWallet(
            { from: account1 })
    })


    it('Should set account1 as trustedAgent', async () => {
        return UTIL_TKN.grantRole(
            trustedAgentRoleB32,
            account1,
            { from: account1 })
    })

    //5
    it('Should fail because account is coldWallet', async () => {
        return UTIL_TKN.trustedAgentBurn(
            account1,
            "10000000000000000000000",
            { from: account1 })
    })


    it('Should unset account1 as coldWallet', async () => {
        return UTIL_TKN.unSetColdWallet(
            { from: account1 })
    })


    it('Should burn 5000 tokens from account1', async () => {
        return UTIL_TKN.trustedAgentBurn(
            account1,
            "5000000000000000000000",
            { from: account1 })
    })


    it("Should retrieve balanceOf(25000) Pruf tokens @account1", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //6
    it('Should fail because caller is not a trusted agent', async () => {
        console.log('//**************************END trustedAgentBurn FAIL BATCH**************************//')
        console.log('//**************************BEGIN trustedAgentTransfer FAIL BATCH**************************//')
        return UTIL_TKN.trustedAgentTransfer(
            account1,
            account2,
            "10000000000000000000000",
            { from: account2 })
    })


    it('Should set account1 as coldWallet', async () => {
        return UTIL_TKN.setColdWallet(
            { from: account1 })
    })

    //7
    it('Should fail because account is coldWallet', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            account1,
            account2,
            "10000000000000000000000",
            { from: account1 })
    })


    it('Should unset account1 as coldWallet', async () => {
        return UTIL_TKN.unSetColdWallet(
            { from: account1 })
    })

    //8
    it('Should fail because caller is not snapshot authorized', async () => {
        console.log('//**************************END trustedAgentTransfer FAIL BATCH**************************//')
        console.log('//**************************BEGIN takeSnapshot FAIL BATCH**************************//')
        return UTIL_TKN.takeSnapshot(
            { from: account1 })
    })

    //9
    it('Should fail because caller is not minter authorized', async () => {
        console.log('//**************************END takeSnapshot FAIL BATCH**************************//')
        console.log('//**************************BEGIN mint FAIL BATCH**************************//')
        return UTIL_TKN.mint(
            account2,
            "10000000000000000000000",
            { from: account2 })
    })


    it('Should mint 5000 to account1', async () => {
        return UTIL_TKN.mint(
            account1,
            "5000000000000000000000",
            { from: account1 })
    })


    it("Should retrieve balanceOf(30000) Pruf tokens @account1", async () => {
        console.log('//**************************END mint FAIL BATCH**************************//')
        console.log('//**************************END UTIL_TKN FAIL BATCH**************************//')
        var Balance = [];

        return await UTIL_TKN.balanceOf(account1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })



})