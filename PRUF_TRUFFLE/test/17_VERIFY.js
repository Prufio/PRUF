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
const PRUF_VERIFY = artifacts.require('VERIFY');

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

let account2Hash;
let account4Hash;
let account6Hash;

let account000 = '0x0000000000000000000000000000000000000000'

let nakedAuthCode1;
let nakedAuthCode3;
let nakedAuthCode7;

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


it('Should deploy PRUF_VERIFY', async () => {
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


    account2Hash = await Helper.getAddrHash(
        account2
    )

    account4Hash = await Helper.getAddrHash(
        account4
    )

    account6Hash = await Helper.getAddrHash(
        account6
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
            console.log("Adding VERIFY to storage for use in AC 0")
            return STOR.OO_addContract("VERIFY", VERIFY.address, '0', '1', { from: account1 })
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
        
        .then(() => {
            console.log("Adding in AC_TKN")
            return AC_TKN.OO_setStorageContract(STOR.address, { from: account1 })
        })
        
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
            console.log("Adding in VERIFY")
            return VERIFY.OO_setStorageContract(STOR.address, { from: account1 })
        })
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
        
        .then(() => {
            console.log("Resolving in AC_TKN")
            return AC_TKN.OO_resolveContractAddresses({ from: account1 })
        })
        
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
            return APP_NC.OO_resolveContractAddresses({ from: account1 })})
        
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
            console.log("Resolving in VERIFY")
            return VERIFY.OO_resolveContractAddresses({ from: account1 })
        })
})


it('Should mint a asset root token', async () => {

    console.log("Minting root token 1")
    return AC_MGR.createAssetClass(account1, 'CUSTODIAL_ROOT', '1', '1', '3', { from: account1 })
})


it("Should Mint 2 non cust AC", async () => {
    
    console.log("Minting AC 10 -NC")
    return AC_MGR.createAssetClass(account1, "NonCustodial_AC10", "10", "1", "2", { from: account1 })

        .then(() => {
            console.log("Minting AC 11 -NC to Account2")
            return AC_MGR.createAssetClass(account2, "NonCustodial_AC11", "11", "1", "2", { from: account1 })
        })
})


it("Should Mint 4 verify AC tokens", async () => {
    
    console.log("Minting AC 12 Verify")
    return AC_MGR.createAssetClass(account1, "Verify1", "12", "1", "4", { from: account1 })

        .then(() => {
            console.log("Minting AC 13 Verify")
            return AC_MGR.createAssetClass(account1, "Verify2", "13", "1", "4", { from: account1 })
        })

        .then(() => {
            console.log("Minting AC 14 Verify to Account2")
            return AC_MGR.createAssetClass(account2, "Verify3", "14", "1", "4", { from: account1 })
        })

        .then(() => {
            console.log("Minting AC 15 Verify to Account2")
            return AC_MGR.createAssetClass(account2, "Verify4", "15", "1", "4", { from: account1 })
        })

})


// it('Should authorize APP in all relevant asset classes', async () => {
//     console.log("Authorizing APP")
//     return STOR.enableContractForAC('APP', '10', '1', { from: account1 })
        
//     .then(() => {
//             return STOR.enableContractForAC('APP', '11', '1', { from: account1 })
//         })
// })


