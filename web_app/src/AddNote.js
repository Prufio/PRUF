import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function AddNote() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");

  var [idxHash, setidxHash] = useState("");
  var [rgtHash, setrgtHash] = useState("");
  var [newIpfs2, setNewIpfs2] = useState("");
  var [txHash, setTxHash] = useState("");
  const _addNote = () => {
    console.log(
      //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      rgtHash,
      newIpfs2
    );
    
  let _rgtHash = web3.utils.soliditySha3(idxHash, rgtHash);
    console.log("NewHash", _rgtHash);
    console.log("idxHash", idxHash);

    bulletproof.methods
      .$addIpfs2Note(idxHash, _rgtHash, newIpfs2)
      .send({ from: addr, value: web3.utils.toWei("0.01") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="ANform" onSubmit={_addNote}>
      <h2>Add Note</h2>
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
      IPFS2 (Note)
      <input
        type="text"
        name="NewNoteField"
        placeholder="New IPFS2 Note"
        required
        onChange={(e) => setNewIpfs2("0x" + keccak256(e.target.value))}
      />
      <input type="submit" value="Add Note" />
    </form>
  );
}

export default AddNote;
