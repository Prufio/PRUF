function returnSAbi(){
    return(
        [
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": false,
                        "internalType": "bytes32",
                        "name": "",
                        "type": "bytes32"
                    },
                    {
                        "indexed": false,
                        "internalType": "bytes32",
                        "name": "",
                        "type": "bytes32"
                    },
                    {
                        "indexed": false,
                        "internalType": "bytes32",
                        "name": "",
                        "type": "bytes32"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint8",
                        "name": "",
                        "type": "uint8"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint8",
                        "name": "",
                        "type": "uint8"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint16",
                        "name": "",
                        "type": "uint16"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    },
                    {
                        "indexed": false,
                        "internalType": "uint256",
                        "name": "",
                        "type": "uint256"
                    },
                    {
                        "indexed": false,
                        "internalType": "bytes32",
                        "name": "",
                        "type": "bytes32"
                    },
                    {
                        "indexed": false,
                        "internalType": "bytes32",
                        "name": "",
                        "type": "bytes32"
                    }
                ],
                "name": "EMIT_RECORD",
                "type": "event"
            },
            {
                "anonymous": false,
                "inputs": [
                    {
                        "indexed": false,
                        "internalType": "bytes32",
                        "name": "",
                        "type": "bytes32"
                    }
                ],
                "name": "EMIT_RIGHTS_HOLDER",
                "type": "event"
            },
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
                        "internalType": "address",
                        "name": "_addr",
                        "type": "address"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_contractAuthLevel",
                        "type": "uint8"
                    }
                ],
                "name": "ADMIN_addContract",
                "outputs": [],
                "stateMutability": "nonpayable",
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
                "name": "ADMIN_addUser",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_idx",
                        "type": "string"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_stat",
                        "type": "uint8"
                    }
                ],
                "name": "ADMIN_lockStatus",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_idx",
                        "type": "string"
                    }
                ],
                "name": "ADMIN_resetFMC",
                "outputs": [],
                "stateMutability": "nonpayable",
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
                        "name": "_transferRecordCost",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_createNoteCost",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_cost4",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_cost5",
                        "type": "uint256"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_forceModCost",
                        "type": "uint256"
                    }
                ],
                "name": "ADMIN_setCosts",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_idx",
                        "type": "string"
                    },
                    {
                        "internalType": "uint256",
                        "name": "_blockNumber",
                        "type": "uint256"
                    }
                ],
                "name": "ADMIN_setTimelock",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_idx",
                        "type": "string"
                    }
                ],
                "name": "ADMIN_unlock",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "string",
                        "name": "_idx",
                        "type": "string"
                    },
                    {
                        "internalType": "string",
                        "name": "_rgt",
                        "type": "string"
                    }
                ],
                "name": "XcompareRightsHolder",
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
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    }
                ],
                "name": "emitRecord",
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
                    }
                ],
                "name": "emitRightsHolder",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_userHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_IPFS1",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_IPFS2",
                        "type": "bytes32"
                    }
                ],
                "name": "modifyIPFS",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            },
            {
                "inputs": [
                    {
                        "internalType": "bytes32",
                        "name": "_userHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_regHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "uint8",
                        "name": "_status",
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
                        "name": "_userHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_idxHash",
                        "type": "bytes32"
                    },
                    {
                        "internalType": "bytes32",
                        "name": "_rgt",
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
                        "name": "_IPFS1",
                        "type": "bytes32"
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
                "name": "renounceOwnership",
                "outputs": [],
                "stateMutability": "nonpayable",
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
                "name": "retrieveIPFSData",
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
                        "internalType": "uint16",
                        "name": "",
                        "type": "uint16"
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
                        "internalType": "uint16",
                        "name": "",
                        "type": "uint16"
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
                "name": "retrieveRecorder",
                "outputs": [
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
                        "internalType": "address",
                        "name": "newOwner",
                        "type": "address"
                    }
                ],
                "name": "transferOwnership",
                "outputs": [],
                "stateMutability": "nonpayable",
                "type": "function"
            }
        ]

    );
}

export default returnSAbi;