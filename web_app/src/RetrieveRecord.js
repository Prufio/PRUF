import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function RetrieveRecord() {
  let addr = Web3Listener("addr");
  let storage = Web3Listener("storage");
  var [idxHash, setidxHash] = useState("");
  var [result, setResult] = useState([]);
  const _retrieveRecord = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
    );

    storage.methods
      .retrieveRecord(idxHash)
      .call({ from: addr}).then(_result => {setResult(_result);});
    console.log(result[0]);
  };

  return (
    <div>
    <form className="RRform" onSubmit={_retrieveRecord}>
      <h2>Search for Record</h2>
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
    <br></br>
    Status: {result[3]}
    <br></br>
    Force Mod Count: {result[4]}
    <br></br>
    Asset Class: {result[5]}
    <br></br>
    Count Down Status: {result[6]}
    <br></br>
    NotesHashKey: {result[8]}
    <br></br>
    InscriptionKey: {result[9]}
    </div>
  );
}

export default RetrieveRecord;
