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
    
    contract('APP', accounts => {
            
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

            .then(() => {
                console.log("Account10 => AC15 (NAKEDMINTER)")
                return AC_MGR.OO_addUser(account10, '1', '10', { from: account1 })
            })
    })

    
        it('Should mint a record in AC 10', async () => { //Bare custodial record, Used all over
            console.log("//************************************************************BEGIN APP TEST**********************************************************//")
            return APP.$newRecord(
                asset1,
                rgt1,
                '10',
                '5000',
                { from: account2, value: 20000000000000000 }
            )
        })
    

        it('Should mint a second record in AC 10', async () => { // Used in import  
            return APP.$newRecord(
                asset2,
                rgt1,
                '10',
                '5000',
                { from: account2, value: 20000000000000000 }
            )
        })
    

        it('Should mint a third record in AC 10', async () => { // Transferred, not claimed, used in status !== status 5 checks 
            return APP.$newRecord(
                asset3,
                rgt1,
                '10',
                '5000',
                { from: account2, value: 20000000000000000 }
            )
        })
    

        it('Should mint a record in AC 11', async () => { //Put into escrow, used in ForceTransfer, Transfer
            return APP.$newRecord(
                asset4,
                rgt1,
                '11',
                '5000',
                { from: account3, value: 20000000000000000 }
            )
        })
    

        it('Should mint a second record in AC 11', async () => { //Note added, used in AddNote
            return APP.$newRecord(
                asset5,
                rgt1,
                '11',
                '5000',
                { from: account3, value: 20000000000000000 }
            )
        })

    
        it('Should mint a third record in AC 11', async () => { // Status changed, exported, used in Import
            return APP.$newRecord(
                asset6,
                rgt1,
                '11',
                '5000',
                { from: account3, value: 20000000000000000 }
            )
        })
    

        it('Should mint a record in AC 13', async () => { //unused
            return APP_NC.$newRecord(
                asset7,
                rgt1,
                '13',
                '5000',
                { from: account5, value: 20000000000000000 }
            )
        })
    

        it('Should mint a record in AC 14', async () => { //Bare NC record, used in custody checks
            return APP_NC.$newRecord(
                asset8,
                rgt1,
                '14',
                '5000',
                { from: account6, value: 20000000000000000 }
            )
        })
    

        it('Should mint a second record in AC 14', async () => { //unused
            return APP_NC.$newRecord(
                asset9,
                rgt1,
                '14',
                '5000',
                { from: account6, value: 20000000000000000 }
            )
        })

        it('Should mint a third record in AC 14', async () => { //status changed to 51, burned
            return APP_NC.$newRecord(
                asset11,
                rgt1,
                '14',
                '5000',
                { from: account6, value: 20000000000000000 }
            )
        })
    

        it('Should change status of asset asset6 to 51 for export eligibility', async () => {
            return NP._modStatus(
                asset6,
                rgt1,
                '51',
                { from: account3 }
            )
        })

        it('Should change status of asset11 to 59 for discard eligibility', async () => {
            return NP_NC._modStatus(
                asset11,
                '59',
                { from: account6 }
            )
        })
    

        it('Should change status of asset asset2 to 1 for transfer eligibility', async () => {
            return NP._modStatus(
                asset2,
                rgt1,
                '1',
                { from: account2 }
            )
        })
    

        it('Should put asset asset4 into an escrow', async () => {
            return ECR.setEscrow(
                asset4,
                rgt1,
                '30',
                '6',
                { from: account3 }
            )
        })


        it('Should put asset9 into an escrow', async () => {
            return ECR_NC.setEscrow(
                asset9,
                rgt1,
                '30',
                '50',
                { from: account6 }
            )
        })
    

        it('Should add asset note to asset asset5', async () => {
            return APP.$addIpfs2Note(
                asset5,
                rgt1,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account3, value: 20000000000000000 }
            )
        })
    

        it('Should transfer asset asset2 to unclaimed', async () => { // Transferred, not claimed, used in status !== status 5 checks 
            return APP.$transferAsset(
                asset2,
                rgt1,
                rgt000,
                { from: account2, value: 20000000000000000 }
            )
        })
    

        it('Should export asset asset6 to account2 in AC10', async () => {
            return NP.exportAsset(
                asset6,
                NP.address,
                { from: account3 }
            )
        })

        it('Should discard asset11', async () => {
            return A_TKN.discard(
                asset11,
                { from: account6 }
            )
        })
    
        //
        //
        // END SETUP ENVIRONMENT
        //
        //
    
        //
        //
        // APP FAILBATCH
        //
        //

        //NEW RECORD
        //1
        it('Should fail to create new record due to non-custodial AC type', async () => {
            console.log('//**************************BEGIN APP FAILBATCH**************************//')
            console.log('//**************************NEW RECORD**************************//')
            return APP.$newRecord(
                asset10,
                rgt1,
                '12',
                '5000',
                {from: account4, value: 20000000000000000}
            )

        })

        //2
        it('Should fail to create new record due to user ineligibility', async () => {
            return APP.$newRecord(
                asset10,
                rgt1,
                '10',
                '5000',
                {from: account8, value: 20000000000000000}
            )

        })

        //3
        it('Should fail to create new record due to rgtHash == 0x0...', async () => {
            return APP.$newRecord(
                asset10,
                rgt000,
                '10',
                '5000',
                {from: account2, value: 20000000000000000}
            )

        })
    
        //EXPORT ASSET
        //4
        it('Should fail to export asset due to non-custodial AC type (FAILS IN ISAUTHORIZED MOD)', async () => {
            console.log('//**************************EXPORT ASSET**************************//')
            return NP.exportAsset(
                asset8,
                account10,
                { from: account6 }
            )
        })

        //5
        it('Should fail to export asset due to user ineligibility in AC', async () => {
            return NP.exportAsset(
                asset1,
                account10,
                { from: account6 }
            )
        })
        
        /* it('Should log the short record of asset 0x3531 before attempt to export', async () => {
            let asset = await STOR.retrieveShortRecord(asset1)
            return console.log(asset)
        }) */
    
        //6
        it('Should fail to export asset due to asset status !== 51', async () => {
            return NP.exportAsset(
                asset1,
                account10,
                { from: account2 }
            )
        }) 
        //END EXPORT ASSET
        
        //FORCETRANSFER ASSET
        //7
        it('Should fail to forceTransfer the record due to non-custodial AC type', async () => {
            
            console.log('//**************************FORCETRANSFER ASSET**************************//')
            return APP.$forceModRecord(
                asset8,
                rgt2,
                { from: account6, value: 20000000000000000 }
            )
        })

        //8
        it('Should fail to forceTransfer the record due to nonexistance', async () => {
            return APP.$forceModRecord(
                asset10,
                rgt2,
                { from: account2, value: 20000000000000000 }
            )
        })

        //9
        it('Should fail to forceTransfer the record due to nonHuman user type', async () => {
            return APP.$forceModRecord(
                asset1,
                rgt2,
                { from: account7, value: 20000000000000000 }
            )
        })

        //10
        it('Should fail to forceTransfer the record due to empty NRH field', async () => {
            return APP.$forceModRecord(
                asset1,
                rgt000,
                { from: account2, value: 20000000000000000 }
            )
        })

        //SHOULD PASS
        it('Should change status to 3', async () => {
            return NP._setLostOrStolen(
                asset1,
                rgt1,
                '3',
                { from: account2 }
            )
        })

        //11
        it('Should fail to forceTransfer the record due to lost or stolen status', async () => {
            return APP.$forceModRecord(
                asset1,
                rgt2,
                { from: account2, value: 20000000000000000 }
            )
        })

        //12
        it('Should fail to forceTransfer the record due to escrow status', async () => {
            return APP.$forceModRecord(
                asset4,
                rgt2,
                { from: account3, value: 20000000000000000 }
            )
        })

        //13
        it('Should fail to forceTransfer asset due to transferred/unclaimed status', async () => {
            return APP.$forceModRecord(
                asset2,
                rgt2,
                { from: account2, value: 20000000000000000 }
            )
        }) 
        //END FORCETRANSFER ASSET
        
        // TRANSFER ASSET
        //14
        it('Should fail to transfer the record due to non-custodial AC type', async () => {
            
            console.log('//**************************TRANSFER ASSET**************************//')
            return APP.$transferAsset(
                asset8,
                rgt1,
                rgt2,
                { from: account6, value: 20000000000000000 }
            )
        })
    
        //15
        it('Should fail to transfer the record due to asset nonexistance', async () => {
            return APP.$transferAsset(
                asset10,
                rgt1,
                rgt2,
                { from: account2, value: 20000000000000000 }
            )
        })

        //16
        it('Should fail to transfer the record due to user ineligibility in AC', async () => {
            return APP.$transferAsset(
                asset1,
                rgt1,
                rgt2,
                { from: account3, value: 20000000000000000 }
            )
        })

        //17
        it('Should fail to transfer the record due to userType > 5 && assetStatus < 50', async () => {
            return APP.$transferAsset(
                asset1,
                rgt1,
                rgt2,
                { from: account8, value: 20000000000000000 }
            )
        })

        //18
        it('Should fail to transfer the record due to status nontransferrable', async () => {
            return APP.$transferAsset(
                asset1,
                rgt1,
                rgt2,
                { from: account2, value: 20000000000000000 }
            )
        })

        //SHOULD PASS
        it('Should change status to 1', async () => {
            return NP._modStatus(
                asset1,
                rgt1,
                '1',
                { from: account2 }
            )
        })

        //19    
        it('Should fail to transfer the record due to rgtHash mismatch', async () => {
            return APP.$transferAsset(
                asset1,
                rgt3,
                rgt2,
                { from: account2, value: 20000000000000000 }
            )
        })

        //SHOULD PASS    
        it('Should change status to 0', async () => {
            return NP._modStatus(
                asset1,
                rgt1,
                '0',
                { from: account2 }
            )
        })
        //END TRANSFER ASSET

        //ADD NOTE 
        //20
        it('Should fail to add asset note due to non-custodial AC type', async () => {
            
            console.log('//**************************ADD NOTE**************************//')
            return APP.$addIpfs2Note(
                asset8,
                rgt1,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account6, value: 20000000000000000 }
            )
        })

        //21
        it('Should fail to add asset note due to asset nonexistence', async () => {
            return APP.$addIpfs2Note(
                asset10,
                rgt1,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account6, value: 20000000000000000 }
            )
        })

        //22
        it('Should fail to add asset note due to user ineligibility in AC', async () => {
            return APP.$addIpfs2Note(
                asset1,
                rgt1,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account6, value: 20000000000000000 }
            )
        })

        //23
        it('Should fail to add asset note due to escrow status', async () => {
            return APP.$addIpfs2Note(
                asset4,
                rgt1,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account3, value: 20000000000000000 }
            )
        })

        //24
        it('Should fail to add asset note due to rgtHash mismatch', async () => {
            return APP.$addIpfs2Note(
                asset1,
                rgt3,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account2, value: 20000000000000000 }
            )
        })

        //25
        it('Should fail to add asset note due to existing note', async () => {
            return APP.$addIpfs2Note(
                asset5,
                rgt1,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account3, value: 20000000000000000 }
            )
        })

        //26
        it('Should fail to add asset note due to transferred/unclaimed status', async () => {
            return APP.$addIpfs2Note(
                asset2,
                rgt1,
                '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
                { from: account2, value: 20000000000000000 }
            )
        }) 
        //END ADD NOTE
    
        //IMPORT ASSET
        //27
        it('Should fail to import an asset due to non-custodial AC type', async () => {
            
            console.log('//**************************IMPORT ASSET**************************//')
            return APP.$importAsset(
                asset8,
                rgt1,
                '14',
                { from: account6, value: 20000000000000000 }
            )
        })

        //28
        it('Should fail to import an asset due to asset nonexistence', async () => {
            return APP.$importAsset(
                asset10,
                rgt1,
                '14',
                { from: account6, value: 20000000000000000 }
            )
        })

        //29
        it('Should fail to import an asset due to userType > 3', async () => {
            return APP.$importAsset(
                asset6,
                rgt1,
                '10',
                { from: account8, value: 20000000000000000 }
            )
        })

        //30
        it('Should fail to import an asset due to user ineligibility in AC', async () => {
            return APP.$importAsset(
                asset6,
                rgt1,
                '10',
                { from: account3, value: 20000000000000000 }
            )
        })

        //31
        it('Should fail to import an asset due to attempted change of root AC', async () => {
            return APP.$importAsset(
                asset6,
                rgt1,
                '14',
                { from: account6, value: 20000000000000000 }
            )
        })


        it('Should write record in AC 10 @ IDX&RGT(1)', async () => {

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
    })