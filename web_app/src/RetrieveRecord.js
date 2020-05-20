import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function RetrieveRecord() {
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");
  let web3 = Web3Listener("web3");
  var [idxHash, setidxHash] = useState("");
  var [txHash, setTxHash] = useState("");
  const _retrieveRecord = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
    );

    frontend.methods
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
        onChange={(e) => setidxHash(web3.utils.keccak256(e.target.value))}
      />
      <input type="submit" value="Retrieve Record" />
    </form>
  );
}

export default RetrieveRecord;
