const PRUF_APP = artifacts.require('PRUF_APP');

contract('PRUF_APP', () => {
    it('Should deploy Pruf_app', async () => {
        const PRUF_APP_TEST = await PRUF_APP.deployed();
        console.log(PRUF_APP_TEST.address);
        assert(PRUF_APP_TEST.address !== '');
    });

});