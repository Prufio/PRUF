import React, { useState } from 'react';
import { keccak256 } from 'js-sha3';
import Web3Listener from './Web3Listener';

function DeepCompare() {
  let addr = Web3Listener('addr');
  let bulletproof = Web3Listener('bulletproof');
  let eventLog  = Web3Listener('REPORT');

  var [index, setIndex] = useState('');
  var [RH, setRH] = useState('');
  var [txHash, setTx] = useState('');

  const digForRecord = () => { 
    console.log("A little paranoid, aren't ya?");
    console.log("Confirming Bias...");
    bulletproof.methods.rightsholderBlockchainVerify(index, RH)
    .send({ from: addr }).on('receipt', (receipt) => {console.log(setTx(receipt.transactionHash))});
    }

  return (
    <div>
      <h3>Deep Provenance Verification Form</h3>
      <label>
        Index Reference:
          <input type="text" placeholder="string" name="IndexField" onChange={e => setIndex('0x' + keccak256(e.target.value))} />
        <br></br>
            Rights Holder:
          <input type="text" placeholder="string" name="RHField" onChange={e => setRH('0x' + keccak256(e.target.value))} />
        <br></br>
      </label>
      <button onClick={digForRecord}>Deep Compare</button>
      {txHash}
      <br></br>
      {eventLog}
    </div>
  );
}

export default DeepCompare;