const PRUF_APP = artifacts.require('PRUF_APP');
const Storage = artifacts.require('Storage');
const PRUF_NP = artifacts.require('PRUF_NP') 

contract('Storage', () => {
    it('Should deploy Storage properly', async () => {
        const PRUF_STORAGE_TEST = await Storage.deployed();
        console.log(PRUF_STORAGE_TEST.address);
        assert(PRUF_STORAGE_TEST.address !== '');

        
    });

    it('Should add contr ')

});

contract('PRUF_NP', () => {
    it('Should deploy PRUF_NP properly', async () => {
        const PRUF_NP_TEST = await PRUF_NP.deployed();
        console.log(PRUF_NP_TEST.address);
        assert(PRUF_NP_TEST.address !== '');

        
    });

    it("should change asset status to 1", async () => {
        let _idxHash = "0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d";
        let _rgtHash = "0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f";
        let _assetClass = "10";
        let hash = instance.addExam().call(hash_test, {from: accounts[0]});
        assert.equal(hash.valueOf(), hash_test, "Not returning the correct address")
    })

});

contract('PRUF_APP', () => {
    it('Should deploy Pruf_app properly', async () => {
        const PRUF_APP_TEST = await PRUF_APP.deployed();
        console.log(PRUF_APP_TEST.address);
        assert(PRUF_APP_TEST.address !== '');
    });

    it("should add a record to storage", async () => {
        let _idxHash = "0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d";
        let _rgtHash = "0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f";
        let _assetClass = "10";
        let hash = instance.addExam().call(hash_test, {from: accounts[0]});
        assert.equal(hash.valueOf(), hash_test, "Not returning the correct address")
    })

});

