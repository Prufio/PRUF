const PRUF_HELPER = artifacts.require('Helper');
const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
const BUY_PRUF = artifacts.require('PRESALE');
const PRUF_STOR = artifacts.require('STOR');
const PRUF_HELPER2 = artifacts.require('Helper2');

let PRESALE;
let UTIL_TKN;
let Helper;
let Helper2;
let STOR;

let account000 = '0x0000000000000000000000000000000000000000'

let airdropRoleB32;
let minterRoleB32;
let payableRoleB32;
let trustedAgentRoleB32;
let snapshotRoleB32;

contract('PRESALE', accounts => {

    console.log('//**************************BEGIN BOOTSTRAP**************************//')

    const A = accounts[0];
    const B = accounts[1];
    const C = accounts[2];
    const account4 = accounts[3];
    const account5 = accounts[4];
    const account6 = accounts[5];
    const account7 = accounts[6];
    const account8 = accounts[7];
    const account9 = accounts[8];
    const A0 = accounts[9];


    it('Should deploy PRUF_HELPER', async () => {
        const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: A });
        console.log(PRUF_HELPER_TEST.address);
        assert(PRUF_HELPER_TEST.address !== '')
        Helper = PRUF_HELPER_TEST;
    })


    it('Should deploy PRUF_HELPER2', async () => {
        const PRUF_HELPER2_TEST = await PRUF_HELPER2.deployed({ from: A });
        console.log(PRUF_HELPER2_TEST.address);
        assert(PRUF_HELPER2_TEST.address !== '')
        Helper2 = PRUF_HELPER2_TEST;
    })


    it('Should deploy UTIL_TKN', async () => {
        const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: A });
        console.log(PRUF_UTIL_TKN_TEST.address);
        assert(PRUF_UTIL_TKN_TEST.address !== '')
        UTIL_TKN = PRUF_UTIL_TKN_TEST;
    })


    it('Should deploy PRESALE', async () => {
        const BUY_PRUF_TEST = await BUY_PRUF.deployed({ from: A });
        console.log(BUY_PRUF_TEST.address);
        assert(BUY_PRUF_TEST.address !== '');
        PRESALE = BUY_PRUF_TEST;
    })


    it('Should deploy Storage', async () => {
        const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: A });
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
    
        payableRoleB32 = await Helper.getStringHash(
        'PAYABLE_ROLE'
    )
    
        trustedAgentRoleB32 = await Helper.getStringHash(
        'TRUSTED_AGENT_ROLE'
    )
    
        snapshotRoleB32 = await Helper.getStringHash(
        'SNAPSHOT_ROLE'
    )

    })

    it('Should authorize Helper', async () => {
        console.log("Adding in Helper")
        return Helper.OO_setStorageContract(STOR.address, { from: A })

            .then(() => {
                console.log("Authorizing Helper")
                return UTIL_TKN.grantRole(payableRoleB32, Helper.address, { from: A })
            })

            .then(() => {
                console.log("Adding UTIL_TKN to storage for use in AC 0")
                return STOR.OO_addContract("UTIL_TKN", UTIL_TKN.address, '0', '1', { from: A })
            })

            .then(() => {
                console.log("Resolving in Helper")
                return Helper.OO_resolveContractAddresses({ from: A })
            })
    })


    it('Should give PRESALE MINTER_ROLE', async () => {
        return UTIL_TKN.grantRole(
            minterRoleB32,
            PRESALE.address,
            { from: A })
    })


    it('Should give A SNAPSHOT_ROLE', async () => {
        return UTIL_TKN.grantRole(
            snapshotRoleB32,
            A,
            { from: A })
    })

    //1
    it('Should fail because caller is not admin', async () => {
        console.log('//**************************END BOOTSTRAP**************************//')
        console.log('//**************************BEGIN PRESALE_MAL (25)**************************//')

        return PRESALE.setTokenContract(
            UTIL_TKN.address,
            { from: B })
    })


    it('Should set setTokenContract to UTIL_TKN', async () => {
        return PRESALE.setTokenContract(
            UTIL_TKN.address,
            { from: A })
    })


    it('Should set payment address', async () => {
        return PRESALE.setPaymentAddress(
            account9,
            { from: A })
    })


    it('Should set airdropAmount to 10', async () => {
        return PRESALE.setAirDropAmount(
            "10000000000000000000",
            { from: A })
    })


    it('Should set PresaleLimit to 11', async () => {
        return PRESALE.setPresaleLimit(
            "11000000000000000000",
            { from: A })
    })


    it('Should airdrop 10 PRuF to B', async () => {
        return PRESALE.AIRDROP_Mint1(
            B,
            { from: A })
    })


    it("Should check balanceOf A (0)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (0)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should whitelist C', async () => {
        return PRESALE.whitelist(
            C,
            "10000000000000000000",
            "100000000000000000",
            "1000000000000000000",
            { from: A })
    })

    //2
    it('Should fail because exceeds presale limit', async () => {
        return PRESALE.BUY_PRUF(
            { from: B, value: 100000000000000000})
    })


    it('Should purchase 1 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 100000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (1)", async () => {
        0

        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //3
    it('Should fail because under min limit', async () => {
        return PRESALE.BUY_PRUF(
            { from: B, value: 10000000000000000})
    })


    it('Should purchase 0.1 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 10000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (1.1)", async () => {
        0

        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should purchase 0.9 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 90000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (2)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should snapshot (1)', async () => {
        return UTIL_TKN.takeSnapshot(
            { from: A }
            )
    })

    //4
    it('Should fail because exceeds allotment', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 900000000000000000})
    })


    it('Should buy 8 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 800000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (10)", async () => {
        0

        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //5
    it('Should fail because exceeds allotment', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 10000000000000000})
    })


    it('Should whitelist C', async () => {
        return PRESALE.whitelist(
            C,
            "10000000000000000000",
            "10000000000000000",
            "2000000000000000000",
            { from: A })
    })


    it('Should buy 0.1 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 10000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (10.1)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //6
    it('Should fail because exceeds presale limit', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 100000000000000000})
    })


    it('Should buy 0.9 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 90000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (11)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //7
    it('Should fail because exceeds presale limit', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 100000000000000000})
    })


    it('Should set PresaleLimit to 1', async () => {
        return PRESALE.setPresaleLimit(
            "1000000000000000000",
            { from: A })
    })


    it('Should buy 0.1 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 10000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (11.1)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should whitelist B', async () => {
        return PRESALE.whitelist(
            B,
            "10000000000000000000",
            "10000000000000000",
            "100000000000000000",
            { from: A })
    })


    it('Should buy 0.1 to B', async () => {
        return PRESALE.BUY_PRUF(
            { from: B, value: 10000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10.1)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (11.1)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should snapshot (2)', async () => {
        return UTIL_TKN.takeSnapshot(
            { from: A }
            )
    })

    //8
    it('Should fail because exceeds presale limit', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 100000000000000000})
    })


    it('Should buy 0.4 to B', async () => {
        return PRESALE.BUY_PRUF(
            { from: B, value: 40000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10.5)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (11.1)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should buy 0.4 to C', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 40000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (10.5)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (11.5)", async () => {
        0
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //9
    it('Should fail because exceeds presale limit', async () => {
        return PRESALE.BUY_PRUF(
            { from: B, value: 10000000000000000})
    })

    //10
    it('Should fail because exceeds presale limit', async () => {
        return PRESALE.BUY_PRUF(
            { from: C, value: 10000000000000000})
    })


    it('Should set PresaleLimit to 1', async () => {
        return PRESALE.setPresaleLimit(
            "1000000000000000000",
            { from: A })
    })


    it('Should buy 0.5 to B', async () => {
        return PRESALE.BUY_PRUF(
            { from: B, value: 50000000000000000})
    })


    it("Should check balanceOf A (0)", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf B (11)", async () => {
        

        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should check balanceOf C (11.5)", async () => {

        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //11
    it('Should fail because exceeds allotment', async () => {
        return PRESALE.BUY_PRUF(
            { from: B, value: 10000000000000000})
    })


    //12
    it('Should fail because exceeds allowance', async () => {
        return UTIL_TKN.burnFrom(
            B,
            "10000000000000000",
            { from: A }
        )
    })

    //13
    it('Should fail because exceeds allowance', async () => {
        return UTIL_TKN.transfer(
            B,
            "10000000000000000",
            { from: A }
        )
    })

    //14
    it('Should fail because exceeds allowance', async () => {
        return UTIL_TKN.transferFrom(
            B,
            A,
            "10000000000000000",
            { from: A }
        )
    })


    it('Should grant C trusted agent role', async () => {
        return UTIL_TKN.grantRole(
            trustedAgentRoleB32,
            C,
            { from: A }
        )
    })


    it('Should give C PAYABLE_ROLE', async () => {
        return UTIL_TKN.grantRole(
            payableRoleB32,
            C,
            { from: A })
    })

    // //15
    // it('Should fail because not payable agent', async () => {
    //     return Helper2.helper_payForService(
    //         B,
    //         A,
    //         "50000000000000000",
    //         C,
    //         "50000000000000000",
    //         { from: A }
    //     )
    // })


    it('Should pay for service and distribute', async () => {
        return Helper.helper_payForService(
            "1",
            B,
            A,
            "50000000000000000",
            C,
            "50000000000000000",
            { from: C }
        )
    })


    it("Should retrieve balanceOf(.05) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(10.9) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(11.55) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //15
    it('Should fail because not trusted agent', async () => {
        return UTIL_TKN.trustedAgentBurn(
            C,
            "1000000000000000000",
            { from: B }
        )
    })


    it('Should burn 1 from B', async () => {
        return UTIL_TKN.trustedAgentBurn(
            B,
            "1000000000000000000",
            { from: C }
        )
    })


    it("Should retrieve balanceOf(.05) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(9.9) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(11.55) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //16
    it('Should fail because not trusted agent', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "150000000000000000",
            { from: B }
        )
    })


    it('Should transfer 0.9 from B to A', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            B,
            A,
            "900000000000000000",
            { from: C }
        )
    })


    it("Should retrieve balanceOf(.95) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(9) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(11.55) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should snapshot (3)', async () => {
        return UTIL_TKN.takeSnapshot(
            { from: A }
            )
    })


    it('Should revoke trusted agent role from C', async () => {
        return UTIL_TKN.revokeRole(
            trustedAgentRoleB32,
            C,
            { from: A }
        )
    })

    //17
    it('Should fail because not trusted agent', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            B,
            A,
            "900000000000000000",
            { from: C }
        )
    })


    it('Should grant B trusted agent role', async () => {
        return UTIL_TKN.grantRole(
            trustedAgentRoleB32,
            B,
            { from: A }
        )
    })


    it('Should transfer 0.15 from C to A', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "150000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(1.1) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(9) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(11.4) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should transfer 1 from B to A', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            B,
            A,
            "1000000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(2.1) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(8) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(11.4) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should set C as coldWallet', async () => {
        return UTIL_TKN.setColdWallet(
            { from: C })
    })

    //18
    it('Should fail because C is cold wallet', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "1000000000000000000",
            { from: B }
        )
    })

    //19
    it('Should fail because C is cold wallet', async () => {
        return UTIL_TKN.trustedAgentBurn(
            C,
            "1000000000000000000",
            { from: B }
        )
    })

    
    it('Should give B PAYABLE_ROLE', async () => {
        return UTIL_TKN.grantRole(
            payableRoleB32,
            B,
            { from: A })
    })

    //20
    it('Should fail because C is cold wallet', async () => {
        return Helper.helper_payForService(
            "1",
            C,
            A,
            "1000000000000000000",
            B,
            "1000000000000000000",
            { from: B }
        )
    })


    it('Should unset C as coldWallet', async () => {
        return UTIL_TKN.unSetColdWallet(
            { from: C })
    })


    it('Should transfer 1 from C to A', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "1000000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(3.1) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(8) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(10.4) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should burn 1 from C', async () => {
        return UTIL_TKN.trustedAgentBurn(
            C,
            "1000000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(3.1) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(8) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(9.4) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should payForService and distribute', async () => {
        return Helper.helper_payForService(
            "1",
            C,
            A,
            "1000000000000000000",
            B,
            "1000000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(4.1) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(9) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(7.4) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //21
    it('Should fail because not default admin', async () => {
        return UTIL_TKN.adminKillTrustedAgent(
            "170",
            { from: B }
        )
    })


    it('Should kill all trusted agent functionality', async () => {
        return UTIL_TKN.adminKillTrustedAgent(
            "170",
            { from: A }
        )
    })

    //22
    it('Should fail because trusted agent function permanently disabled', async () => {
        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "1000000000000000000",
            { from: B }
        )
    })

    //23
    it('Should fail because trusted agent function permanently disabled', async () => {
        return UTIL_TKN.trustedAgentBurn(
            C,
            "1000000000000000000",
            { from: B }
        )
    })

    //24
    it('Should fail because trusted agent function permanently disabled', async () => {
        return Helper.helper_payForService(
            "1",
            C,
            A,
            "1000000000000000000",
            B,
            "1000000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(0) @ snapshot 1 @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(A, "1", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(10) @ snapshot 1 @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(B, "1", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(2) @ snapshot 1 @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(C, "1", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0) @ snapshot 2 @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(A, "2", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(10.1) @ snapshot 2 @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(B, "2", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(11.1) @ snapshot 2 @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(C, "2", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0.95) @ snapshot 3 @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(A, "3", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(9) @ snapshot 3 @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(B, "3", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(11.55) @ snapshot 3 @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOfAt(C, "3", { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

})