/*--------------------------------------------------------PRüF0.8.0
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
        const PRUF_NP = artifacts.require('NP');
        const PRUF_AC_MGR = artifacts.require('AC_MGR');
        const PRUF_AC_TKN = artifacts.require('AC_TKN');
        const PRUF_A_TKN = artifacts.require('A_TKN');
        const PRUF_ID_TKN = artifacts.require('ID_TKN');
        const PRUF_ECR_MGR = artifacts.require('ECR_MGR');
        const PRUF_ECR = artifacts.require('ECR');
        const PRUF_ECR2 = artifacts.require('ECR2');
        const PRUF_APP_NC = artifacts.require('APP_NC');
        const PRUF_NP_NC = artifacts.require('NP_NC');
        const PRUF_ECR_NC = artifacts.require('ECR_NC');
        const PRUF_RCLR = artifacts.require('RCLR');
        const PRUF_PIP = artifacts.require('PIP');
        const PRUF_HELPER = artifacts.require('Helper');
        const PRUF_MAL_APP = artifacts.require('MAL_APP');
        const PRUF_UTIL_TKN = artifacts.require('UTIL_TKN');
        
        let STOR;
        let APP;
        let NP;
        let AC_MGR;
        let AC_TKN;
        let A_TKN;
        let ID_TKN;
        let ECR_MGR;
        let ECR;
        let ECR2;
        let ECR_NC;
        let APP_NC;
        let NP_NC;
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
        
        contract('UTIL_TKN', accounts => {
        
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
        
        
            it('Should deploy PRUF_NP', async () => {
                const PRUF_NP_TEST = await PRUF_NP.deployed({ from: account1 });
                console.log(PRUF_NP_TEST.address);
                assert(PRUF_NP_TEST.address !== '');
                NP = PRUF_NP_TEST;
            })
        
        
            it('Should deploy PRUF_AC_MGR', async () => {
                const PRUF_AC_MGR_TEST = await PRUF_AC_MGR.deployed({ from: account1 });
                console.log(PRUF_AC_MGR_TEST.address);
                assert(PRUF_AC_MGR_TEST.address !== '');
                AC_MGR = PRUF_AC_MGR_TEST;
            })
        
        
            it('Should deploy PRUF_AC_TKN', async () => {
                const PRUF_AC_TKN_TEST = await PRUF_AC_TKN.deployed({ from: account1 });
                console.log(PRUF_AC_TKN_TEST.address);
                assert(PRUF_AC_TKN_TEST.address !== '')
                AC_TKN = PRUF_AC_TKN_TEST;
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
        
        
            it('Should deploy PRUF_NP_NC', async () => {
                const PRUF_NP_NC_TEST = await PRUF_NP_NC.deployed({ from: account1 });
                console.log(PRUF_NP_NC_TEST.address);
                assert(PRUF_NP_NC_TEST.address !== '')
                NP_NC = PRUF_NP_NC_TEST;
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

        console.log("Adding APP to storage for use in AC 0")
        return STOR.OO_addContract("APP", APP.address, '0', '1', { from: account1 })

            .then(() => {
                console.log("Adding NP to storage for use in AC 0")
                return STOR.OO_addContract("NP", NP.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding AC_MGR to storage for use in AC 0")
                return STOR.OO_addContract("AC_MGR", AC_MGR.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding AC_TKN to storage for use in AC 0")
                return STOR.OO_addContract("AC_TKN", AC_TKN.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding A_TKN to storage for use in AC 0")
                return STOR.OO_addContract("A_TKN", A_TKN.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding ID_TKN to storage for use in AC 0")
                return STOR.OO_addContract("ID_TKN", ID_TKN.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding ECR_MGR to storage for use in AC 0")
                return STOR.OO_addContract("ECR_MGR", ECR_MGR.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding ECR to storage for use in AC 0")
                return STOR.OO_addContract("ECR", ECR.address, '0', '3', { from: account1 })
            })

            .then(() => {
                console.log("Adding ECR2 to storage for use in AC 0")
                return STOR.OO_addContract("ECR2", ECR2.address, '0', '3', { from: account1 })
            })

            .then(() => {
                console.log("Adding APP_NC to storage for use in AC 0")
                return STOR.OO_addContract("APP_NC", APP_NC.address, '0', '2', { from: account1 })
            })

            .then(() => {
                console.log("Adding NP_NC to storage for use in AC 0")
                return STOR.OO_addContract("NP_NC", NP_NC.address, '0', '2', { from: account1 })
            })

            .then(() => {
                console.log("Adding ECR_NC to storage for use in AC 0")
                return STOR.OO_addContract("ECR_NC", ECR_NC.address, '0', '3', { from: account1 })
            })

            .then(() => {
                console.log("Adding PIP to storage for use in AC 0")
                return STOR.OO_addContract("PIP", PIP.address, '0', '2', { from: account1 })
            })

            .then(() => {
                console.log("Adding RCLR to storage for use in AC 0")
                return STOR.OO_addContract("RCLR", RCLR.address, '0', '3', { from: account1 })
            })

            .then(() => {
                console.log("Adding MAL_APP to storage for use in AC 0")
                return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding UTIL_TKN to storage for use in AC 0")
                return STOR.OO_addContract("UTIL_TKN", UTIL_TKN.address, '0', '1', { from: account1 })
            })
    })


    it('Should add Storage in each contract', async () => {

        console.log("Adding in APP")
        return APP.OO_setStorageContract(STOR.address, { from: account1 })

            .then(() => {
                console.log("Adding in NP")
                return NP.OO_setStorageContract(STOR.address, { from: account1 })
            })

            .then(() => {
                console.log("Adding in MAL_APP")
                return MAL_APP.OO_setStorageContract(STOR.address, { from: account1 })
            })

            .then(() => {
                console.log("Adding in AC_MGR")
                return AC_MGR.OO_setStorageContract(STOR.address, { from: account1 })
            })

            // .then(() => {
            //     console.log("Adding in AC_TKN")
            //     return AC_TKN.OO_setStorageContract(STOR.address, { from: account1 })
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
                console.log("Adding in NP_NC")
                return NP_NC.OO_setStorageContract(STOR.address, { from: account1 })
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

            // .then(() => {
            //     console.log("Adding in UTIL_TKN")
            //     return UTIL_TKN.AdminSetStorageContract(STOR.address, { from: account1 })
            // })
    })


    it('Should resolve contract addresses', async () => {

        console.log("Resolving in APP")
        return APP.OO_resolveContractAddresses({ from: account1 })

            .then(() => {
                console.log("Resolving in NP")
                return NP.OO_resolveContractAddresses({ from: account1 })
            })

            .then(() => {
                console.log("Resolving in MAL_APP")
                return MAL_APP.OO_resolveContractAddresses({ from: account1 })
            })

            .then(() => {
                console.log("Resolving in AC_MGR")
                return AC_MGR.OO_resolveContractAddresses({ from: account1 })
            })

            // .then(() => {
            //     console.log("Resolving in AC_TKN")
            //     return AC_TKN.OO_resolveContractAddresses({ from: account1 })
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
                console.log("Resolving in NP_NC")
                return NP_NC.OO_resolveContractAddresses({ from: account1 })
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

            // .then(() => {
            //     console.log("Resolving in UTIL_TKN")
            //     return UTIL_TKN.AdminResolveContractAddresses({ from: account1 })
            // })
    })
        
    it('Should authorize all minter contracts for minting A_TKN(s)', async () => {

        console.log("Authorizing NP")
        return A_TKN.grantRole(minterRoleB32, NP.address, { from: account1 })

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

        console.log("Authorizing AC_MGR")
        return UTIL_TKN.grantRole(payableRoleB32, AC_MGR.address, { from: account1 })

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
                console.log("Authorizing NP")
                return UTIL_TKN.grantRole(payableRoleB32, NP.address, { from: account1 })
            })

            .then(() => {
                console.log("Authorizing NP_NC")
                return UTIL_TKN.grantRole(payableRoleB32, NP_NC.address, { from: account1 })
            })
    })


    it('Should authorize AC_MGR as trusted agent in AC_TKN', async () => {
    
        console.log("Authorizing AC_MGR")
        return UTIL_TKN.grantRole(trustedAgentRoleB32, AC_MGR.address, { from: account1 })
    })


    it('Should authorize all minter contracts for minting AC_TKN(s)', async () => {
        console.log("Authorizing AC_MGR")
        return AC_TKN.grantRole(minterRoleB32, AC_MGR.address, { from: account1 })
    })


    it('Should authorize all minter contracts for minting AC_TKN(s)', async () => {
        console.log("Authorizing AC_MGR")
        return APP.grantRole(assetTransferRoleB32, NP.address, { from: account1 })
    })


    it('Should authorize all minter contracts for minting AC_TKN(s)', async () => {
        console.log("Authorizing AC_MGR")
        return RCLR.grantRole(discardRoleB32, A_TKN.address, { from: account1 })
    })
        
        
    it('Should mint a couple of asset root tokens', async () => {
        
        console.log("Minting root token 1 -C")
        return AC_MGR.createAssetClass("1", 'CUSTODIAL_ROOT1', '1', '3', '0', "0", rgt000, account1, { from: account1 })

            .then(() => {
                console.log("Minting root token 2 -NC")
                return AC_MGR.createAssetClass("2", 'CUSTODIAL_ROOT2', '2', '3', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting root token 3 -RESTRICTED")
                return AC_MGR.createAssetClass("3", 'CUSTODIAL_ROOT3', '3', '3', '1', "0", rgt000, account2, { from: account1 })
            })
    })


    it("Should Mint 2 cust and 2 non-cust AC tokens in AC_ROOT 1", async () => {

        console.log("Minting AC 10 -C")
        return AC_MGR.createAssetClass("10", 'CUSTODIAL_AC10', '1', '1', '0', "0", rgt000, account1, { from: account1 })

            .then(() => {
                console.log("Minting AC 11 -C")
                return AC_MGR.createAssetClass("11", 'CUSTODIAL_AC11', '1', '1', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 12 -NC")
                return AC_MGR.createAssetClass("12", 'CUSTODIAL_AC12', '1', '2', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 13 -NC")
                return AC_MGR.createAssetClass("13", 'CUSTODIAL_AC13', '1', '2', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 16 -NC")
                return AC_MGR.createAssetClass("16", 'CUSTODIAL_AC16', '1', '2', '0', "0", rgt000, account10, { from: account1 })
            })
    })


    it("Should Mint 2 non-cust AC tokens in AC_ROOT 2", async () => {

        console.log("Minting AC 14 -NC")
        return AC_MGR.createAssetClass("14", 'CUSTODIAL_AC14', '2', '2', '0', "0", rgt000, account1, { from: account1 })

            .then(() => {
                console.log("Minting AC 15 -NC")
                return AC_MGR.createAssetClass("15", 'CUSTODIAL_AC15', '2', '2', '0', "0", rgt000, account10, { from: account1 })
            })
    })

    it('Should authorize APP in all relevant asset classes', async () => {
        console.log("Authorizing APP")
        return STOR.enableContractForAC('APP', '10', '1', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('APP', '11', '1', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('APP', '12', '1', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('APP', '13', '1', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('APP', '14', '1', { from: account1 })
            })
    })


    it('Should authorize NP in all relevant asset classes', async () => {

        console.log("Authorizing NP")
        return STOR.enableContractForAC('NP', '10', '1', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('NP', '11', '1', { from: account1 })
            })
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {

        console.log("Authorizing MAL_APP")
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('MAL_APP', '11', '1', { from: account1 })
            })
    })


    it('Should authorize ECR in all relevant asset classes', async () => {

        console.log("Authorizing ECR")
        return STOR.enableContractForAC('ECR', '10', '3', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('ECR', '11', '3', { from: account1 })
            })
    })


    it('Should authorize ECR_MGR in all relevant asset classes', async () => {

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
    })


    it('Should authorize AC_TKN in all relevant asset classes', async () => {

        console.log("Authorizing AC_TKN")
        return STOR.enableContractForAC('AC_TKN', '10', '1', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('AC_TKN', '11', '1', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('AC_TKN', '12', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('AC_TKN', '13', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('AC_TKN', '14', '2', { from: account1 })
            })
    })


    it('Should authorize A_TKN in all relevant asset classes', async () => {

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
                return STOR.enableContractForAC('A_TKN', '1', '1', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('A_TKN', '2', '1', { from: account1 })
            })
    })


    it('Should authorize PIP in all relevant asset classes', async () => {

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
                return STOR.enableContractForAC('PIP', '1', '1', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('PIP', '2', '1', { from: account1 })
            })
    })


    it('Should authorize AC_MGR in all relevant asset classes', async () => {

        console.log("Authorizing AC_MGR")
        return STOR.enableContractForAC('AC_MGR', '10', '1', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('AC_MGR', '11', '1', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('AC_MGR', '12', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('AC_MGR', '13', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('AC_MGR', '14', '2', { from: account1 })
            })
    })


    it('Should authorize RCLR in all relevant asset classes', async () => {

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
    })


    it("Should set costs in minted Root AC1", async () => {

        console.log("Setting costs in AC 1")
        return AC_MGR.ACTH_setCosts(
            "1",
            "1",
            "100000000000000000",
            account4,
            { from: account1 })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "1",
                    "2",
                    "100000000000000000",
                    account4,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "1",
                    "3",
                    "100000000000000000",
                    account4,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "1",
                    "4",
                    "100000000000000000",
                    account4,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "1",
                    "5",
                    "100000000000000000",
                    account4,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "1",
                    "6",
                    "100000000000000000",
                    account4,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "1",
                    "7",
                    "100000000000000000",
                    account4,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "1",
                    "8",
                    "100000000000000000",
                    account4,
                    { from: account1 })
            })
    })


    it("Should set costs in minted Root AC2", async () => {

        console.log("Setting costs in AC 2")
        return AC_MGR.ACTH_setCosts(
            "2",
            "1",
            "200000000000000000",
            account5,
            { from: account1 })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "2",
                    "2",
                    "200000000000000000",
                    account5,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "2",
                    "3",
                    "200000000000000000",
                    account5,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "2",
                    "4",
                    "200000000000000000",
                    account5,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "2",
                    "5",
                    "200000000000000000",
                    account5,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "2",
                    "6",
                    "200000000000000000",
                    account5,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "2",
                    "7",
                    "200000000000000000",
                    account5,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "2",
                    "8",
                    "200000000000000000",
                    account5,
                    { from: account1 })
            })
    })


    it("Should set costs in minted AC's", async () => {

        console.log("Setting costs in AC 10")
        return AC_MGR.ACTH_setCosts(
            "10",
            "1",
            "100000000000000000",
            account6,
            { from: account1 })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "10",
                    "2",
                    "100000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "10",
                    "3",
                    "100000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "10",
                    "4",
                    "100000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "10",
                    "5",
                    "100000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "10",
                    "6",
                    "100000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "10",
                    "7",
                    "100000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "10",
                    "8",
                    "100000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 11")
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "1",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "2",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "3",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "4",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "5",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "6",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "7",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "8",
                    "200000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 12")
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "1",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "2",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "3",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "4",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "5",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "6",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "7",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "8",
                    "300000000000000000",
                    account6,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 13")
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "1",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "2",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "3",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "4",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "5",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "6",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "7",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "8",
                    "400000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 14")
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "1",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "2",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "3",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "4",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "5",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "6",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "7",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "8",
                    "500000000000000000",
                    account7,
                    { from: account1 })
            })
    })


    it('Should add users to AC 10-14 in AC_Manager', async () => {
    
        console.log("//**************************************END BOOTSTRAP**********************************************/")
        console.log("Account2 => AC10")
        return AC_MGR.addUser('10', account2Hash, '1', { from: account1 })
            
            .then(() => {
                console.log("Account2 => AC11")
                return AC_MGR.addUser('11', account2Hash, '1', { from: account1 })
            })
            
            .then(() => {
                console.log("Account2 => AC12")
                return AC_MGR.addUser('12', account2Hash, '1', { from: account1 })
            })
    
            .then(() => {
                console.log("Account2 => AC13")
                return AC_MGR.addUser('13', account2Hash, '1', { from: account1 })
            })
    
            .then(() => {
                console.log("Account2 => AC14")
                return AC_MGR.addUser('14', account2Hash, '1', { from: account1 })
            })
    })


    // it('Should set PaymentAddress', async () => {


    //     return UTIL_TKN.AdminSetPaymentAddress(
    //         account8,
    //         { from: account1 }
    //     )
    // })


    it('Should mint 30000 tokens to account1', async () => {
             console.log("//**************************************BEGIN UTIL_TKN**********************************************/")
        return UTIL_TKN.mint(
            account1,
            '30000000000000000000000',
            { from: account1 }
        )
    })


    it('Should add all default contracts', async () => {

        return STOR.addDefaultContracts('0', 'NP_NC', '2', { from: account1 })

            .then(() => {
                return STOR.addDefaultContracts('1', 'APP_NC', '2', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('2', 'AC_MGR', '1', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('3', 'AC_TKN', '1', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('4', 'A_TKN', '1', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('5', 'ECR_MGR', '3', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('6', 'RCLR', '3', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('7', 'PIP', '1', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('8', 'PURCHASE', '2', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('9', 'DECORATE', '2', { from: account1 })
            })

            .then(() => {
                return STOR.addDefaultContracts('10', 'WRAP', '2', { from: account1 })
            })
    })


    it('Should mint ID token to account2', async () => {
        return ID_TKN.mintPRUF_IDToken(
        account2, 
        "1",
        {from: account1}
        )
    })


    it('Should mint ID token to account3', async () => {
        return ID_TKN.mintPRUF_IDToken(
        account3, 
        "2",
        {from: account1}
        )
    })


    it("Should retrieve balanceOf(30000) Pruf tokens @account1", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    // it("Should retrieve base AC_discount @AC13 0/100", async () => {
    //     var Discount = [];

    //     return await AC_MGR.getAC_discount('13', { from: account1 }, function (_err, _result) {
    //         if (_err) { }
    //         else {
    //             Discount = Object.values(_result)
    //             console.log(Discount)
    //         }
    //     })
    // })


    // it('Should increaseShare to 3/97 split @AC13', async () => {
    //     return AC_MGR.increaseShare(
    //         '13',
    //         '3000000000000000000000',
    //         { from: account1 }
    //     )
    // })


    // it("Should retrieve AC_discount @AC13 54/46", async () => {
    //     var Discount = [];

    //     return await AC_MGR.getAC_discount('13', { from: account1 }, function (_err, _result) {
    //         if (_err) { }
    //         else {
    //             Discount = Object.values(_result)
    //             console.log(Discount)
    //         }
    //     })
    // })


    it('Should mint 300000 tokens to account2', async () => {
        return UTIL_TKN.mint(
            account2,
            '300000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(300000) Pruf tokens @account2", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account2, { from: account2 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve cost of ACtoken", async () => {
        var ACSaleInfo = [];

        return await AC_MGR.currentACpricingInfo({ from: account2 }, function (_err, _result) {
            if (_err) { }
            else {
                ACSaleInfo = Object.values(_result)
                console.log(ACSaleInfo)
            }
        })
    })


    it('Should purchace ACtoken to account2', async () => {
        return AC_MGR.purchaseACnode(
            'account2FTW',
            '1',
            '1',
            rgt000, 
            { from: account2 }
        )
    })


    it("Should retrieve 300000 - cost of purchaseACnode", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account2, { from: account2 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve balanceOf(1) ACtokens @account2", async () => {
        var Balance = [];

        return await AC_TKN.balanceOf(account2, { from: account2 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should mint 300000 tokens to account3', async () => {
        return UTIL_TKN.mint(
            account3,
            '300000000000000000000000',
            { from: account1 }
        )
    })


    it("Should retrieve balanceOf(300000) Pruf tokens @account3", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account3 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it("Should retrieve cost of ACtoken", async () => {
        var ACSaleInfo = [];

        return await AC_MGR.currentACpricingInfo({ from: account2 }, function (_err, _result) {
            if (_err) { }
            else {
                ACSaleInfo = Object.values(_result)
                console.log(ACSaleInfo)
            }
        })
    })


    it('Should purchace ACtoken to account3', async () => {
        return AC_MGR.purchaseACnode(
            'account3FTW',
            '1',
            '1',
            rgt000, 
            { from: account3 }
        )
    })


    it("Should retrieve balanceOf(1) ACtokens @account3", async () => {
        var Balance = [];

        return await AC_TKN.balanceOf(account3, { from: account3 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    // it("Should make sure account3 is owner of AC12", async () => {
    //     var ACnumber = [];

    //     return await AC_TKN.tokenOfOwnerByIndex(account3, '12', { from: account3 }, function (_err, _result) {
    //         if (_err) { }
    //         else {
    //             ACnumber = Object.values(_result)
    //             console.log(ACnumber)
    //         }
    //     })
    // })


    it("Should retrieve 10000 - cost of purchaseACnode", async () => {
        var Balance = [];

        return await UTIL_TKN.balanceOf(account3, { from: account3 }, function (_err, _result) {
            if (_err) { }
            else {
                Balance = Object.values(_result)
                console.log(Balance)
            }
        })
    })


    it('Should pause contract', async () => {
        return UTIL_TKN.pause(
            { from: account1 }
        )
    })


    it('Should unpause contract', async () => {
        return UTIL_TKN.unpause(
            { from: account1 }
        )
    })


    // it("Should retrieve balanceOf Pruf tokens @account8", async () => {

    //     console.log("//**************************************END Discount TEST**********************************************/")
    //     var Balance = [];

    //     return await UTIL_TKN.balanceOf(account8, { from: account8 }, function (_err, _result) {
    //         if (_err) { }
    //         else {
    //             Balance = Object.values(_result)
    //             console.log(Balance)
    //         }
    //     })
    // })
})