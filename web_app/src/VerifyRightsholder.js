import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function VerifyRightsholder() {
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");

  var [idxHash, setidxHash] = useState("");
  var [rgtHash, setrgtHash] = useState("");
  var [newIpfs1, setNewIpfs1] = useState("");
  var [txHash, setTxHash] = useState("");
  const _modifyDescription = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      rgtHash,
      newIpfs1
    );

    bulletproof.methods
      ._modIpfs1(idxHash, rgtHash, newIpfs1)
      .send({ from: addr})
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="VRform" onSubmit={_modifyDescription}>
      <h2>Verify</h2>
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
      <input type="radio" value="true" name="verify"/> on blockchain
      <br></br>
      <input type="submit" value="Verify" />
    </form>
  );
}

export default VerifyRightsholder;
