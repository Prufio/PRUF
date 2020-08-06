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
    const PRUF_APP_NC = artifacts.require('APP_NC');
    const PRUF_NP_NC = artifacts.require('NP_NC');
    const PRUF_ECR_NC = artifacts.require('ECR_NC');
    const PRUF_RCLR = artifacts.require('RCLR');
    const PRUF_HELPER = artifacts.require('Helper');
    
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
    let Helper;
    
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
    
    let rgt1;
    let rgt2;
    let rgt3;
    let rgt4;
    let rgt5;
    let rgt000 = "0x0000000000000000000000000000000000000000000000000000000000000000";
    
        //
        //
        // END DECLARATIONS
        //
        //
    
    contract('THE_WORKS', accounts => {
            
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
                    console.log("Adding in ECR_MGR")
                    return ECR_MGR.OO_setStorageContract(STOR.address, { from: account1 })
                })
                
                .then(() => {
                    console.log("Adding in ECR")
                    return ECR.OO_setStorageContract(STOR.address, { from: account1 })
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
                    console.log("Resolving in ECR_MGR")
                    return ECR_MGR.OO_ResolveContractAddresses({ from: account1 })
                })
                
                .then(() => {
                    console.log("Resolving in ECR")
                    return ECR.OO_ResolveContractAddresses({ from: account1 })
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
                    console.log("Resolving in RCLR")
                    return RCLR.OO_ResolveContractAddresses({ from: account1 })
                })
        })
    

        it('Should mint a couple of asset root tokens', async () => {
    
            console.log("Minting root token 1 -C")
            return AC_MGR.createAssetClass('1', account1, 'CUSTODIAL_ROOT', '1', '1', '0', { from: account1 })
    
                .then(() => {
                    console.log("Minting root token 2 -NC")
                    return AC_MGR.createAssetClass('2', account1, 'NON-CUSTODIAL_ROOT', '2', '2', '0', { from: account1 })
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
                    return AC_MGR.createAssetClass("15", account1, "Non_Custodial_AC4", "15", "2", "2", { from: account1 })
                })
        })
    

        it('Should authorize APP in all relevant asset classes', async () => {
            console.log("Authorizing APP")
            return STOR.enableContractForAC('APP', '10', '1', { from: account1 })
                
            .then(() => {
                    return STOR.enableContractForAC('APP', '11', '1', { from: account1 })
                })

                .then(() => {
                    return STOR.enableContractForAC('APP', '1', '1', { from: account1 })
                })
        })
    

        it('Should authorize APP_NC in all relevant asset classes', async () => {
            
            console.log("Authorizing APP_NC")
            return STOR.enableContractForAC('APP_NC', '12', '1', { from: account1 })
                
            .then(() => {
                    return STOR.enableContractForAC('APP_NC', '13', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('APP_NC', '14', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('APP_NC', '2', '1', { from: account1 })
                })
        })
    

        it('Should authorize NP in all relevant asset classes', async () => {
            
            console.log("Authorizing NP")
            return STOR.enableContractForAC('NP', '10', '1', { from: account1 })
                
                .then(() => {
                    return STOR.enableContractForAC('NP', '11', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('NP', '1', '1', { from: account1 })
                })
        })
    

        it('Should authorize NP_NC in all relevant asset classes', async () => {
            
            console.log("Authorizing NP_NC")
            return STOR.enableContractForAC('NP_NC', '12', '1', { from: account1 })
                
                .then(() => {
                    return STOR.enableContractForAC('NP_NC', '13', '1', { from: account1 })
                })

                .then(() => {
                    return STOR.enableContractForAC('NP_NC', '14', '1', { from: account1 })
                })

                .then(() => {
                    return STOR.enableContractForAC('NP_NC', '2', '1', { from: account1 })
                })
        })
    

        it('Should authorize ECR in all relevant asset classes', async () => {
            
            console.log("Authorizing ECR")
            return STOR.enableContractForAC('ECR', '10', '3', { from: account1 })
                
                .then(() => {
                    return STOR.enableContractForAC('ECR', '11', '3', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('ECR', '1', '3', { from: account1 })
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
                
                .then(() => {
                    return STOR.enableContractForAC('ECR_NC', '2', '3', { from: account1 })
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
                
                .then(() => {
                    return STOR.enableContractForAC('ECR_MGR', '1', '3', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('ECR_MGR', '2', '3', { from: account1 })
                })
        })


        it('Should authorize AC_TKN in all relevant asset classes', async () => {
            
            console.log("Authorizing AC_TKN")
            return STOR.enableContractForAC('AC_TKN', '10', '1', { from: account1 })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_TKN', '11', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_TKN', '12', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_TKN', '13', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_TKN', '14', '1', { from: account1 })
                })
        })
    

        it('Should authorize A_TKN in all relevant asset classes', async () => {
            
            console.log("Authorizing A_TKN")
            return STOR.enableContractForAC('A_TKN', '10', '1', { from: account1 })
                
                .then(() => {
                    return STOR.enableContractForAC('A_TKN', '11', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('A_TKN', '12', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('A_TKN', '13', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('A_TKN', '14', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('A_TKN', '1', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('A_TKN', '2', '1', { from: account1 })
                })
        })
    

        it('Should authorize AC_MGR in all relevant asset classes', async () => {
            
            console.log("Authorizing AC_MGR")
            return STOR.enableContractForAC('AC_MGR', '10', '1', { from: account1 })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_MGR', '11', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_MGR', '12', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_MGR', '13', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_MGR', '14', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_MGR', '1', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('AC_MGR', '2', '1', { from: account1 })
                })
        })
    

        it('Should authorize RCLR in all relevant asset classes', async () => {
            
            console.log("Authorizing RCLR")
            return STOR.enableContractForAC('RCLR', '10', '1', { from: account1 })
                
                .then(() => {
                    return STOR.enableContractForAC('RCLR', '11', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('RCLR', '12', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('RCLR', '13', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('RCLR', '14', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('RCLR', '1', '1', { from: account1 })
                })
                
                .then(() => {
                    return STOR.enableContractForAC('RCLR', '2', '1', { from: account1 })
                })
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
                        { from: account1 })
                })
        })
    

        it('Should add users to AC 10-14 in AC_Manager', async () => {
            
            console.log("Account2 => AC10")
            return AC_MGR.OO_addUser(account2, '1', '10', { from: account1 })
                
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
                    console.log("Account10 => AC15")
                    return AC_MGR.OO_addUser(account10, '1', '15', { from: account1 })
                })
        })


    it('Should write record in AC 10 @ IDX&RGT(1)', async () => {

        console.log("//**************************************BEGIN THE WORKS**********************************************/")
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