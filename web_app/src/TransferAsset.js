import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function TransferAsset() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");

  var [idxHash, setidxHash] = useState("");
  var [rgtHash, setrgtHash] = useState("");
  var [newRgtHash, setNewRgtHash] = useState("");
  var [txHash, setTxHash] = useState("");
  const _transferAsset = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      rgtHash,
      newRgtHash
    );

    bulletproof.methods
      .$transferAsset(idxHash, rgtHash, newRgtHash)
      .send({ from: addr, value: web3.utils.toWei("0.01") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="TAform" onSubmit={_transferAsset}>
      <h2>Transfer Asset</h2>
      Asset ID:
      <input
        type="text"
        name="idxHashField"
        placeholder="Asset ID"
        required
        onChange={(e) => setidxHash("0x" + keccak256(e.target.value))}
      />
      <br></br>
      Rights Holder:
      <input
        type="text"
        name="rgtHashField"
        placeholder="Rights Holder"
        required
        onChange={(e) => setrgtHash("0x" + keccak256(e.target.value))}
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
      <input type="submit" value="Transfer Asset" />
    </form>
  );
}

export default TransferAsset;
