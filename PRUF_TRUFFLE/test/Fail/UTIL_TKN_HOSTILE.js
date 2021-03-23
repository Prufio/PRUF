const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
const PRUF_HELPER = artifacts.require('Helper');
const PRUF_STOR = artifacts.require('STOR');
const PRUF_AC_MGR = artifacts.require('AC_MGR');
const PRUF_AC_TKN = artifacts.require('AC_TKN');

let UTIL_TKN;
let Helper;
let STOR;
let AC_MGR;
let AC_TKN;

contract('UTIL_TKN', accounts => {

    console.log('//**************************BEGIN BOOTSTRAP**************************//')

    const MAIN = accounts[0];
    const A = accounts[1];
    const B = accounts[2];
    const C = accounts[3];


    let MINTER_ROLE;
    let PAUSER_ROLE;
    let PAYABLE_ROLE;
    let TRUSTED_AGENT_ROLE;


    it('Should deploy UTIL_TKN', async () => {
        const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: MAIN });
        console.log(PRUF_UTIL_TKN_TEST.address);
        assert(PRUF_UTIL_TKN_TEST.address !== '')
        UTIL_TKN = PRUF_UTIL_TKN_TEST;
    })


    it('Should deploy PRUF_HELPER', async () => {
        const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: MAIN });
        console.log(PRUF_HELPER_TEST.address);
        assert(PRUF_HELPER_TEST.address !== '')
        Helper = PRUF_HELPER_TEST;
    })


    it('Should deploy Storage', async () => {
        const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: MAIN });
        console.log(PRUF_STOR_TEST.address);
        assert(PRUF_STOR_TEST.address !== '');
        STOR = PRUF_STOR_TEST;
    })


    it('Should deploy PRUF_AC_MGR', async () => {
        const PRUF_AC_MGR_TEST = await PRUF_AC_MGR.deployed({ from: MAIN });
        console.log(PRUF_AC_MGR_TEST.address);
        assert(PRUF_AC_MGR_TEST.address !== '');
        AC_MGR = PRUF_AC_MGR_TEST;
    })


    it('Should deploy PRUF_AC_TKN', async () => {
        const PRUF_AC_TKN_TEST = await PRUF_AC_TKN.deployed({ from: MAIN });
        console.log(PRUF_AC_TKN_TEST.address);
        assert(PRUF_AC_TKN_TEST.address !== '')
        AC_TKN = PRUF_AC_TKN_TEST;
    })


    it('Should build all variables with Helper', async () => {

        MINTER_ROLE = await Helper.getStringHash(
            'MINTER_ROLE'
        )

        PAUSER_ROLE = await Helper.getStringHash(
            'PAUSER_ROLE'
        )

        PAYABLE_ROLE = await Helper.getStringHash(
            'PAYABLE_ROLE'
        )

        TRUSTED_AGENT_ROLE = await Helper.getStringHash(
            'TRUSTED_AGENT_ROLE'
        )
    })

    it('Should authorize Helper', async () => {
        console.log("Adding in Helper")
        return Helper.OO_setStorageContract(STOR.address, { from: MAIN })

            .then(() => {
                console.log("Authorizing Helper")
                return UTIL_TKN.grantRole(PAYABLE_ROLE, Helper.address, { from: MAIN })
            })

            .then(() => {
                console.log("Adding UTIL_TKN to storage for use in AC 0")
                return STOR.OO_addContract("UTIL_TKN", UTIL_TKN.address, '0', '1', { from: MAIN })
            })

            .then(() => {
                console.log("Adding AC_MGR to storage for use in AC 0")
                return STOR.OO_addContract("AC_MGR", AC_MGR.address, '0', '1', { from: MAIN })
            })

            .then(() => {
                console.log("Adding AC_TKN to storage for use in AC 0")
                return STOR.OO_addContract("AC_TKN", AC_TKN.address, '0', '1', { from: MAIN })
            })

            .then(() => {
                console.log("Resolving in Helper")
                return Helper.OO_resolveContractAddresses({ from: MAIN })
            })
    })


    it('Should mint a couple of asset root tokens', async () => {

        console.log("Minting root token 1 -C")
        return AC_MGR.createAssetClass("1", 'CUSTODIAL_ROOT1', '1', '3', '0', "0", rgt000, account1, { from: account1 })

    })


    it('Should mint 100 to A', async () => {
        console.log('//**************************END BOOTSTRAP**************************//')

        return UTIL_TKN.mint(
            A,
            "100000000000000000000",
            { from: MAIN }
        )
    })


    it("Should retrieve balanceOf(100) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //1
    it('Should fail to mint 4000000000 Pruf tokens to B', async () => {

        return UTIL_TKN.mint(
            A,
            "4000000000000000000000000000",
            { from: MAIN }
        )
    })

    //2
    it('Should fail to transfer 101 Pruf tokens from A to B', async () => {

        return UTIL_TKN.transfer(
            B,
            "101000000000000000000",
            { from: A }
        )
    })


    it('Should transfer 100 Pruf tokens from A to B', async () => {

        return UTIL_TKN.transfer(
            B,
            "100000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(0) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(100) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //3    
    it('Should fail to transfer 10 Pruf tokens from A to B because of insufficiant balance', async () => {

        return UTIL_TKN.transferFrom(
            A,
            B,
            "10000000000000000000",
            { from: B }
        )
    })

    //4
    it('Should fail to transfer 10 Pruf tokens from A to C because B is not authroized to send', async () => {

        return UTIL_TKN.transferFrom(
            B,
            C,
            "10000000000000000000",
            { from: B }
        )
    })


    it('Should approve A for 50 PRuf Tokens from B', async () => {

        return UTIL_TKN.approve(
            A,
            "50000000000000000000",
            { from: B }
        )
    })

    //5
    it('Should fail to transfer 50 Pruf tokens from B to A because C(sender) is not authroized to send', async () => {

        return UTIL_TKN.transferFrom(
            B,
            A,
            "50000000000000000000",
            { from: C }
        )
    })


    it('Should transfer 30 Pruf tokens from B to C', async () => {

        return UTIL_TKN.transferFrom(
            B,
            C,
            "30000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(0) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(70) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(30) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should transfer 20 Pruf tokens from B to A', async () => {

        return UTIL_TKN.transferFrom(
            B,
            A,
            "20000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(20) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(50) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(30) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //6    
    it('Should fail to transfer 1 Pruf token from B to A because permitted transfer from A amount has run out', async () => {

        return UTIL_TKN.transferFrom(
            B,
            A,
            "1000000000000000000",
            { from: A }
        )
    })

    //7
    it('Should fail to burn 50 Pruf tokens from A because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentBurn(
            A,
            "50000000000000000000",
            { from: A }
        )
    })

    //8
    it('Should fail to transfer 50 Pruf tokens from A to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentTransfer(
            A,
            B,
            "50000000000000000000",
            { from: A }
        )
    })

    //9
    it('Should fail to payForService involving 50 PRuf tokens because A is not an Authorized Agent', async () => {

        return Helper.helper_payForService(
            "1",
            A,
            B,
            "25000000000000000000",
            C,
            "25000000000000000000",
            { from: A }
        )
    })

    //10
    it('Should fail to pause because A is not an Authorized Agent', async () => {

        return UTIL_TKN.pause(
            { from: A }
        )
    })

    //11
    it('Should fail to unpause because A is not an Authorized Agent', async () => {

        return UTIL_TKN.unpause(
            { from: A }
        )
    })

    //12
    it('Should fail to mint 100 PRuf tokens to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.mint(
            B,
            "100000000000000000000",
            { from: A }
        )
    })


    it('Should grant MINTER_ROLE to A', async () => {

        return UTIL_TKN.grantRole(
            MINTER_ROLE,
            A,
            { from: MAIN }
        )
    })


    it('Should mint 100 PRuf tokens to B', async () => {

        return UTIL_TKN.mint(
            B,
            "100000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(20) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(150) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(30) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //13
    it('Should fail to burn 50 Pruf tokens from A because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentBurn(
            A,
            "50000000000000000000",
            { from: A }
        )
    })

    //14
    it('Should fail to transfer 50 Pruf tokens from A to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentTransfer(
            A,
            B,
            "50000000000000000000",
            { from: A }
        )
    })

    //15
    it('Should fail to payForService involving 50 PRuf tokens because A is not an Authorized Agent', async () => {

        return Helper.helper_payForService(
            A,
            B,
            "25000000000000000000",
            C,
            "25000000000000000000",
            { from: A }
        )
    })

    //16
    it('Should fail to pause because A is not an Authorized Agent', async () => {

        return UTIL_TKN.pause(
            { from: A }
        )
    })

    //17
    it('Should fail to unpause because A is not an Authorized Agent', async () => {

        return UTIL_TKN.unpause(
            { from: A }
        )
    })


    it('Should revoke MINTER_ROLE from A', async () => {

        return UTIL_TKN.revokeRole(
            MINTER_ROLE,
            A,
            { from: MAIN }
        )
    })

    //18
    it('Should fail to mint 100 PRuf tokens to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.mint(
            B,
            "100000000000000000000",
            { from: A }
        )
    })


    it('Should grant PAUSER_ROLE to A', async () => {

        return UTIL_TKN.grantRole(
            PAUSER_ROLE,
            A,
            { from: MAIN }
        )
    })


    it('Should grant PAUSER_ROLE to C', async () => {

        return UTIL_TKN.grantRole(
            PAUSER_ROLE,
            C,
            { from: MAIN }
        )
    })

    //19
    it('Should fail to mint 100 PRuf tokens to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.mint(
            B,
            "100000000000000000000",
            { from: A }
        )
    })

    //20
    it('Should fail to burn 50 Pruf tokens from A because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentBurn(
            A,
            "50000000000000000000",
            { from: A }
        )
    })

    //21
    it('Should fail to transfer 50 Pruf tokens from A to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentTransfer(
            A,
            B,
            "50000000000000000000",
            { from: A }
        )
    })

    //22
    it('Should fail to payForService involving 50 PRuf tokens because A is not an Authorized Agent', async () => {

        return Helper.helper_payForService(
            "1",
            A,
            B,
            "25000000000000000000",
            C,
            "25000000000000000000",
            { from: A }
        )
    })


    it('Should pause', async () => {

        return UTIL_TKN.pause(
            { from: A }
        )
    })


    // it('Should pause', async () => {

    //     return UTIL_TKN.pause(
    //         { from: C }
    //     )
    // })

    //23
    it('Should fail to transfer 25 Pruf tokens from A to B because contract is paused', async () => {

        return UTIL_TKN.transfer(
            B,
            "25000000000000000000",
            { from: A }
        )
    })

    //24
    it('Should fail to transfer 25 Pruf tokens from B to A because contract is paused', async () => {

        return UTIL_TKN.transfer(
            A,
            "25000000000000000000",
            { from: B }
        )
    })

    //25
    it('Should fail to unpause becasue B is not an Authorized Agent', async () => {

        return UTIL_TKN.unpause(
            { from: B }
        )
    })


    it('Should unpause', async () => {

        return UTIL_TKN.unpause(
            { from: A }
        )
    })


    it('Should transfer 25 Pruf tokens from B to A', async () => {

        return UTIL_TKN.transfer(
            A,
            "25000000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(45) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(125) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(30) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should revoke PAUSER_ROLE from C', async () => {

        return UTIL_TKN.revokeRole(
            PAUSER_ROLE,
            C,
            { from: MAIN }
        )
    })

    //26
    it('Should fail to pause because C is not an Authorized Agent', async () => {

        return UTIL_TKN.pause(
            { from: C }
        )
    })


    it('Should revoke PAUSER_ROLE from A', async () => {

        return UTIL_TKN.revokeRole(
            PAUSER_ROLE,
            A,
            { from: MAIN }
        )
    })

    //27
    it('Should fail to pause because A is not an Authorized Agent', async () => {

        return UTIL_TKN.pause(
            { from: A }
        )
    })


    it('Should grant PAYABLE_ROLE to A', async () => {

        return UTIL_TKN.grantRole(
            PAYABLE_ROLE,
            A,
            { from: MAIN }
        )
    })

    //28
    it('Should fail to mint 100 PRuf tokens to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.mint(
            B,
            "100000000000000000000",
            { from: A }
        )
    })

    //29
    it('Should fail to burn 50 Pruf tokens from A because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentBurn(
            A,
            "50000000000000000000",
            { from: A }
        )
    })

    //30
    it('Should fail to transfer 50 Pruf tokens from A to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentTransfer(
            A,
            B,
            "50000000000000000000",
            { from: A }
        )
    })


    it('Should  involving 50 PRuf tokens', async () => {

        return Helper.helper_payForService(
            "1",
            B,
            A,
            "25000000000000000000",
            C,
            "25000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(70) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(75) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(55) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //31
    it('Should fail payForService involving 50 PRuf tokens because insufficiant balance', async () => {

        return Helper.helper_payForService(
            "1",
            A,
            B,
            "70000000000000000000",
            C,
            "10000000000000000000",
            { from: A }
        )
    })


    it('Should revoke PAYABLE_ROLE from A', async () => {

        return UTIL_TKN.revokeRole(
            PAYABLE_ROLE,
            A,
            { from: MAIN }
        )
    })

    //32
    it('Should fail to payForService involving 50 PRuf tokens because A is not an Authorized Agent', async () => {

        return Helper.helper_payForService(
            "1",
            A,
            B,
            "25000000000000000000",
            C,
            "25000000000000000000",
            { from: A }
        )
    })


    it('Should grant TRUSTED_AGENT_ROLE to A', async () => {

        return UTIL_TKN.grantRole(
            TRUSTED_AGENT_ROLE,
            A,
            { from: MAIN }
        )
    })

    //33
    it('Should fail to mint 100 PRuf tokens to B because A is not an Authorized Agent', async () => {

        return UTIL_TKN.mint(
            B,
            "100000000000000000000",
            { from: A }
        )
    })

    //34
    it('Should fail to payForService involving 50 PRuf tokens because A is not an Authorized Agent', async () => {

        return Helper.helper_payForService(
            "1",
            A,
            B,
            "25000000000000000000",
            C,
            "25000000000000000000",
            { from: A }
        )
    })


    it('Should burn 50 Pruf tokens from C', async () => {

        return UTIL_TKN.trustedAgentBurn(
            C,
            "50000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(70) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(75) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(5) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //35
    it('Should fail to transfer 10 Pruf tokens from C to A due to insufficient balance', async () => {

        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "10000000000000000000",
            { from: A }
        )
    })


    it('Should transfer 5 Pruf tokens from C to A', async () => {

        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "5000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(75) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(75) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should revoke TRUSTED_AGENT_ROLE from A', async () => {

        return UTIL_TKN.revokeRole(
            TRUSTED_AGENT_ROLE,
            A,
            { from: MAIN }
        )
    })

    //36
    it('Should fail to transfer 10 Pruf tokens from A to C because A is not an Authorized Agent', async () => {

        return UTIL_TKN.trustedAgentTransfer(
            C,
            A,
            "10000000000000000000",
            { from: A }
        )
    })


    it('Should transfer 75 Pruf tokens from A to C', async () => {

        return UTIL_TKN.transfer(
            C,
            "75000000000000000000",
            { from: A }
        )
    })


    it("Should retrieve balanceOf(0) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(75) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(75) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should transfer 75 Pruf tokens from B to C', async () => {

        return UTIL_TKN.transfer(
            C,
            "75000000000000000000",
            { from: B }
        )
    })


    it("Should retrieve balanceOf(0) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(150) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })

    //37
    it('Should fail to transfer 151 Pruf tokens from C to A due to insufficient balance', async () => {

        return UTIL_TKN.transfer(
            A,
            "151000000000000000000",
            { from: C }
        )
    })


    it("Should retrieve balanceOf(0) Pruf tokens @A", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(A, { from: A }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(0) Pruf tokens @B", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(B, { from: B }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(150) Pruf tokens @C", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(C, { from: C }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })
}
)