const Storage = artifacts.require('Storage');
const PRUF_APP = artifacts.require('PRUF_APP');
const PRUF_NP = artifacts.require('PRUF_NP');
const PRUF_AC_MGR = artifacts.require('PRUF_AC_MGR');
const PRUF_simpleEscrow = artifacts.require('PRUF_simpleEscrow');

contract('PRUF_FULL_TEST', accounts  => {

    const account1 = accounts[0];
    const account2 = accounts[1];
    const account3 = accounts[2];
    const account4 = accounts[3];

    let STOR;
    let APP;
    let NP;
    let MGR;
    let ECR;

    it('Should deploy Storage', async () => {
        const PRUF_STORAGE_TEST = await Storage.deployed({from: account1});
        console.log(PRUF_STORAGE_TEST.address);
        assert(PRUF_STORAGE_TEST.address !== '');
        STOR = PRUF_STORAGE_TEST;
    });
    it('Should deploy PRUF_NP', async () => {
        const PRUF_NP_TEST = await PRUF_NP.deployed({from: account1});
        console.log(PRUF_NP_TEST.address);
        assert(PRUF_NP_TEST.address !== '');
        NP = PRUF_NP_TEST;
    });
    it('Should deploy simpleEscrow', async () => {
        const PRUF_ECR_TEST = await PRUF_simpleEscrow.deployed({from: account1});
        console.log(PRUF_ECR_TEST.address);
        assert(PRUF_ECR_TEST.address !== '');
        ECR = PRUF_ECR_TEST;
    });
    it('Should deploy PRUF_AC_MGR', async () => {
        const PRUF_AC_MGR_TEST = await PRUF_AC_MGR.deployed({from: account1});
        console.log(PRUF_AC_MGR_TEST.address);
        assert(PRUF_AC_MGR_TEST.address !== '');
        MGR = PRUF_AC_MGR_TEST;
    });
    it('Should deploy PRUF_APP', async () => {
        const PRUF_APP_TEST = await PRUF_APP.deployed({from: account1});
        console.log(PRUF_APP_TEST.address);
        assert(PRUF_APP_TEST.address !== '')
        APP = PRUF_APP_TEST;
    })

    it('Should add contract addresses', async () => {

        return STOR.OO_addContract("PRUF_APP", APP.address, '3', {from: account1})
        .then(()=>{ 
        return STOR.OO_addContract("PRUF_NP", NP.address, '3', {from: account1})
        }).then(()=>{ 
        return STOR.OO_addContract("AC_MGR", MGR.address, '3', {from: account1})
        }).then(()=>{ 
        return STOR.OO_addContract("ECR", ECR.address, '3', {from: account1})
        })

    })

    it('Should resolve contract addresses', async () => {
        console.log("Resolving in APP")
        return APP.OO_ResolveContractAddresses({from: account1})
        .then(() => {
        console.log("Resolving in NP")
        return NP.OO_ResolveContractAddresses({from: account1})
        }).then(() => {
        console.log("Resolving in MGR")
        return MGR.OO_ResolveContractAddresses({from: account1})
        }).then(() => {
        console.log("Resolving in ECR")
        return ECR.OO_ResolveContractAddresses({from: account1})
        })
    })

});