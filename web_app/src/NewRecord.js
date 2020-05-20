import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function NewRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");

  var [AssetClass, setAssetClass] = useState("");
  var [CountDownStart, setCountDownStart] = useState("");
  var [Ipfs1, setIPFS1] = useState("");
  var [txHash, setTxHash] = useState("");

  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");

  var [first, setFirst] = useState("");
  var [middle, setMiddle] = useState("");
  var [surname, setSurname] = useState("");
  var [id, setID] = useState("");
  var [secret, setSecret] = useState("");

  
  const _newRecord = () => {

    var idxHash = (web3.utils.soliditySha3(type, manufacturer, model, serial));
    var rgtRaw = (web3.utils.soliditySha3(first, middle, surname, id, secret));
    var rgtHash = (web3.utils.soliditySha3(idxHash, rgtRaw));

    console.log("idxHash", idxHash);
    console.log("New rgtRaw", rgtRaw);
    console.log("New rgtHash", rgtHash);

    frontend.methods
      .$newRecord(idxHash, rgtHash, AssetClass, CountDownStart, Ipfs1)
      .send({ from: addr, value: web3.utils.toWei("0.01") })

      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="NRform">
      <h2>New Asset</h2>
      {addr}
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
      First Name:
      <input
        type="text"
        name="first"
        placeholder="First name"
        required
        onChange={(e) => setFirst(e.target.value)}
      />
      <br></br>
      Middle Name:
      <input
        type="text"
        name="middle"
        placeholder="Middle name"
        required
        onChange={(e) => setMiddle(e.target.value)}
      />
      <br></br>
      Surname:
      <input
        type="text"
        name="surname"
        placeholder="Surname"
        required
        onChange={(e) => setSurname(e.target.value)}
      />
      <br></br>
      ID:
      <input
        type="text"
        name="id"
        placeholder="ID"
        required
        onChange={(e) => setID(e.target.value)}
      />
      <br></br>
      Password:
      <input
        type="text"
        name="secret"
        placeholder="Secret"
        required
        onChange={(e) => setSecret(e.target.value)}
      />
      <br></br>
      Asset Class:
      <input
        type="text"
        name="AssetClassField"
        placeholder="Asset Class"
        required
        onChange={(e) => setAssetClass(e.target.value)}
      />
      <br></br>
      Log Start Value:
      <input
        type="text"
        name="CountDownStartField"
        placeholder="Countdown Start"
        required
        onChange={(e) => setCountDownStart(e.target.value)}
      />
      <br></br>
      Description:
      <input
        type="text"
        name="IPFS1Field"
        placeholder="Description IPFS hash"
        required
        onChange={(e) => setIPFS1(web3.utils.soliditySha3(e.target.value))}
      />
      <br />
      <input type="button" value="New Record" onClick={_newRecord} />
    </form>
  );
}

export default NewRecord;
