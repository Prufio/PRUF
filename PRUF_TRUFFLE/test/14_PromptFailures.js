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

contract('PRUF_FULL_TEST', accounts => {

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

    //ENVIRONMENT SETUP


    it('Should deploy Storage', async () => {
        const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: account1 });
        console.log(PRUF_STOR_TEST.address);
        assert(PRUF_STOR_TEST.address !== '');
        STOR = PRUF_STOR_TEST;
    });
    it('Should deploy PRUF_APP', async () => {
        const PRUF_APP_TEST = await PRUF_APP.deployed({ from: account1 });
        console.log(PRUF_APP_TEST.address);
        assert(PRUF_APP_TEST.address !== '');
        APP = PRUF_APP_TEST;
    });
    it('Should deploy PRUF_NP', async () => {
        const PRUF_NP_TEST = await PRUF_NP.deployed({ from: account1 });
        console.log(PRUF_NP_TEST.address);
        assert(PRUF_NP_TEST.address !== '');
        NP = PRUF_NP_TEST;
    });
    it('Should deploy PRUF_AC_MGR', async () => {
        const PRUF_AC_MGR_TEST = await PRUF_AC_MGR.deployed({ from: account1 });
        console.log(PRUF_AC_MGR_TEST.address);
        assert(PRUF_AC_MGR_TEST.address !== '');
        AC_MGR = PRUF_AC_MGR_TEST;
    });
    it('Should deploy PRUF_AC_TKN', async () => {
        const PRUF_AC_TKN_TEST = await PRUF_AC_TKN.deployed({ from: account1 });
        console.log(PRUF_AC_TKN_TEST.address);
        assert(PRUF_AC_TKN_TEST.address !== '')
        AC_TKN = PRUF_AC_TKN_TEST;
    });
    it('Should deploy PRUF_A_TKN', async () => {
        const PRUF_A_TKN_TEST = await PRUF_A_TKN.deployed({ from: account1 });
        console.log(PRUF_A_TKN_TEST.address);
        assert(PRUF_A_TKN_TEST.address !== '')
        A_TKN = PRUF_A_TKN_TEST;
    });
    it('Should deploy PRUF_ECR_MGR', async () => {
        const PRUF_ECR_MGR_TEST = await PRUF_ECR_MGR.deployed({ from: account1 });
        console.log(PRUF_ECR_MGR_TEST.address);
        assert(PRUF_ECR_MGR_TEST.address !== '');
        ECR_MGR = PRUF_ECR_MGR_TEST;
    });
    it('Should deploy PRUF_ECR', async () => {
        const PRUF_ECR_TEST = await PRUF_ECR.deployed({ from: account1 });
        console.log(PRUF_ECR_TEST.address);
        assert(PRUF_ECR_TEST.address !== '');
        ECR = PRUF_ECR_TEST;
    });
    it('Should deploy PRUF_APP_NC', async () => {
        const PRUF_APP_NC_TEST = await PRUF_APP_NC.deployed({ from: account1 });
        console.log(PRUF_APP_NC_TEST.address);
        assert(PRUF_APP_NC_TEST.address !== '');
        APP_NC = PRUF_APP_NC_TEST;
    });
    it('Should deploy PRUF_NP_NC', async () => {
        const PRUF_NP_NC_TEST = await PRUF_NP_NC.deployed({ from: account1 });
        console.log(PRUF_NP_NC_TEST.address);
        assert(PRUF_NP_NC_TEST.address !== '')
        NP_NC = PRUF_NP_NC_TEST;
    });
    it('Should deploy PRUF_ECR_NC', async () => {
        const PRUF_ECR_NC_TEST = await PRUF_ECR_NC.deployed({ from: account1 });
        console.log(PRUF_ECR_NC_TEST.address);
        assert(PRUF_ECR_NC_TEST.address !== '');
        ECR_NC = PRUF_ECR_NC_TEST;
    });
    it('Should deploy PRUF_RCLR', async () => {
        const PRUF_RCLR_TEST = await PRUF_RCLR.deployed({ from: account1 });
        console.log(PRUF_RCLR_TEST.address);
        assert(PRUF_RCLR_TEST.address !== '')
        RCLR = PRUF_RCLR_TEST;
    });

    it('Should add contract addresses', async () => {

        console.log("Adding APP to storage for use in AC 0")
        return STOR.OO_addContract("APP", APP.address, '0', '1', { from: account1 })

            .then(() => {
                console.log("Adding NP to storage for use in AC 0")
                return STOR.OO_addContract("NP", NP.address, '0', '1', { from: account1 })

            }).then(() => {
                console.log("Adding AC_MGR to storage for use in AC 0")
                return STOR.OO_addContract("AC_MGR", AC_MGR.address, '0', '1', { from: account1 })

            }).then(() => {
                console.log("Adding AC_TKN to storage for use in AC 0")
                return STOR.OO_addContract("AC_TKN", AC_TKN.address, '0', '1', { from: account1 })

            }).then(() => {
                console.log("Adding A_TKN to storage for use in AC 0")
                return STOR.OO_addContract("A_TKN", A_TKN.address, '0', '1', { from: account1 })

            }).then(() => {
                console.log("Adding ECR_MGR to storage for use in AC 0")
                return STOR.OO_addContract("ECR_MGR", ECR_MGR.address, '0', '1', { from: account1 })

            }).then(() => {
                console.log("Adding ECR to storage for use in AC 0")
                return STOR.OO_addContract("ECR", ECR.address, '0', '3', { from: account1 })

            }).then(() => {
                console.log("Adding APP_NC to storage for use in AC 0")
                return STOR.OO_addContract("APP_NC", APP_NC.address, '0', '2', { from: account1 })

            }).then(() => {
                console.log("Adding NP_NC to storage for use in AC 0")
                return STOR.OO_addContract("NP_NC", NP_NC.address, '0', '2', { from: account1 })

            }).then(() => {
                console.log("Adding ECR_NC to storage for use in AC 0")
                return STOR.OO_addContract("ECR_NC", ECR_NC.address, '0', '3', { from: account1 })

            }).then(() => {
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

            }).then(() => {
                console.log("Adding in AC_MGR")
                return AC_MGR.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
                console.log("Adding in AC_TKN")
                return AC_TKN.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
                console.log("Adding in A_TKN")
                return A_TKN.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
                console.log("Adding in ECR_MGR")
                return ECR_MGR.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
                console.log("Adding in ECR")
                return ECR.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
                console.log("Adding in APP_NC")
                return APP_NC.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
                console.log("Adding in NP_NC")
                return NP_NC.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
                console.log("Adding in ECR_NC")
                return ECR_NC.OO_setStorageContract(STOR.address, { from: account1 })

            }).then(() => {
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

            }).then(() => {
                console.log("Resolving in AC_MGR")
                return AC_MGR.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in AC_TKN")
                return AC_TKN.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in A_TKN")
                return A_TKN.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in ECR_MGR")
                return ECR_MGR.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in ECR")
                return ECR.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in APP_NC")
                return APP_NC.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in NP_NC")
                return NP_NC.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in ECR_NC")
                return ECR_NC.OO_ResolveContractAddresses({ from: account1 })

            }).then(() => {
                console.log("Resolving in RCLR")
                return RCLR.OO_ResolveContractAddresses({ from: account1 })

            })
    })

    it('Should mint a couple of asset root tokens', async () => {

        console.log("Minting root token 1")
        return AC_MGR.createAssetClass('1', account1, 'CUSTODIAL_ROOT', '1', '1', '1', { from: account1 })

            .then(() => {
                console.log("Minting root token 2")
                return AC_MGR.createAssetClass('2', account1, 'NON-CUSTODIAL_ROOT', '2', '2', '2', { from: account1 })
            })
    })

    it("Should Mint 2 cust and 2 non-cust AC tokens in AC_ROOT 1", async () => {
        console.log("Minting AC 10 -C")
        return AC_MGR.createAssetClass("10", account1, "Custodial_AC1", "10", "1", "1", { from: account1 })

            .then(() => {
                console.log("Minting AC 11 -C")
                return AC_MGR.createAssetClass("11", account1, "Custodial_AC2", "11", "1", "1", { from: account1 })

            }).then(() => {
                console.log("Minting AC 12 -NC")
                return AC_MGR.createAssetClass("12", account1, "Non-Custodial_AC1", "12", "1", "2", { from: account1 })

            }).then(() => {
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
        return STOR.enableContractForAC('APP','10', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('APP','11', '1', {from: account1})
        })
    })

    it('Should authorize APP_NC in all relevant asset classes', async () => {
        console.log("Authorizing APP_NC")
        return STOR.enableContractForAC('APP_NC','12', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('APP_NC','13', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('APP_NC','14', '1', {from: account1})
        })
    })

    it('Should authorize NP in all relevant asset classes', async () => {
        console.log("Authorizing NP")
        return STOR.enableContractForAC('NP','10', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('NP','11', '1', {from: account1})
        })
    })

    it('Should authorize NP_NC in all relevant asset classes', async () => {
        console.log("Authorizing NP_NC")
        return STOR.enableContractForAC('NP_NC','12', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('NP_NC','13', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('NP_NC','14', '1', {from: account1})
        })
    })

    it('Should authorize ECR in all relevant asset classes', async () => {
        console.log("Authorizing ECR")
        return STOR.enableContractForAC('ECR','10', '3', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('ECR','11', '3', {from: account1})
        })
    })

    it('Should authorize ECR_NC in all relevant asset classes', async () => {
        console.log("Authorizing ECR_NC")
        return STOR.enableContractForAC('ECR_NC','12', '3', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('ECR_NC','13', '3', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('ECR_NC','14', '3', {from: account1})
        })
    })

    it('Should authorize ECR_MGR in all relevant asset classes', async () => {
        console.log("Authorizing ECR_MGR")
        return STOR.enableContractForAC('ECR_MGR','10', '3', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('ECR_MGR','11', '3', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('ECR_MGR','12', '3', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('ECR_MGR','13', '3', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('ECR_MGR','14', '3', {from: account1})
        })
    })

    it('Should authorize AC_TKN in all relevant asset classes', async () => {
        console.log("Authorizing AC_TKN")
        return STOR.enableContractForAC('AC_TKN','10', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('AC_TKN','11', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('AC_TKN','12', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('AC_TKN','13', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('AC_TKN','14', '1', {from: account1})
        })
    })

    it('Should authorize A_TKN in all relevant asset classes', async () => {
        console.log("Authorizing A_TKN")
        return STOR.enableContractForAC('A_TKN','10', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('A_TKN','11', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('A_TKN','12', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('A_TKN','13', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('A_TKN','14', '1', {from: account1})
        })
    })

    it('Should authorize AC_MGR in all relevant asset classes', async () => {
        console.log("Authorizing AC_MGR")
        return STOR.enableContractForAC('AC_MGR','10', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('AC_MGR','11', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('AC_MGR','12', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('AC_MGR','13', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('AC_MGR','14', '1', {from: account1})
        })
    })

    it('Should authorize RCLR in all relevant asset classes', async () => {
        console.log("Authorizing RCLR")
        return STOR.enableContractForAC('RCLR','10', '1', {from: account1})
        .then(()=> {
            return STOR.enableContractForAC('RCLR','11', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('RCLR','12', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('RCLR','13', '1', {from: account1})
        }).then(()=> {
            return STOR.enableContractForAC('RCLR','14', '1', {from: account1})
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

            }).then(() => {
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

            }).then(() => {
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

            }).then(() => {
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

            }).then(() => {
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
            }).then(() => {
                console.log("Account8 => AC10 (ROBOT)")
                return AC_MGR.OO_addUser(account8, '9', '10', { from: account1 })
            }).then(() => {
                console.log("Account9 => AC11 (ROBOT)")
                return AC_MGR.OO_addUser(account9, '9', '11', { from: account1 })
            })
    })

    it('Should mint a record in AC 11', async () => { //Put into escrow, used in ForceTransfer, Transfer
        return APP.$newRecord(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint a second record in AC 11', async () => { //Note added, used in AddNote
        return APP.$newRecord(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint a third record in AC 11', async () => { // Status changed, exported, used in Import
        return APP.$newRecord(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 10', async () => { //Bare custodial record, Used all over
        return APP.$newRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            '5000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should mint a second record in AC 10', async () => { // Used in import 
        return APP.$newRecord(
            '0xaa31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            '5000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should mint a third record in AC 10', async () => { // Transferred, not claimed, used in status !== status 5 checks 
        return APP.$newRecord(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            '5000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 13', async () => { //unused
        return APP_NC.$newRecord(
            '0xab31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '13',
            '5000',
            { from: account5, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 14', async () => { //Bare NC record, used in custody checks
        return APP_NC.$newRecord(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            '5000',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should mint a second record in AC 14', async () => { //unused
        return APP_NC.$newRecord(
            '0xc531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            '5000',
            { from: account6, value: 20000000000000000 }
        )
    })

    /* it('Should log the short record of asset 0xf531 before status mod', async () => {
        let asset = await STOR.retrieveShortRecord('0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef')
        return console.log(asset)
    }) */

    it('Should change status of asset 0xf531 to 51 for export eligibility', async () => {
        return NP._modStatus(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '51',
            { from: account3 }
        )
    })

    it('Should change status of asset 0xbb31 to 1 for transfer eligibility', async () => {
        return NP._modStatus(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '1',
            { from: account2 }
        )
    })

   /*  it('Should log the short record of asset 0xf531 after status mod', async () => {
        let asset = await STOR.retrieveShortRecord('0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef')
        return console.log(asset)
    }) */

    it('Should put asset 0xd531 into an escrow', async () => {
        return ECR.setEscrow(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '30',
            '6',
            { from: account3 }
        )
    })
    
    it('Should add asset note to asset 0xe531', async () => { 
        return APP.$addIpfs2Note(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should transfer asset 0xbb31 to unclaimed', async () => { // Transferred, not claimed, used in status !== status 5 checks 
        return APP.$transferAsset(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0x0000000000000000000000000000000000000000000000000000000000000000',
            { from: account2, value: 20000000000000000 }
        )
    })
    
    it('Should export asset 0xf531 to account2 in AC10', async () => {
        return APP.exportAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            APP.address,
            { from: account3 }
        )
    })

    //
    //
    // END SETUP
    //
    //

    //
    //
    // APP FAILBATCH
    //
    //


    //EXPORT ASSET
    //1
    it('Should fail to export asset due to non-custodial AC type (FAILS IN ISAUTHORIZED MOD)', async () => {
        return APP.exportAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            account10,
            { from: account6 }
        )
    })
    //2
    it('Should fail to export asset due to user ineligibility in AC', async () => {
        return APP.exportAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            account10,
            { from: account6 }
        )
    })
    
    /* it('Should log the short record of asset 0x3531 before attempt to export', async () => {
        let asset = await STOR.retrieveShortRecord('0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d')
        return console.log(asset)
    }) */

    //3
    it('Should fail to export asset due to asset status !== 51', async () => {
        return APP.exportAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            account10,
            { from: account2 }
        )
    }) //END EXPORT ASSET


    //FORCETRANSFER ASSET
    //4
    it('Should fail to forceTransfer the record due to non-custodial AC type', async () => {
        return APP.$forceModRecord(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account6, value: 20000000000000000 }
        )
    })
    //5
    it('Should fail to forceTransfer the record due to nonexistance', async () => {
        return APP.$forceModRecord(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //6
    it('Should fail to forceTransfer the record due to nonHuman user type', async () => {
        return APP.$forceModRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account7, value: 20000000000000000 }
        )
    })
    //7
    it('Should fail to forceTransfer the record due to empty NRH field', async () => {
        return APP.$forceModRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0000000000000000000000000000000000000000000000000000000000000000',
            { from: account2, value: 20000000000000000 }
        )
    })
    //SHOULD PASS
    it('Should change status to 3', async () => {
        return NP._setLostOrStolen(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '3',
            { from: account2 }
        )
    })
    //8
    it('Should fail to forceTransfer the record due to lost or stolen status', async () => {
        return APP.$forceModRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //9
    it('Should fail to forceTransfer the record due to escrow status', async () => {
        return APP.$forceModRecord(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account3, value: 20000000000000000 }
        )
    })
    //10
    it('Should fail to forceTransfer asset due to transferred/unclaimed status', async () => {
        return APP.$forceModRecord(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    }) //END FORCETRANSFER ASSET
    
    


    // TRANSFER ASSET
    //11
    it('Should fail to transfer the record due to non-custodial AC type', async () => {
        return APP.$transferAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account6, value: 20000000000000000 }
        )
    })

    //12
    it('Should fail to transfer the record due to asset nonexistance', async () => {
        return APP.$transferAsset(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //13
    it('Should fail to transfer the record due to user ineligibility in AC', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account3, value: 20000000000000000 }
        )
    })
    //14
    it('Should fail to transfer the record due to userType > 5 && assetStatus < 50', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account8, value: 20000000000000000 }
        )
    })
    //15
    it('Should fail to transfer the record due to status nontransferrable', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //SHOULD PASS
    it('Should change status to 1', async () => {
        return NP._modStatus(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '1',
            { from: account2 }
        )
    })
    //16    
    it('Should fail to transfer the record due to rgtHash mismatch', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee60',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })
    //SHOULD PASS    
    it('Should change status to 0', async () => {
        return NP._modStatus(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0',
            { from: account2 }
        )
    })//END TRANSFER ASSET

    
    //ADD NOTE 
    //17
    it('Should fail to add asset note due to non-custodial AC type', async () => {
        return APP.$addIpfs2Note(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account6, value: 20000000000000000 }
        )
    })
    //18
    it('Should fail to add asset note due to asset nonexistence', async () => {
        return APP.$addIpfs2Note(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account6, value: 20000000000000000 }
        )
    })
    //19
    it('Should fail to add asset note due to user ineligibility in AC', async () => {
        return APP.$addIpfs2Note(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account6, value: 20000000000000000 }
        )
    })
    //20
    it('Should fail to add asset note due to escrow status', async () => {
        return APP.$addIpfs2Note(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account3, value: 20000000000000000 }
        )
    })
    //21
    it('Should fail to add asset note due to rgtHash mismatch', async () => {
        return APP.$addIpfs2Note(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account2, value: 20000000000000000 }
        )
    })
    //22
    it('Should fail to add asset note due to existing note', async () => {
        return APP.$addIpfs2Note(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account3, value: 20000000000000000 }
        )
    })
    //23
    it('Should fail to add asset note due to transferred/unclaimed status', async () => {
        return APP.$addIpfs2Note(
            '0xbb31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07b0000',
            { from: account2, value: 20000000000000000 }
        )
    }) //END ADD NOTE


    //IMPORT ASSET
    //24
    it('Should fail to import an asset due to non-custodial AC type', async () => {
        return APP.$importAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            { from: account6, value: 20000000000000000 }
        )
    })
    //25
    it('Should fail to import an asset due to asset nonexistence', async () => {
        return APP.$importAsset(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            { from: account6, value: 20000000000000000 }
        )
    })
    //26
    it('Should fail to import an asset due to userType > 3', async () => {
        return APP.$importAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            { from: account8, value: 20000000000000000 }
        )
    })
    //27
    it('Should fail to import an asset due to user ineligibility in AC', async () => {
        return APP.$importAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            { from: account3, value: 20000000000000000 }
        )
    })
    //28
    it('Should fail to import an asset due to attempted change of root AC', async () => {
        return APP.$importAsset(
            '0xf531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722aeeef',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            { from: account6, value: 20000000000000000 }
        )
    })
    //29
    it('Should fail to import an asset due to nonExported status', async () => {
        return APP.$importAsset(
            '0xaa31cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            { from: account2, value: 20000000000000000 }
        )
    })

    //
    //
    // END APP FAILBATCH
    //
    //


    ///
    //
    // NP FAILBATCH
    //
    //



    /* it('Should change status to 1', async () => {
        NP._modStatus(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '1',
            { from: account2 }
        )
    })

    it('Should fail to change status due to non-custodial AC type', async () => {
        NP._modStatus(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '1',
            { from: account2 }
        )
    })

    it('Should fail to change status due to non-custodial AC type', async () => {
        NP._modStatus(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '1',
            { from: account2 }
        )
    }) */

});

