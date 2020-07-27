const Storage = artifacts.require('Storage');
const PRUF_APP = artifacts.require('PRUF_APP');
const PRUF_NP = artifacts.require('PRUF_NP');
const PRUF_AC_MGR = artifacts.require('PRUF_AC_MGR');
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


contract('PRUF_AC_MGR', () => {
    it('Should deploy PRUF_AC_MGR', async () => {
        const PRUF_AC_MGR_TEST = await PRUF_AC_MGR.deployed();
        console.log(PRUF_AC_MGR_TEST.address);
        assert(PRUF_AC_MGR_TEST.address !== '');
    });

})


contract('PRUF_APP', () => {
    it('Should deploy Pruf_app', async () => {
        const PRUF_APP_TEST = await PRUF_APP.deployed();
        console.log(PRUF_APP_TEST.address);
        assert(PRUF_APP_TEST.address !== '');
    });

});