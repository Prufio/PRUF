const Storage = artifacts.require('Storage');

contract('Storage', () => {
    it('Should deploy Storage', async () => {
        const PRUF_STORAGE_TEST = await Storage.deployed();
        console.log(PRUF_STORAGE_TEST.address);
        assert(PRUF_STORAGE_TEST.address !== '');
    });

});