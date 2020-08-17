function returnABIs() {
    let abis = {STOR:"",
                APP:"",
                NP:"",
                ECR:"",
                AC_MGR:"",
                }; 
    
    const STOR = [
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "previousOwner",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "OwnershipTransferred",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "internalType": "address",
                    "name": "account",
                    "type": "address"
                }
            ],
            "name": "Paused",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "internalType": "string",
                    "name": "_msg",
                    "type": "string"
                },
                {
                    "indexed": false,
                    "internalType": "bytes32",
                    "name": "b32",
                    "type": "bytes32"
                }
            ],
            "name": "REPORT",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "internalType": "address",
                    "name": "account",
                    "type": "address"
                }
            ],
            "name": "Unpaused",
            "type": "event"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "_addr",
                    "type": "address"
                },
                {
                    "internalType": "uint256",
                    "name": "_assetClass",
                    "type": "uint256"
                }
            ],
            "name": "ContractInfoHash",
            "outputs": [
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                },
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_name",
                    "type": "string"
                },
                {
                    "internalType": "address",
                    "name": "_addr",
                    "type": "address"
                },
                {
                    "internalType": "uint256",
                    "name": "_assetClass",
                    "type": "uint256"
                },
                {
                    "internalType": "uint8",
                    "name": "_contractAuthLevel",
                    "type": "uint8"
                }
            ],
            "name": "OO_addContract",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                }
            ],
            "name": "_verifyRightsHolder",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                }
            ],
            "name": "blockchainVerifyRightsHolder",
            "outputs": [
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                }
            ],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint256",
                    "name": "_newAssetClass",
                    "type": "uint256"
                }
            ],
            "name": "changeAC",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_name",
                    "type": "string"
                },
                {
                    "internalType": "uint256",
                    "name": "_assetClass",
                    "type": "uint256"
                },
                {
                    "internalType": "uint8",
                    "name": "_contractAuthLevel",
                    "type": "uint8"
                }
            ],
            "name": "enableContractForAC",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_contractNameHash",
                    "type": "bytes32"
                }
            ],
            "name": "endEscrow",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_Ipfs1",
                    "type": "bytes32"
                }
            ],
            "name": "modifyIpfs1",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_Ipfs2",
                    "type": "bytes32"
                }
            ],
            "name": "modifyIpfs2",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint8",
                    "name": "_newAssetStatus",
                    "type": "uint8"
                },
                {
                    "internalType": "uint256",
                    "name": "_countDown",
                    "type": "uint256"
                },
                {
                    "internalType": "uint8",
                    "name": "_forceCount",
                    "type": "uint8"
                },
                {
                    "internalType": "uint16",
                    "name": "_numberOfTransfers",
                    "type": "uint16"
                }
            ],
            "name": "modifyRecord",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint256",
                    "name": "_assetClass",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "_countDownStart",
                    "type": "uint256"
                }
            ],
            "name": "newRecord",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "owner",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "pause",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "paused",
            "outputs": [
                {
                    "internalType": "bool",
                    "name": "",
                    "type": "bool"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "renounceOwnership",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "string",
                    "name": "_name",
                    "type": "string"
                }
            ],
            "name": "resolveContractAddress",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                }
            ],
            "name": "retrieveRecord",
            "outputs": [
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                },
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint16",
                    "name": "",
                    "type": "uint16"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                }
            ],
            "name": "retrieveShortRecord",
            "outputs": [
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                },
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint16",
                    "name": "",
                    "type": "uint16"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint8",
                    "name": "_newAssetStatus",
                    "type": "uint8"
                },
                {
                    "internalType": "bytes32",
                    "name": "_contractNameHash",
                    "type": "bytes32"
                }
            ],
            "name": "setEscrow",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint8",
                    "name": "_newAssetStatus",
                    "type": "uint8"
                }
            ],
            "name": "setStolenOrLost",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "transferOwnership",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "unpause",
            "outputs": [],
            "stateMutability": "nonpayable",
            "type": "function"
        }
    ]

