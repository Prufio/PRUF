import React, { useState } from "react";
import Web3Listener from "./Web3Listener";
function RetrieveRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let storage = Web3Listener("storage");

  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");


  var [result, setResult] = useState([]);

  
  const _retrieveRecord = () => {

    var idxHash = (web3.utils.soliditySha3(type, manufacturer, model, serial));

    console.log("idxHash", idxHash);

    storage.methods
      .retrieveRecord(idxHash)
      .call({ from: addr}).then(_result => {setResult(_result);});
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
        onChange={(e) => setType(e.target.value)}
      />
      <br></br>
      Manufacturer:
      <input
        type="text"
        name="manufacturer"
        placeholder="Manufacturer"
        required
        onChange={(e) => setManufacturer(e.target.value)}
      />
      <br></br>
      Model:
      <input
        type="text"
        name="model"
        placeholder="Model"
        required
        onChange={(e) => setModel(e.target.value)} 
      />
      <br></br>
      Serial:
      <input
        type="text"
        name="serial"
        placeholder="Serial Number"
        required
        onChange={(e) => setSerial(e.target.value)} 
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
    Description Hash: {result[8]}
    <br></br>
    Note Hash: {result[9]}
    </div>
  );
}

export default RetrieveRecord;