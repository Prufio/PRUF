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
        const PRUF_APP2 = artifacts.require('APP2');
        const PRUF_NODE_MGR = artifacts.require('NODE_MGR');
        const PRUF_NODE_TKN = artifacts.require('NODE_TKN');
        const PRUF_A_TKN = artifacts.require('A_TKN');
        const PRUF_ID_TKN = artifacts.require('ID_TKN');
        const PRUF_ECR_MGR = artifacts.require('ECR_MGR');
        const PRUF_ECR = artifacts.require('ECR');
        const PRUF_ECR2 = artifacts.require('ECR2');
        const PRUF_APP_NC = artifacts.require('APP_NC');
        const PRUF_APP2_NC = artifacts.require('APP2_NC');
        const PRUF_ECR_NC = artifacts.require('ECR_NC');
        const PRUF_RCLR = artifacts.require('RCLR');
        const PRUF_PIP = artifacts.require('PIP');
        const PRUF_HELPER = artifacts.require('Helper');
        const PRUF_MAL_APP = artifacts.require('MAL_APP');
        const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
        const PRUF_VERIFY = artifacts.require('VERIFY');
        
        let STOR;
        let APP;
        let APP2;
        let NODE_MGR;
        let NODE_TKN;
        let A_TKN;
        let ID_TKN;
        let ECR_MGR;
        let ECR;
        let ECR2;
        let ECR_NC;
        let APP_NC;
        let APP2_NC;
        let RCLR;
        let Helper;
        let MAL_APP;
        let UTIL_TKN;
        let VERIFY;
        
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
        
        contract('VERIFY', accounts => {
        
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
        
        
            it('Should deploy PRUF_APP2', async () => {
                const PRUF_APP2_TEST = await PRUF_APP2.deployed({ from: account1 });
                console.log(PRUF_APP2_TEST.address);
                assert(PRUF_APP2_TEST.address !== '');
                APP2 = PRUF_APP2_TEST;
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
        
        
            it('Should deploy PRUF_APP2_NC', async () => {
                const PRUF_APP2_NC_TEST = await PRUF_APP2_NC.deployed({ from: account1 });
                console.log(PRUF_APP2_NC_TEST.address);
                assert(PRUF_APP2_NC_TEST.address !== '')
                APP2_NC = PRUF_APP2_NC_TEST;
            })
        
        
            it('Should deploy PRUF_ECR_NC', async () => {
                const PRUF_ECR_NC_TEST = await PRUF_ECR_NC.deployed({ from: account1 });
                console.log(PRUF_ECR_NC_TEST.address);
                assert(PRUF_ECR_NC_TEST.address !== '');
                ECR_NC = PRUF_ECR_NC_TEST;
            })
        
        
            it('Should deploy PRUF_PIP', async () => {
                const PRUF_PIP_TEST = await PRUF_PIP.deployed({ from: account1 });
                console.log(PRUF_PIP_TEST.address);
                assert(PRUF_PIP_TEST.address !== '')
                PIP = PRUF_PIP_TEST;
            })
        
        
            it('Should deploy PRUF_RCLR', async () => {
                const PRUF_RCLR_TEST = await PRUF_RCLR.deployed({ from: account1 });
                console.log(PRUF_RCLR_TEST.address);
                assert(PRUF_RCLR_TEST.address !== '')
                RCLR = PRUF_RCLR_TEST;
            })
        
        
            it('Should deploy PRUF_HELPER', async () => {
                const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: account1 });
                console.log(PRUF_HELPER_TEST.address);
                assert(PRUF_HELPER_TEST.address !== '')
                Helper = PRUF_HELPER_TEST;
            })
        
        
            it('Should deploy PRUF_ID_TKN', async () => {
                const PRUF_ID_TKN_TEST = await PRUF_ID_TKN.deployed({ from: account1 });
                console.log(PRUF_ID_TKN_TEST.address);
                assert(PRUF_ID_TKN_TEST.address !== '')
                ID_TKN = PRUF_ID_TKN_TEST;
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
        
        
            it('Should deploy VERIFY', async () => {
                const PRUF_VERIFY_TEST = await PRUF_VERIFY.deployed({ from: account1 });
                console.log(PRUF_VERIFY_TEST.address);
                assert(PRUF_VERIFY_TEST.address !== '')
                VERIFY = PRUF_VERIFY_TEST;
            })
        
        
            it('Should build a few IDX and RGT hashes', async () => {
        
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
                    '15',
                    '1'
                )
        
                nakedAuthCode3 = await Helper.getURIb32fromAuthcode(
                    '15',
                    '3'
                )
        
                nakedAuthCode7 = await Helper.getURIb32fromAuthcode(
                    '15',
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
                    '14'
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
        
        
            it('Should add contract addresses', async () => {
        
                console.log("Adding APP to storage for use in Node 0")
                return STOR.OO_addContract("APP", APP.address, '0', '1', { from: account1 })
        
                    .then(() => {
                        console.log("Adding APP2 to storage for use in Node 0")
                        return STOR.OO_addContract("APP2", APP2.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding NODE_MGR to storage for use in Node 0")
                        return STOR.OO_addContract("NODE_MGR", NODE_MGR.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding NODE_TKN to storage for use in Node 0")
                        return STOR.OO_addContract("NODE_TKN", NODE_TKN.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding A_TKN to storage for use in Node 0")
                        return STOR.OO_addContract("A_TKN", A_TKN.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ID_TKN to storage for use in Node 0")
                        return STOR.OO_addContract("ID_TKN", ID_TKN.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR_MGR to storage for use in Node 0")
                        return STOR.OO_addContract("ECR_MGR", ECR_MGR.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR to storage for use in Node 0")
                        return STOR.OO_addContract("ECR", ECR.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR2 to storage for use in Node 0")
                        return STOR.OO_addContract("ECR2", ECR2.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding APP_NC to storage for use in Node 0")
                        return STOR.OO_addContract("APP_NC", APP_NC.address, '0', '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding APP2_NC to storage for use in Node 0")
                        return STOR.OO_addContract("APP2_NC", APP2_NC.address, '0', '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding ECR_NC to storage for use in Node 0")
                        return STOR.OO_addContract("ECR_NC", ECR_NC.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding PIP to storage for use in Node 0")
                        return STOR.OO_addContract("PIP", PIP.address, '0', '2', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding RCLR to storage for use in Node 0")
                        return STOR.OO_addContract("RCLR", RCLR.address, '0', '3', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding MAL_APP to storage for use in Node 0")
                        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding UTIL_TKN to storage for use in Node 0")
                        return STOR.OO_addContract("UTIL_TKN", UTIL_TKN.address, '0', '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding VERIFY to storage for use in Node 0")
                        return STOR.OO_addContract("VERIFY", VERIFY.address, '0', '1', { from: account1 })
                    })
            })
        
        
            it('Should add Storage in each contract', async () => {
        
                console.log("Adding in APP")
                return APP.OO_setStorageContract(STOR.address, { from: account1 })
        
                    .then(() => {
                        console.log("Adding in APP2")
                        return APP2.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in MAL_APP")
                        return MAL_APP.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in NODE_MGR")
                        return NODE_MGR.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    // .then(() => {
                    //     console.log("Adding in NODE_TKN")
                    //     return NODE_TKN.OO_setStorageContract(STOR.address, { from: account1 })
                    // })
        
                    .then(() => {
                        console.log("Adding in A_TKN")
                        return A_TKN.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR_MGR")
                        return ECR_MGR.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR")
                        return ECR.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR2")
                        return ECR2.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in APP_NC")
                        return APP_NC.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in APP2_NC")
                        return APP2_NC.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in ECR_NC")
                        return ECR_NC.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in PIP")
                        return PIP.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in RCLR")
                        return RCLR.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Adding in VERIFY")
                        return VERIFY.OO_setStorageContract(STOR.address, { from: account1 })
                    })
        
                // .then(() => {
                //     console.log("Adding in UTIL_TKN")
                //     return UTIL_TKN.AdminSetStorageContract(STOR.address, { from: account1 })
                // })
            })
        
        
            it('Should resolve contract addresses', async () => {
        
                console.log("Resolving in APP")
                return APP.OO_resolveContractAddresses({ from: account1 })
        
                    .then(() => {
                        console.log("Resolving in APP2")
                        return APP2.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in MAL_APP")
                        return MAL_APP.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in NODE_MGR")
                        return NODE_MGR.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    // .then(() => {
                    //     console.log("Resolving in NODE_TKN")
                    //     return NODE_TKN.OO_resolveContractAddresses({ from: account1 })
                    // })
        
                    .then(() => {
                        console.log("Resolving in A_TKN")
                        return A_TKN.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR_MGR")
                        return ECR_MGR.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR")
                        return ECR.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR2")
                        return ECR2.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in APP_NC")
                        return APP_NC.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in APP2_NC")
                        return APP2_NC.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in ECR_NC")
                        return ECR_NC.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in PIP")
                        return PIP.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in RCLR")
                        return RCLR.OO_resolveContractAddresses({ from: account1 })
                    })
        
                    .then(() => {
                        console.log("Resolving in VERIFY")
                        return VERIFY.OO_resolveContractAddresses({ from: account1 })
                    })
            })
        
            it('Should authorize all minter contracts for minting A_TKN(s)', async () => {
        
                console.log("Authorizing APP2")
                return A_TKN.grantRole(minterRoleB32, APP2.address, { from: account1 })
        
                    .then(() => {
                        console.log("Authorizing APP_NC")
                        return A_TKN.grantRole(minterRoleB32, APP_NC.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing APP")
                        return A_TKN.grantRole(minterRoleB32, APP.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing PIP")
                        return A_TKN.grantRole(minterRoleB32, PIP.address, { from: account1 })
                    })
            })
        
            it('Should authorize all payable contracts for transactions', async () => {
        
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
                        console.log("Authorizing APP2")
                        return UTIL_TKN.grantRole(payableRoleB32, APP2.address, { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Authorizing APP2_NC")
                        return UTIL_TKN.grantRole(payableRoleB32, APP2_NC.address, { from: account1 })
                    })
            })
        
        
            it('Should authorize NODE_MGR as trusted agent in NODE_TKN', async () => {
            
                console.log("Authorizing NODE_MGR")
                return UTIL_TKN.grantRole(trustedAgentRoleB32, NODE_MGR.address, { from: account1 })
            })
        
        
            it('Should authorize all minter contracts for minting NODE_TKN(s)', async () => {
                console.log("Authorizing NODE_MGR")
                return NODE_TKN.grantRole(minterRoleB32, NODE_MGR.address, { from: account1 })
            })
        
        
            it('Should authorize all minter contracts for minting NODE_TKN(s)', async () => {
                console.log("Authorizing NODE_MGR")
                return APP.grantRole(assetTransferRoleB32, APP2.address, { from: account1 })
            })
        
        
            it('Should authorize all minter contracts for minting NODE_TKN(s)', async () => {
                console.log("Authorizing NODE_MGR")
                return RCLR.grantRole(discardRoleB32, A_TKN.address, { from: account1 })
            })
        
        
            it('Should mint 2 asset root tokens', async () => {

                console.log("Minting root token 1")
                return NODE_MGR.createNode('1', 'ROOT1', '1', '3', "0", "0", rgt000, account1, { from: account1 })
            
                .then(() => {
                    console.log("Minting root token 2")
                    return NODE_MGR.createNode('2', 'ROOT2', '2', '3', "0", "0", rgt000, account1, { from: account1 })
                })
            })
            
            
            it("Should Mint 2 non cust Node", async () => {
                
                console.log("Minting Node 10 -NC")
                return NODE_MGR.createNode('10', 'NonCustodial_AC10', '1', '2', "0", "0", rgt000, account1, { from: account1 })
            
                    .then(() => {
                        console.log("Minting Node 11 -NC to Account1")
                        return NODE_MGR.createNode('11', 'NonCustodial_AC11', '1', '2', "0", "0", rgt000, account1, { from: account1 })
                    })
            })
            
            
            it("Should Mint 4 verify Node tokens", async () => {
                
                console.log("Minting Node 12 Verify")
                return NODE_MGR.createNode('12', 'Verify1', '1', '4', "0", "0", rgt000, account1, { from: account1 })
            
                    .then(() => {
                        console.log("Minting Node 13 Verify")
                        return NODE_MGR.createNode('13', 'Verify2', '1', '4', "0", "0", rgt000, account1, { from: account1 })
                    })
            
                    .then(() => {
                        console.log("Minting Node 14 Verify to Account1")
                        return NODE_MGR.createNode('14', 'Verify3', '1', '4', "0", "0", rgt000, account1, { from: account1 })
                    })
            
                    .then(() => {
                        console.log("Minting Node 15 Verify to Account1")
                        return NODE_MGR.createNode('15', 'Verify4', '2', '4', "0", "0", rgt000, account1, { from: account1 })
                    })
            
            })
        
        
            it('Should authorize APP in all relevant nodes', async () => {
                console.log("Authorizing APP")
                return STOR.enableContractForAC('APP', '10', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP', '11', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize APP_NC in all relevant nodes', async () => {
        
                console.log("Authorizing APP_NC")
                return STOR.enableContractForAC('APP_NC', '12', '2', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP_NC', '13', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP_NC', '14', '2', { from: account1 })
                    })

                    .then(() => {
                        return STOR.enableContractForAC('APP_NC', '11', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP_NC', '10', '2', { from: account1 })
                    })
        
                    // .then(() => {
                    //     return STOR.enableContractForAC('APP_NC', '16', '2', { from: account10 })
                    // })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP_NC', '15', '2', { from: account1 })
                    })
            })
        
        
            it('Should authorize APP2 in all relevant nodes', async () => {
        
                console.log("Authorizing APP2")
                return STOR.enableContractForAC('APP2', '10', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP2', '11', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize MAL_APP in all relevant nodes', async () => {
        
                console.log("Authorizing MAL_APP")
                return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('MAL_APP', '11', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize APP2_NC in all relevant nodes', async () => {
        
                console.log("Authorizing APP2_NC")
                return STOR.enableContractForAC('APP2_NC', '12', '2', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP2_NC', '13', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('APP2_NC', '14', '2', { from: account1 })
                    })
        
                    // .then(() => {
                    //     return STOR.enableContractForAC('APP2_NC', '16', '2', { from: account10 })
                    // })
            })
        
        
            it('Should authorize ECR in all relevant nodes', async () => {
        
                console.log("Authorizing ECR")
                return STOR.enableContractForAC('ECR', '10', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR', '11', '3', { from: account1 })
                    })
            })
        
        
            it('Should authorize ECR2 in all relevant nodes', async () => {
        
                console.log("Authorizing ECR2")
                return STOR.enableContractForAC('ECR2', '10', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR2', '11', '3', { from: account1 })
                    })
            })
        
        
            it('Should authorize ECR_NC in all relevant nodes', async () => {
        
                console.log("Authorizing ECR_NC")
                return STOR.enableContractForAC('ECR_NC', '12', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR_NC', '13', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR_NC', '14', '3', { from: account1 })
                    })
        
                    // .then(() => {
                    //     return STOR.enableContractForAC('ECR_NC', '16', '3', { from: account10 })
                    // })
            })
        
        
            it('Should authorize ECR_MGR in all relevant nodes', async () => {
        
                console.log("Authorizing ECR_MGR")
                return STOR.enableContractForAC('ECR_MGR', '10', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR_MGR', '11', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR_MGR', '12', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR_MGR', '13', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('ECR_MGR', '14', '3', { from: account1 })
                    })
        
                    // .then(() => {
                    //     return STOR.enableContractForAC('ECR_MGR', '16', '3', { from: account10 })
                    // })
            })
        
        
            it('Should authorize NODE_TKN in all relevant nodes', async () => {
        
                console.log("Authorizing NODE_TKN")
                return STOR.enableContractForAC('NODE_TKN', '10', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_TKN', '11', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_TKN', '12', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_TKN', '13', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_TKN', '14', '2', { from: account1 })
                    })
            })
        
        
            it('Should authorize A_TKN in all relevant nodes', async () => {
        
                console.log("Authorizing A_TKN")
                return STOR.enableContractForAC('A_TKN', '10', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('A_TKN', '11', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('A_TKN', '12', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('A_TKN', '13', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('A_TKN', '14', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('A_TKN', '15', '2', { from: account1 })
                    })
        
                    // .then(() => {
                    //     return STOR.enableContractForAC('A_TKN', '16', '2', { from: account10 })
                    // })
        
                    .then(() => {
                        return STOR.enableContractForAC('A_TKN', '1', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('A_TKN', '2', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize PIP in all relevant nodes', async () => {
        
                console.log("Authorizing PIP")
                return STOR.enableContractForAC('PIP', '10', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('PIP', '11', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('PIP', '12', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('PIP', '13', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('PIP', '14', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('PIP', '15', '2', { from: account1 })
                    })
        
                    // .then(() => {
                    //     return STOR.enableContractForAC('PIP', '16', '2', { from: account10 })
                    // })
        
                    .then(() => {
                        return STOR.enableContractForAC('PIP', '1', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('PIP', '2', '1', { from: account1 })
                    })
            })
        
        
            it('Should authorize NODE_MGR in all relevant nodes', async () => {
        
                console.log("Authorizing NODE_MGR")
                return STOR.enableContractForAC('NODE_MGR', '10', '1', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_MGR', '11', '1', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_MGR', '12', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_MGR', '13', '2', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('NODE_MGR', '14', '2', { from: account1 })
                    })
            })
        
        
            it('Should authorize RCLR in all relevant nodes', async () => {
        
                console.log("Authorizing RCLR")
                return STOR.enableContractForAC('RCLR', '10', '3', { from: account1 })
        
                    .then(() => {
                        return STOR.enableContractForAC('RCLR', '11', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('RCLR', '12', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('RCLR', '13', '3', { from: account1 })
                    })
        
                    .then(() => {
                        return STOR.enableContractForAC('RCLR', '14', '3', { from: account1 })
                    })
        
                    // .then(() => {
                    //     return STOR.enableContractForAC('RCLR', '16', '3', { from: account10 })
                    // })
            })


            it("Should set costs in minted Node's", async () => {
        
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
        
                    .then(() => {
                        console.log("Setting base costs in Node 10")
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "1",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "10",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Setting base costs in Node 11")
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "1",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "11",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Setting base costs in Node 12")
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "1",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "12",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Setting base costs in Node 13")
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "1",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "13",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Setting base costs in Node 14")
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "1",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "14",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Setting base costs in Node 15")
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "1",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "2",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "3",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "4",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "5",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "6",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "7",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
        
                    .then(() => {
                        return NODE_MGR.setOperationCosts(
                            "15",
                            "8",
                            "10000000000000000",
                            account1,
                            { from: account1 })
                    })
            })
        
        
            it('Should add users to Node 10-14 in AC_Manager', async () => {
        
                console.log("//**************************************END BOOTSTRAP**********************************************/")
                console.log("Account1 => AC10")
                return NODE_MGR.addUser('10', account1Hash, '1', { from: account1 })
        
                    .then(() => {
                        console.log("Account1 => AC10")
                        return NODE_MGR.addUser('10', account1Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account1 => AC11")
                        return NODE_MGR.addUser('11', account1Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account3 => AC11")
                        return NODE_MGR.addUser('11', account3Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account4 => AC10")
                        return NODE_MGR.addUser('10', account4Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account4 => AC12")
                        return NODE_MGR.addUser('12', account4Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account1 => AC12")
                        return NODE_MGR.addUser('12', account1Hash, '1', { from: account1 })
                    })
        
                    // .then(() => {
                    //     console.log("Account4 => AC16")
                    //     return NODE_MGR.addUser(account4Hash, '1', '16', { from: account10 })
                    // })
        
                    .then(() => {
                        console.log("Account5 => AC13")
                        return NODE_MGR.addUser('13', account5Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account1 => AC14")
                        return NODE_MGR.addUser('14', account1Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account6 => AC14")
                        return NODE_MGR.addUser('14', account6Hash, '1', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account7 => AC14 (ROBOT)")
                        return NODE_MGR.addUser('14', account7Hash, '9', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account8 => AC10 (ROBOT)")
                        return NODE_MGR.addUser('10', account8Hash, '9', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account9 => AC11 (ROBOT)")
                        return NODE_MGR.addUser('11', account9Hash, '9', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account10 => AC15 (PIPMINTER)")
                        return NODE_MGR.addUser('15', account10Hash, '10', { from: account1 })
                    })
        
                    .then(() => {
                        console.log("Account1 => AC15")
                        return NODE_MGR.addUser('15', account1Hash, '1', { from: account1 })
                    })
        
                    // .then(() => {
                    //     console.log("Account10 => AC16 (PIPMINTER)")
                    //     return NODE_MGR.addUser(account10Hash, '10', '16', { from: account10 })
                    // })
        
                    .then(() => {
                        console.log("Account10 => AC10 (PIPMINTER)")
                        return NODE_MGR.addUser('10', account10Hash, '1', { from: account1 })
                    })
            })


    it('Should set SharesAddress', async () => {

        console.log("//**************************************BEGIN VERIFY TEST**********************************************/")
        return UTIL_TKN.AdminSetSharesAddress(
            account1,
            { from: account1 }
        )
    })


    it('Should mint 30000 tokens to account2', async () => {
        return UTIL_TKN.mint(
            account2,
            '30000000000000000000000',
            { from: account1 }
        )
    })


    it('Should mint 30000 tokens to account1', async () => {
        return UTIL_TKN.mint(
            account1,
            '30000000000000000000000',
            { from: account1 }
        )
    })


    it('Should mint PRUF_ID token to account1', async () => {

        return ID_TKN.mintIDtoken(
            account1,
            '1',
            { from: account1 }
        )
    })


    // it('Should mint PRUF_ID token to account2', async () => {
    //     return ID_TKN.mintIDtoken(
    //         account1,
    //         '2',
    //         { from: account1 }
    //     )
    // })


    it('Should mint asset1', async () => {
        return APP_NC.newRecord(
            asset1,
            rgt1,
            '12',
            '100',
            { from: account1 }
        )
    })


    it('Should authorize asset1 as verify wallet', async () => {
        return VERIFY.authorizeTokenForVerify(
            asset1,
            '3',
            '12',
            { from: account1 }
        )
    })


    it('Should mint asset2', async () => {
        return APP_NC.newRecord(
            asset2,
            rgt2,
            '14',
            '100',
            { from: account1 }
        )
    })


    it('Should authorize asset2 as verify wallet', async () => {
        return VERIFY.authorizeTokenForVerify(
            asset2,
            '3',
            '14',
            { from: account1 }
        )
    })


    it('Should mint asset3', async () => {
        return APP_NC.newRecord(
            asset3,
            rgt3,
            '14',
            '100',
            { from: account1 }
        )
    })


    it('Should authorize asset3 as verify wallet', async () => {
        return VERIFY.authorizeTokenForVerify(
            asset3,
            '4',
            '14',
            { from: account1 }
        )
    })

    
    it('Should safePutIn string2 to asset2', async () => {
        return VERIFY.safePutIn(
            asset2,
            string2Hash,
            '20',
            { from: account1 }
        )
    })


    it('Should putIn string1 to asset1', async () => {
        return VERIFY.putIn(
            asset1,
            string1Hash,
            { from: account1 }
        )
    })


    it('Should putIn string3 to asset1', async () => {
        return VERIFY.putIn(
            asset1,
            string3Hash,
            { from: account1 }
        )
    })


    it('Should takeOut string2 from asset2', async () => {
        return VERIFY.takeOut(
            asset2,
            string2Hash,
            { from: account1 }
        )
    })


    it('Should putIn string2 to asset1', async () => {
        return VERIFY.putIn(
            asset1,
            string2Hash,
            { from: account1 }
        )
    })

    
    it('Should transferVerify 1 to asset2', async () => {
        return VERIFY.transfer(
            asset1,
            asset2,
            string1Hash,
            { from: account1 }
        )
    })


    it('Should mark asset1 counterfeit', async () => {
        return VERIFY.markCounterfeit(
            asset1,
            string1Hash,
            { from: account1 }
        )
    })


    it('Should mark string3 to status0', async () => {
        console.log("//**************************************END VERIFY TEST**********************************************/")
        return VERIFY.markItem(
            asset1,
            string3Hash,
            '0',
            '0',
            { from: account1 }
        )
    })

})