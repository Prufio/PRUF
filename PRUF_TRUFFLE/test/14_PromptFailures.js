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

        console.log("Adding APP to storage")
        return STOR.OO_addContract("APP", APP.address, '1', { from: account1 })

            .then(() => {
                console.log("Adding NP to storage")
                return STOR.OO_addContract("NP", NP.address, '1', { from: account1 })

            }).then(() => {
                console.log("Adding AC_MGR to storage")
                return STOR.OO_addContract("AC_MGR", AC_MGR.address, '1', { from: account1 })

            }).then(() => {
                console.log("Adding AC_TKN to storage")
                return STOR.OO_addContract("AC_TKN", AC_TKN.address, '1', { from: account1 })

            }).then(() => {
                console.log("Adding A_TKN to storage")
                return STOR.OO_addContract("A_TKN", A_TKN.address, '1', { from: account1 })

            }).then(() => {
                console.log("Adding ECR_MGR to storage")
                return STOR.OO_addContract("ECR_MGR", ECR_MGR.address, '1', { from: account1 })

            }).then(() => {
                console.log("Adding ECR to storage")
                return STOR.OO_addContract("ECR", ECR.address, '3', { from: account1 })

            }).then(() => {
                console.log("Adding APP_NC to storage")
                return STOR.OO_addContract("APP_NC", APP_NC.address, '1', { from: account1 })

            }).then(() => {
                console.log("Adding NP_NC to storage")
                return STOR.OO_addContract("NP_NC", NP_NC.address, '1', { from: account1 })

            }).then(() => {
                console.log("Adding ECR_NC to storage")
                return STOR.OO_addContract("ECR_NC", ECR_NC.address, '3', { from: account1 })

            }).then(() => {
                console.log("Adding RCLR to storage")
                return STOR.OO_addContract("RCLR", RCLR.address, '3', { from: account1 })

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

        console.log("Minting custodial root token")
        return AC_MGR.createAssetClass('1', account1, 'CUSTODIAL_ROOT', '1', '1', '1', { from: account1 })

            .then(() => {
                console.log("Minting non-custodial root token")
                return AC_MGR.createAssetClass('2', account1, 'NON-CUSTODIAL_ROOT', '2', '2', '2', { from: account1 })
            })
    })

    it("Should Mint 2 cust and 2 non-cust AC tokens in AC_ROOT 1", async () => {
        console.log("Minting AC 10")
        return AC_MGR.createAssetClass("10", account1, "Custodial_AC", "10", "1", "1", { from: account1 })

            .then(() => {
                console.log("Minting AC 11")
                return AC_MGR.createAssetClass("11", account1, "Custodial_AC", "11", "1", "1", { from: account1 })

            }).then(() => {
                console.log("Minting AC 12")
                return AC_MGR.createAssetClass("12", account1, "Non-Custodial_AC", "12", "1", "2", { from: account1 })

            }).then(() => {
                console.log("Minting AC 13")
                return AC_MGR.createAssetClass("13", account1, "Non-Custodial_AC", "13", "1", "2", { from: account1 })
            })
    })

    it("Should Mint 1 cust and 1 non-cust AC tokens in AC_ROOT 2", async () => {
        return AC_MGR.createAssetClass("14", account1, "Custodial_AC", "14", "2", "1", { from: account1 })

            .then(() => {
                console.log("Minting AC 15")
                return AC_MGR.createAssetClass("15", account1, "Non_Custodial_AC", "15", "2", "2", { from: account1 })
            })
    })

    it('Should add users to AC 10-15 in AC_Manager', async () => {
        console.log("Account2 => AC10")
        return AC_MGR.OO_addUser(account2, '1', '10')
            .then(() => {
                console.log("Account3 => AC11")
                return AC_MGR.OO_addUser(account3, '1', '11', { from: account1 })
            })
            .then(() => {
                console.log("Account3 => AC12")
                return AC_MGR.OO_addUser(account4, '1', '12', { from: account1 })
            })
            .then(() => {
                console.log("Account4 => AC13")
                return AC_MGR.OO_addUser(account5, '1', '13', { from: account1 })
            })
            .then(() => {
                console.log("Account5 => AC14")
                return AC_MGR.OO_addUser(account6, '1', '14', { from: account1 })
            })
            .then(() => {
                console.log("Account6 => AC15")
                return AC_MGR.OO_addUser(account7, '9', '15', { from: account1 })
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
                console.log("Setting base costs in root 11")
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
                console.log("Setting base costs in root 12")
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
                console.log("Setting base costs in root 13")
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
                console.log("Setting base costs in root 14")
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
                console.log("Setting base costs in root 15")
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

    it('Should mint a record in AC 11', async () => {
        return APP.$newRecord(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint another record in AC 11', async () => {
        return APP.$newRecord(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '11',
            '5000',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 10', async () => {
        return APP.$newRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '10',
            '5000',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 14', async () => {
        return APP.$newRecord(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '14',
            '5000',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should mint a record in AC 15', async () => {
        return APP.$newRecord(
            '0xc531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '15',
            '5000',
            { from: account7, value: 20000000000000000 }
        )
    })

    it('Should put asset 0xd531 into an escrow', async () => {
        return ECR.setEscrow(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '30',
            '6',
            { from: account2 }
        )
    })
    
    it('Should add asset note to asset 0xe531', async () => {
        return APP.$addIpfs2Note(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bnote',
            { from: account3, value: 20000000000000000 }
        )
    })//END SETUP


    //EXPORT ASSET

    it('Should fail to export asset due to non-custodial AC type', async () => {
        return APP.exportAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0004feb54a4ACfcD7E4F7AC8709c749e519Cb5cf',
            { from: account6 }
        )
    })

    it('Should fail to export asset due to user ineligibility in AC', async () => {
        return APP.exportAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0004feb54a4ACfcD7E4F7AC8709c749e519Cb5cf',
            { from: account2 }
        )
    })

    it('Should fail to export asset due to asset status !== 51', async () => {
        return APP.exportAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0004feb54a4ACfcD7E4F7AC8709c749e519Cb5cf',
            { from: account6 }
        )
    }) //END EXPORT ASSET


    //FORCETRANSFER ASSET
    it('Should fail to transfer the record due to non-custodial AC type', async () => {
        return APP.$forceModRecord(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to nonexistance', async () => {
        return APP.$forceModRecord(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to nonHuman user type', async () => {
        return APP.$forceModRecord(
            '0xc531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account7, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to empty NRH field', async () => {
        return APP.$forceModRecord(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should change status to 3', async () => {
        NP._modStatus(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '3',
            { from: account2 }
        )
    })

    it('Should fail to transfer the record due to lost or stolen status', async () => {
        return APP.$forceModRecord(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to escrow status', async () => {
        return APP.$forceModRecord(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Test not active', async () => {
        // @DEV ADD: TRANSFERRED NOT RECIEVED FAILURE CASE
    }) //END FORCETRANSFER ASSET
    
    


    // TRANSFER ASSET

    it('Should fail to transfer the record due to non-custodial AC type', async () => {
        return APP.$transferAsset(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account6, value: 20000000000000000 }
        )
    })


    it('Should fail to transfer the record due to asset nonexistance', async () => {
        return APP.$transferAsset(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to user ineligibility in AC', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to userType > 5 && assetStatus < 50', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account7, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to empty NRH field', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to status nontransferrable', async () => {
        return APP.$transferAsset(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should fail to transfer the record due to rgtHash mismatch', async () => {
        return APP.$transferAsset(
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            { from: account2, value: 20000000000000000 }
        )
    }) //END TRANSFER ASSET

    
    //ADD NOTE 

    it('Should fail to add asset note due to non-custodial AC type', async () => {
        return APP.$addIpfs2Note(
            '0xb531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bnote',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should fail to add asset note due to asset nonexistence', async () => {
        return APP.$addIpfs2Note(
            '0x0531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bnote',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should fail to add asset note due to user ineligibility in AC', async () => {
        return APP.$addIpfs2Note(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bnote',
            { from: account6, value: 20000000000000000 }
        )
    })

    it('Should fail to add asset note due to escrow status', async () => {
        return APP.$addIpfs2Note(
            '0xd531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bnote',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should fail to add asset note due to rgtHash mismatch', async () => {
        return APP.$addIpfs2Note(
            '0x3531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0x0083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bnote',
            { from: account2, value: 20000000000000000 }
        )
    })

    it('Should fail to add asset note due to existing note', async () => {
        return APP.$addIpfs2Note(
            '0xe531cc3dc5bb231b65d260771886cc583d8fe8fb29b457554cb1930a722a747d',
            '0xb083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bee6f',
            '0xa083f25ffc9716fa6c018e077f602f3c6d2377f0bd01917fa75c4e9ca07bnote',
            { from: account3, value: 20000000000000000 }
        )
    })

    it('Test not active', async () => {
        // @DEV ADD: TRANSFERRED NOT RECIEVED FAILURE CASE
    }) //END ADD NOTE
    



    it('Should change status to 1', async () => {
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
    })

});

