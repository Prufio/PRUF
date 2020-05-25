function returnTestNRAbi() {
	return ([
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
					"indexed": false,
					"internalType": "string",
					"name": "_msg",
					"type": "string"
				},
				{
					"indexed": false,
					"internalType": "uint256",
					"name": "_tokenID",
					"type": "uint256"
				},
				{
					"indexed": false,
					"internalType": "bytes32",
					"name": "_userHash",
					"type": "bytes32"
				},
				{
					"indexed": false,
					"internalType": "bytes32",
					"name": "_idxHash",
					"type": "bytes32"
				},
				{
					"indexed": false,
					"internalType": "bytes32",
					"name": "_rgt",
					"type": "bytes32"
				},
				{
					"indexed": false,
					"internalType": "uint16",
					"name": "_assetClass",
					"type": "uint16"
				},
				{
					"indexed": false,
					"internalType": "uint256",
					"name": "_countDownStart",
					"type": "uint256"
				},
				{
					"indexed": false,
					"internalType": "bytes32",
					"name": "_Ipfs1",
					"type": "bytes32"
				}
			],
			"name": "REPORT",
			"type": "event"
		}
	]);
}

export default returnTestNRAbi; 