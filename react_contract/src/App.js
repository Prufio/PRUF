import React, { useState } from 'react';
import './App.css';
import Web3 from 'web3';
import returnAbi from './abi';
import returnSAbi from './sAbi';

function App() {
  let web3 = require('web3');
  const keccak256 = require('js-sha3').keccak256;
  const bulletproof_frontend_addr = "0xCc2CBfd27fbf7AEF15FFfe119B91c3006B5DE0b0";
  const bulletproof_storage_addr = "0xec7C54c5A4F454fA951077A6D200A73910eB1ae0";
  const ethereum = window.ethereum;

  web3 = new Web3(web3.givenProvider);

  var [addr, setAddr] = useState('');
  var [index, setIndex] = useState('');
  var [CRH, setCRH] = useState('');
  var [NRH, setNRH] = useState('');
  var [txIndex, setTxIndex] = useState('');
  var [RH, setRH] = useState('');
  var [NRIndex, setNRIndex] = useState('');
  var [NRRH, setNRRH] = useState('');
  var [NRAC, setNRAC] = useState('');
  var [LS, setLS] = useState('');
  var [IPFS1, setIPFS1] = useState('');
  var [compareResult, setResult] = useState('');
  var [txHash, setTxHash] = useState('');
  
  const myAbi = returnAbi();
  const sAbi = returnSAbi();
  const bulletproof = new web3.eth.Contract(myAbi, bulletproof_frontend_addr);
  const storage = new web3.eth.Contract(sAbi, bulletproof_storage_addr);
  
  window.addEventListener('load', async () => {

    await ethereum.enable();
    web3.eth.getAccounts().then(e => setAddr(e[0]));
    

    if (web3.eth.getAccounts().then(e => e === addr)) {
      console.log("Serving current metamask address at accounts[0]");

    }

    if (web3.currentProvider.isMetaMask === false) {
      await ethereum.enable();
    }

    ethereum.on('accountsChanged', function (accounts) {
      console.log('trying to change active address');
      web3.eth.getAccounts().then(e => setAddr(e[0]));
    })


  })

  const callForRecord = () => {
    if (ethereum) {
    console.log('Scouring the blockchain for information!');
    storage.methods.XcompareRightsHolder(index, RH)
    .call({from: addr})
    .then(result => setResult(result));
    }
  }

  const txProvenance = () => {
    console.log("Transferring provenance of asset...");
    console.log("Using data: ", txIndex, CRH, NRH);
    bulletproof.methods.$transferAsset(txIndex, CRH, NRH)
    .send({from: addr , value: web3.utils.toWei('0.04')})
    .on('receipt', (receipt) => {setTxHash(receipt.transactionHash)});
  }

  const newRecord = () => {
    console.log("Creating asset record in database");
    console.log("Using data: ", NRIndex, NRRH, NRAC, LS, IPFS1);
    bulletproof.methods.$newRecord(NRIndex, NRRH, NRAC, LS, IPFS1)
    .send({from: addr, value: web3.utils.toWei('0.04')})
    .on('receipt', (receipt) => {setTxHash(receipt.transactionHash)});
  }

  return (
    <div className="App">
      Currently serving: {addr}
      {/* {ethereum && <p>currently serving: {addr} </p>}
      {!ethereum && <p>Metamask not currently installed</p>} */}
      <header className="App-header">

          <h3>Provenance Verification Form</h3>
          <label>
            Index Reference: 
          <input type="text" name="IndexField" onChange={e => setIndex('0x' + keccak256(e.target.value))}/>
          <br></br>
            Rights Holder: 
          <input type="text" name="RHField" onChange={e => setRH('0x' + keccak256(e.target.value))}/>
          <br></br>
          </label>
          <button onClick={callForRecord}>Compare</button>
          <br></br>

          <h3>Provenance Update Form</h3>
          <label>
            Index Reference: 
          <input type="text" name="txIndexField" onChange={e => setTxIndex('0x' + keccak256(e.target.value))}/>
          <br></br>
            Current Rights Holder: 
          <input type="text" name="CRHField" onChange={e => setCRH('0x' + keccak256(e.target.value))}/>
          <br></br>
            New Rights Holder: 
          <input type="text" name="NRHField" onChange={e => setNRH('0x' + keccak256(e.target.value))}/>
          <br></br>
          </label>
          <button onClick={txProvenance}>Update Provenance</button>
          <br></br>

          <h3>New Asset Form</h3>
          <label>
            Index Reference: 
          <input type="text" name="NRIndexField" onChange={e => setNRIndex('0x' + keccak256(e.target.value))}/>
          <br></br>
            Rights Holder: 
          <input type="text" name="NRRHField" onChange={e => setNRRH('0x' + keccak256(e.target.value))}/>
          <br></br>
            Asset Class: 
          <input type="text" name="NRACField" onChange={e => setNRAC(e.target.value)}/>
          <br></br>
            Log Start Value: 
          <input type="text" name="LSField" onChange={e => setLS(e.target.value)}/>
          <br></br>
            Permanent Asset Notes: 
          <input type="text" name="IPFS1Field" onChange={e => setIPFS1('0x' + keccak256(e.target.value))}/>
          <br></br>
          </label>
          <button onClick={newRecord}>Create New Asset</button>
          <br></br>
            Transaction hash:  {txHash}
        <h4>{compareResult}</h4>
      </header>
    </div>
  );
}

export default App;
