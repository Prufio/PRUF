import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function RetrieveRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");

  var [idxHash, setidxHash] = useState("");
  var [RH, setRH] = useState("");
  var [AC, setAC] = useState("");
  var [LS, setLS] = useState("");
  var [IPFS1, setIPFS1] = useState("");
  var [txHash, setTxHash] = useState("");

  const _newRecord = () => {
    console.log("Checking with main...");
    console.log("Shipping data: ", idxHash, RH, AC, LS, IPFS1);
    bulletproof.methods
      .$newRecord(idxHash, RH, AC, LS, IPFS1)
      .send({ from: addr, value: web3.utils.toWei("0.04") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="NRform" onSubmit={_newRecord}>
      <h2>New Asset</h2>
        Asset ID:
        <input
          type="text"
          name="idxHashField"
          placeholder='Asset ID'
          required
          onChange={(e) => setidxHash("0x" + keccak256(e.target.value))}
        />
        <br></br>
        Rights Holder:
        <input
          type="text"
          name="RHField"
          onChange={(e) => setRH("0x" + keccak256(e.target.value))}
        />
        <br></br>
        Asset Class:
        <input
          type="text"
          name="ACField"
          onChange={(e) => setAC(e.target.value)}
        />
        <br></br>
        Log Start Value:
        <input
          type="text"
          name="LSField"
          onChange={(e) => setLS(e.target.value)}
        />
        <br></br>
        Description:
        <input
          type="text"
          name="IPFS1Field"
          onChange={(e) => setIPFS1("0x" + keccak256(e.target.value))}
        />
        <br />
        <input type="submit" value="New Record" />
      </form>
  );
}

export default RetrieveRecord;
