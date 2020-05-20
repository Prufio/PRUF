import React, { useState } from 'react';
import Web3Listener from './Web3Listener';


function Transfer() {
  let web3 = Web3Listener('web3');
  let addr = Web3Listener('addr');
  let bulletproof = Web3Listener('bulletproof');

  var [txIndex, setTxIndex] = useState('');
  var [CRH, setCRH] = useState('');
  var [NRH, setNRH] = useState('');
  var [txHash, setTxHash] = useState('');

  const txProvenance = () => {
    console.log("Transferring provenance of asset...");
    console.log("Using data: ", txIndex, CRH, NRH);
    bulletproof.methods.$transferAsset(txIndex, CRH, NRH)
      .send({ from: addr, value: web3.utils.toWei('0.04') })
      .on('receipt', (receipt) => { setTxHash(receipt.transactionHash) });
  }

  return (
    <div>
      txHash: {txHash}
      <h3>Provenance Update Form</h3>
      <label>
        Index Reference:
          <input type="text" name="txIndexField" onChange={e => setTxIndex('0x' + web3.utils.soliditySha3(e.target.value))} />
        <br></br>
            Current Rights Holder:
          <input type="text" name="CRHField" onChange={e => setCRH('0x' + web3.utils.soliditySha3(e.target.value))} />
        <br></br>
            New Rights Holder:
          <input type="text" name="NRHField" onChange={e => setNRH('0x' + web3.utils.soliditySha3(e.target.value))} />
        <br></br>
      </label>
      <button onClick={txProvenance}>Transfer Asset</button>
    </div>

  );
}

export default Transfer;