//............................................................................................................................................

    const APP = [
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "previousOwner",
                    "type": "address"
                },
                {
                    "indexed": true,
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "OwnershipTransferred",
            "type": "event"
        },
        {
            "anonymous": false,
            "inputs": [
                {
                    "indexed": false,
                    "internalType": "string",
                    "name": "_msg",
                    "type": "string"
                }
            ],
            "name": "REPORT",
            "type": "event"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_IpfsHash",
                    "type": "bytes32"
                }
            ],
            "name": "$addIpfs2Note",
            "outputs": [
                {
                    "internalType": "bytes32",
                    "name": "",
                    "type": "bytes32"
                }
            ],
            "stateMutability": "APP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                }
            ],
            "name": "$forceModRecord",
            "outputs": [
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                }
            ],
            "stateMutability": "APP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                }
            ],
            "name": "$importAsset",
            "outputs": [
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                }
            ],
            "stateMutability": "APP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "uint16",
                    "name": "_assetClass",
                    "type": "uint16"
                },
                {
                    "internalType": "uint256",
                    "name": "_countDownStart",
                    "type": "uint256"
                },
                {
                    "internalType": "bytes32",
                    "name": "_Ipfs",
                    "type": "bytes32"
                }
            ],
            "name": "$newRecord",
            "outputs": [],
            "stateMutability": "APP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_rgtHash",
                    "type": "bytes32"
                },
                {
                    "internalType": "bytes32",
                    "name": "_newrgtHash",
                    "type": "bytes32"
                }
            ],
            "name": "$transferAsset",
            "outputs": [
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                }
            ],
            "stateMutability": "APP",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "$withdraw",
            "outputs": [],
            "stateMutability": "APP",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "OO_ResolveContractAddresses",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "_to",
                    "type": "address"
                },
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                }
            ],
            "name": "OO_TX_AC_Token",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "_to",
                    "type": "address"
                },
                {
                    "internalType": "bytes32",
                    "name": "_idxHash",
                    "type": "bytes32"
                }
            ],
            "name": "OO_TX_asset_Token",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "_authAddr",
                    "type": "address"
                },
                {
                    "internalType": "uint8",
                    "name": "_userType",
                    "type": "uint8"
                },
                {
                    "internalType": "uint16",
                    "name": "_authorizedAssetClass",
                    "type": "uint16"
                }
            ],
            "name": "OO_addUser",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "_storageAddress",
                    "type": "address"
                }
            ],
            "name": "OO_setStorageContract",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "bytes32",
                    "name": "_userHash",
                    "type": "bytes32"
                }
            ],
            "name": "getUserExt",
            "outputs": [
                {
                    "internalType": "uint8",
                    "name": "",
                    "type": "uint8"
                },
                {
                    "internalType": "uint16",
                    "name": "",
                    "type": "uint16"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                },
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                },
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                },
                {
                    "internalType": "bytes",
                    "name": "",
                    "type": "bytes"
                }
            ],
            "name": "onERC721Received",
            "outputs": [
                {
                    "internalType": "bytes4",
                    "name": "",
                    "type": "bytes4"
                }
            ],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "owner",
            "outputs": [
                {
                    "internalType": "address",
                    "name": "",
                    "type": "address"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "dest",
                    "type": "address"
                }
            ],
            "name": "payments",
            "outputs": [
                {
                    "internalType": "uint256",
                    "name": "",
                    "type": "uint256"
                }
            ],
            "stateMutability": "view",
            "type": "function"
        },
        {
            "inputs": [],
            "name": "renounceOwnership",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address",
                    "name": "newOwner",
                    "type": "address"
                }
            ],
            "name": "transferOwnership",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        },
        {
            "inputs": [
                {
                    "internalType": "address APP",
                    "name": "payee",
                    "type": "address"
                }
            ],
            "name": "withdrawPayments",
            "outputs": [],
            "stateMutability": "nonAPP",
            "type": "function"
        }
    ]

