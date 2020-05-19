import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function ModifyRecordStatus() {
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");

  var [idxHash, setidxHash] = useState("");
  var [rgtHash, setrgtHash] = useState("");
  var [_status, setNewStatus] = useState("");
  var [txHash, setTxHash] = useState("");
  const _modifyRecordStatus = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      rgtHash,
      _status
    );

    bulletproof.methods
      ._modStatus(idxHash, rgtHash, _status)
      .send({ from: addr})
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="MRform" onSubmit={_modifyRecordStatus}>
      <h2>Update Status</h2>
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
      New Status:
      <input
        type="text"
        name="NewStatusField"
        placeholder="New Status"
        required
        onChange={(e) => setNewStatus(e.target.value)}
      />
      <input type="submit" value="Modify Record Status" />
    </form>
  );
}

export default ModifyRecordStatus;

//BROKEN

