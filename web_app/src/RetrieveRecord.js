import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function RetrieveRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let storage = Web3Listener("storage");
  var [result, setResult] = useState([]);
  var [idxHash, setIdxHash] = useState("");

  const indexDoctor = (e) => {
    _setIndex({
      ..._index,
      [e.target.name]: e.target.value
    });
    console.log(_index.type, _index.manufacturer, _index.model, _index.serial);
    setIdxHash(web3.utils.soliditySha3(_index.type, _index.manufacturer, _index.model, _index.serial))
}
const [_index, _setIndex] = useState({
  type:'',
  manufacturer:'',
  model:'',
  serial:''
})

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
    <form className="RRform">
      <h2>Search for Record</h2>
      Type:
      <input
        type="text"
        name="type"
        placeholder="Type"
        required
        onChange={(e) => indexDoctor(e)}
      />
      <br></br>
      Manufacturer:
      <input
        type="text"
        name="manufacturer"
        placeholder="Manufacturer"
        required
        onChange={(e) => indexDoctor(e)}
      />
      <br></br>
      Model:
      <input
        type="text"
        name="model"
        placeholder="Model"
        required
        onChange={(e) => indexDoctor(e)}
      />
      <br></br>
      Serial:
      <input
        type="text"
        name="serial"
        placeholder="Serial Number"
        required
      />
      <br></br>
      <input type="button" value="Retrieve Record"  onClick={_retrieveRecord}/>
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