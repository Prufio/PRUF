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
    const PRUF_A_TKN2 = artifacts.require('A_TKN2');
    const PRUF_ECR_MGR = artifacts.require('ECR_MGR');
    const PRUF_ECR = artifacts.require('ECR');
    const PRUF_ECR2 = artifacts.require('ECR2');
    const PRUF_APP_NC = artifacts.require('APP_NC');
    const PRUF_NP_NC = artifacts.require('NP_NC');
    const PRUF_ECR_NC = artifacts.require('ECR_NC');
    const PRUF_RCLR = artifacts.require('RCLR');
    const PRUF_NAKED = artifacts.require('NAKED');
    const PRUF_HELPER = artifacts.require('Helper');
    
    let STOR;
    let APP;
    let NP;
    let AC_MGR;
    let AC_TKN;
    let A_TKN;
    let A_TKN2;
    let ECR_MGR;
    let ECR;
    let ECR2;
    let ECR_NC;
    let APP_NC;
    let NP_NC;
    let RCLR;
    let Helper;

    let string1Hash;
    let string2Hash;
    let string3Hash;
    let string4Hash;
    let string5Hash;
    
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
    let rgt12;
    let rgt000 = "0x0000000000000000000000000000000000000000000000000000000000000000";
    let rgtFFF = "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

    let account2Hash;
    let account4Hash;
    let account6Hash;

    let account000 = '0x0000000000000000000000000000000000000000'

    let nakedAuthCode1;
    let nakedAuthCode3;
    
        //
        //
        // END DECLARATIONS
        //
        //
    
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


    it('Should deploy PRUF_A_TKN2', async () => {
        const PRUF_A_TKN2_TEST = await PRUF_A_TKN2.deployed({ from: account1 });
        console.log(PRUF_A_TKN2_TEST.address);
        assert(PRUF_A_TKN2_TEST.address !== '')
        A_TKN2 = PRUF_A_TKN2_TEST;
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


        nakedAuthCode1 = await Helper.getURIfromAuthcode(
            '15',
            '1'
        )

        nakedAuthCode3 = await Helper.getURIfromAuthcode(
            '15',
            '3'
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
                console.log("Adding A_TKN2 to storage for use in AC 0")
                return STOR.OO_addContract("A_TKN2", A_TKN2.address, '0', '1', { from: account1 })
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
                return STOR.OO_addContract("NAKED", NAKED.address, '0', '1', { from: account1 })
            })
            
            .then(() => {
                console.log("Adding RCLR to storage for use in AC 0")
                return STOR.OO_addContract("RCLR", RCLR.address, '0', '3', { from: account1 })
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
                console.log("Adding in A_TKN2")
                return A_TKN2.OO_setStorageContract(STOR.address, { from: account1 })
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
                console.log("Resolving in A_TKN2")
                return A_TKN2.OO_ResolveContractAddresses({ from: account1 })
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
        return AC_MGR.createAssetClass('1', account1, 'CUSTODIAL_ROOT', '1', '1', '3', { from: account1 })

            .then(() => {
                console.log("Minting root token 2 -NC")
                return AC_MGR.createAssetClass('2', account1, 'NON-CUSTODIAL_ROOT', '2', '2', '3', { from: account1 })
            })
    })


    it("Should Mint 2 cust and 2 non-cust AC tokens in AC_ROOT 1", async () => {
        
        console.log("Minting AC 10 -C")
        return AC_MGR.createAssetClass("10", account1, "Custodial_AC1", "10", "1", "1", { from: account1 })

            .then(() => {
                console.log("Minting AC 11 -C")
                return AC_MGR.createAssetClass("11", account1, "Custodial_AC2", "11", "1", "1", { from: account1 })
            })
            
            .then(() => {
                console.log("Minting AC 12 -NC")
                return AC_MGR.createAssetClass("12", account1, "Non-Custodial_AC1", "12", "1", "2", { from: account1 })
            })
            
            .then(() => {
                console.log("Minting AC 13 -NC")
                return AC_MGR.createAssetClass("13", account1, "Non-Custodial_AC2", "13", "1", "2", { from: account1 })
            })
    })


    it("Should Mint 2 non-cust AC tokens in AC_ROOT 2", async () => {
        
        console.log("Minting AC 14 -NC")
        return AC_MGR.createAssetClass("14", account1, "Non-Custodial_AC3", "14", "2", "2", { from: account1 })

            .then(() => {
                console.log("Minting AC 15 -NC")
                return AC_MGR.createAssetClass("15", account10, "Non_Custodial_AC4", "15", "2", "2", { from: account1 })
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


    it('Should authorize A_TKN2 in all relevant asset classes', async () => {
        
        console.log("Authorizing A_TKN2")
        return STOR.enableContractForAC('A_TKN2', '10', '1', { from: account1 })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN2', '11', '1', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN2', '12', '2', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN2', '13', '2', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN2', '14', '2', { from: account1 })
            })

            .then(() => {
                return STOR.enableContractForAC('A_TKN2', '15', '2', { from: account10 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN2', '1', '1', { from: account1 })
            })
            
            .then(() => {
                return STOR.enableContractForAC('A_TKN2', '2', '1', { from: account1 })
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
    })
})