const PRUF_APP = artifacts.require('PRUF_APP');
const Storage = artifacts.require('Storage');
const PRUF_NP = artifacts.require('PRUF_NP');
const PRUF_AC_manager = artifacts.require('PRUF_AC_MGR');
const PRUF_simpleEscrow = artifacts.require('PRUF_simpleEscrow');

contract('Storage', () => {
    it('Should deploy Storage', async () => {
        const PRUF_STORAGE_TEST = await Storage.deployed();
        console.log(PRUF_STORAGE_TEST.address);
        assert(PRUF_STORAGE_TEST.address !== '');
    });

});

contract('PRUF_NP', () => {
    it('Should deploy PRUF_NP', async () => {
        const PRUF_NP_TEST = await PRUF_NP.deployed();
        console.log(PRUF_NP_TEST.address);
        assert(PRUF_NP_TEST.address !== '');
    });

});

contract('PRUF_APP', () => {
    it('Should deploy Pruf_app', async () => {
        const PRUF_APP_TEST = await PRUF_APP.deployed();
        console.log(PRUF_APP_TEST.address);
        assert(PRUF_APP_TEST.address !== '');
    });

});

contract('PRUF_AC_manager', () => {
    it('Should deploy PRUF_AC_manager', async () => {
        const PRUF_AC_MANAGER_TEST = await PRUF_AC_manager.deployed();
        console.log(PRUF_AC_MANAGER_TEST.address);
        assert(PRUF_AC_MANAGER_TEST.address !== '');
    });

})

contract('PRUF_simpleEscrow', () => {
    it('Should deploy PRUF_simpleEscrow', async () => {
        const PRUF_AC_MANAGER_TEST = await PRUF_AC_manager.deployed();
        console.log(PRUF_AC_MANAGER_TEST.address);
        assert(PRUF_AC_MANAGER_TEST.address !== '');
    });

})


