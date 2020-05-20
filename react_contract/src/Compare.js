import React, { useState } from 'react';
import Web3Listener from './Web3Listener';

function Compare() {
  let addr = Web3Listener('addr');
  let storage = Web3Listener('storage');

  var [index, setIndex] = useState('');
  var [RH, setRH] = useState('');
  var [compareResult, setResult] = useState('');

  const callForRecord = () => {
    console.log('Scouring the blockchain for information!');
    storage.methods.XcompareRightsHolder(index, RH)
      .call({ from: addr })
      .then(result => setResult(result));
  }

  return (
    <div>
      <h3>Provenance Verification Form</h3>
      <label>
        Index Reference:
          <input type="text" name="IndexField" onChange={e => setIndex('0x' + web3.utils.soliditySha3(e.target.value))} />
        <br></br>
            Rights Holder:
          <input type="text" name="RHField" onChange={e => setRH('0x' + web3.utils.soliditySha3(e.target.value))} />
        <br></br>
      </label>
      <button onClick={callForRecord}>Compare</button>
      <br></br>
      {compareResult}
    </div>
  );
}

export default Compare;