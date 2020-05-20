import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function ForceModifyRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");

  var [idxHash, setidxHash] = useState("");
  var [newRgtHash, setNewRgtHash] = useState("");
  var [txHash, setTxHash] = useState("");
  const _forceModifyRecord = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      newRgtHash
    );
  
  let _rgtHash = (web3.utils.soliditySha3(idxHash, newRgtHash));
    console.log('NewHash', _rgtHash);
    console.log('idxHash', idxHash);

    frontend.methods
      .$forceModRecord(idxHash, _rgtHash)
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
        onChange={(e) => setidxHash(web3.utils.keccak256(e.target.value))}
      />
      <br></br>
      New Rights Holder:
      <input
        type="text"
        name="NewRightsHolderField"
        placeholder="New Rights Holder"
        required
        onChange={(e) => setNewRgtHash(web3.utils.keccak256(e.target.value))}
      />
      <input type="submit" value="Modify Record" />
    </form>
  );
}

export default ForceModifyRecord;
