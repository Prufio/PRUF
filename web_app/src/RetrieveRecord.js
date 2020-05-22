import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function RetrieveRecord() {
  let web3 = Web3Listener("web3");
  web3.eth.getAccounts().then((e) => setAddr(e[0]));
  let storage = Web3Listener("storage");

  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");
  var [addr, setAddr] = useState("");
  var [error, setError] = useState(['0']);
  var [result, setResult] = useState([]);

  const _retrieveRecord = () => {
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);

    console.log("idxHash", idxHash);

    storage.methods
      .retrieveRecord(idxHash)
      .call({ from: addr }, function(error, _result){
        if(error){setError(error)}
        else{setResult(_result)}
  });
  }
  return (
    <div>
      
      {addr === undefined && (
          <div className="VRresults">
            <h2>WARNING!</h2>
            Injected web3 not connected to form!
          </div>
        )}

      {addr > 0 && (
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
        <input
          type="button"
          value="Retrieve Record"
          onClick={_retrieveRecord}
        />
      </form>
      )}
      {error != '0' && (
        <div className="RRresults">
          ERROR: {error.message}
          <br></br>
        </div>
      )}
      {result > 0 && (
        <div className="RRresults">
        {result}
        </div>
      )}
      {result[5] > 0 && ( //conditional rendering
        <div className="RRresults">
          Status:
          {result[3]}
          <br></br>
          Mod Count:
          {result[4]}
          <br></br>
          Asset Class :{result[5]}
          <br></br>
          Count :{result[6]} of {result[7]}
          <br></br>
          <br></br>
          Description Hash :<br></br>
          {result[8]}
          <br></br>
          <br></br>
          Note Hash :<br></br>
          {result[9]}
          <br></br>
          <br></br>
          Token ID :<br></br>
          {result[1]}
        </div>
      )}
    </div>
  );
}

export default RetrieveRecord;