//............................................................................................................................................

        const NP = [
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "previousOwner",
                        "type": "address"
                    },
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "newOwner",
                        "type": "address"
                    }
                ],
                "name": "OwnershipTransferred",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": false,
                        "internalType": "string",
                        "name": "_msg",
                        "type": "string"
                    }
                ],
                "name": "REPORT",
                "type": "event"
            },
            {
                "inputs": [],
                "name": "$withdraw",
                "outputs": [],
                "stateMutability": "APP",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "OO_ResolveContractAddresses",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_to",
                        "type": "address"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    }
                ],
                "name": "OO_TX_AC_Token",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_to",
                        "type": "address"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    }
                ],
                "name": "OO_TX_asset_Token",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_authAddr",
                        "type": "address"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_userType",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint16",
                        "name": "_authorizedAssetClass",
                        "type": "uint16"
                    }
                ],
                "name": "OO_addUser",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_storageAddress",
                        "type": "address"
                    }
                ],
                "name": "OO_setStorageContract",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_rgtHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_decAmount",
                        "type": "uint256"
                    }
                ],
                "name": "_decCounter",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_rgtHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_IpfsHash",
                        "type": "bytes32"
                    }
                ],
                "name": "_modIpfs1",
                "outputs": [
                    {
                        "internalType": "bytes32",
                        "name": "",
                        "type": "bytes32"
                    }
                ],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_rgtHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_newAssetStatus",
                        "type": "uint8"
                    }
                ],
                "name": "_modStatus",
                "outputs": [
                    {
                        "internalType": "uint8",
                        "name": "",
                        "type": "uint8"
                    }
                ],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_rgtHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_newAssetStatus",
                        "type": "uint8"
                    }
                ],
                "name": "_setLostOrStolen",
                "outputs": [
                    {
                        "internalType": "uint8",
                        "name": "",
                        "type": "uint8"
                    }
                ],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_userHash",
                        "type": "bytes32"
                    }
                ],
                "name": "getUserExt",
                "outputs": [
                    {
                        "internalType": "uint8",
                        "name": "",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint16",
                        "name": "",
                        "type": "uint16"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bytes",
                        "name": "",
                        "type": "bytes"
                    }
                ],
                "name": "onERC721Received",
                "outputs": [
                    {
                        "internalType": "bytes4",
                        "name": "",
                        "type": "bytes4"
                    }
                ],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "owner",
                "outputs": [
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "dest",
                        "type": "address"
                    }
                ],
                "name": "payments",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "renounceOwnership",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "newOwner",
                        "type": "address"
                    }
                ],
                "name": "transferOwnership",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address APP",
                        "name": "payee",
                        "type": "address"
                    }
                ],
                "name": "withdrawPayments",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            }
        ]
        
//............................................................................................................................................

        const ECR = [
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "previousOwner",
                        "type": "address"
                    },
                    {
                        "indexed": true,
                        "internalType": "address",
                        "name": "newOwner",
                        "type": "address"
                    }
                ],
                "name": "OwnershipTransferred",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": false,
                        "internalType": "string",
                        "name": "_msg",
                        "type": "string"
                    }
                ],
                "name": "REPORT",
                "type": "event"
            },
            {
                "inputs": [],
                "name": "$withdraw",
                "outputs": [],
                "stateMutability": "APP",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "OO_ResolveContractAddresses",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_to",
                        "type": "address"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    }
                ],
                "name": "OO_TX_AC_Token",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_to",
                        "type": "address"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    }
                ],
                "name": "OO_TX_asset_Token",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_authAddr",
                        "type": "address"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_userType",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint16",
                        "name": "_authorizedAssetClass",
                        "type": "uint16"
                    }
                ],
                "name": "OO_addUser",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "_storageAddress",
                        "type": "address"
                    }
                ],
                "name": "OO_setStorageContract",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    }
                ],
                "name": "endEscrow",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_userHash",
                        "type": "bytes32"
                    }
                ],
                "name": "getUserExt",
                "outputs": [
                    {
                        "internalType": "uint8",
                        "name": "",
                        "type": "uint8"
                    },
                    {
                        "internalType": "uint16",
                        "name": "",
                        "type": "uint16"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    },
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    },
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    },
                    {
                        "internalType": "bytes",
                        "name": "",
                        "type": "bytes"
                    }
                ],
                "name": "onERC721Received",
                "outputs": [
                    {
                        "internalType": "bytes4",
                        "name": "",
                        "type": "bytes4"
                    }
                ],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "owner",
                "outputs": [
                    {
                        "internalType": "address",
                        "name": "",
                        "type": "address"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "dest",
                        "type": "address"
                    }
                ],
                "name": "payments",
                "outputs": [
                    {
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    }
                ],
                "stateMutability": "view",
                "type": "function"
            },
            {
                "inputs": [],
                "name": "renounceOwnership",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_escrowTime",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_escrowStatus",
                        "type": "uint8"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_escrowOwnerHash",
                        "type": "bytes32"
                    }
                ],
                "name": "setEscrow",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address",
                        "name": "newOwner",
                        "type": "address"
                    }
                ],
                "name": "transferOwnership",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "address APP",
                        "name": "payee",
                        "type": "address"
                    }
                ],
                "name": "withdrawPayments",
                "outputs": [],
                "stateMutability": "nonAPP",
                "type": "function"
            }
        ]

