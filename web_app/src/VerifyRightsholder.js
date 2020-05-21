import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function VerifyRightsholder() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let storage = Web3Listener("storage");

  var [txHash, setTxHash] = useState("");
  var [txLink, setTxLink] = useState("");

  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");

  var [first, setFirst] = useState("");
  var [middle, setMiddle] = useState("");
  var [surname, setSurname] = useState("");
  var [id, setID] = useState("");
  var [secret, setSecret] = useState("");

  var [result, setResult] = useState("");

  const _verify = () => {
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);
    var rgtRaw = web3.utils.soliditySha3(first, middle, surname, id, secret);
    var rgtHash = web3.utils.soliditySha3(idxHash, rgtRaw);

    console.log("idxHash", idxHash);
    console.log("New rgtRaw", rgtRaw);
    console.log("New rgtHash", rgtHash);

    storage.methods
      .blockchainVerifyRightsHolder(idxHash, rgtHash)
      .send({ from: addr, value: web3.utils.toWei("0.00") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
       //Stuff to do here when tx confirmed?
      });

    console.log(txHash);

    storage.methods
      ._verifyRightsHolder(idxHash, rgtHash)
      .call({ from: addr })
      .then((_result) => {
        setResult(_result);
      });
  };

  return (
    <div>
      <form className="VRform">
        <h2>Verify Provenance</h2>
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
        <input
          type="button"
          value="Verify"
          onClick={_verify}
        />
      </form>

      {txHash > 0 && ( //conditional rendering
        <div className="VRresults">
          {result === "170"? ('Match Confirmed') : ('No match found')}
          <br></br>
          <br></br>
          <a href={"https://kovan.etherscan.io/tx/"+txHash}>Etherscan:{txHash}</a>
        </div>
      )}
    </div>
  );
}

export default VerifyRightsholder;
