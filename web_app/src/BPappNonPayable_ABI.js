function returnBPFAbi() {
	return (
		[
			{
				"inputs": [
					{
						"internalType": "uint256",
						"name": "",
						"type": "uint256"
					}
				],
				"name": "ownerOf",
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
						"name": "from",
						"type": "address"
					},
					{
						"internalType": "address",
						"name": "to",
						"type": "address"
					},
					{
						"internalType": "bytes32",
						"name": "idxHash",
						"type": "bytes32"
					}
				],
				"name": "transferAssetClassToken",
				"outputs": [],
				"stateMutability": "nonpayable",
				"type": "function"
			}
		]
	);
}

export default returnBPFAbi;