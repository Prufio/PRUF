import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function ForceModifyRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");

  var [idxHash, setidxHash] = useState("");
  var [newRgtHash, setNewRgtHash] = useState("");
  var [txHash, setTxHash] = useState("");
  const _forceModifyRecord = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      newRgtHash
    );

    bulletproof.methods
      .$forceModRecord(idxHash, newRgtHash)
      .send({ from: addr, value: web3.utils.toWei("0.01") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="FMRform" onSubmit={_forceModifyRecord}>
      <h2>Modify Record</h2>
      Asset ID:
      <input
        type="text"
        name="idxHashField"
        placeholder="Asset ID"
        required
        onChange={(e) => setidxHash("0x" + keccak256(e.target.value))}
      />
      <br></br>
      New Rights Holder:
      <input
        type="text"
        name="NewRightsHolderField"
        placeholder="New Rights Holder"
        required
        onChange={(e) => setNewRgtHash("0x" + keccak256(e.target.value))}
      />
      <input type="submit" value="New Rights Holder" />
    </form>
  );
}

export default ForceModifyRecord;
