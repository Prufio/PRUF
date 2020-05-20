import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function TransferAsset() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");

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

  let _rgtHash = (web3.utils.soliditySha3(idxHash, newRgtHash));
  let _oldRgtHash = (web3.utils.soliditySha3(idxHash, rgtHash));
    console.log('NewHash', _rgtHash);
    console.log('idxHash', idxHash);

    frontend.methods
      .$transferAsset(idxHash, _oldRgtHash, _rgtHash)
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
        onChange={(e) => setidxHash(web3.utils.keccak256(e.target.value))}
      />
      <br></br>
      Rights Holder:
      <input
        type="text"
        name="rgtHashField"
        placeholder="Rights Holder"
        required
        onChange={(e) => setrgtHash(web3.utils.keccak256(e.target.value))}
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
      <input type="submit" value="Transfer Asset" />
    </form>
  );
}

export default TransferAsset;
