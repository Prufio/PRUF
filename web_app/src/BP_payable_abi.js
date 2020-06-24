function returnBPPAbi() {
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
				"name": "REPORT_B32",
				"type": "event"
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
						"name": "_reMintRecordCost",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "_modifyStatusCost",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "_forceModCost",
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
				"name": "ADMIN_resetFMC",
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
				"name": "OO_addContract",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			},
			{
				"inputs": [],
				"name": "OO_getTokenAddresses",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			},
			{
				"inputs": [
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
						"name": "_reMintRecordCost",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "_modifyStatusCost",
						"type": "uint256"
					},
					{
						"internalType": "uint256",
						"name": "_forceModCost",
						"type": "uint256"
					},
					{
						"internalType": "address",
						"name": "_paymentAddress",
						"type": "address"
					}
				],
				"name": "OO_setBaseCosts",
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
						"name": "_userHash",
						"type": "bytes32"
					},
					{
						"internalType": "bytes32",
						"name": "_idxHash",
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
				"inputs": [],
				"name": "retrieveBaseCosts",
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
						"internalType": "uint8",
						"name": "_newAssetStatus",
						"type": "uint8"
					},
					{
						"internalType": "uint256",
						"name": "_escrowTime",
						"type": "uint256"
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
						"name": "_userHash",
						"type": "bytes32"
					},
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
			}
		]

	);
}

export default returnBPPAbi;