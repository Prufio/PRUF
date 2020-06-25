import React, { useState } from 'react';
import Web3Listener from './Web3Listener';

function NewRecord() {

    let web3 = Web3Listener('web3');
    let addr = Web3Listener('addr');
    let bulletproof = Web3Listener('bulletproof');

    var [index, setIndex] = useState('');
    var [RH, setRH] = useState('');
    var [AC, setAC] = useState('');
    var [LS, setLS] = useState('');
    var [IPFS1, setIPFS1] = useState('');
    var [txHash, setTxHash] = useState('');

    const _newRecord = () => {
        console.log("Checking with main...");
        console.log("Shipping data: ", index, RH, AC, LS, IPFS1);
        bulletproof.methods.$newRecord(index, RH, AC, LS, IPFS1)
            .send({ from: addr, value: web3.utils.toWei('0.04') })
            .on('receipt', (receipt) => { setTxHash(receipt.transactionHash) });
        console.log(txHash);
    }

    return (
        <div>
            <h3>New Asset Form</h3>
            <label>
                Index Reference:
          <input type="text" name="indexField" onChange={e => setIndex('0x' + web3.utils.soliditySha3(e.target.value))} />
                <br></br>
            Rights Holder:
          <input type="text" name="RHField" onChange={e => setRH('0x' + web3.utils.soliditySha3(e.target.value))} />
                <br></br>
            Asset Class:
          <input type="text" name="ACField" onChange={e => setAC(e.target.value)} />
                <br></br>
            Log Start Value:
          <input type="text" name="LSField" onChange={e => setLS(e.target.value)} />
                <br></br>
            Permanent Asset Notes:
          <input type="text" name="IPFS1Field" onChange={e => setIPFS1('0x' + web3.utils.soliditySha3(e.target.value))} />
                <br></br>
            </label>
            <button onClick={_newRecord}>Create New Record</button>
            <br></br>
        </div>
    );
}

export default NewRecord;