it('Should authorize APP_NC in all relevant asset classes', async () => {
    
    console.log("Authorizing APP_NC")
    return STOR.enableContractForAC('APP_NC', '10', '2', { from: account1 })
        
        .then(() => {
            return STOR.enableContractForAC('APP_NC', '11', '2', { from: account2 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('APP_NC', '12', '4', { from: account1 })
        })

        .then(() => {
            return STOR.enableContractForAC('APP_NC', '13', '4', { from: account1 })
        })

        .then(() => {
            return STOR.enableContractForAC('APP_NC', '14', '4', { from: account2 })
        })

        .then(() => {
            return STOR.enableContractForAC('APP_NC', '15', '4', { from: account2 })
        })

})


// it('Should authorize NP in all relevant asset classes', async () => {
    
//     console.log("Authorizing NP")
//     return STOR.enableContractForAC('NP', '10', '1', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('NP', '11', '1', { from: account1 })
//         })
// })


// it('Should authorize MAL_APP in all relevant asset classes', async () => {
    
//     console.log("Authorizing MAL_APP")
//     return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('MAL_APP', '11', '1', { from: account1 })
//         })
// })


it('Should authorize NP_NC in all relevant asset classes', async () => {
    
    console.log("Authorizing NP_NC")
    return STOR.enableContractForAC('NP_NC', '10', '2', { from: account1 })
        
        .then(() => {
            return STOR.enableContractForAC('NP_NC', '11', '2', { from: account2 })
        })

        .then(() => {
            return STOR.enableContractForAC('NP_NC', '12', '4', { from: account1 })
        })

        .then(() => {
            return STOR.enableContractForAC('NP_NC', '13', '4', { from: account1 })
        })

        .then(() => {
            return STOR.enableContractForAC('NP_NC', '14', '4', { from: account2 })
        })

        .then(() => {
            return STOR.enableContractForAC('NP_NC', '15', '4', { from: account2 })
        })
})


// it('Should authorize ECR in all relevant asset classes', async () => {
    
//     console.log("Authorizing ECR")
//     return STOR.enableContractForAC('ECR', '10', '3', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR', '11', '3', { from: account1 })
//         })
// })


// it('Should authorize ECR2 in all relevant asset classes', async () => {
    
//     console.log("Authorizing ECR2")
//     return STOR.enableContractForAC('ECR2', '10', '3', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR2', '11', '3', { from: account1 })
//         })
// })


// it('Should authorize ECR_NC in all relevant asset classes', async () => {
    
//     console.log("Authorizing ECR_NC")
//     return STOR.enableContractForAC('ECR_NC', '12', '3', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR_NC', '13', '3', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR_NC', '14', '3', { from: account1 })
//         })

//         .then(() => {
//             return STOR.enableContractForAC('ECR_NC', '16', '3', { from: account10 })
//         })
// })


// it('Should authorize ECR_MGR in all relevant asset classes', async () => {
    
//     console.log("Authorizing ECR_MGR")
//     return STOR.enableContractForAC('ECR_MGR', '10', '3', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR_MGR', '11', '3', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR_MGR', '12', '3', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR_MGR', '13', '3', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('ECR_MGR', '14', '3', { from: account1 })
//         })

//         .then(() => {
//             return STOR.enableContractForAC('ECR_MGR', '16', '3', { from: account10 })
//         })
// })


it('Should authorize AC_TKN in all relevant asset classes', async () => {
    
    console.log("Authorizing AC_TKN")
    return STOR.enableContractForAC('AC_TKN', '10', '2', { from: account1 })
        
        .then(() => {
            return STOR.enableContractForAC('AC_TKN', '11', '2', { from: account2 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('AC_TKN', '12', '4', { from: account1 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('AC_TKN', '13', '4', { from: account1 })
        })

        .then(() => {
            return STOR.enableContractForAC('AC_TKN', '14', '4', { from: account2 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('AC_TKN', '15', '4', { from: account2 })
        })
})


it('Should authorize A_TKN in all relevant asset classes', async () => {
    
    console.log("Authorizing A_TKN")
    return STOR.enableContractForAC('A_TKN', '10', '2', { from: account1 })
        
        .then(() => {
            return STOR.enableContractForAC('A_TKN', '11', '2', { from: account2 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('A_TKN', '12', '4', { from: account1 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('A_TKN', '13', '4', { from: account1 })
        })

        .then(() => {
            return STOR.enableContractForAC('A_TKN', '14', '4', { from: account2 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('A_TKN', '15', '4', { from: account2 })
        })
})


// it('Should authorize PIP in all relevant asset classes', async () => {
    
//     console.log("Authorizing PIP")
//     return STOR.enableContractForAC('PIP', '10', '1', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('PIP', '11', '1', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('PIP', '12', '2', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('PIP', '13', '2', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('PIP', '14', '2', { from: account1 })
//         })

//         .then(() => {
//             return STOR.enableContractForAC('PIP', '15', '2', { from: account10 })
//         })

//         .then(() => {
//             return STOR.enableContractForAC('PIP', '16', '2', { from: account10 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('PIP', '1', '1', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('PIP', '2', '1', { from: account1 })
//         })
// })


it('Should authorize AC_MGR in all relevant asset classes', async () => {
    
    console.log("Authorizing AC_MGR")
    return STOR.enableContractForAC('AC_MGR', '10', '2', { from: account1 })
        
        .then(() => {
            return STOR.enableContractForAC('AC_MGR', '11', '2', { from: account2 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('AC_MGR', '12', '4', { from: account1 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('AC_MGR', '13', '4', { from: account1 })
        })

        .then(() => {
            return STOR.enableContractForAC('AC_MGR', '14', '4', { from: account2 })
        })
        
        .then(() => {
            return STOR.enableContractForAC('AC_MGR', '15', '4', { from: account2 })
        })
})


// it('Should authorize RCLR in all relevant asset classes', async () => {
    
//     console.log("Authorizing RCLR")
//     return STOR.enableContractForAC('RCLR', '10', '3', { from: account1 })
        
//         .then(() => {
//             return STOR.enableContractForAC('RCLR', '11', '3', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('RCLR', '12', '3', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('RCLR', '13', '3', { from: account1 })
//         })
        
//         .then(() => {
//             return STOR.enableContractForAC('RCLR', '14', '3', { from: account1 })
//         })

//         .then(() => {
//             return STOR.enableContractForAC('RCLR', '16', '3', { from: account10 })
//         })
// })


it('Should authorize VERIFY in all relevant asset classes', async () => {
    
    console.log("Authorizing VERIFY")
    return STOR.enableContractForAC('VERIFY', '12', '4', { from: account1 })

    .then(() => {
        return STOR.enableContractForAC('VERIFY', '13', '4', { from: account1 })
    })

    .then(() => {
        return STOR.enableContractForAC('VERIFY', '14', '4', { from: account2 })
    })

    .then(() => {
        return STOR.enableContractForAC('VERIFY', '15', '4', { from: account2 })
    })
})


it("Should set costs in minted AC's", async () => {

    console.log("Setting costs in AC 10")
    return AC_MGR.ACTH_setCosts(
        "10",
        "1",
        "10000000000000000",
        account1,
        { from: account1 })

        .then(() => {
            return AC_MGR.ACTH_setCosts(
                "10",
                "2",
                "10000000000000000",
                account1,
                { from: account1 })
        })

        .then(() => {
            return AC_MGR.ACTH_setCosts(
                "10",
                "3",
                "10000000000000000",
                account1,
                { from: account1 })
        })

        .then(() => {
            return AC_MGR.ACTH_setCosts(
                "10",
                "4",
                "10000000000000000",
                account1,
                { from: account1 })
        })

        .then(() => {
            return AC_MGR.ACTH_setCosts(
                "10",
                "5",
                "10000000000000000",
                account1,
                { from: account1 })
        })

        .then(() => {
            return AC_MGR.ACTH_setCosts(
                "10",
                "6",
                "10000000000000000",
                account1,
                { from: account1 })
        })

        .then(() => {
            console.log("Setting base costs in AC 11")
            return AC_MGR.ACTH_setCosts(
                "11",
                "1",
                "10000000000000000",
                account1,
                { from: account2 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account2 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account2 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account2 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account2 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "11",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account2 })
            })
        
        .then(() => {
            console.log("Setting base costs in AC 12")
            return AC_MGR.ACTH_setCosts(
                "12",
                "1",
                "10000000000000000",
                account1,
                { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "12",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })
        
        .then(() => {
            console.log("Setting base costs in AC 13")
            return AC_MGR.ACTH_setCosts(
                "13",
                "1",
                "10000000000000000",
                account1,
                { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "2",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "3",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "4",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "5",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                return AC_MGR.ACTH_setCosts(
                    "13",
                    "6",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })

            .then(() => {
                console.log("Setting base costs in AC 14")
                return AC_MGR.ACTH_setCosts(
                    "14",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "14",
                        "2",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "14",
                        "3",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "14",
                        "4",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "14",
                        "5",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "14",
                        "6",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
            
            .then(() => {
                console.log("Setting base costs in AC 15")
                return AC_MGR.ACTH_setCosts(
                    "15",
                    "1",
                    "10000000000000000",
                    account1,
                    { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "15",
                        "2",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "15",
                        "3",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "15",
                        "4",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "15",
                        "5",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
    
                .then(() => {
                    return AC_MGR.ACTH_setCosts(
                        "15",
                        "6",
                        "10000000000000000",
                        account1,
                        { from: account2 })
                })
})


it('Should add users to AC 10-14 in AC_Manager', async () => {

    console.log("//**************************************END BOOTSTRAP**********************************************/")
    console.log("Account1 => AC10")
    return AC_MGR.OO_addUser(account1, '1', '10', { from: account1 })
        
        .then(() => {
            console.log("Account1 => AC11")
            return AC_MGR.OO_addUser(account1, '1', '11', { from: account2 })
        })
        
        .then(() => {
            console.log("Account1 => AC12")
            return AC_MGR.OO_addUser(account1, '1', '12', { from: account1 })
        })

        .then(() => {
            console.log("Account1 => AC13")
            return AC_MGR.OO_addUser(account1, '1', '13', { from: account1 })
        })

        .then(() => {
            console.log("Account1 => AC14")
            return AC_MGR.OO_addUser(account1, '1', '14', { from: account2 })
        })

        .then(() => {
            console.log("Account1 => AC15")
            return AC_MGR.OO_addUser(account1, '1', '15', { from: account2 })
        })
        
        .then(() => {
            console.log("Account2 => AC10")
            return AC_MGR.OO_addUser(account2, '1', '10', { from: account1 })
        })
        
        .then(() => {
            console.log("Account2 => AC11")
            return AC_MGR.OO_addUser(account2, '1', '11', { from: account2 })
        })

        .then(() => {
            console.log("Account2 => AC12")
            return AC_MGR.OO_addUser(account2, '1', '12', { from: account1 })
        })

        .then(() => {
            console.log("Account2 => AC13")
            return AC_MGR.OO_addUser(account2, '1', '13', { from: account1 })
        })

        .then(() => {
            console.log("Account2 => AC14")
            return AC_MGR.OO_addUser(account2, '1', '14', { from: account2 })
        })

        .then(() => {
            console.log("Account2 => AC15")
            return AC_MGR.OO_addUser(account2, '1', '15', { from: account2 })
        })
})


it('Should mint PRUF_ID token to account1', async () => {

    console.log("//**************************************BEGIN VERIFY TEST**********************************************/")
    console.log("//**************************************BEGIN VERIFY SETUP**********************************************/")
    return ID_TKN.mintPRUF_IDToken(
    account1,
    '1',
    {from: account1}
    )
})


it('Should mint PRUF_ID token to account2', async () => {
    return ID_TKN.mintPRUF_IDToken(
    account2,
    '2',
    {from: account1}
    )
})


it('Should mint asset1', async () => {
    return APP_NC.$newRecord(
    asset1,
    rgt1,
    '12',
    '100',
    {from: account1, value: 20000000000000000 }
    )
})


it('Should authorize asset1 as verify wallet', async () => {
    return VERIFY.authorizeTokenForVerify(
    asset1,
    '2',
    '12',
    {from: account1}
    )
})


it('Should mint asset2', async () => {
    return APP_NC.$newRecord(
    asset2,
    rgt2,
    '14',
    '100',
    {from: account2, value: 20000000000000000 }
    )
})


it('Should authorize asset2 as verify wallet', async () => {
    return VERIFY.authorizeTokenForVerify(
    asset2,
    '3',
    '14',
    {from: account2}
    )
})


it('Should mint asset3', async () => {
    return APP_NC.$newRecord(
    asset3,
    rgt3,
    '10',
    '100',
    {from: account1, value: 20000000000000000 }
    )
})


it('Should mint asset4', async () => {
    return APP_NC.$newRecord(
    asset4,
    rgt4,
    '12',
    '100',
    {from: account1, value: 20000000000000000 }
    )
})

it('Should authorize asset4 as verify wallet', async () => {
    return VERIFY.authorizeTokenForVerify(
    asset4,
    '2',
    '12',
    {from: account1}
    )
})


it('Should mint asset5', async () => {
    return APP_NC.$newRecord(
    asset5,
    rgt5,
    '11',
    '100',
    {from: account2, value: 20000000000000000 }
    )
})


it('Should mint asset6', async () => {
    return APP_NC.$newRecord(
    asset6,
    rgt6,
    '15',
    '100',
    {from: account2, value: 20000000000000000 }
    )
})


it('Should authorize asset6 as verify wallet', async () => {
    return VERIFY.authorizeTokenForVerify(
    asset6,
    '2',
    '15',
    {from: account2}
    )
})


it('Should mint asset7', async () => {
    return APP_NC.$newRecord(
    asset7,
    rgt7,
    '14',
    '100',
    {from: account2, value: 20000000000000000 }
    )
})


it('Should authorize asset7 as verify wallet', async () => {
    return VERIFY.authorizeTokenForVerify(
    asset7,
    '1',
    '14',
    {from: account2}
    )
})

//1
it('Should fail because caller does not hold AC token', async () => {

    console.log("//**************************************END VERIFY SETUP**********************************************/")
    console.log("//**************************************BEGIN VERIFY FAIL BATCH (33)**********************************************/")
    console.log("//**************************************BEGIN authorizeTokenForVerify FAIL BATCH**********************************************/")
    return VERIFY.authorizeTokenForVerify(
    asset6,
    '2',
    '12',
    {from: account2}
    )
})

//2
it('Should fail because AC is not VERIFY authorized', async () => {
    return VERIFY.authorizeTokenForVerify(
    asset4,
    '2',
    '10',
    {from: account1}
    )
})

//3
it('Should fail because AC of asset token does not match supplied AC', async () => {
    return VERIFY.authorizeTokenForVerify(
    asset3,
    '2',
    '13',
    {from: account1}
    )
})

//4
it('Should fail because caller does not hold verify wallet', async () => {

    console.log("//**************************************END authorizeTokenForVerify FAIL BATCH**********************************************/")
    console.log("//**************************************BEGIN safePutIn FAIL BATCH**********************************************/")
    return VERIFY.safePutIn(
    asset2,
    string1Hash,
    '20',
    {from: account1}
    )
})

//5
it('Should fail because asset3 is not verified wallet', async () => {
    return VERIFY.safePutIn(
    asset3,
    string2Hash,
    '20',
    {from: account1}
    )
})


it('Should put string1 into asset1', async () => {
    return VERIFY.safePutIn(
    asset1,
    string1Hash,
    '20',
    {from: account1}
    )
})

//6
it('Should fail because asset is already in Verify wallet', async () => {
    return VERIFY.safePutIn(
    asset1,
    string1Hash,
    '20',
    {from: account1}
    )
})

it('Should put string2 into asset2', async () => {
    return VERIFY.safePutIn(
    asset2,
    string2Hash,
    '17',
    {from: account2}
    )
})


it('Should mark string1 as status 1', async () => {
    return VERIFY.markItem(
    asset1,
    string1Hash,
    '1',
    '0',
    {from: account1}
    )
})


it('Should takeOut string1 from asset1', async () => {
    return VERIFY.takeOut(
    asset1,
    string1Hash,
    {from: account1}
    )
})

//7
it('Should fail because string1 is not in status 0', async () => {
    return VERIFY.safePutIn(
    asset2,
    string1Hash,
    '20',
    {from: account2}
    )
})


it('Should put string1 into asset2', async () => {
    return VERIFY.putIn(
    asset2,
    string1Hash,
    {from: account2}
    )
})


it('Should change string1 status to 0', async () => {
    return VERIFY.markItem(
    asset2,
    string1Hash,
    '0',
    '0',
    {from: account2}
    )
})


it('Should add 1 collision to string1', async () => {
    return VERIFY.putIn(
    asset1,
    string1Hash,
    {from: account1}
    )
})


it('Should takeOut string1 from asset1', async () => {
    return VERIFY.takeOut(
    asset2,
    string1Hash,
    {from: account2}
    )
})

//8
it('Should fail because string1 maxCollisions exceeds 1', async () => {
    return VERIFY.safePutIn(
    asset2,
    string1Hash,
    '0',
    {from: account2}
    )
})


it('Should put string1 into asset2', async () => {
    return VERIFY.putIn(
    asset2,
    string1Hash,
    {from: account2}
    )
})


//9
it('Should fail because caller does not hold verify wallet', async () => {

    console.log("//**************************************END safePutIn FAIL BATCH**********************************************/")
    console.log("//**************************************BEGIN putIn FAIL BATCH**********************************************/")
    return VERIFY.putIn(
    asset2,
    string1Hash,
    {from: account1}
    )
})

//10
it('Should fail because asset3 is not verified wallet', async () => {
    return VERIFY.putIn(
    asset3,
    string2Hash,
    {from: account1}
    )
})

//11
it('Should fail because string1 already in callers verify wallet', async () => {
    return VERIFY.putIn(
    asset2,
    string1Hash,
    {from: account2}
    )
})


it('Should mark string1 counterfeit', async () => {
    return VERIFY.adminMarkItem(
    asset2,
    string1Hash,
    '2',
    '0',
    {from: account2}
    )
})


it('Should takeOut string1 from asset2', async () => {
    return VERIFY.takeOut(
    asset2,
    string1Hash,
    {from: account2}
    )
})

//12
it('Should fail because string1 is marked status2(counterfeit)', async () => {
    return VERIFY.putIn(
    asset1,
    string1Hash,
    {from: account1}
    )
})



it('Should put string1 into asset2)', async () => {
    return VERIFY.putIn(
    asset2,
    string1Hash,
    {from: account2}
    )
})


it('Should mark string1 status 3(stolen)', async () => {
    return VERIFY.adminMarkItem(
    asset2,
    string1Hash,
    '3',
    '0',
    {from: account2}
    )
})


it('Should takeOut string1 from asset2', async () => {
    return VERIFY.takeOut(
    asset2,
    string1Hash,
    {from: account2}
    )
})

//13
it('Should fail because string1 is marked status3(stolen)', async () => {
    return VERIFY.putIn(
    asset1,
    string1Hash,
    {from: account1}
    )
})

it('Should put string1 into asset2', async () => {
    return VERIFY.safePutIn(
    asset2,
    string1Hash,
    '20',
    {from: account2}
    )
})

//14
it('Should fail because caller does not hold verify wallet', async () => {

    console.log("//**************************************END putIn FAIL BATCH**********************************************/")
    console.log("//**************************************BEGIN takeOut FAIL BATCH**********************************************/")
    return VERIFY.takeOut(
    asset2,
    string1Hash,
    {from: account1}
    )
})

//15
it('Should fail because asset3 is not verified wallet', async () => {
    return VERIFY.takeOut(
    asset3,
    string2Hash,
    {from: account1}
    )
})

//16
it('Should fail because caller does not hold item', async () => {
    return VERIFY.takeOut(
    asset1,
    string1Hash,
    {from: account1}
    )
})

//17
it('Should fail because caller does not hold item', async () => {
    return VERIFY.takeOut(
    asset2,
    string1Hash,
    {from: account2}
    )
})

//18
it('Should fail because caller does not hold verify wallet', async () => {

    console.log("//**************************************END takeOut FAIL BATCH**********************************************/")
    console.log("//**************************************BEGIN transfer FAIL BATCH**********************************************/")
    return VERIFY.transfer(
    asset2,
    asset1,
    string1Hash,
    {from: account1}
    )
})

//19
it('Should fail because asset3 is not verified wallet', async () => {
    return VERIFY.transfer(
    asset3,
    asset1,
    string2Hash,
    {from: account1}
    )
})

//20
it('Should fail because caller does not hold item', async () => {
    return VERIFY.transfer(
    asset1,
    asset4,
    string1Hash,
    {from: account1}
    )
})

//21
it('Should fail because wallet is not in the same AC', async () => {
    return VERIFY.transfer(
    asset2,
    asset6,
    string1Hash,
    {from: account2}
    )
})


it('Should mark string1 status 2(Counterfeit)', async () => {
    return VERIFY.adminMarkItem(
    asset2,
    string1Hash,
    '2',
    '0',
    {from: account2}
    )
})

//22
it('Should fail because item is marked status2(Counterfeit)', async () => {
    return VERIFY.transfer(
    asset2,
    asset7,
    string1Hash,
    {from: account2}
    )
})


it('Should mark string1 status 3(Stolen)', async () => {
    return VERIFY.adminMarkItem(
    asset2,
    string1Hash,
    '3',
    '0',
    {from: account2}
    )
})

//23
it('Should fail because item is marked L/S)', async () => {
    return VERIFY.transfer(
    asset2,
    asset7,
    string1Hash,
    {from: account2}
    )
})

//24
it('Should fail because caller does not hold verify wallet', async () => {

    console.log("//**************************************END transfer FAIL BATCH**********************************************/")
    console.log("//**************************************BEGIN adminMarkItem FAIL BATCH**********************************************/")
    return VERIFY.adminMarkItem(
    asset2,
    string1Hash,
    '1',
    '0',
    {from: account1}
    )
})

//25
it('Should fail because asset3 is not verified wallet', async () => {
    return VERIFY.adminMarkItem(
    asset3,
    string2Hash,
    '1',
    '0',
    {from: account1}
    )
})


it('Should mark string1 to status0', async () => {
    return VERIFY.adminMarkItem(
    asset2,
    string1Hash,
    '0',
    '0',
    {from: account2}
    )
})


it('Should transfer string1 to asset7', async () => {
    return VERIFY.transfer(
    asset2,
    asset7,
    string1Hash,
    {from: account2}
    )
})

//26
it('Should fail because caller is not authLevel3 in verify wallet', async () => {
    return VERIFY.adminMarkItem(
    asset7,
    string1Hash,
    '1',
    '0',
    {from: account2}
    )
})

//27
it('Should fail because caller does not hold item', async () => {
    return VERIFY.adminMarkItem(
    asset1,
    string1Hash,
    '1',
    '0',
    {from: account1}
    )
})

//28
it('Should fail because caller does not hold verify wallet', async () => {

    console.log("//**************************************END adminMarkItem FAIL BATCH**********************************************/")
    console.log("//**************************************BEGIN markItem FAIL BATCH**********************************************/")
    return VERIFY.markItem(
    asset2,
    string1Hash,
    '1',
    '0',
    {from: account1}
    )
})

//29
it('Should fail because asset3 is not verified wallet', async () => {
    return VERIFY.markItem(
    asset3,
    string2Hash,
    '1',
    '0',
    {from: account1}
    )
})

//30
it('Should fail because decclared status cannot = 2', async () => {
    return VERIFY.markItem(
    asset7,
    string1Hash,
    '2',
    '0',
    {from: account2}
    )
})

//31
it('Should fail because user not authroized >1 authLevel', async () => {
    return VERIFY.markItem(
    asset7,
    string1Hash,
    '1',
    '0',
    {from: account2}
    )
})


it('Should transfer string1 to asset2', async () => {
    return VERIFY.transfer(
    asset7,
    asset2,
    string1Hash,
    {from: account2}
    )
})


it('Should mark item as 5(In Process)', async () => {
    return VERIFY.adminMarkItem(
    asset2,
    string1Hash,
    '5',
    '0',
    {from: account2}
    )
})

//32
it('Should fail because item is in status5(In Process)', async () => {
    return VERIFY.markItem(
    asset2,
    string1Hash,
    '1',
    '0',
    {from: account2}
    )
})

//33
it('Should fail because caller does not hold item', async () => {

    console.log("//**************************************END VERIFY FAIL BATCH**********************************************/")
    console.log("//**************************************END VERIFY TEST**********************************************/")
    return VERIFY.markItem(
    asset1,
    string1Hash,
    '1',
    '0',
    {from: account1}
    )
})

})