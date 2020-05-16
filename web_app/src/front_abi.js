function returnFrontEndAbi(){
    return(
      [
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
              "name": "_IPFSHash",
              "type": "bytes32"
            }
          ],
          "name": "$addIPFS2Note",
          "outputs": [],
          "stateMutability": "payable",
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
          "name": "$forceModRecord",
          "outputs": [],
          "stateMutability": "payable",
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
              "name": "_IPFS",
              "type": "bytes32"
            }
          ],
          "name": "$newRecord",
          "outputs": [],
          "stateMutability": "payable",
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
          "outputs": [],
          "stateMutability": "payable",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "$withdraw",
          "outputs": [],
          "stateMutability": "payable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "bytes32",
              "name": "_idx",
              "type": "bytes32"
            }
          ],
          "name": "XemitRightsHolder",
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
              "name": "_decAmount",
              "type": "uint256"
            }
          ],
          "name": "_decCounter",
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
          "name": "_emitRecord",
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
          "name": "_getRecord",
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
            }
          ],
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
          "name": "_getRecordIPFS",
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
            }
          ],
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
          "name": "_getRecorders",
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
              "internalType": "bytes32",
              "name": "_rgtHash",
              "type": "bytes32"
            },
            {
              "internalType": "bytes32",
              "name": "_IPFSHash",
              "type": "bytes32"
            }
          ],
          "name": "_modIPFS1",
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
              "name": "_status",
              "type": "uint8"
            }
          ],
          "name": "_modStatus",
          "outputs": [],
          "stateMutability": "nonpayable",
          "type": "function"
        },
        {
          "inputs": [
            {
              "internalType": "address",
              "name": "_addr",
              "type": "address"
            }
          ],
          "name": "_setMainWallet",
          "outputs": [],
          "stateMutability": "nonpayable",
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
          "name": "_setStorageContract",
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
          "name": "getAnyHash",
          "outputs": [
            {
              "internalType": "bytes32",
              "name": "",
              "type": "bytes32"
            }
          ],
          "stateMutability": "pure",
          "type": "function"
        },
        {
          "inputs": [],
          "name": "getBlock",
          "outputs": [
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

export default returnFrontEndAbi;