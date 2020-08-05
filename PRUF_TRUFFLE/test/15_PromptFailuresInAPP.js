    //
    //
    // SETUP
    //
    //

    contract('PRUF_APP', accounts => {
        
        const account1 = accounts[0];
        const account2 = accounts[1];
        const account3 = accounts[2];
        const account4 = accounts[3];
        const account5 = accounts[4];
        const account6 = accounts[5];
        const account7 = accounts[6];
        const account8 = accounts[7];
        const account9 = accounts[8];
        const account10 = accounts[9];

    it('Should mint a record in AC 11', async () => { //Put into escrow, used in ForceTransfer, Transfer
        return APP.$newRecord(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint a second record in AC 11', async () => { //Note added, used in AddNote
        return APP.$newRecord(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint a third record in AC 11', async () => { // Status changed, exported, used in Import
        return APP.$newRecord(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 10', async () => { //Bare custodial record, Used all over
        return APP.$newRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            '5000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should mint a second record in AC 10', async () => { // Used in import 
        return APP.$newRecord(
            '0xaa31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            '5000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should mint a third record in AC 10', async () => { // Transferred, not claimed, used in status !== status 5 checks 
        return APP.$newRecord(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            '5000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 13', async () => { //unused
        return APP_NC.$newRecord(
            '0xab31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '13',
            '5000',
            { from: account5, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 14', async () => { //Bare NC record, used in custody checks
        return APP_NC.$newRecord(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            '5000',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should mint a second record in AC 14', async () => { //unused
        return APP_NC.$newRecord(
            '0xc531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            '5000',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should change status of asset 0xf531 to 51 for export eligibility', async () => {
        return NP._modStatus(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '51',
            { from: account3 }
        )
    })

    it('Should change status of asset 0xbb31 to 1 for transfer eligibility', async () => {
        return NP._modStatus(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '1',
            { from: account2 }
        )
    })

    it('Should put asset 0xd531 into an escrow', async () => {
        return ECR.setEscrow(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '30',
            '6',
            { from: account3 }
        )
    })

    it('Should add asset note to asset 0xe531', async () => {
        return APP.$addIpfs2Note(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should transfer asset 0xbb31 to unclaimed', async () => { // Transferred, not claimed, used in status !== status 5 checks 
        return APP.$transferAsset(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0x0000000000000000000000000000000000000000000000000000000000000000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should export asset 0xf531 to account2 in AC10', async () => {
        return APP.exportAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            APP.address,
            { from: account3 }
        )
    })

    //
    //
    // END SETUP
    //
    //

    //
    //
    // APP FAILBATCH
    //
    //

    //EXPORT ASSET
    //1
    it('Should fail to export asset due to non-custodial AC type (FAILS IN ISAUTHORIZED MOD)', async () => {
        return APP.exportAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            account10,
            { from: account6 }
        )
    })
    //2
    it('Should fail to export asset due to user ineligibility in AC', async () => {
        return APP.exportAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            account10,
            { from: account6 }
        )
    })
    
    /* it('Should log the short record of asset 0x3531 before attempt to export', async () => {
        let asset = await STOR.retrieveShortRecord('0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d')
        return console.log(asset)
    }) */

    //3
    it('Should fail to export asset due to asset status !== 51', async () => {
        return APP.exportAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            account10,
            { from: account2 }
        )
    }) //END EXPORT ASSET


    //FORCETRANSFER ASSET
    //4
    it('Should fail to forceTransfer the record due to non-custodial AC type', async () => {
        return APP.$forceModRecord(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account6, value: 20000000000000000 }
        )
    })
    //5
    it('Should fail to forceTransfer the record due to nonexistance', async () => {
        return APP.$forceModRecord(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //6
    it('Should fail to forceTransfer the record due to nonHuman user type', async () => {
        return APP.$forceModRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account7, value: 20000000000000000 }
        )
    })
    //7
    it('Should fail to forceTransfer the record due to empty NRH field', async () => {
        return APP.$forceModRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0000000000000000000000000000000000000000000000000000000000000000',
            { from: account2, value: 20000000000000000 }
        )
    })
    //SHOULD PASS
    it('Should change status to 3', async () => {
        return NP._setLostOrStolen(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '3',
            { from: account2 }
        )
    })
    //8
    it('Should fail to forceTransfer the record due to lost or stolen status', async () => {
        return APP.$forceModRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //9
    it('Should fail to forceTransfer the record due to escrow status', async () => {
        return APP.$forceModRecord(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account3, value: 20000000000000000 }
        )
    })
    //10
    it('Should fail to forceTransfer asset due to transferred/unclaimed status', async () => {
        return APP.$forceModRecord(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    }) //END FORCETRANSFER ASSET
    
    


    // TRANSFER ASSET
    //11
    it('Should fail to transfer the record due to non-custodial AC type', async () => {
        return APP.$transferAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account6, value: 20000000000000000 }
        )
    })

    //12
    it('Should fail to transfer the record due to asset nonexistance', async () => {
        return APP.$transferAsset(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //13
    it('Should fail to transfer the record due to user ineligibility in AC', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account3, value: 20000000000000000 }
        )
    })
    //14
    it('Should fail to transfer the record due to userType > 5 && assetStatus < 50', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account8, value: 20000000000000000 }
        )
    })
    //15
    it('Should fail to transfer the record due to status nontransferrable', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //SHOULD PASS
    it('Should change status to 1', async () => {
        return NP._modStatus(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '1',
            { from: account2 }
        )
    })
    //16    
    it('Should fail to transfer the record due to rgtHash mismatch', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee60',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //SHOULD PASS    
    it('Should change status to 0', async () => {
        return NP._modStatus(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0',
            { from: account2 }
        )
    })//END TRANSFER ASSET

    
    //ADD NOTE 
    //17
    it('Should fail to add asset note due to non-custodial AC type', async () => {
        return APP.$addIpfs2Note(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account6, value: 20000000000000000 }
        )
    })
    //18
    it('Should fail to add asset note due to asset nonexistence', async () => {
        return APP.$addIpfs2Note(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account6, value: 20000000000000000 }
        )
    })
    //19
    it('Should fail to add asset note due to user ineligibility in AC', async () => {
        return APP.$addIpfs2Note(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account6, value: 20000000000000000 }
        )
    })
    //20
    it('Should fail to add asset note due to escrow status', async () => {
        return APP.$addIpfs2Note(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account3, value: 20000000000000000 }
        )
    })
    //21
    it('Should fail to add asset note due to rgtHash mismatch', async () => {
        return APP.$addIpfs2Note(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account2, value: 20000000000000000 }
        )
    })
    //22
    it('Should fail to add asset note due to existing note', async () => {
        return APP.$addIpfs2Note(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account3, value: 20000000000000000 }
        )
    })
    //23
    it('Should fail to add asset note due to transferred/unclaimed status', async () => {
        return APP.$addIpfs2Note(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account2, value: 20000000000000000 }
        )
    }) //END ADD NOTE


    //IMPORT ASSET
    //24
    it('Should fail to import an asset due to non-custodial AC type', async () => {
        return APP.$importAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            { from: account6, value: 20000000000000000 }
        )
    })
    //25
    it('Should fail to import an asset due to asset nonexistence', async () => {
        return APP.$importAsset(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            { from: account6, value: 20000000000000000 }
        )
    })
    //26
    it('Should fail to import an asset due to userType > 3', async () => {
        return APP.$importAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            { from: account8, value: 20000000000000000 }
        )
    })
    //27
    it('Should fail to import an asset due to user ineligibility in AC', async () => {
        return APP.$importAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            { from: account3, value: 20000000000000000 }
        )
    })
    //28
    it('Should fail to import an asset due to attempted change of root AC', async () => {
        return APP.$importAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            { from: account6, value: 20000000000000000 }
        )
    })
    //29
    it('Should fail to import an asset due to nonExported status', async () => {
        return APP.$importAsset(
            '0xaa31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            { from: account2, value: 20000000000000000 }
        )
    })

    //
    //
    // END APP FAILBATCH
    //
    //

});

