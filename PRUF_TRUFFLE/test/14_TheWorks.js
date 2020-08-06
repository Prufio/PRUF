let STOR;
let APP;
let NP;
let AC_MGR;
let AC_TKN;
let A_TKN;
let ECR_MGR;
let ECR;
let ECR_NC;
let APP_NC;
let NP_NC;
let RCLR;


const launchContracts = async () => {
    const fs = require('fs');
    const PRUF_STOR = artifacts.require('STOR');
    const PRUF_APP = artifacts.require('APP');
    const PRUF_NP = artifacts.require('NP');
    const PRUF_AC_MGR = artifacts.require('AC_MGR');
    const PRUF_AC_TKN = artifacts.require('AC_TKN');
    const PRUF_A_TKN = artifacts.require('A_TKN');
    const PRUF_ECR_MGR = artifacts.require('ECR_MGR');
    const PRUF_ECR = artifacts.require('ECR');
    const PRUF_APP_NC = artifacts.require('APP_NC');
    const PRUF_NP_NC = artifacts.require('NP_NC');
    const PRUF_ECR_NC = artifacts.require('ECR_NC');
    const PRUF_RCLR = artifacts.require('RCLR');

    fs.readFile('contracts.json', 'utf8', async function readFileCallback(err, data) {
        let contracts;
        if (err) {
            console.log(err);
        } else {
            console.log('Successful file read: ')
            contracts = JSON.parse(data);
            console.log('parsed data: ', contracts);
            console.log('parsed data element: ', contracts.content[0]);
        }
        STOR = await PRUF_STOR.at(contracts.content[0]);
        APP = await PRUF_APP.at(contracts.content[1]);
        NP = await PRUF_NP.at(contracts.content[2]);
        AC_MGR = await PRUF_AC_MGR.at(contracts.content[3]);
        AC_TKN = await PRUF_AC_TKN.at(contracts.content[4]);
        A_TKN = await PRUF_A_TKN.at(contracts.content[5]);
        ECR_MGR = await PRUF_ECR_MGR.at(contracts.content[6]);
        ECR = await PRUF_ECR.at(contracts.content[7]);
        ECR_NC = await PRUF_APP_NC.at(contracts.content[8]);
        APP_NC = await PRUF_NP_NC.at(contracts.content[9]);
        NP_NC = await PRUF_ECR_NC.at(contracts.content[10]);
        RCLR = await PRUF_RCLR.at(contracts.content[11]);
    });
}

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

    it('Should launch contracts', async () => {
        await launchContracts();
        return(APP.address);
    })

    /* it('Should get contract addresses', async () => {
        const fs = require('fs');
        fs.readFile('contracts.json', 'utf8', async function readFileCallback(err, data) {
            if (err) {
                console.log(err);
            } else {
                console.log('Successful file read: ')
                contracts = JSON.parse(data);
                console.log('parsed data: ', contracts);

                return console.log('parsed data element: ', contracts.content[0]);

            }
        });
        return;
    }) */

    /* it('Should build contracts at given addresses', async () => {
        console.log('attempting to use addresses: ', contracts);
        console.log('Storage address: ', contracts.content[0]);

        let _STOR = await PRUF_STOR.at(contracts.content[0]);
        let _APP = await PRUF_APP.at(contracts.content[1]);
        let _NP = await PRUF_NP.at(contracts.content[2]);
        let _AC_MGR = await PRUF_AC_MGR.at(contracts.content[3]);
        let _AC_TKN = await PRUF_AC_TKN.at(contracts.content[4]);
        let _A_TKN = await PRUF_A_TKN.at(contracts.content[5]);
        let _ECR_MGR = await PRUF_ECR_MGR.at(contracts.content[6]);
        let _ECR = await PRUF_ECR.at(contracts.content[7]);
        let _ECR_NC = await PRUF_APP_NC.at(contracts.content[8]);
        let _APP_NC = await PRUF_NP_NC.at(contracts.content[9]);
        let _NP_NC = await PRUF_ECR_NC.at(contracts.content[10]);
        let _RCLR = await PRUF_RCLR.at(contracts.content[11]);

        STOR = _STOR;
        APP = _APP;
        NP = _NP;
        AC_MGR = _AC_MGR;
        AC_TKN = _AC_TKN;
        A_TKN = _A_TKN;
        ECR_MGR = _ECR_MGR;
        ECR = _ECR;
        ECR_NC = _ECR_NC;
        APP_NC = _APP_NC;
        NP_NC = _NP_NC;
        RCLR = _RCLR;
        
    }) */

    console.log("Running record tests")
    it('Should write record in AC 10 @ IDX&RGT(1)', async () => {

        return APP.$newRecord(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '10',
            '100',
            { from: account2, value: 20000000000000000 }
        )
    })


    it('Should change status of new record(5) to status(1)', async () => {
        return NP._modStatus(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '1',
            { from: account2 }
        )
    })


    it('Should Transfer record(5) RGT(1) to RGT(2)', async () => {
        return APP.$transferAsset(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '0x5d5d1ee487d05f715ddd883e185ff5b672bed217ac7f9ab3073b39b19762ce8b',
            { from: account2, value: 20000000000000000 }
        )
    })


    it('Should force modify record(5) RGT(2) to RGT(1)', async () => {
        return APP.$forceModRecord(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            { from: account2, value: 20000000000000000 }
        )
    })


    it('Should change decrement amount @record(5) from (100) to (85)', async () => {
        return NP._decCounter(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '15',
            { from: account2 }
        )
    })


    it('Should modify Ipfs1 note @record(5) to IDX(1)', async () => {
        return NP._modIpfs1(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            { from: account2 }
        )
    })


    it('Should change status of new record(5) to status(51)', async () => {
        return NP._modStatus(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '51',
            { from: account2 }
        )
    })


    it('Should export record(5) to account2', async () => {
        return APP.exportAsset(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            account2,
            { from: account2 }
        )
    })


    it('Should import record(5) to AC(12)(NC)', async () => {
        return APP_NC.$importAsset(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '12',
            { from: account2, value: 20000000000000000 }
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
            { from: account2, value: 20000000000000000 }
        )
    })


    it('Should set Ipfs2 note to IDX(1)', async () => {
        return APP_NC.$addIpfs2Note(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            { from: account2, value: 20000000000000000 }
        )
    })


    it('Should change status of record(5) to status(51)', async () => {
        return NP_NC._modStatus(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '51',
            { from: account2 }
        )
    })


    it('Should set record(5) into escrow for 3 minutes', async () => {
        return ECR_NC.setEscrow(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0xdd4238c78de8c3b265f806a08e56dceae2142cf9514c5038157c71dd6396bf37',
            '180',
            '56',
            { from: account2 }
        )
    })


    it('Should take record(5) out of escrow', async () => {
        return ECR_NC.endEscrow(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            { from: account2 }
        )
    })


    it('Should change decrement amount @record(5) from (85) to (70)', async () => {
        return NP_NC._decCounter(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '15',
            { from: account2 }
        )
    })


    it('Should force modify record(5) RGT(1) to RGT(2)', async () => {
        return NP_NC._changeRgt(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x5d5d1ee487d05f715ddd883e185ff5b672bed217ac7f9ab3073b39b19762ce8b',
            { from: account2 }
        )
    })


    it('Should modify Ipfs1 note @record(5) to RGT(1)', async () => {
        return NP_NC._modIpfs1(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            { from: account2 }
        )
    })


    it('Should export record(5)(status70)', async () => {
        return NP_NC._exportNC(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            { from: account2 }
        )
    })


    it('Should transfer record(5) token to PRUF_APP contract', async () => {
        return A_TKN.safeTransferFrom(
            account2,
            APP.address,
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            { from: account2 }
        )
    })


    it('Should import record(5) to AC(11)', async () => {
        return APP.$importAsset(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '11',
            { from: account2, value: 20000000000000000 }
        )
    })


    it('Should change status of record(5) to status(1)', async () => {
        return NP._modStatus(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '1',
            { from: account2 }
        )
    })


    it('Should set record(5) into locked escrow for 3 minutes', async () => {
        return ECR.setEscrow(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0xdd4238c78de8c3b265f806a08e56dceae2142cf9514c5038157c71dd6396bf37',
            '180',
            '50',
            { from: account2 }
        )
    })


    it('Should take record(5) out of escrow', async () => {
        return ECR.endEscrow(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            { from: account2 }
        )
    })


    it('Should change status of record(5) to status(1)', async () => {
        return NP._modStatus(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '1',
            { from: account2 }
        )
    })


    it('Should set record(5) into escrow for 3 minutes', async () => {
        return ECR.setEscrow(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0xdd4238c78de8c3b265f806a08e56dceae2142cf9514c5038157c71dd6396bf37',
            '180',
            '6',
            { from: account2 }
        )
    })


    it('Should set record(5) to stolen(3) status', async () => {
        return NP._setLostOrStolen(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '3',
            { from: account2 }
        )
    })


    it('Should change status of record(5) to status(1)', async () => {
        return NP._modStatus(
            '0x54504a0f5147c9104ec2eb44b310674a57a337acd90083d946c3fd39bac4f2b2',
            '0x0e69eb84e028dc5e631c372e69871d1b072a1ebc12266e477c71b90d89d4008f',
            '1',
            { from: account2 }
        )
    })

});