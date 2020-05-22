function returnStorageAbi() {
	return (
		[
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
						"name": "_Ipfs1",
						"type": "bytes32"
					},
					{
						"internalType": "bytes32",
						"name": "_Ipfs2",
						"type": "bytes32"
					}
				],
				"name": "modifyIpfs",
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
						"name": "_assetStatus",
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
						"name": "_Ipfs1",
						"type": "bytes32"
					}
				],
				"name": "newRecord",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
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
				"inputs": [],
				"name": "renounceOwnership",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
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
						"name": "contractAddress",
						"type": "address"
					}
				],
				"name": "setErc721_tokenAddress",
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
				"name": "ADMIN_compare_rgt",
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
				"name": "retrieveRecord",
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
					},
					{
						"internalType": "bytes32",
						"name": "",
						"type": "bytes32"
					}
				],
				"stateMutability": "view",
				"type": "function"
			}
		]

	);
}

export default returnStorageAbi;