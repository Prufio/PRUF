//
    //
    // DECLARATIONS
    //
    //
    const PRUF_STOR = artifacts.require('STOR');
    const PRUF_APP = artifacts.require('APP');
    const PRUF_NP = artifacts.require('NP');
    const PRUF_AC_MGR = artifacts.require('AC_MGR');
    const PRUF_AC_TKN = artifacts.require('AC_TKN');
    const PRUF_A_TKN = artifacts.require('A_TKN');
    const PRUF_ECR_MGR = artifacts.require('ECR_MGR');
    const PRUF_ECR = artifacts.require('ECR');
    const PRUF_ECR2 = artifacts.require('ECR2');
    const PRUF_APP_NC = artifacts.require('APP_NC');
    const PRUF_NP_NC = artifacts.require('NP_NC');
    const PRUF_ECR_NC = artifacts.require('ECR_NC');
    const PRUF_RCLR = artifacts.require('RCLR');
    const PRUF_NAKED = artifacts.require('NAKED');
    const PRUF_HELPER = artifacts.require('Helper');
    const PRUF_MAL_APP = artifacts.require('MAL_APP');

    let STOR;
    let APP;
    let NP;
    let AC_MGR;
    let AC_TKN;
    let A_TKN;
    let ECR_MGR;
    let ECR;
    let ECR2;
    let ECR_NC;
    let APP_NC;
    let NP_NC;
    let RCLR;
    let Helper;
    let MAL_APP;

    let string1Hash;
    let string2Hash;
    let string3Hash;
    let string4Hash;
    let string5Hash;

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

    let rgt1;
    let rgt2;
    let rgt3;
    let rgt4;
    let rgt5;
    let rgt6;
    let rgt7;
    let rgt8;
    let rgt12;
    let rgt000 = "0x0000000000000000000000000000000000000000000000000000000000000000";
    let rgtFFF = "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

    let account2Hash;
    let account4Hash;
    let account6Hash;

    let account000 = '0x0000000000000000000000000000000000000000'

    let nakedAuthCode1;
    let nakedAuthCode3;
    let nakedAuthCode7;
    
        //
        //
        // END DECLARATIONS
        //
        //
    
    contract('STOR', accounts => {
            
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

    //
    //
    //ENVIRONMENT SETUP
    //
    //

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


    it('Should deploy PRUF_NAKED', async () => {
        const PRUF_NAKED_TEST = await PRUF_NAKED.deployed({ from: account1 });
        console.log(PRUF_NAKED_TEST.address);
        assert(PRUF_NAKED_TEST.address !== '')
        NAKED = PRUF_NAKED_TEST;
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
                console.log("Adding NAKED to storage for use in AC 0")
                return STOR.OO_addContract("NAKED", NAKED.address, '0', '2', { from: account1 })
            })
            
            .then(() => {
                console.log("Adding RCLR to storage for use in AC 0")
                return STOR.OO_addContract("RCLR", RCLR.address, '0', '3', { from: account1 })
            })

            .then(() => {
                console.log("Adding MAL_APP to storage for use in AC 0")
                return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
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
                console.log("Adding in NAKED")
                return NAKED.OO_setStorageContract(STOR.address, { from: account1 })
            })
            
            .then(() => {
                console.log("Adding in RCLR")
                return RCLR.OO_setStorageContract(STOR.address, { from: account1 })
            })
    })


    it('Should resolve contract addresses', async () => {

        console.log("Resolving in APP")
        return APP.OO_ResolveContractAddresses({ from: account1 })

            .then(() => {
                console.log("Resolving in NP")
                return NP.OO_ResolveContractAddresses({ from: account1 })
            })

            .then(() => {
                console.log("Resolving in MAL_APP")
                return MAL_APP.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in AC_MGR")
                return AC_MGR.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in AC_TKN")
                return AC_TKN.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in A_TKN")
                return A_TKN.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in ECR_MGR")
                return ECR_MGR.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in ECR")
                return ECR.OO_ResolveContractAddresses({ from: account1 })
            })

            .then(() => {
                console.log("Resolving in ECR2")
                return ECR2.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in APP_NC")
                return APP_NC.OO_ResolveContractAddresses({ from: account1 })})
            
            .then(() => {
                console.log("Resolving in NP_NC")
                return NP_NC.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in ECR_NC")
                return ECR_NC.OO_ResolveContractAddresses({ from: account1 })
            })

            .then(() => {
                console.log("Resolving in NAKED")
                return NAKED.OO_ResolveContractAddresses({ from: account1 })
            })
            
            .then(() => {
                console.log("Resolving in RCLR")
                return RCLR.OO_ResolveContractAddresses({ from: account1 })
            })
    })


    it('Should mint a couple of asset root tokens', async () => {

        console.log("Minting root token 1 -C")
        return AC_MGR.createAssetClass(account1, 'CUSTODIAL_ROOT', '1', '1', '3', { from: account1 })

            .then(() => {
                console.log("Minting root token 2 -NC")
                return AC_MGR.createAssetClass(account1, 'NON-CUSTODIAL_ROOT', '2', '2', '3', { from: account1 })
            })
    })


    it("Should Mint 2 cust and 2 non-cust AC tokens in AC_ROOT 1", async () => {
        
        console.log("Minting AC 10 -C")
        return AC_MGR.createAssetClass(account1, "Custodial_AC1", "10", "1", "1", { from: account1 })

            .then(() => {
                console.log("Minting AC 11 -C")
                return AC_MGR.createAssetClass(account1, "Custodial_AC2", "11", "1", "1", { from: account1 })
            })
            
            .then(() => {
                console.log("Minting AC 12 -NC")
                return AC_MGR.createAssetClass(account1, "Non-Custodial_AC1", "12", "1", "2", { from: account1 })
            })
            
            .then(() => {
                console.log("Minting AC 13 -NC")
                return AC_MGR.createAssetClass(account1, "Non-Custodial_AC2", "13", "1", "2", { from: account1 })
            })
    })


    it("Should Mint 2 non-cust AC tokens in AC_ROOT 2", async () => {
        
        console.log("Minting AC 14 -NC")
        return AC_MGR.createAssetClass(account1, "Non-Custodial_AC3", "14", "2", "2", { from: account1 })

            .then(() => {
                console.log("Minting AC 15 -NC")
                return AC_MGR.createAssetClass(account10, "Non_Custodial_AC4", "15", "2", "2", { from: account1 })
            })
    })


    it('Should authorize APP in all relevant asset classes', async () => {
        console.log("Authorizing APP")
        return STOR.enableContractForAC('APP', '10', '1', { from: account1 })
            
        .then(() => {
                return STOR.enableContractForAC('APP', '11', '1', { from: account1 })
            })

            // .then(() => {
            //     return STOR.enableContractForAC('APP', '1', '1', { from: account1 })
            // })
    })


    it('Should authorize APP_NC in all relevant asset classes', async () => {
        
        console.log("Authorizing APP_NC")
        return STOR.enableContractForAC('APP_NC', '12', '2', { from: account1 })
            
        .then(() => {
                return STOR.enableContractForAC('APP_NC', '13', '2', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('APP_NC', '14', '2', { from: account1 })
            })
            
            // .then(() => {
            //     return STOR.enableContractForAC('APP_NC', '2', '2', { from: account1 })
            // })
    })


    it('Should authorize NP in all relevant asset classes', async () => {
        
        console.log("Authorizing NP")
        return STOR.enableContractForAC('NP', '10', '1', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('NP', '11', '1', { from: account1 })
            })
            
            // .then(() => {
            //     return STOR.enableContractForAC('NP', '1', '1', { from: account1 })
            // })
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {
        
        console.log("Authorizing MAL_APP")
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('MAL_APP', '11', '1', { from: account1 })
            })
            
            // .then(() => {
            //     return STOR.enableContractForAC('NP', '1', '1', { from: account1 })
            // })
    })


    it('Should authorize NP_NC in all relevant asset classes', async () => {
        
        console.log("Authorizing NP_NC")
        return STOR.enableContractForAC('NP_NC', '12', '2', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('NP_NC', '13', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('NP_NC', '14', '2', { from: account1 })
            })

            // .then(() => {
            //     return STOR.enableContractForAC('NP_NC', '2', '0', { from: account1 })
            // })
    })


    it('Should authorize ECR in all relevant asset classes', async () => {
        
        console.log("Authorizing ECR")
        return STOR.enableContractForAC('ECR', '10', '3', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('ECR', '11', '3', { from: account1 })
            })
            
            // .then(() => {
            //     return STOR.enableContractForAC('ECR', '1', '3', { from: account1 })
            // })
    })


    it('Should authorize ECR2 in all relevant asset classes', async () => {
        
        console.log("Authorizing ECR2")
        return STOR.enableContractForAC('ECR2', '10', '3', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('ECR2', '11', '3', { from: account1 })
            })
            
    })


    it('Should authorize ECR_NC in all relevant asset classes', async () => {
        
        console.log("Authorizing ECR_NC")
        return STOR.enableContractForAC('ECR_NC', '12', '3', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('ECR_NC', '13', '3', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('ECR_NC', '14', '3', { from: account1 })
            })
            
            // .then(() => {
            //     return STOR.enableContractForAC('ECR_NC', '2', '3', { from: account1 })
            // })
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
            
            // .then(() => {
            //     return STOR.enableContractForAC('ECR_MGR', '1', '3', { from: account1 })
            // })
            
            // .then(() => {
            //     return STOR.enableContractForAC('ECR_MGR', '2', '3', { from: account1 })
            // })
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
                return STOR.enableContractForAC('A_TKN', '15', '2', { from: account10 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN', '1', '1', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN', '2', '1', { from: account1 })
            })
    })


    it('Should authorize NAKED in all relevant asset classes', async () => {
        
        console.log("Authorizing NAKED")
        return STOR.enableContractForAC('NAKED', '10', '1', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('NAKED', '11', '1', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('NAKED', '12', '2', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('NAKED', '13', '2', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('NAKED', '14', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('NAKED', '15', '2', { from: account10 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('NAKED', '1', '1', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('NAKED', '2', '1', { from: account1 })
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
            
            // .then(() => {
            //     return STOR.enableContractForAC('AC_MGR', '1', '0', { from: account1 })
            // })
            
            // .then(() => {
            //     return STOR.enableContractForAC('AC_MGR', '2', '0', { from: account1 })
            // })
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
            
            // .then(() => {
            //     return STOR.enableContractForAC('RCLR', '1', '0', { from: account1 })
            // })
            
            // .then(() => {
            //     return STOR.enableContractForAC('RCLR', '2', '0', { from: account1 })
            // })
    })


    it("Should set base costs in root tokens", async () => {

        console.log("Setting base costs in root 1")
        return AC_MGR.ACTH_setCosts("1",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            account1,
            { from: account1 })

            .then(() => {
                console.log("Setting base costs in root 2")
                return AC_MGR.ACTH_setCosts("2",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    account1,
                    { from: account1 })
            })
    })


    it("Should set costs in minted AC's", async () => {

        console.log("Setting costs in AC 10")
        return AC_MGR.ACTH_setCosts("10",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            "10000000000000000",
            account1,
            { from: account1 })

            .then(() => {
                console.log("Setting base costs in AC 11")
                return AC_MGR.ACTH_setCosts("11",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    account1,
                    { from: account1 })
                })
            
            .then(() => {
                console.log("Setting base costs in AC 12")
                return AC_MGR.ACTH_setCosts("12",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    account1,
                    { from: account1 })
                })
            
            .then(() => {
                console.log("Setting base costs in AC 13")
                return AC_MGR.ACTH_setCosts("13",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    account1,
                    { from: account1 })
                })
            
            .then(() => {
                console.log("Setting base costs in AC 14")
                return AC_MGR.ACTH_setCosts("14",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    account1,
                    { from: account1 })
                })
            
            .then(() => {
                console.log("Setting base costs in AC 15")
                return AC_MGR.ACTH_setCosts("15",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    "10000000000000000",
                    account1,
                    { from: account10 })
            })
    })


    it('Should add users to AC 10-14 in AC_Manager', async () => {

        console.log("//**************************************END BOOTSTRAP**********************************************/")
        console.log("Account2 => AC10")
        return AC_MGR.OO_addUser(account2, '1', '10', { from: account1 })
            
            .then(() => {
                console.log("Account2 => AC11")
                return AC_MGR.OO_addUser(account2, '1', '11', { from: account1 })
            })
            
            .then(() => {
                console.log("Account3 => AC11")
                return AC_MGR.OO_addUser(account3, '1', '11', { from: account1 })
            })
            
            .then(() => {
                console.log("Account4 => AC12")
                return AC_MGR.OO_addUser(account4, '1', '12', { from: account1 })
            })
            
            .then(() => {
                console.log("Account5 => AC13")
                return AC_MGR.OO_addUser(account5, '1', '13', { from: account1 })
            })
            
            .then(() => {
                console.log("Account6 => AC14")
                return AC_MGR.OO_addUser(account6, '1', '14', { from: account1 })
            })
            
            .then(() => {
                console.log("Account7 => AC14 (ROBOT)")
                return AC_MGR.OO_addUser(account7, '9', '14', { from: account1 })
            })
            
            .then(() => {
                console.log("Account8 => AC10 (ROBOT)")
                return AC_MGR.OO_addUser(account8, '9', '10', { from: account1 })
            })
            
            .then(() => {
                console.log("Account9 => AC11 (ROBOT)")
                return AC_MGR.OO_addUser(account9, '9', '11', { from: account1 })
            })
            
            .then(() => {
                console.log("Account10 => AC15 (NAKEDMINTER)")
                return AC_MGR.OO_addUser(account10, '10', '15', { from: account10 })
            })

            .then(() => {
                console.log("Account10 => AC15 (NAKEDMINTER)")
                return AC_MGR.OO_addUser(account10, '1', '10', { from: account1 })
            })
    })


    it('Should write asset1 in AC12', async () => {

        console.log("//**************************************BEGIN STOR TEST**********************************************/")
        console.log("//**************************************BEGIN STOR SETUP**********************************************/")
        return APP_NC.$newRecord(
        asset1,
        rgt1,
        '12',
        '100',
        {from: account4, value: 20000000000000000}
        )
    })


    it('Should set asset1 status to 59', async () => {
        return NP_NC._modStatus(
        asset1,
        '59',
        {from: account4}
        )
    })


    it('Should discard asset1', async () => {
        return A_TKN.discard(
        asset1,
        {from: account4}
        )
    })


    it('Should write asset2 in AC10', async () => {
        return APP.$newRecord(
        asset2,
        rgt2,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should write asset3 in AC10', async () => {
        return APP.$newRecord(
        asset3,
        rgt3,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should set asset3 status to 1', async () => {
        return NP._modStatus(
        asset3,
        rgt3,
        '1',
        {from: account2}
        )
    })


    it('Should transfer asset3 status to rgt000', async () => {
        return APP.$transferAsset(
        asset3,
        rgt3,
        rgt000,
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should write asset4 in AC10', async () => {
        return APP.$newRecord(
        asset4,
        rgt4,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should set asset4 status to 3', async () => {
        return NP._setLostOrStolen(
        asset4,
        rgt4,
        '3',
        {from: account2}
        )
    })


    it('Should write asset5 in AC10', async () => {
        return APP.$newRecord(
        asset5,
        rgt5,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should set asset5 status to 4', async () => {
        return NP._setLostOrStolen(
        asset5,
        rgt5,
        '4',
        {from: account2}
        )
    })


    it('Should write asset6 in AC12', async () => {
        return APP_NC.$newRecord(
        asset6,
        rgt6,
        '12',
        '100',
        {from: account4, value: 20000000000000000}
        )
    })


    it('Should set asset6 status to 59', async () => {
        return NP_NC._modStatus(
        asset6,
        '59',
        {from: account4}
        )
    })


    it('Should discard asset6', async () => {
        return A_TKN.discard(
        asset6,
        {from: account4}
        )
    })


    it('Should write asset7 in AC10', async () => {
        return APP.$newRecord(
        asset7,
        rgt7,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should set asset7 status to 1', async () => {
        return NP._modStatus(
        asset7,
        rgt7,
        '1',
        {from: account2}
        )
    })


    it('Should set asset7 into escrow', async () => {
        return ECR.setEscrow(
        asset7,
        account2Hash,
        '200',
        '50',
        {from: account2}
        )
    })


    it('Should write asset8 in AC10', async () => {
        return APP.$newRecord(
        asset8,
        rgt8,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    //1
    it('Should fail because caller is not owner', async () => {

        console.log("//**************************************END STOR SETUP**********************************************/")
        console.log("//**************************************BEGIN STOR FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN OO_addContract FAIL BATCH**********************************************/")
        return STOR.OO_addContract(
        'ECR2',
        ECR2.address,
        '1',
        '3',
        {from: account2}
        )
    })

    //2
    it('Should fail because AC != 0', async () => {
        return STOR.OO_addContract(
        'ECR2',
        ECR2.address,
        '1',
        '3',
        {from: account1}
        )
    })

    //3
    it('Should fail because AuthLv != > 4 invalid user type', async () => {
        return STOR.OO_addContract(
        'ECR2',
        ECR2.address,
        '0',
        '5',
        {from: account1}
        )
    })

    //4
    it('Should fail because caller does not hold AC token', async () => {

        console.log("//**************************************END OO_addContract FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN enableContractForAC FAIL BATCH**********************************************/")
        return STOR.enableContractForAC(
        'ECR2',
        '10',
        '5',
        {from: account2}
        )
    })

    //5
    it('Should fail because calling contract not auth in AC', async () => {

        console.log("//**************************************END enableContractForAC FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN NewRecord FAIL BATCH**********************************************/")
        return APP_NC.$newRecord(
        asset1,
        rgt1,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })

    //6
    it('Should fail because asset in discarded status', async () => {
        return APP_NC.$newRecord(
        asset1,
        rgt1,
        '12',
        '100',
        {from: account4, value: 20000000000000000}
        )
    })

    // //7                                                                   //THROWS IN CORE                                                                              
    // it('Should fail because asset already exists', async () => {
    //     return APP.$newRecord(
    //     asset2,
    //     rgt2,
    //     '10',
    //     '100',
    //     {from: account2, value: 20000000000000000}
    //     )
    // })

    //8                                                                                    
    it('Should fail because rgt = 0', async () => {
        return APP_NC.$newRecord(
        asset10,
        rgt000,
        '12',
        '100',
        {from: account4, value: 20000000000000000}
        )
    })


    // it('Should authorize account2 in AC0', async () => {
    //     return AC_MGR.OO_addUser(account2, '1', '0', { from: account1 })
    // })

    //9   
    it('Should fail because AC = 0', async () => {
        return MAL_APP.$newRecord(
        asset9,
        rgt3,
        '0',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    // it('Should unauthorize account2 in AC0', async () => {
    //     return AC_MGR.OO_addUser(account2, '0', '0', { from: account1 })
    // })


    //10                                                                               
    it('Should fail because record doesnt exist', async () => {

        console.log("//**************************************END NewRecord FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN modifyRecord FAIL BATCH**********************************************/")
        return MAL_APP._decCounter(
        asset10,
        // rgt6,
        '15',
        {from: account2}
        )
    })

    
    it('Should unauthorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '0', { from: account1 })
    })

    //11
    it('Should fail because calling contract is not auth in AC', async () => {
        return MAL_APP._decCounter(
        asset2,
        '15',
        {from: account2}
        )
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
    })


    it('Should authorize MAL_APP as an escrow contract', async () => {
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '3', { from: account1 })
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '3', { from: account1 })
    })


    it('Should put asset2 into escrow', async () => {
        return MAL_APP.setEscrow(
        asset2,
        account2Hash,
        '180',
        '50',
        {from: account2}
        )
    })

    //12
    it('Should fail because asset in escrow', async () => {
        return MAL_APP._decCounter(
        asset2,
        '15',
        {from: account2}
        )
    })


    it('Should take asset2 out of escrow', async () => {
        return MAL_APP.endEscrow(
        asset2,
        {from: account2}
        )
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
    })


    it('Should authorize MAL_APP as a normal contract', async () => {
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
    })


    it('Should change stat of asset2 to 1', async () => {
        return MAL_APP._modStatus(
        asset2,
        '1',
        {from: account2}
        )
    })

    // //13
    // it('Should fail because you cannot increase countdown', async () => {
    //     return MAL_APP._decCounter(
    //     asset2,
    //     '-15',
    //     {from: account2}
    //     )
    // })

                                                                  //Storage needs to be modified in order to throw
    // it("Should retrieve asset2", async () =>{ 
    //     var Record = [];
        
    //     return await STOR.retrieveShortRecord(asset2, {from: account2}, function (_err, _result) {
    //         if(_err){} 
    //         else{Record = Object.values(_result)
    //     console.log(Record)}
    //     })
    // })


    // it('Should fail because you cannot reduce FMRcount', async () => {

    //     return MAL_APP._decCounterFMR(
    //     asset2,
    //     rgt2,
    //     '15',
    //     {from: account2}
    //     )
    // })


    // it("Should retrieve asset2", async () =>{ 
    //     var Record = [];
        
    //     return await STOR.retrieveShortRecord(asset2, {from: account2}, function (_err, _result) {
    //         if(_err){} 
    //         else{Record = Object.values(_result)
    //     console.log(Record)}
    //     })
    // })


    // it('Should fail because you cannot reduce TXFRcount', async () => {

    //     return MAL_APP._decCounterTXFR(
    //     asset2,
    //     rgt2,
    //     '15',
    //     {from: account2}
    //     )
    // })


    // it("Should retrieve asset2", async () =>{ 
    //     var Record = [];
        
    //     return await STOR.retrieveShortRecord(asset2, {from: account2}, function (_err, _result) {
    //         if(_err){} 
    //         else{Record = Object.values(_result)
    //     console.log(Record)}
    //     })
    // })

    //14
    it('Should fail because you cannot set assetStatus to stolen with modifyRecord', async () => {

        return MAL_APP._modStatus(
        asset2,
        '3',
        {from: account2}
        )
    })

    //15
    it('Should fail because you cannot set assetStatus to lost with modifyRecord', async () => {

        return MAL_APP._modStatus(
        asset2,
        '4',
        {from: account2}
        )
    })


    //16
    it('Should fail because you cannot set assetStatus to ECR stat(6) with modifyRecord', async () => {

        return MAL_APP._modStatus(
        asset2,
        '6',
        {from: account2}
        )
    })


    //17
    it('Should fail because you cannot set assetStatus to ECR stat(56) with modifyRecord', async () => {

        return MAL_APP._modStatus(
        asset2,
        '56',
        {from: account2}
        )
    })


    //18
    it('Should fail because you cannot set assetStatus to ECR stat(50) with modifyRecord', async () => {

        return MAL_APP._modStatus(
        asset2,
        '50',
        {from: account2}
        )
    })


    it('Should authorize account2 in AC 2', async () => {

        console.log("//**************************************END modifyRecord FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN changeAC FAIL BATCH**********************************************/")
        return AC_MGR.OO_addUser(account2, '1', '2', { from: account1 })
    })


    //16
    it('Should fail because record does not exist', async () => {
        return MAL_APP.changeAC(
        asset10,
        '2',
        {from: account2}
        )
    })


    it('Should authorize MAL_APP as an escrow contract', async () => {
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '3', { from: account1 })
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '3', { from: account1 })
    })


    it('Should put asset2 into escrow', async () => {
        return MAL_APP.setEscrow(
        asset2,
        account2Hash,
        '180',
        '50',
        {from: account2}
        )
    })

    //17
    it('Should fail because asset in escrow', async () => {
        return MAL_APP.changeAC(
        asset2,
        '11',
        {from: account2}
        )
    })


    it('Should take asset2 out of escrow', async () => {
        return MAL_APP.endEscrow(
        asset2,
        {from: account2}
        )
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
    })


    it('Should authorize MAL_APP as a normal contract', async () => {
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
    })


    it('Should change stat of asset2 to 1', async () => {
        return MAL_APP._modStatus(
        asset2,
        '1',
        {from: account2}
        )
    })


    it('Should unauthorize MAL_APP as a contract', async () => {
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '0', { from: account1 })
    })

    //18
    it('Should fail because MAL_APP is not authroized in system', async () => {
        return MAL_APP.changeAC(
        asset2,
        '11',
        {from: account2}
        )
    })


    it('Should authorize MAL_APP as a contract', async () => {
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
    })


    //19
    it('Should fail because AC = 0', async () => {
        return MAL_APP.changeAC(
        asset2,
        '0',
        {from: account2}
        )
    })

    //20
    it('Should fail because you cannot change AC to new root', async () => {
        return MAL_APP.changeAC(
        asset2,
        '2',
        {from: account2}
        )
    })


    //21
    it('Should fail because record is in L/S status', async () => {
        return MAL_APP.changeAC(
        asset4,
        '11',
        {from: account2}
        )
    })


    //22
    it('Should fail because record is in TXFR stat', async () => {
        return MAL_APP.changeAC(
        asset3,
        '11',
        {from: account2}
        )
    })


    it('Should unauthorize account2 in AC 2', async () => {
        return AC_MGR.OO_addUser(account2, '0', '2', { from: account1 })
    })

    //21
    it('Should fail because record doesnt exist', async () => {

        console.log("//**************************************END changeAC FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN setStolenOrLost FAIL BATCH**********************************************/")
        return MAL_APP._setLostOrStolen(
        asset10,
        // rgt10,
        '3',
        {from: account2}
        )
    })


    it('Should unauthorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '0', { from: account1 })
    })

    //22
    it('Should fail because calling contract is not auth in AC', async () => {
        return MAL_APP._setLostOrStolen(
        asset2,
        // rgt2,
        '3',
        {from: account2}
        )
    })


    it('Should authorize MAL_APP in all relevant asset classes', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
    })

    //23
    it('Should fail because not being set to L/S status', async () => {
        return MAL_APP._setLostOrStolen(
        asset2,
        // rgt2,
        '1',
        {from: account2}
        )
    })

    //24
    it('Should fail because asset in transfered status', async () => {
        return MAL_APP._setLostOrStolen(
        asset3,
        // rgtFFF,
        '3',
        {from: account2}
        )
    })


    // it('Should authorize MAL_APP in AC12', async () => {
    //     return STOR.enableContractForAC('MAL_APP', '12', '2', { from: account1 })
    // })

    //14                                                                                   //cannot be set to stat 55 with current contracts
    // it('Should fail because asset in transfered status(NC)', async () => {
    //     return MAL_APP._setLostOrStolen(
    //     asset6,
    //     rgtFFF,
    //     '4',
    //     {from: account4}
    //     )
    // })


    // it('Should unauthorize MAL_APP in AC12', async () => {
    //     return STOR.enableContractForAC('MAL_APP', '12', '0', { from: account1 })
    // })

    //25
    it('Should fail because asset in locked escrow', async () => {
        return MAL_APP._setLostOrStolen(
        asset7,
        // rgt7,
        '4',
        {from: account2}
        )
    })


    it('Should authorize MAL_APP as an escrow contract', async () => {

        console.log("//**************************************END setStolenOrLost FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN setEscrow FAIL BATCH**********************************************/")
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '3', { from: account1 })
        
        .then(() => {
            return STOR.enableContractForAC('MAL_APP', '10', '3', { from: account1 })
        })

    })


    it('Should resolve ECR_MGR', async () => {
        return ECR_MGR.OO_ResolveContractAddresses({ from: account1 })
    })

    //26
    it('Should fail because caller != ECR_MGR', async () => {
        return MAL_APP.setEscrowStor(
        asset2,
        '50',
        {from: account2}
        )
    })

    //27
    it('Should fail because record does not exist', async () => {
        return MAL_APP.setEscrow(
        asset10,
        account2Hash,
        '180',
        '6',
        {from: account2}
        )
    })

    //28                                                                        
    it('Should fail because asset already in escrow', async () => {
        return MAL_APP.setEscrow(
        asset7,
        account2Hash,
        '180',
        '6',
        {from: account2}
        )
    })

    //29                                                                         
    it('Should fail because must be set to escrow status', async () => {
        return MAL_APP.setEscrow(
        asset8,
        account2Hash,
        '180',
        '2',
        {from: account2}
        )
    })


    //30                                                                       
    it('Should fail because asset in stolen stat', async () => {
        return MAL_APP.setEscrow(
        asset4,
        account2Hash,
        '180',
        '6',
        {from: account2}
        )
    })

    //31                                                                         
    it('Should fail because asset in lost stat', async () => {
        return MAL_APP.setEscrow(
        asset5,
        account2Hash,
        '180',
        '6',
        {from: account2}
        )
    })


    //31                                                                         
    it('Should fail because asset in transfered stat', async () => {
        return MAL_APP.setEscrow(
        asset3,
        account2Hash,
        '180',
        '6',
        {from: account2}
        )
    })

    //33                                                                         
    it('Should fail because calling contract != ECR_MGR', async () => {

        console.log("//**************************************END setEscrow FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN endEscrow FAIL BATCH**********************************************/")
        return MAL_APP.endEscrowStor(
            asset8,
            {from: account2}
            )
    })

    // //34                                                                    //THROWS IN ECR_MGR, requires that its in escrow     
    // it('Should fail because asset does not exist', async () => {
    //     return MAL_APP.endEscrow(
    //         asset10,
    //         {from: account2}
    //         )
    // })

    // //35                                                                    //THROWS IN ECR_MGR                                                                            
    // it('Should fail because asset not in escrow', async () => {
    //     return MAL_APP.endEscrow(
    //         asset8,
    //         {from: account2}
    //         )
    // })


    it('Should authorize MAL_APP as a normal contract', async () => {

        console.log("//**************************************END settEscrow FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN modifyIpfs1 FAIL BATCH**********************************************/")
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })

        .then(() => {
            return STOR.enableContractForAC('MAL_APP', '10', '0', { from: account1 })
        })

    })

    //36
    it('Should fail because record does not exist', async () => {
        return MAL_APP._modIpfs1(
            asset10,
            rgt1,
            {from: account2}
            )
    })

    //37
    it('Should fail because calling contract not auth in AC', async () => {
        return MAL_APP._modIpfs1(
            asset8,
            // rgt8,
            asset8,
            {from: account2}
            )
    })


    it('Should authorize MAL_APP in AC10', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
    })

    //38
    it('Should fail because record in escrow stat', async () => {
        return MAL_APP._modIpfs1(
            asset7,
            // rgt7,
            asset7,
            {from: account2}
            )
    })


    it('Should set asset8 ipfs1 to asset8', async () => {
        return MAL_APP._modIpfs1(
            asset8,
            // rgt8,
            asset8,
            {from: account2}
            )
    })

    //39
    it('Should fail because ips1 cannot match previous data', async () => {
        return MAL_APP._modIpfs1(
            asset8,
            // rgt8,
            asset8,
            {from: account2}
            )
    })

    //40
    it('Should fail because record does not exist', async () => {

        console.log("//**************************************END modifyIpfs1 FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN modifyIpfs2 FAIL BATCH**********************************************/")
        return MAL_APP.$addIpfs2Note(
            asset10,
            // rgt6,
            rgt6,
            {from: account2, value: 20000000000000000}
            )
    })


    it('Should unauthorize MAL_APP in AC10', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '0', { from: account1 })
    })


    //41
    it('Should fail becasue contract not auth in AC', async () => {
        return MAL_APP.$addIpfs2Note(
            asset2,
            // rgt2,
            rgt2,
            {from: account2, value: 20000000000000000}
        )
    })


    it('Should authorize MAL_APP in AC10', async () => {
        return STOR.enableContractForAC('MAL_APP', '10', '1', { from: account1 })
    })


    //42
    it('Should fail becasue asset in escrow stat', async () => {
        return MAL_APP.$addIpfs2Note(
            asset7,
            // rgt7,
            rgt7,
            {from: account2, value: 20000000000000000}
        )
    })


    //42
    it('Should fail becasue asset in L/S stat', async () => {
        return MAL_APP.$addIpfs2Note(
            asset4,
            // rgt7,
            rgt4,
            {from: account2, value: 20000000000000000}
        )
    })


    //42
    it('Should fail becasue asset in transfered stat', async () => {
        return MAL_APP.$addIpfs2Note(
            asset3,
            // rgt7,
            rgt3,
            {from: account2, value: 20000000000000000}
        )
    })


    it('Should set asset8 ipfs2 to asset8', async () => {
        return MAL_APP.$addIpfs2Note(
            asset8,
            // rgt8,
            asset8,
            {from: account2, value: 20000000000000000}
        )
    })

    //43
    it('Should fail becasue attempting to modify IPFS2', async () => {
        return MAL_APP.$addIpfs2Note(
            asset8,
            // rgt8,
            rgt8,
            {from: account2, value: 20000000000000000}
            )
    })


    it('Should unauthorize MAL_APP in system', async () => {

        console.log("//**************************************END modifyIpfs2 FAIL BATCH**********************************************/")
        console.log("//**************************************BEGIN retrieveRecord FAIL BATCH**********************************************/")
            return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '0', { from: account1 })
    })

    //44
    it('Should fail because contract not registered in system', async () => {
        return MAL_APP.retrieveRecordStor(
            asset1,
            {from: account2}
            )
    })


    it('Should authorize MAL_APP in system', async () => {
        return STOR.OO_addContract("MAL_APP", MAL_APP.address, '0', '1', { from: account1 })
    })


    it('Should write record in AC 10 @ IDX&RGT(1)', async () => {

        
        console.log("//**************************************END retrieveRecord FAIL BATCH**********************************************/")
        console.log("//**************************************END STOR FAIL BATCH**********************************************/")
        console.log("//**************************************END STOR TEST**********************************************/")
        console.log("//**************************************BEGIN THE WORKS**********************************************/")
        return APP.$newRecord(
        asset12, 
        rgt12,
        '10',
        '100',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change status of new asset12 to status(1)', async () => {
        return NP._modStatus(
        asset12, 
        rgt12,
        '1',
        {from: account2}
        )
    })


    it('Should Transfer asset12 RGT(1) to RGT(2)', async () => {
        return APP.$transferAsset(
        asset12, 
        rgt12,
        rgt2,
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should force modify asset12 RGT(2) to RGT(1)', async () => {
        return APP.$forceModRecord(
        asset12, 
        rgt12,
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change decrement amount @asset12 from (100) to (85)', async () => {
        return NP._decCounter(
        asset12, 
        rgt12,
        '15',
        {from: account2}
        )
    })


    it('Should modify Ipfs1 note @asset12 to IDX(1)', async () => {
        return NP._modIpfs1(
        asset12, 
        rgt12,
        asset12,
        {from: account2}
        )
    })


    it('Should change status of new asset12 to status(51)', async () => {
        return NP._modStatus(
        asset12, 
        rgt12,
        '51',
        {from: account2}
        )
    })


    it('Should export asset12 to account2', async () => {
        return NP.exportAsset(
        asset12, 
        account2,
        {from: account2}
        )
    })


    it('Should import asset12 to AC(12)(NC)', async () => {
        return APP_NC.$importAsset(
        asset12,
        '12',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should re-mint asset12 token to account2', async () => {
        return APP_NC.$reMintToken(
        asset12,
        'a',
        'a',
        'a',
        'a',
        'a',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should set Ipfs2 note to IDX(1)', async () => {
        return APP_NC.$addIpfs2Note(
        asset12,
        asset12,
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change status of asset12 to status(51)', async () => {
        return NP_NC._modStatus(
        asset12, 
        '51',
        {from: account2}
        )
    })


    it('Should set asset12 into escrow for 3 minutes', async () => {
        return ECR_NC.setEscrow(
        asset12, 
        account2Hash,
        '180',
        '56',
        {from: account2}
        )
    })


    it('Should take asset12 out of escrow', async () => {
        return ECR_NC.endEscrow(
        asset12, 
        {from: account2}
        )
    })


    it('Should change decrement amount @asset12 from (85) to (70)', async () => {
        return NP_NC._decCounter(
        asset12, 
        '15',
        {from: account2}
        )
    })


    it('Should force modify asset12 RGT(1) to RGT(2)', async () => {
        return NP_NC._changeRgt(
        asset12, 
        rgt2,
        {from: account2}
        )
    })


    it('Should modify Ipfs1 note @asset12 to RGT(1)', async () => {
        return NP_NC._modIpfs1(
        asset12, 
        rgt12,
        {from: account2}
        )
    })

    it('Should change status of asset12 to status(51)', async () => {
        return NP_NC._modStatus(
        asset12, 
        '51',
        {from: account2}
        )
    })

    it('Should export asset12(status70)', async () => {
        return NP_NC._exportNC(
        asset12, 
        {from: account2}
        )
    })


    it('Should transfer asset12 token to PRUF_APP contract', async () => {
        return A_TKN.safeTransferFrom(
        account2,
        APP.address,
        asset12,
        {from: account2}
        )
    })


    it('Should import asset12 to AC(11)', async () => {
        return APP.$importAsset(
        asset12,
        rgt12,
        '11',
        {from: account2, value: 20000000000000000}
        )
    })


    it('Should change status of asset12 to status(1)', async () => {
        return NP._modStatus(
        asset12, 
        rgt12,
        '1',
        {from: account2}
        )
    })


    it('Should set asset12 into locked escrow for 3 minutes', async () => {
        return ECR.setEscrow(
        asset12, 
        account2Hash,
        '180',
        '50',
        {from: account2}
        )
    })


    it('Should take asset12 out of escrow', async () => {
        return ECR.endEscrow(
        asset12, 
        {from: account2}
        )
    })


    it('Should change status of asset12 to status(1)', async () => {
        return NP._modStatus(
        asset12, 
        rgt12,
        '1',
        {from: account2}
        )
    })


    it('Should set asset12 into escrow for 3 minutes', async () => {
        return ECR.setEscrow(
        asset12, 
        account2Hash,
        '180',
        '6',
        {from: account2}
        )
    })


    it('Should set asset12 to stolen(3) status', async () => {
        return NP._setLostOrStolen(
        asset12,
        rgt12,
        '3',
        {from: account2}
        )
    })


    it('Should change status of asset12 to status(1)', async () => {
        return NP._modStatus(
        asset12, 
        rgt12,
        '1',
        {from: account2}
        )
    })

    it("Should retrieve asset12", async () =>{ 
        var Record = [];
        
        return await STOR.retrieveShortRecord(asset12, {from: account2}, function (_err, _result) {
            if(_err){} 
            else{Record = Object.values(_result)
        console.log(Record)}
        })
    })

});