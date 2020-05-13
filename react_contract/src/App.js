import React, { useState } from 'react';
import './App.css';
import Web3 from 'web3';
import returnAbi from './abi';
import returnSAbi from './sAbi';




function App() {
  let web3 = require('web3');
  const keccak256 = require('js-sha3').keccak256;
  const bulletproof_frontend_addr = "0xD097ce9cC3f8402a7311c576c60f7CeE44baf711";
  const bulletproof_storage_addr = "0x124B7F075b9b18aCd8Fb1C7C4c14A5EA959dDB82";
  const ethereum = window.ethereum;

  web3 = new Web3(web3.givenProvider);

  var [addr, setAddr] = useState('');
  var [index, setIndex] = useState('');
  var [CRH, setCRH] = useState('');
  var [NRH, setNRH] = useState('');
  var [txIndex, setTxIndex] = useState('');
  var [txHash, setTxHash] = useState('');
  var [RH, setRH] = useState('');
  var [compareResult, setResult] = useState('');
  

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

    ethereum.on('accountsChanged', function (accounts) {
      console.log('trying to change active address');
      web3.eth.getAccounts().then(e => setAddr(e[0]));
    })

  })

  const callForRecord = () => {
    console.log('Scouring the blockchain for information!');
    storage.methods.XcompareRightsHolder(index, RH).call({from: addr}).then(result => setResult(result));
  }

  const txProvenance = () => {
    console.log("Transferring provenance of asset...");
    console.log("Using data: ", txIndex, CRH, NRH);
    bulletproof.methods.$transferAsset(txIndex, CRH, NRH).send({from: addr , value: web3.utils.toWei('0.04')}).then(_txHash => setTxHash(_txHash));
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
          <input type="text" name="IndexField" onChange={e => setIndex(e.target.value)}/>
          <br></br>
            Rights Holder:
          <input type="text" name="RHField" onChange={e => setRH(e.target.value)}/>
          <br></br>
          </label>
          <button onClick={callForRecord}>Compare</button>
          <br></br>

          <h3>Provenance Update Form</h3>
          <label>
            Index Reference:
          <input type="text" name="txIndexField" onChange={e => setTxIndex(e.target.value)}/>
          <br></br>
            Current Rights Holder:
          <input type="text" name="CRHField" onChange={e => setCRH(e.target.value)}/>
          <br></br>
            New Rights Holder:
          <input type="text" name="NRHField" onChange={e => setNRH(e.target.value)}/>
          <br></br>
          </label>
          <button onClick={txProvenance}>Update Provenance</button>
          <br></br>
            Transaction hash: {txHash}

  <h4>Index Hash: {index}</h4>
        <h4>{compareResult}</h4>
      </header>
    </div>
  );
}

/* Index Reference:
<input type="text" name="IndexField" onChange={e => setIndex('0x' + keccak256(e.target.value))}/>
<br></br>
  Rights Holder:
<input type="text" name="RHField" onChange={e => setRH('0x' + keccak256(e.target.value))}/>
<br></br> */

export default App;
