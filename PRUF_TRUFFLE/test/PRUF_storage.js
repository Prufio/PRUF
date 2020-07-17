const Storage = artifacts.require('Storage');

contract('Storage', () => {
    it('Should deploy smart contract properly', async () => {
        const PRUF_storage_065 = await Storage.deployed();
        console.log(PRUF_storage_065.address);
        assert(PRUF_storage_065.address !== '');
    });
});