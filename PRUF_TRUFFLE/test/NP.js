const PRUF_NP = artifacts.require('PRUF_NP');

contract('PRUF_NP', () => {
    it('Should deploy PRUF_NP', async () => {
        const PRUF_NP_TEST = await PRUF_NP.deployed();
        console.log(PRUF_NP_TEST.address);
        assert(PRUF_NP_TEST.address !== '');
    });

});