function returnBPFAbi() {
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
					}
				],
				"name": "$reimportRecord",
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
				"stateMutability": "nonpayable",
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
				"stateMutability": "nonpayable",
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
				"name": "OO_addUser",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "address",
						"name": "_contractAddress",
						"type": "address"
					}
				],
				"name": "OO_setAssetClassTokenAddress",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			},
			{
				"inputs": [
					{
						"internalType": "address",
						"name": "_contractAddress",
						"type": "address"
					}
				],
				"name": "OO_setAssetTokenAddress",
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
				"name": "OO_setStorageContract",
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
				"name": "endEscrow",
				"outputs": [],
				"stateMutability": "nonpayable",
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

export default returnBPFAbi;