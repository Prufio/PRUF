/*--------------------------------------------------------PRüF0.8.6
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

        const PRUF_STOR = artifacts.require('STOR');
        const PRUF_APP = artifacts.require('APP');
        const PRUF_APP = artifacts.require('APP');
        const PRUF_NODE_MGR = artifacts.require('NODE_MGR');
        const PRUF_NODE_TKN = artifacts.require('NODE_TKN');
        const PRUF_A_TKN = artifacts.require('A_TKN');
        const PRUF_ID_MGR = artifacts.require('ID_MGR');
        const PRUF_ECR_MGR = artifacts.require('ECR_MGR');
        const PRUF_ECR = artifacts.require('ECR');
        const PRUF_ECR2 = artifacts.require('ECR2');
        const PRUF_APP_NC = artifacts.require('APP_NC');
        const PRUF_APP_NC = artifacts.require('APP_NC');
        const PRUF_ECR_NC = artifacts.require('ECR_NC');
        const PRUF_RCLR = artifacts.require('RCLR');
        const PRUF_HELPER = artifacts.require('Helper');
        const PRUF_MAL_APP = artifacts.require('MAL_APP');
        const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
        const PRUF_PURCHASE = artifacts.require('PURCHASE');
        const PRUF_DECORATE = artifacts.require('DECORATE');
        const PRUF_WRAP = artifacts.require('WRAP');
        
        let STOR;
        let APP;
        let APP;
        let NODE_MGR;
        let NODE_TKN;
        let A_TKN;
        let ID_MGR;
        let ECR_MGR;
        let ECR;
        let ECR2;
        let ECR_NC;
        let APP_NC;
        let APP_NC;
        let RCLR;
        let Helper;
        let MAL_APP;
        let UTIL_TKN;
        
        let string1Hash;
        let string2Hash;
        let string3Hash;
        let string4Hash;
        let string5Hash;
        let string14Hash;
        
        let ECR_MGRHASH;
        
        let asset1;
        let asset2;
        let asset3;
        let asset4;
        let asset5;
        let asset6;
        let asset7;
        let asset8;
        let asset9;
        let asset10;
        let asset11;
        let asset12;
        let asset13;
        let asset14;
        
        let rgt1;
        let rgt2;
        let rgt3;
        let rgt4;
        let rgt5;
        let rgt6;
        let rgt7;
        let rgt8;
        let rgt12;
        let rgt13;
        let rgt14;
        let rgt000 = "0x0000000000000000000000000000000000000000000000000000000000000000";
        let rgtFFF = "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";
        
        let account1Hash;
        let account2Hash;
        let account3Hash;
        let account4Hash;
        let account5Hash;
        let account6Hash;
        let account7Hash;
        let account8Hash;
        let account9Hash;
        let account10Hash;
        
        let account000 = '0x0000000000000000000000000000000000000000'
        
        let nakedAuthCode1;
        let nakedAuthCode3;
        let nakedAuthCode7;
        
        let payableRoleB32;
        let minterRoleB32;
        let trustedAgentRoleB32;
        let assetTransferRoleB32;
        let discardRoleB32;
        
        contract('BOOTSTRAP', accounts => {
        
            console.log('//**************************BEGIN BOOTSTRAP**************************//')
        
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
        
        
            it('Should deploy PRUF_HELPER', async () => {
                const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: account1 });
                console.log(PRUF_HELPER_TEST.address);
                assert(PRUF_HELPER_TEST.address !== '')
                Helper = PRUF_HELPER_TEST;
            })
        
        
            it('Should build variables', async () => {
        
                asset1 = await Helper.getIdxHash(
                    'aaa',
                    'aaa',
                    'aaa',
                    'aaa'
                )
        
                asset2 = await Helper.getIdxHash(
                    'bbb',
                    'bbb',
                    'bbb',
                    'bbb'
                )
        
                asset3 = await Helper.getIdxHash(
                    'ccc',
                    'ccc',
                    'ccc',
                    'ccc'
                )
        
                asset4 = await Helper.getIdxHash(
                    'ddd',
                    'ddd',
                    'ddd',
                    'ddd'
                )
        
                asset5 = await Helper.getIdxHash(
                    'eee',
                    'eee',
                    'eee',
                    'eee'
                )
        
                asset6 = await Helper.getIdxHash(
                    'fff',
                    'fff',
                    'fff',
                    'fff'
                )
        
                asset7 = await Helper.getIdxHash(
                    'ggg',
                    'ggg',
                    'ggg',
                    'ggg'
                )
        
                asset8 = await Helper.getIdxHash(
                    'hhh',
                    'hhh',
                    'hhh',
                    'hhh'
                )
        
                asset9 = await Helper.getIdxHash(
                    'iii',
                    'iii',
                    'iii',
                    'iii'
                )
        
                asset10 = await Helper.getIdxHash(
                    'jjj',
                    'jjj',
                    'jjj',
                    'jjj'
                )
        
                asset11 = await Helper.getIdxHash(
                    'kkk',
                    'kkk',
                    'kkk',
                    'kkk'
                )
        
                asset12 = await Helper.getIdxHash(
                    'lll',
                    'lll',
                    'lll',
                    'lll'
                )
        
                asset13 = await Helper.getIdxHash(
                    'mmm',
                    'mmm',
                    'mmm',
                    'mmm'
                )
        
                asset14 = await Helper.getIdxHash(
                    'nnn',
                    'nnn',
                    'nnn',
                    'nnn'
                )
        
                rgt1 = await Helper.getJustRgtHash(
                    asset1,
                    'aaa',
                    'aaa',
                    'aaa',
                    'aaa',
                    'aaa'
                )
        
                rgt2 = await Helper.getJustRgtHash(
                    asset2,
                    'bbb',
                    'bbb',
                    'bbb',
                    'bbb',
                    'bbb'
                )
        
                rgt3 = await Helper.getJustRgtHash(
                    asset3,
                    'ccc',
                    'ccc',
                    'ccc',
                    'ccc',
                    'ccc'
                )
        
                rgt4 = await Helper.getJustRgtHash(
                    asset4,
                    'ddd',
                    'ddd',
                    'ddd',
                    'ddd',
                    'ddd'
                )
        
                rgt5 = await Helper.getJustRgtHash(
                    asset5,
                    'eee',
                    'eee',
                    'eee',
                    'eee',
                    'eee'
                )
        
                rgt6 = await Helper.getJustRgtHash(
                    asset6,
                    'fff',
                    'fff',
                    'fff',
                    'fff',
                    'fff'
                )
        
                rgt7 = await Helper.getJustRgtHash(
                    asset7,
                    'ggg',
                    'ggg',
                    'ggg',
                    'ggg',
                    'ggg'
                )
        
                rgt8 = await Helper.getJustRgtHash(
                    asset7,
                    'hhh',
                    'hhh',
                    'hhh',
                    'hhh',
                    'hhh'
                )
        
                rgt12 = await Helper.getJustRgtHash(
                    asset12,
                    'a',
                    'a',
                    'a',
                    'a',
                    'a'
                )
        
                rgt13 = await Helper.getJustRgtHash(
                    asset13,
                    'a',
                    'a',
                    'a',
                    'a',
                    'a'
                )
        
                rgt14 = await Helper.getJustRgtHash(
                    asset14,
                    'a',
                    'a',
                    'a',
                    'a',
                    'a'
                )
        
        
                account1Hash = await Helper.getAddrHash(
                    account1
                )
        
                account2Hash = await Helper.getAddrHash(
                    account2
                )
        
                account3Hash = await Helper.getAddrHash(
                    account3
                )
        
                account4Hash = await Helper.getAddrHash(
                    account4
                )
        
                account5Hash = await Helper.getAddrHash(
                    account5
                )
        
                account6Hash = await Helper.getAddrHash(
                    account6
                )
        
                account7Hash = await Helper.getAddrHash(
                    account7
                )
        
                account8Hash = await Helper.getAddrHash(
                    account8
                )
        
                account9Hash = await Helper.getAddrHash(
                    account9
                )
        
                account10Hash = await Helper.getAddrHash(
                    account10
                )
        
        
                nakedAuthCode1 = await Helper.getURIb32fromAuthcode(
                    '1000005',
                    '1'
                )
        
                nakedAuthCode3 = await Helper.getURIb32fromAuthcode(
                    '1000005',
                    '3'
                )
        
                nakedAuthCode7 = await Helper.getURIb32fromAuthcode(
                    '1000005',
                    '7'
                )
        
                string1Hash = await Helper.getStringHash(
                    '1'
                )
        
                string2Hash = await Helper.getStringHash(
                    '2'
                )
        
                string3Hash = await Helper.getStringHash(
                    '3'
                )
        
                string4Hash = await Helper.getStringHash(
                    '4'
                )
        
                string5Hash = await Helper.getStringHash(
                    '5'
                )
        
                string14Hash = await Helper.getStringHash(
                    '1000004'
                )
        
        
                ECR_MGRHASH = await Helper.getStringHash(
                    'ECR_MGR'
                )
        
                payableRoleB32 = await Helper.getStringHash(
                    'PAYABLE_ROLE'
                )
        
                minterRoleB32 = await Helper.getStringHash(
                    'MINTER_ROLE'
                )
        
                trustedAgentRoleB32 = await Helper.getStringHash(
                    'TRUSTED_AGENT_ROLE'
                )
        
                assetTransferRoleB32 = await Helper.getStringHash(
                    'ASSET_TXFR_ROLE'
                )
        
                discardRoleB32 = await Helper.getStringHash(
                    'DISCARD_ROLE'
                )
            })
        
        
            it('Should deploy Storage', async () => {
                const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: account1 });
                console.log(PRUF_STOR_TEST.address);
                assert(PRUF_STOR_TEST.address !== '');
                STOR = PRUF_STOR_TEST;
            })
        
        
            it('Should deploy PRUF_APP', async () => {
                const PRUF_APP_TEST = await PRUF_APP.deployed({ from: account1 });
                console.log(PRUF_APP_TEST.address);
                assert(PRUF_APP_TEST.address !== '');
                APP = PRUF_APP_TEST;
            })
        
        
            it('Should deploy PRUF_APP', async () => {
                const PRUF_APP_TEST = await PRUF_APP.deployed({ from: account1 });
                console.log(PRUF_APP_TEST.address);
                assert(PRUF_APP_TEST.address !== '');
                APP = PRUF_APP_TEST;
            })
        
        
            it('Should deploy PRUF_NODE_MGR', async () => {
                const PRUF_NODE_MGR_TEST = await PRUF_NODE_MGR.deployed({ from: account1 });
                console.log(PRUF_NODE_MGR_TEST.address);
                assert(PRUF_NODE_MGR_TEST.address !== '');
                NODE_MGR = PRUF_NODE_MGR_TEST;
            })
        
        
            it('Should deploy PRUF_NODE_TKN', async () => {
                const PRUF_NODE_TKN_TEST = await PRUF_NODE_TKN.deployed({ from: account1 });
                console.log(PRUF_NODE_TKN_TEST.address);
                assert(PRUF_NODE_TKN_TEST.address !== '')
                NODE_TKN = PRUF_NODE_TKN_TEST;
            })
        
        
            it('Should deploy PRUF_A_TKN', async () => {
                const PRUF_A_TKN_TEST = await PRUF_A_TKN.deployed({ from: account1 });
                console.log(PRUF_A_TKN_TEST.address);
                assert(PRUF_A_TKN_TEST.address !== '')
                A_TKN = PRUF_A_TKN_TEST;
            })
        
        
            it('Should deploy PRUF_ECR_MGR', async () => {
                const PRUF_ECR_MGR_TEST = await PRUF_ECR_MGR.deployed({ from: account1 });
                console.log(PRUF_ECR_MGR_TEST.address);
                assert(PRUF_ECR_MGR_TEST.address !== '');
                ECR_MGR = PRUF_ECR_MGR_TEST;
            })
        
        
            it('Should deploy PRUF_ECR', async () => {
                const PRUF_ECR_TEST = await PRUF_ECR.deployed({ from: account1 });
                console.log(PRUF_ECR_TEST.address);
                assert(PRUF_ECR_TEST.address !== '');
                ECR = PRUF_ECR_TEST;
            })
        
        
            it('Should deploy PRUF_APP_NC', async () => {
                const PRUF_APP_NC_TEST = await PRUF_APP_NC.deployed({ from: account1 });
                console.log(PRUF_APP_NC_TEST.address);
                assert(PRUF_APP_NC_TEST.address !== '');
                APP_NC = PRUF_APP_NC_TEST;
            })
        
        
            it('Should deploy PRUF_APP_NC', async () => {
                const PRUF_APP_NC_TEST = await PRUF_APP_NC.deployed({ from: account1 });
                console.log(PRUF_APP_NC_TEST.address);
                assert(PRUF_APP_NC_TEST.address !== '')
                APP_NC = PRUF_APP_NC_TEST;
            })
        
        
            it('Should deploy PRUF_ECR_NC', async () => {
                const PRUF_ECR_NC_TEST = await PRUF_ECR_NC.deployed({ from: account1 });
                console.log(PRUF_ECR_NC_TEST.address);
                assert(PRUF_ECR_NC_TEST.address !== '');
                ECR_NC = PRUF_ECR_NC_TEST;
            })
        
        
            it('Should deploy PRUF_RCLR', async () => {
                const PRUF_RCLR_TEST = await PRUF_RCLR.deployed({ from: account1 });
                console.log(PRUF_RCLR_TEST.address);
                assert(PRUF_RCLR_TEST.address !== '')
                RCLR = PRUF_RCLR_TEST;
            })
        
        
            it('Should deploy PRUF_ID_MGR', async () => {
                const PRUF_ID_MGR_TEST = await PRUF_ID_MGR.deployed({ from: account1 });
                console.log(PRUF_ID_MGR_TEST.address);
                assert(PRUF_ID_MGR_TEST.address !== '')
                ID_MGR = PRUF_ID_MGR_TEST;
            })
        
        
            it('Should deploy PRUF_ECR2', async () => {
                const PRUF_ECR2_TEST = await PRUF_ECR2.deployed({ from: account1 });
                console.log(PRUF_ECR2_TEST.address);
                assert(PRUF_ECR2_TEST.address !== '');
                ECR2 = PRUF_ECR2_TEST;
            })
        
        
            it('Should deploy PRUF_MAL_APP', async () => {
                const PRUF_MAL_APP_TEST = await PRUF_MAL_APP.deployed({ from: account1 });
                console.log(PRUF_MAL_APP_TEST.address);
                assert(PRUF_MAL_APP_TEST.address !== '')
                MAL_APP = PRUF_MAL_APP_TEST;
            })
        
        
            it('Should deploy UTIL_TKN', async () => {
                const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: account1 });
                console.log(PRUF_UTIL_TKN_TEST.address);
                assert(PRUF_UTIL_TKN_TEST.address !== '')
                UTIL_TKN = PRUF_UTIL_TKN_TEST;
            })
        
        
            it('Should deploy PURCHASE', async () => {
                const PRUF_PURCHASE_TEST = await PRUF_PURCHASE.deployed({ from: account1 });
                console.log(PRUF_PURCHASE_TEST.address);
                assert(PRUF_PURCHASE_TEST.address !== '')
                PURCHASE = PRUF_PURCHASE_TEST;
            })
        
        
            it('Should deploy DECORATE', async () => {
                const PRUF_DECORATE_TEST = await PRUF_DECORATE.deployed({ from: account1 });
                console.log(PRUF_DECORATE_TEST.address);
                assert(PRUF_DECORATE_TEST.address !== '')
                DECORATE = PRUF_DECORATE_TEST;
            })
        
        
            it('Should deploy WRAP', async () => {
                const PRUF_WRAP_TEST = await PRUF_WRAP.deployed({ from: account1 });
                console.log(PRUF_WRAP_TEST.address);
                assert(PRUF_WRAP_TEST.address !== '')
                WRAP = PRUF_WRAP_TEST;
            })
        
        
            it('Should add default contracts to storage', () => {
        
                console.log("Adding NODE_MGR to default contract list")
                return STOR.addDefaultContracts("0", "NODE_MGR", '1', { from: account1 })
        
                    .then(() => {
                        console.log("Adding NODE_TKN to default contract list")
                        return STOR.addDefaultContracts("1", "NODE_TKN", '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding A_TKN to default contract list")
                        return STOR.addDefaultContracts("2", "A_TKN", '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR_MGR to default contract list")
                        return STOR.addDefaultContracts("3", "ECR_MGR", '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding APP_NC to default contract list")
                        return STOR.addDefaultContracts("4", "APP_NC", '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding APP_NC to default contract list")
                        return STOR.addDefaultContracts("5", "APP_NC", '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding RCLR to default contract list")
                        return STOR.addDefaultContracts("6", "RCLR", '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding PURCHASE to default contract list")
                        return STOR.addDefaultContracts("8", "PURCHASE", '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding DECORATE to default contract list")
                        return STOR.addDefaultContracts("9", "DECORATE", '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding WRAP to default contract list")
                        return STOR.addDefaultContracts("10", "WRAP", '2', { from: account1 })
                    })
            })
        
        
            it('Should add contract addresses to storage', () => {
        
                console.log("Adding APP to storage for use in Node 0")
                return STOR.authorizeContract("APP", APP.address, '0', '1', { from: account1 })
        
                    .then(() => {
                        console.log("Adding APP to storage for use in Node 0")
                        return STOR.authorizeContract("APP", APP.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding NODE_MGR to storage for use in Node 0")
                        return STOR.authorizeContract("NODE_MGR", NODE_MGR.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding NODE_TKN to storage for use in Node 0")
                        return STOR.authorizeContract("NODE_TKN", NODE_TKN.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding A_TKN to storage for use in Node 0")
                        return STOR.authorizeContract("A_TKN", A_TKN.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ID_MGR to storage for use in Node 0")
                        return STOR.authorizeContract("ID_MGR", ID_MGR.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR_MGR to storage for use in Node 0")
                        return STOR.authorizeContract("ECR_MGR", ECR_MGR.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR to storage for use in Node 0")
                        return STOR.authorizeContract("ECR", ECR.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR2 to storage for use in Node 0")
                        return STOR.authorizeContract("ECR2", ECR2.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding APP_NC to storage for use in Node 0")
                        return STOR.authorizeContract("APP_NC", APP_NC.address, '0', '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding APP_NC to storage for use in Node 0")
                        return STOR.authorizeContract("APP_NC", APP_NC.address, '0', '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR_NC to storage for use in Node 0")
                        return STOR.authorizeContract("ECR_NC", ECR_NC.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding RCLR to storage for use in Node 0")
                        return STOR.authorizeContract("RCLR", RCLR.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding MAL_APP to storage for use in Node 0")
                        return STOR.authorizeContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding UTIL_TKN to storage for use in Node 0")
                        return STOR.authorizeContract("UTIL_TKN", UTIL_TKN.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding PURCHASE to storage for use in Node 0")
                        return STOR.authorizeContract("PURCHASE", PURCHASE.address, '0', '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding DECORATE to storage for use in Node 0")
                        return STOR.authorizeContract("DECORATE", DECORATE.address, '0', '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding WRAP to storage for use in Node 0")
                        return STOR.authorizeContract("WRAP", WRAP.address, '0', '2', { from: account1 })
                    })
            })
        
        
            it('Should add Storage to each contract', () => {
        
                console.log("Adding in APP")
                return APP.setStorageContract(STOR.address, { from: account1 })
        
                    .then(() => {
                        console.log("Adding in APP")
                        return APP.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in MAL_APP")
                        return MAL_APP.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in NODE_MGR")
                        return NODE_MGR.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in A_TKN")
                        return A_TKN.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR_MGR")
                        return ECR_MGR.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR")
                        return ECR.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR2")
                        return ECR2.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in APP_NC")
                        return APP_NC.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in APP_NC")
                        return APP_NC.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR_NC")
                        return ECR_NC.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in RCLR")
                        return RCLR.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in PURCHASE")
                        return PURCHASE.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in DECORATE")
                        return DECORATE.setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in WRAP")
                        return WRAP.setStorageContract(STOR.address, { from: account1 })
                    })
            })
        
        
            it('Should resolve contract addresses', () => {
        
                console.log("Resolving in APP")
                return APP.resolveContractAddresses({ from: account1 })
        
                    .then(() => {
                        console.log("Resolving in APP")
                        return APP.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in MAL_APP")
                        return MAL_APP.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in NODE_MGR")
                        return NODE_MGR.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in A_TKN")
                        return A_TKN.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR_MGR")
                        return ECR_MGR.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR")
                        return ECR.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR2")
                        return ECR2.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in APP_NC")
                        return APP_NC.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in APP_NC")
                        return APP_NC.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR_NC")
                        return ECR_NC.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in RCLR")
                        return RCLR.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in PURCHASE")
                        return PURCHASE.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in DECORATE")
                        return DECORATE.resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in WRAP")
                        return WRAP.resolveContractAddresses({ from: account1 })
                    })
            })
        
        
            it('Should set all permitted storage providers', () => {
                console.log("Authorizing UNCONFIGURED")
                return NODE_STOR.setStorageProviders('0', '1', { from: account1 })
        
                    .then(() => {
                        console.log("Authorizing Mutable")
                        return NODE_STOR.setStorageProviders('1', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing ARWEAVE")
                        return NODE_STOR.setStorageProviders('2', '1', { from: account1 })
                    })
            })
        
        
            it('Should set all permitted management types', () => {
                console.log("Authorizing Unrestricted")
                return NODE_STOR.setManagementTypes('0', '1', { from: account1 })
        
                    .then(() => {
                        console.log("Authorizing Restricted")
                        return NODE_STOR.setManagementTypes('1', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Less Restricted")
                        return NODE_STOR.setManagementTypes('2', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Authorized")
                        return NODE_STOR.setManagementTypes('3', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Trusted")
                        return NODE_STOR.setManagementTypes('4', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Remotely Managed")
                        return NODE_STOR.setManagementTypes('5', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Unconfigured")
                        return NODE_STOR.setManagementTypes('255', '1', { from: account1 })
                    })
            })
        
        
            it('Should set all permitted custody types', () => {
                console.log("Authorizing NONE")
                return NODE_STOR.setCustodyTypes('0', '1', { from: account1 })
        
                    .then(() => {
                        console.log("Authorizing Custodial")
                        return NODE_STOR.setCustodyTypes('1', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Non-Custodial")
                        return NODE_STOR.setCustodyTypes('2', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing ROOT")
                        return NODE_STOR.setCustodyTypes('3', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Verify-Non-Custodial")
                        return NODE_STOR.setCustodyTypes('4', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Wrapped or decorated ERC721")
                        return NODE_STOR.setCustodyTypes('5', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Free Custodial")
                        return NODE_STOR.setCustodyTypes('11', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing Free Non-Custodial")
                        return NODE_STOR.setCustodyTypes('12', '1', { from: account1 })
                    })
            })
        
            it('Should authorize all minter contracts for minting A_TKN(s)', () => {
        
                console.log("Authorizing APP")
                return A_TKN.grantRole(minterRoleB32, APP.address, { from: account1 })
        
                    .then(() => {
                        console.log("Authorizing APP_NC")
                        return A_TKN.grantRole(minterRoleB32, APP_NC.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing APP")
                        return A_TKN.grantRole(minterRoleB32, APP.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing RCLR")
                        return A_TKN.grantRole(minterRoleB32, RCLR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing PURCHASE")
                        return A_TKN.grantRole(trustedAgentRoleB32, PURCHASE.address, { from: account1 })
                    })
            })
        
            it('Should authorize all payable contracts for transactions', () => {
        
                console.log("Authorizing NODE_MGR")
                return UTIL_TKN.grantRole(payableRoleB32, NODE_MGR.address, { from: account1 })
        
                    .then(() => {
                        console.log("Authorizing APP_NC")
                        return UTIL_TKN.grantRole(payableRoleB32, APP_NC.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing APP")
                        return UTIL_TKN.grantRole(payableRoleB32, APP.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing RCLR")
                        return UTIL_TKN.grantRole(payableRoleB32, RCLR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing NODE_MGR")
                        return UTIL_TKN.grantRole(trustedAgentRoleB32, NODE_MGR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing NODE_MGR")
                        return UTIL_TKN.grantRole(trustedAgentRoleB32, NODE_MGR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing APP")
                        return UTIL_TKN.grantRole(payableRoleB32, APP.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing APP_NC")
                        return UTIL_TKN.grantRole(payableRoleB32, APP_NC.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing PURCHASE")
                        return UTIL_TKN.grantRole(payableRoleB32, PURCHASE.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing PURCHASE")
                        return UTIL_TKN.grantRole(trustedAgentRoleB32, PURCHASE.address, { from: account1 })
                    })
            })
        
        
            it('Should authorize all minter contracts for minting NODE_TKN(s)', () => {
                console.log("Authorizing NODE_MGR")
                return NODE_TKN.grantRole(minterRoleB32, NODE_MGR.address, { from: account1 })
            })
        
        
            it('Should authorize all minter contracts for minting NODE_TKN(s)', () => {
                console.log("Authorizing NODE_MGR")
                return APP.grantRole(assetTransferRoleB32, APP.address, { from: account1 })
            })
        
        
            it('Should authorize all minter contracts for minting NODE_TKN(s)', () => {
                console.log("Authorizing NODE_MGR")
                return RCLR.grantRole(discardRoleB32, A_TKN.address, { from: account1 })
            })
        
        
            it('Should mint a couple of asset root tokens', () => {
        
                console.log("Minting root token 1 -C")
                return NODE_MGR.createNode('1', 'CUSTODIAL_ROOT', '1', '3', '0', '0', "9500", rgt000, account1, { from: account1 })
        
                    .then(() => {
                        console.log("Minting root token 2 -NC")
                        return NODE_MGR.createNode('2', 'NON-CUSTODIAL_ROOT', '2', '3', '0', '0', "9500", rgt000, account1, { from: account1 })
                    })
            })
        
        
            it("Should set costs in minted roots", () => {
        
                console.log("Setting costs in Node 1")
        
                return NODE_MGR.setOperationCosts(
                    "1",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
        
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "1",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "1",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "1",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "1",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "1",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "1",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "1",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Setting base costs in Node 2")
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "1",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "2",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
            })
        
        
            it("Should Mint 2 cust and 2 non-cust Node tokens in AC_ROOT 1", () => {
        
                console.log("Minting PRUF to account1")
                return UTIL_TKN.mint(account1, "8000000000000000000000000", { from: account1 })
        
                    .then(() => {
                        console.log("Minting PRUF to account10")
                        return UTIL_TKN.mint(account10, "4000000000000000000000000", { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Minting ID_MGR to account1")
                        return ID_MGR.mintID(account1, "1", "", { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Minting ID_MGR to account10")
                        return ID_MGR.mintID(account10, "2", "", { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Minting Node 1000001 -C")
                        return NODE_MGR.purchaseNode("Custodial_AC1", "1", "1", rgt000, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Minting Node 1000002 -NC")
                        return NODE_MGR.purchaseNode("Non_Custodial_AC2", "1", "2", rgt000, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Minting Node 1000003 -NC")
                        return NODE_MGR.purchaseNode("Non_Custodial_AC3", "1", "2", rgt000, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Minting Node 1000004 -NC")
                        return NODE_MGR.purchaseNode("Non_Custodial_AC4", "1", "2", rgt000, { from: account10 })
                    })
            })
        
        
            it("Should Mint 2 non-cust Node tokens in AC_ROOT 2", () => {
        
                console.log("Minting Node 1000005 -NC")
                return NODE_MGR.purchaseNode("Non-Custodial_AC5", "2", "2", rgt000, { from: account1 })
        
                    .then(() => {
                        console.log("Minting Node 1000006 -NC")
                        return NODE_MGR.purchaseNode("Non_Custodial_AC6", "2", "2", rgt000, { from: account10 })
                    })
            })
        
        
            it('Should finalize all ACs', () => {
                console.log("Updating Node Immutables")
                return NODE_MGR.setNonMutableData('1000001', '3', '1', '0x0000000000000000000000000000000000000000', { from: account1 })
        
                    .then(() => {
                        return NODE_MGR.setNonMutableData('1000002', '3', '1', '0x0000000000000000000000000000000000000000', { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setNonMutableData('1000003', '3', '1', '0x0000000000000000000000000000000000000000', { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setNonMutableData('1000004', '3', '1', '0x0000000000000000000000000000000000000000', { from: account10 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setNonMutableData('1000005', '3', '1', '0x0000000000000000000000000000000000000000', { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setNonMutableData('1000006', '3', '1', '0x0000000000000000000000000000000000000000', { from: account10 })
                    })
            })
        
        
            it('Should finalize all ACs', () => {
                console.log("Authorizing Node Switch 1")
                return NODE_MGR.AdminModAssetClassSwitches('1000001', '1', '1',  {from: account1 })
        
                    .then(() => {
                        return NODE_MGR.AdminModAssetClassSwitches('1000002', '3', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.AdminModAssetClassSwitches('1000003', '3', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.AdminModAssetClassSwitches('1000004', '3', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.AdminModAssetClassSwitches('1000005', '3', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.AdminModAssetClassSwitches('1000006', '3', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize APP in all relevant nodes', () => {
                console.log("Authorizing APP")
                return STOR.enableContractForNode('APP', '1000001', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('APP', '1000002', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize APP_NC in all relevant nodes', () => {
        
                console.log("Authorizing APP_NC")
                return STOR.enableContractForNode('APP_NC', '1000003', '2', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('APP_NC', '1000003', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForNode('APP_NC', '1000004', '2', { from: account10 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForNode('APP_NC', '1000006', '2', { from: account10 })
                    })
            })
        
        
            it('Should authorize APP in all relevant nodes', () => {
        
                console.log("Authorizing APP")
                return STOR.enableContractForNode('APP', '1000001', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('APP', '1000002', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize MAL_APP in all relevant nodes', () => {
        
                console.log("Authorizing MAL_APP")
                return STOR.enableContractForNode('MAL_APP', '1000001', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('MAL_APP', '1000002', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize ECR in all relevant nodes', () => {
        
                console.log("Authorizing ECR")
                return STOR.enableContractForNode('ECR', '1000001', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('ECR', '1000002', '3', { from: account1 })
                    })
            })
        
        
            it('Should authorize ECR_NC in all relevant nodes', () => {
        
                console.log("Authorizing ECR_NC")
                return STOR.enableContractForNode('ECR_NC', '1000003', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('ECR_NC', '1000004', '3', { from: account10 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForNode('ECR_NC', '1000005', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForNode('ECR_NC', '1000006', '3', { from: account10 })
                    })
            })
        
        
            it('Should authorize ECR2 in all relevant nodes', () => {
        
                console.log("Authorizing ECR2")
                return STOR.enableContractForNode('ECR2', '1000001', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('ECR2', '1000002', '3', { from: account1 })
                    })
            })
        
        
            it('Should authorize A_TKN in all relevant nodes', () => {
        
                console.log("Authorizing A_TKN")
                return STOR.enableContractForNode('A_TKN', '1', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForNode('A_TKN', '2', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForNode('A_TKN', '1000001', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForNode('A_TKN', '1000002', '1', { from: account1 })
                    })
            })
        
        
            it('Should add users to Node 1000001-1000006 in AC_Manager', () => {
        
                console.log("//**************************************END BOOTSTRAP**********************************************/")
                console.log("Account2 => 1000001")
                return NODE_MGR.addUser('1000001', account4Hash, '1', { from: account1 })
        
                    .then(() => {
                        console.log("Account2 => 1000001")
                        return NODE_MGR.addUser('1000001', account2Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account2 => 1000003")
                        return NODE_MGR.addUser('1000003', account2Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account4 => 1000003")
                        return NODE_MGR.addUser('1000003', account4Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account4 => 1000004")
                        return NODE_MGR.addUser('1000004', account4Hash, '1', { from: account10 })
                    })
        
                    .then(() => {
                        console.log("Account4 => 1000006")
                        return NODE_MGR.addUser('1000006', account4Hash, '1', { from: account10 })
                    })
        
                    .then(() => {
                        console.log("Account10 => 1000001")
                        return NODE_MGR.addUser('1000001', account10Hash, '1', { from: account1 })
                    })
            })


            it('Should mint ID_MGR(3) to account3', async () => {
                return ID_MGR.mintID(
                    account3,
                    '3',
                    { from: account1 }
                )
            })
        
        
            it('Should reMint ID_MGR(1) to account4', async () => {
                return ID_MGR.remintID(
                    account4,
                    '3',
                    { from: account1 }
                )
            })
})