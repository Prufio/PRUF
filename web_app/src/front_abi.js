function returnFrontEndAbi() {
	return (
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
						"name": "_Ipfs",
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
				"outputs": [
					{
						"internalType": "uint8",
						"name": "",
						"type": "uint8"
					}
				],
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
				"inputs": [
					{
						"internalType": "address payable",
						"name": "payee",
						"type": "address"
					}
				],
				"name": "withdrawPayments",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			}
		]
	);
}

export default returnFrontEndAbi;