//............................................................................................................................................

 const AC_MGR = [
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": true,
				"internalType": "address",
				"name": "previousOwner",
				"type": "address"
			},
			{
				"indexed": true,
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "OwnershipTransferred",
		"type": "event"
	},
	{
		"anonymous": false,
		"inputs": [
			{
				"indexed": false,
				"internalType": "string",
				"name": "_msg",
				"type": "string"
			}
		],
		"name": "REPORT",
		"type": "event"
	},
	{
		"inputs": [],
		"name": "$withdraw",
		"outputs": [],
		"stateMutability": "APP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_class",
				"type": "uint16"
			},
			{
				"internalType": "uint256",
				"name": "_newRecordCost",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_transferAssetCost",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_createNoteCost",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_reMintRecordCost",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_changeStatusCost",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "_forceModifyCost",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_paymentAddress",
				"type": "address"
			}
		],
		"name": "ACTH_setCosts",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "OO_ResolveContractAddresses",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "bytes32",
				"name": "_idxHash",
				"type": "bytes32"
			}
		],
		"name": "OO_TX_AC_Token",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_to",
				"type": "address"
			},
			{
				"internalType": "bytes32",
				"name": "_idxHash",
				"type": "bytes32"
			}
		],
		"name": "OO_TX_asset_Token",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_authAddr",
				"type": "address"
			},
			{
				"internalType": "uint8",
				"name": "_userType",
				"type": "uint8"
			},
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "OO_addUser",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "_storageAddress",
				"type": "address"
			}
		],
		"name": "OO_setStorageContract",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_tokenId",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "_recipientAddress",
				"type": "address"
			},
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			},
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			},
			{
				"internalType": "uint16",
				"name": "_assetClassRoot",
				"type": "uint16"
			},
			{
				"internalType": "uint8",
				"name": "_custodyType",
				"type": "uint8"
			}
		],
		"name": "createAssetClass",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "getAC_data",
		"outputs": [
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			},
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "_tokenId",
				"type": "uint256"
			}
		],
		"name": "getAC_name",
		"outputs": [
			{
				"internalType": "string",
				"name": "",
				"type": "string"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "getChangeStatusCosts",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "getCreateNoteCosts",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "getForceModifyCosts",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "getNewRecordCosts",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "getReMintRecordCosts",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "getTransferAssetCosts",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "bytes32",
				"name": "_userHash",
				"type": "bytes32"
			}
		],
		"name": "getUserExt",
		"outputs": [
			{
				"internalType": "uint8",
				"name": "",
				"type": "uint8"
			},
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "bytes",
				"name": "",
				"type": "bytes"
			}
		],
		"name": "onERC721Received",
		"outputs": [
			{
				"internalType": "bytes4",
				"name": "",
				"type": "bytes4"
			}
		],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "owner",
		"outputs": [
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "dest",
				"type": "address"
			}
		],
		"name": "payments",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "renounceOwnership",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "string",
				"name": "_name",
				"type": "string"
			}
		],
		"name": "resolveAssetClass",
		"outputs": [
			{
				"internalType": "uint16",
				"name": "",
				"type": "uint16"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint16",
				"name": "_assetClass",
				"type": "uint16"
			}
		],
		"name": "retrieveCosts",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			},
			{
				"internalType": "address",
				"name": "",
				"type": "address"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address",
				"name": "newOwner",
				"type": "address"
			}
		],
		"name": "transferOwnership",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "address APP",
				"name": "payee",
				"type": "address"
			}
		],
		"name": "withdrawPayments",
		"outputs": [],
		"stateMutability": "nonAPP",
		"type": "function"
	}
];

//............................................................................................................................................

        
        abis.AC_MGR=AC_MGR;
        abis.STOR=STOR;
        abis.APP=APP;
        abis.NP=NP;
        abis.ECR=ECR;

        return (abis);
}

export default returnABIs;