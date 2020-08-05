
contract('PRUF_THE_WORKS', accounts => {

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

    console.log("Running record tests")
    it('Should write record in AC 10 @ IDX&RGT(1)', async () => {
        
        return APP.$newRecord(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change status of new record(5) to status(1)', async () => {
        return NP._modStatus(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '1',
        {from: account2}
        )
    })


    it('Should Transfer record(5) RGT(1) to RGT(2)', async () => {
        return APP.$transferAsset(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '0x5d5d1ee487d05f715ddd883e185ff5b672bed217ac7f9ab3073b39b19762ce8b',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should force modify record(5) RGT(2) to RGT(1)', async () => {
        return APP.$forceModRecord(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change decrement amount @record(5) from (100) to (85)', async () => {
        return NP._decCounter(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '15',
        {from: account2}
        )
    })


    it('Should modify Ipfs1 note @record(5) to IDX(1)', async () => {
        return NP._modIpfs1(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        {from: account2}
        )
    })


    it('Should change status of new record(5) to status(51)', async () => {
        return NP._modStatus(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '51',
        {from: account2}
        )
    })


    it('Should export record(5) to account2', async () => {
        return APP.exportAsset(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        account2,
        {from: account2}
        )
    })


    it('Should import record(5) to AC(12)(NC)', async () => {
        return APP_NC.$importAsset(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        '12',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should re-mint record(5) token to account2', async () => {
        return APP_NC.$reMintToken(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        '1',
        '1',
        '1',
        '1',
        '1',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should set Ipfs2 note to IDX(1)', async () => {
        return APP_NC.$addIpfs2Note(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change status of record(5) to status(51)', async () => {
        return NP_NC._modStatus(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '51',
        {from: account2}
        )
    })


    it('Should set record(5) into escrow for 3 minutes', async () => {
        return ECR_NC.setEscrow(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0xdd4238c78de8c3b265f806a08e56dceae2142cf9514c5038157c71dd6396bf37',
        '180',
        '56',
        {from: account2}
        )
    })


    it('Should take record(5) out of escrow', async () => {
        return ECR_NC.endEscrow(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        {from: account2}
        )
    })


    it('Should change decrement amount @record(5) from (85) to (70)', async () => {
        return NP_NC._decCounter(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '15',
        {from: account2}
        )
    })


    it('Should force modify record(5) RGT(1) to RGT(2)', async () => {
        return NP_NC._changeRgt(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x5d5d1ee487d05f715ddd883e185ff5b672bed217ac7f9ab3073b39b19762ce8b',
        {from: account2}
        )
    })


    it('Should modify Ipfs1 note @record(5) to RGT(1)', async () => {
        return NP_NC._modIpfs1(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        {from: account2}
        )
    })


    it('Should export record(5)(status70)', async () => {
        return NP_NC._exportNC(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        {from: account2}
        )
    })


    it('Should transfer record(5) token to PRUF_APP contract', async () => {
        return A_TKN.safeTransferFrom(
        account2,
        APP.address,
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        {from: account2}
        )
    })


    it('Should import record(5) to AC(11)', async () => {
        return APP.$importAsset(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '11',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change status of record(5) to status(1)', async () => {
        return NP._modStatus(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '1',
        {from: account2}
        )
    })


    it('Should set record(5) into locked escrow for 3 minutes', async () => {
        return ECR.setEscrow(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0xdd4238c78de8c3b265f806a08e56dceae2142cf9514c5038157c71dd6396bf37',
        '180',
        '50',
        {from: account2}
        )
    })


    it('Should take record(5) out of escrow', async () => {
        return ECR.endEscrow(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        {from: account2}
        )
    })


    it('Should change status of record(5) to status(1)', async () => {
        return NP._modStatus(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '1',
        {from: account2}
        )
    })


    it('Should set record(5) into escrow for 3 minutes', async () => {
        return ECR.setEscrow(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0xdd4238c78de8c3b265f806a08e56dceae2142cf9514c5038157c71dd6396bf37',
        '180',
        '6',
        {from: account2}
        )
    })


    it('Should set record(5) to stolen(3) status', async () => {
        return NP._setLostOrStolen(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '3',
        {from: account2}
        )
    })


    it('Should change status of record(5) to status(1)', async () => {
        return NP._modStatus(
        '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2', 
        '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
        '1',
        {from: account2}
        )
    })

});