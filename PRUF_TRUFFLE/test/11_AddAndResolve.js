const PRUF_STOR = artifacts.require('STOR');
const PRUF_APP = artifacts.require('APP');
const PRUF_NP = artifacts.require('NP');
const PRUF_AC_MGR = artifacts.require('AC_MGR');
const PRUF_AC_TKN = artifacts.require('AC_TKN');
const PRUF_A_TKN = artifacts.require('A_TKN');
const PRUF_ECR_MGR = artifacts.require('ECR_MGR');
const PRUF_ECR = artifacts.require('ECR');
const PRUF_APP_NC = artifacts.require('APP_NC');
const PRUF_NP_NC = artifacts.require('NP_NC');
const PRUF_ECR_NC = artifacts.require('ECR_NC');
const PRUF_RCLR = artifacts.require('RCLR');

contract('PRUF_FULL_TEST', accounts  => {

    const account1 = accounts[0];
    const account2 = accounts[1];
    const account3 = accounts[2];
    const account4 = accounts[3];

    let STOR;
    let APP;
    let NP;
    let AC_MGR;
    let AC_TKN;
    let A_TKN;
    let ECR_MGR;
    let ECR;
    let ECR_NC;
    let APP_NC;
    let NP_NC;
    let RCLR;


    it('Should deploy Storage', async () => {
        const PRUF_STOR_TEST = await PRUF_STOR.deployed({from: account1});
        console.log(PRUF_STOR_TEST.address);
        assert(PRUF_STOR_TEST.address !== '');
        STOR = PRUF_STOR_TEST;
    });
    it('Should deploy PRUF_APP', async () => {
        const PRUF_APP_TEST = await PRUF_APP.deployed({from: account1});
        console.log(PRUF_APP_TEST.address);
        assert(PRUF_APP_TEST.address !== '');
        APP = PRUF_APP_TEST;
    });
    it('Should deploy PRUF_NP', async () => {
        const PRUF_NP_TEST = await PRUF_NP.deployed({from: account1});
        console.log(PRUF_NP_TEST.address);
        assert(PRUF_NP_TEST.address !== '');
        NP = PRUF_NP_TEST;
    });
    it('Should deploy PRUF_AC_MGR', async () => {
        const PRUF_AC_MGR_TEST = await PRUF_AC_MGR.deployed({from: account1});
        console.log(PRUF_AC_MGR_TEST.address);
        assert(PRUF_AC_MGR_TEST.address !== '');
        AC_MGR = PRUF_AC_MGR_TEST;
    });
    it('Should deploy PRUF_AC_TKN', async () => {
        const PRUF_AC_TKN_TEST = await PRUF_AC_TKN.deployed({from: account1});
        console.log(PRUF_AC_TKN_TEST.address);
        assert(PRUF_AC_TKN_TEST.address !== '')
        AC_TKN = PRUF_AC_TKN_TEST;
    });
    it('Should deploy PRUF_A_TKN', async () => {
        const PRUF_A_TKN_TEST = await PRUF_A_TKN.deployed({from: account1});
        console.log(PRUF_A_TKN_TEST.address);
        assert(PRUF_A_TKN_TEST.address !== '')
        A_TKN = PRUF_A_TKN_TEST;
    });
    it('Should deploy PRUF_ECR_MGR', async () => {
        const PRUF_ECR_MGR_TEST = await PRUF_ECR_MGR.deployed({from: account1});
        console.log(PRUF_ECR_MGR_TEST.address);
        assert(PRUF_ECR_MGR_TEST.address !== '');
        ECR_MGR = PRUF_ECR_MGR_TEST;
    });
    it('Should deploy PRUF_ECR', async () => {
        const PRUF_ECR_TEST = await PRUF_ECR.deployed({from: account1});
        console.log(PRUF_ECR_TEST.address);
        assert(PRUF_ECR_TEST.address !== '');
        ECR = PRUF_ECR_TEST;
    });
    it('Should deploy PRUF_APP_NC', async () => {
        const PRUF_APP_NC_TEST = await PRUF_APP_NC.deployed({from: account1});
        console.log(PRUF_APP_NC_TEST.address);
        assert(PRUF_APP_NC_TEST.address !== '');
        APP_NC = PRUF_APP_NC_TEST;
    });
    it('Should deploy PRUF_NP_NC', async () => {
        const PRUF_NP_NC_TEST = await PRUF_NP_NC.deployed({from: account1});
        console.log(PRUF_NP_NC_TEST.address);
        assert(PRUF_NP_NC_TEST.address !== '')
        NP_NC = PRUF_NP_NC_TEST;
    });
    it('Should deploy PRUF_ECR_NC', async () => {
        const PRUF_ECR_NC_TEST = await PRUF_ECR_NC.deployed({from: account1});
        console.log(PRUF_ECR_NC_TEST.address);
        assert(PRUF_ECR_NC_TEST.address !== '');
        ECR_NC = PRUF_ECR_NC_TEST;
    });
    it('Should deploy PRUF_RCLR', async () => {
        const PRUF_RCLR_TEST = await PRUF_RCLR.deployed({from: account1});
        console.log(PRUF_RCLR_TEST.address);
        assert(PRUF_RCLR_TEST.address !== '')
        RCLR = PRUF_RCLR_TEST;
    });

    it('Should add contract addresses', async () => {

        return STOR.OO_addContract("APP", APP.address, '1', {from: account1})

        .then(()=>{
        return STOR.OO_addContract("NP", NP.address, '1', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("AC_MGR", AC_MGR.address, '1', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("AC_TKN", AC_TKN.address, '1', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("A_TKN", A_TKN.address, '1', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("ECR_MGR", ECR_MGR.address, '1', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("ECR", ECR.address, '3', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("APP_NC", APP_NC.address, '1', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("NP_NC", NP_NC.address, '1', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("ECR_NC", ECR_NC.address, '3', {from: account1})

        }).then(()=>{
        return STOR.OO_addContract("RCLR", RCLR.address, '3', {from: account1})
        
        })
    })

    it('Should resolve contract addresses', async () => {
        console.log("Resolving in APP")
        return APP.OO_ResolveContractAddresses({from: account1})
        
        .then(() => {
        console.log("Resolving in NP")
        return NP.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in AC_MGR")
        return AC_MGR.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in AC_TKN")
        return AC_TKN.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in A_TKN")
        return A_TKN.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in ECR_MGR")
        return ECR_MGR.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in ECR")
        return ECR.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in APP_NC")
        return APP_NC.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in NP_NC")
        return NP_NC.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in ECR_NC")
        return ECR_NC.OO_ResolveContractAddresses({from: account1})

        }).then(() => {
        console.log("Resolving in RCLR")
        return RCLR.OO_ResolveContractAddresses({from: account1})

        })
    })

});