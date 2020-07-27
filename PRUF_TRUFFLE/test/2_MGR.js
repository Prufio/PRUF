const PRUF_AC_MGR = artifacts.require('PRUF_AC_MGR')

contract('PRUF_AC_MGR', () => {
    it('Should deploy PRUF_AC_MGR', async () => {
        const PRUF_AC_MGR_TEST = await PRUF_AC_MGR.deployed();
        console.log(PRUF_AC_MGR_TEST.address);
        assert(PRUF_AC_MGR_TEST.address !== '');
    });

})