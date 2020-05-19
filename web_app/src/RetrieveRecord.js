import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function RetrieveRecord() {
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");

  var [idxHash, setidxHash] = useState("");
  var [txHash, setTxHash] = useState("");
  const _retrieveRecord = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
    );

    bulletproof.methods
      .retrieveRecord(idxHash)
      .send({ from: addr})
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="RRform" onSubmit={_retrieveRecord}>
      <h2>Transfer Asset</h2>
      Asset ID:
      <input
        type="text"
        name="idxHashField"
        placeholder="Asset ID"
        required
        onChange={(e) => setidxHash("0x" + keccak256(e.target.value))}
      />
      <input type="submit" value="Retrieve Record" />
    </form>
  );
}

export default RetrieveRecord;
