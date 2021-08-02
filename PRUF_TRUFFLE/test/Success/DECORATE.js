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
const PRUF_NP = artifacts.require('NP');
const PRUF_NODE_MGR = artifacts.require('NODE_MGR');
const PRUF_NODE_TKN = artifacts.require('NODE_TKN');
const PRUF_A_TKN = artifacts.require('A_TKN');
const PRUF_Foreign721 = artifacts.require('Foreign721');
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
const PRUF_DECORATE = artifacts.require('DECORATE');

let STOR;
let APP;
let NP;
let NODE_MGR;
let NODE_TKN;
let A_TKN;
let Foreign721;
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
let DECORATE;

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

let recordCode1;

let payableRoleB32;
let minterRoleB32;
let trustedAgentRoleB32;
let assetTransferRoleB32;
let discardRoleB32;

contract('DECORATE', accounts => {

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


    it('Should deploy PRUF_Foreign721', async () => {
        const PRUF_Foreign721_TEST = await PRUF_Foreign721.deployed({ from: account1 });
        console.log(PRUF_Foreign721_TEST.address);
        assert(PRUF_Foreign721_TEST.address !== '')
        Foreign721 = PRUF_Foreign721_TEST;
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


    it('Should deploy DECORATE', async () => {
        const PRUF_DECORATE_TEST = await PRUF_DECORATE.deployed({ from: account1 });
        console.log(PRUF_DECORATE_TEST.address);
        assert(PRUF_DECORATE_TEST.address !== '')
        DECORATE = PRUF_DECORATE_TEST;
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


        recordCode1 = await Helper.getHashOfUint256AndAddress(
            '0', Foreign721.address
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
                console.log("Adding NODE_MGR to storage for use in AC 0")
                return STOR.OO_addContract("NODE_MGR", NODE_MGR.address, '0', '1', { from: account1 })
            })

            .then(() => {
                console.log("Adding NODE_TKN to storage for use in AC 0")
                return STOR.OO_addContract("NODE_TKN", NODE_TKN.address, '0', '1', { from: account1 })
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

            .then(() => {
                console.log("Adding DECORATE to storage for use in AC 0")
                return STOR.OO_addContract("DECORATE", DECORATE.address, '0', '2', { from: account1 })
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

            .then(() => {
                console.log("Adding in DECORATE")
                return DECORATE.OO_setStorageContract(STOR.address, { from: account1 })
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

            .then(() => {
                console.log("Resolving in DECORATE")
                return DECORATE.OO_resolveContractAddresses({ from: account1 })
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

            // .then(() => {
            //     console.log("Authorizing DECORATE")
            //     return A_TKN.grantRole(minterRoleB32, DECORATE.address, { from: account1 })
            // })
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
                console.log("Authorizing NP")
                return UTIL_TKN.grantRole(payableRoleB32, NP.address, { from: account1 })
            })

            .then(() => {
                console.log("Authorizing NP_NC")
                return UTIL_TKN.grantRole(payableRoleB32, NP_NC.address, { from: account1 })
            })

            .then(() => {
                console.log("Authorizing DECORATE")
                return UTIL_TKN.grantRole(payableRoleB32, DECORATE.address, { from: account1 })
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
        return APP.grantRole(assetTransferRoleB32, NP.address, { from: account1 })
    })


    it('Should authorize all minter contracts for minting NODE_TKN(s)', async () => {
        console.log("Authorizing NODE_MGR")
        return RCLR.grantRole(discardRoleB32, A_TKN.address, { from: account1 })
    })



    // it('Should authorize NODE_MGR as trusted agent in NODE_TKN', async () => {

    //     console.log("Authorizing NODE_MGR")
    //     return NODE_TKN.grantRole(trustedAgentRoleB32, NODE_MGR.address, { from: account1 })
    // })
        
        
    it('Should mint 2 asset root tokens', async () => {

        console.log("Minting root token 1")
        return NODE_MGR.createAssetClass('1', 'ROOT1', '1', '3', "0", "0", rgt000, account1, { from: account1 })
    
        .then(() => {
            console.log("Minting root token 2")
            return NODE_MGR.createAssetClass('2', 'ROOT2', '2', '3', "0", "0", rgt000, account1, { from: account1 })
        })
    })


    it("Should Mint 2 cust and 2 non-cust AC tokens in AC_ROOT 1", async () => {

        console.log("Minting AC 10 -C")
        return NODE_MGR.createAssetClass("10", 'CUSTODIAL_AC10', '1', '1', '0', "0", rgt000, account1, { from: account1 })

            .then(() => {
                console.log("Minting AC 11 -C")
                return NODE_MGR.createAssetClass("11", 'CUSTODIAL_AC11', '1', '1', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 12 -NC")
                return NODE_MGR.createAssetClass("12", 'CUSTODIAL_AC12', '1', '2', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 13 -NC")
                return NODE_MGR.createAssetClass("13", 'CUSTODIAL_AC13', '1', '5', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 16 -NC")
                return NODE_MGR.createAssetClass("16", 'CUSTODIAL_AC16', '2', '5', '0', "0", rgt000, account10, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 17 -NC")
                return NODE_MGR.createAssetClass("17", 'CUSTODIAL_AC17', '2', '5', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 18 -NC")
                return NODE_MGR.createAssetClass("18", 'CUSTODIAL_AC18', '2', '5', '0', "0", rgt000, account1, { from: account1 })
            })

            .then(() => {
                console.log("Minting AC 19 -NC")
                return NODE_MGR.createAssetClass("19", 'CUSTODIAL_AC19', '2', '5', '0', "0", rgt000, account1, { from: account1 })
            })
    })


    it("Should Mint 2 non-cust AC tokens in AC_ROOT 2", async () => {

        console.log("Minting AC 14 -NC")
        return NODE_MGR.createAssetClass("14", 'CUSTODIAL_AC14', '2', '2', '0', "0", rgt000, account1, { from: account1 })

            .then(() => {
                console.log("Minting AC 15 -NC")
                return NODE_MGR.createAssetClass("15", 'CUSTODIAL_AC15', '2', '2', '0', "0", rgt000, account10, { from: account1 })
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
                return STOR.enableContractForAC('APP_NC', '16', '2', { from: account10 })
            })
    })


    it('Should authorize NP in all relevant nodes', async () => {

        console.log("Authorizing NP")
        return STOR.enableContractForAC('NP', '10', '1', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('NP', '11', '1', { from: account1 })
            })
    })


    it('Should authorize MAL_APP in all relevant nodes', async () => {

        console.log("Authorizing MAL_APP")
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('MAL_APP', '11', '1', { from: account1 })
            })
    })


    it('Should authorize NP_NC in all relevant nodes', async () => {

        console.log("Authorizing NP_NC")
        return STOR.enableContractForAC('NP_NC', '12', '2', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('NP_NC', '13', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('NP_NC', '14', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('NP_NC', '16', '2', { from: account10 })
            })
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

            .then(() => {
                return STOR.enableContractForAC('ECR_NC', '16', '3', { from: account10 })
            })
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

            .then(() => {
                return STOR.enableContractForAC('ECR_MGR', '16', '3', { from: account10 })
            })
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
                return STOR.enableContractForAC('A_TKN', '15', '2', { from: account10 })
            })

            .then(() => {
                return STOR.enableContractForAC('A_TKN', '16', '2', { from: account10 })
            })

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
                return STOR.enableContractForAC('PIP', '15', '2', { from: account10 })
            })

            .then(() => {
                return STOR.enableContractForAC('PIP', '16', '2', { from: account10 })
            })

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


    it('Should authorize DECORATE in all relevant nodes', async () => {

        console.log("Authorizing DECORATE")
        return STOR.enableContractForAC('DECORATE', '12', '2', { from: account1 })

            .then(() => {
                return STOR.enableContractForAC('DECORATE', '13', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('DECORATE', '14', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('DECORATE', '16', '2', { from: account10 })
            })

            .then(() => {
                return STOR.enableContractForAC('DECORATE', '17', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('DECORATE', '18', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('DECORATE', '19', '2', { from: account1 })
            })
    })


    it("Should set costs in minted AC's", async () => {

        console.log("Setting costs in AC 1")

        return NODE_MGR.ACTH_setCosts(
            "1",
            "1",
            "10000000000000000",
            account1,
            { from: account1 })


            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "1",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "1",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "1",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "1",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "1",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "1",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "1",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 2")
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "2",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 10")
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "10",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 11")
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "11",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 12")
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "12",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 13")
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "13",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 14")
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "14",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 15")
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "15",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                console.log("Setting base costs in AC 16")
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "16",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })

            .then(() => {
                console.log("Setting base costs in AC 17")
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "17",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 18")
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "18",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 19")
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "7",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return NODE_MGR.ACTH_setCosts(
                    "19",
                    "8",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })
    })


    it('Should add users to AC 10-14 in AC_Manager', async () => {

        console.log("//**************************************END BOOTSTRAP**********************************************/")
        console.log("Account2 => AC10")
        return NODE_MGR.addUser('10', account2Hash, '1', { from: account1 })

            .then(() => {
                console.log("Account2 => AC11")
                return NODE_MGR.addUser('11', account2Hash, '1', { from: account1 })
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
                console.log("Account4 => AC12")
                return NODE_MGR.addUser('16', account4Hash, '1', { from: account10 })
            })

            .then(() => {
                console.log("Account5 => AC13")
                return NODE_MGR.addUser('13', account5Hash, '1', { from: account1 })
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
                return NODE_MGR.addUser('15', account10Hash, '10', { from: account10 })
            })

            .then(() => {
                console.log("Account10 => AC15 (PIPMINTER)")
                return NODE_MGR.addUser('16', account10Hash, '10', { from: account10 })
            })

            .then(() => {
                console.log("Account10 => AC15 (PIPMINTER)")
                return NODE_MGR.addUser('10', account10Hash, '1', { from: account1 })
            })
    })




    it('Should mint 30000 tokens to account1', async () => {

        console.log("//**************************************BEGIN DECORATE SUCCESS TEST**********************************************/")
        return UTIL_TKN.mint(
            account1,
            '30000000000000000000000',
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


    it('Should mint ID_TKN(1) to account1', async () => {
        return ID_TKN.mintPRUF_IDToken(
            account1,
            '1',
            { from: account1 }
        )
    })


    it('Should mint external 721 0', async () => {
        return Foreign721.mint(
            account1,
            { from: account1 }
        )
    })

    // it('Should update extended data of AC17 to Foreign721.address', async () => {
    //     return NODE_MGR.updateACreferenceAddress(
    //         Foreign721.address,
    //         "0",
    //         "0",
    //         "0",
    //         "17",
    //         { from: account1 }
    //     )
    // })

    it("Should retrieve 0 (NULL)", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should decorate asset1', async () => {
        return DECORATE.decorate721(
            "0",
            Foreign721.address,
            rgt1,
            "17",
            "5000",
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should mod status to 52', async () => {
        return DECORATE._modStatus(
            "0",
            Foreign721.address,
            "52",
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1 stat52", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should mod status to 51', async () => {
        return DECORATE._modStatus(
            "0",
            Foreign721.address,
            "51",
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1 stat51", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should setPrice to 500', async () => {
        return DECORATE._setPrice(
            "0",
            Foreign721.address,
            "500000000000000000000",
            "2",
            { from: account1 }
        )
    })

    it("Should retrieve pricedata recordCode1 price 500", async () => {
        var Record = [];

        return await STOR.getPriceData(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should setPrice to 0', async () => {
        return DECORATE._clearPrice(
            "0",
            Foreign721.address,
            { from: account1 }
        )
    })

    it("Should retrieve pricedata recordCode1 price 0", async () => {
        var Record = [];

        return await STOR.getPriceData(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should dec 500', async () => {
        return DECORATE._decCounter(
            "0",
            Foreign721.address,
            "500",
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1 dec 4500", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should _modIpfs1 to rgt1', async () => {
        return DECORATE._modIpfs1(
            "0",
            Foreign721.address,
            rgt1,
            rgt000,
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1 ipfs1=rgt1", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should addIpfs2Note to rgt1', async () => {
        return DECORATE.addIpfs2Note(
            "0",
            Foreign721.address,
            rgt1,
            rgt000,
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1 ipfs1=rgt1", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should export recordCode1', async () => {
        return DECORATE._export(
            "0",
            Foreign721.address,
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1 ac 1 stat 70", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

    it('Should import recordCode1', async () => {
        return DECORATE._import(
            "0",
            Foreign721.address,
            "18",
            { from: account1 }
        )
    })

    it("Should retrieve recordCode1 ac 18 stat 52", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(recordCode1, { from: account1 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })


    it('Should write record in AC 10 @ IDX&RGT(1)', async () => {
        console.log("//**************************************END DECORATE SUCCESS BATCH**********************************************/")
        console.log("//**************************************END DECORATE TEST**********************************************/")
        console.log("//**************************************BEGIN THE WORKS**********************************************/")
        return APP.newRecord(
            asset12,
            rgt12,
            '10',
            '100',
            { from: account2 }
        )
    })


    it('Should change status of new asset12 to status(1)', async () => {
        return NP._modStatus(
            asset12,
            rgt12,
            '1',
            { from: account2 }
        )
    })


    it('Should Transfer asset12 RGT(1) to RGT(2)', async () => {
        return APP.transferAsset(
            asset12,
            rgt12,
            rgt2,
            { from: account2 }
        )
    })


    it('Should force modify asset12 RGT(2) to RGT(1)', async () => {
        return APP.forceModRecord(
            asset12,
            rgt12,
            { from: account2 }
        )
    })


    it('Should change decrement amount @asset12 from (100) to (85)', async () => {
        return NP._decCounter(
            asset12,
            rgt12,
            '15',
            { from: account2 }
        )
    })


    it('Should modify Ipfs1 note @asset12 to IDX(1)', async () => {
        return NP._modIpfs1(
            asset12,
            rgt12,
            asset12,
            rgt000,
            { from: account2 }
        )
    })


    it('Should change status of new asset12 to status(51)', async () => {
        return NP._modStatus(
            asset12,
            rgt12,
            '51',
            { from: account2 }
        )
    })


    it('Should export asset12 to account2', async () => {
        return NP.exportAsset(
            asset12,
            account2,
            { from: account2 }
        )
    })


    it('Should import asset12 to AC(12)(NC)', async () => {
        return APP_NC.importAsset(
            asset12,
            '12',
            { from: account2 }
        )
    })


    // it('Should re-mint asset12 token to account2', async () => {
    //     return APP_NC.reMintToken(
    //     asset12,
    //     'a',
    //     'a',
    //     'a',
    //     'a',
    //     'a',
    //     {from: account2}
    //     )
    // })


    it('Should set Ipfs2 note to IDX(1)', async () => {
        return APP_NC.addIpfs2Note(
            asset12,
            asset12,
            rgt000,
            { from: account2 }
        )
    })


    it('Should change status of asset12 to status(51)', async () => {
        return NP_NC._modStatus(
            asset12,
            '51',
            { from: account2 }
        )
    })


    it('Should set asset12 into escrow for 3 minutes', async () => {
        return ECR_NC.setEscrow(
            asset12,
            account2Hash,
            '180',
            '56',
            { from: account2 }
        )
    })


    it('Should take asset12 out of escrow', async () => {
        return ECR_NC.endEscrow(
            asset12,
            { from: account2 }
        )
    })


    it('Should change decrement amount @asset12 from (85) to (70)', async () => {
        return NP_NC._decCounter(
            asset12,
            '15',
            { from: account2 }
        )
    })


    it('Should force modify asset12 RGT(1) to RGT(2)', async () => {
        return NP_NC._changeRgt(
            asset12,
            rgt2,
            { from: account2 }
        )
    })


    it('Should modify Ipfs1 note @asset12 to RGT(1)', async () => {
        return NP_NC._modIpfs1(
            asset12,
            rgt12,
            rgt000,
            { from: account2 }
        )
    })

    it('Should change status of asset12 to status(51)', async () => {
        return NP_NC._modStatus(
            asset12,
            '51',
            { from: account2 }
        )
    })

    it('Should export asset12(status70)', async () => {
        return NP_NC._exportNC(
            asset12,
            { from: account2 }
        )
    })


    it('Should transfer asset12 token to PRUF_APP contract', async () => {
        return A_TKN.safeTransferFrom(
            account2,
            APP.address,
            asset12,
            { from: account2 }
        )
    })


    it('Should import asset12 to AC(11)', async () => {
        return APP.importAsset(
            asset12,
            rgt12,
            '11',
            { from: account2 }
        )
    })


    it('Should change status of asset12 to status(1)', async () => {
        return NP._modStatus(
            asset12,
            rgt12,
            '1',
            { from: account2 }
        )
    })


    it('Should set asset12 into locked escrow for 3 minutes', async () => {
        return ECR.setEscrow(
            asset12,
            account2Hash,
            '180',
            '50',
            { from: account2 }
        )
    })


    it('Should take asset12 out of escrow', async () => {
        return ECR.endEscrow(
            asset12,
            { from: account2 }
        )
    })


    it('Should change status of asset12 to status(1)', async () => {
        return NP._modStatus(
            asset12,
            rgt12,
            '1',
            { from: account2 }
        )
    })


    it('Should set asset12 into escrow for 3 minutes', async () => {
        return ECR.setEscrow(
            asset12,
            account2Hash,
            '180',
            '6',
            { from: account2 }
        )
    })


    it('Should set asset12 to stolen(3) status', async () => {
        return NP._setLostOrStolen(
            asset12,
            rgt12,
            '3',
            { from: account2 }
        )
    })


    it('Should change status of asset12 to status(1)', async () => {
        return NP._modStatus(
            asset12,
            rgt12,
            '1',
            { from: account2 }
        )
    })

    it("Should retrieve asset12", async () => {
        var Record = [];

        return await STOR.retrieveShortRecord(asset12, { from: account2 }, function (_err, _result) {
            if (_err) { }
            else {
                Record = Object.values(_result)
                console.log(Record)
            }
        })
    })

});