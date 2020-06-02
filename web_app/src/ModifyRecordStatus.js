import React, { useState } from "react";
import Web3Listener from "./Web3Listener";
import Web3 from "web3";

function ModifyRecordStatus() {
  var web3 = require("web3");
  web3 = new Web3(web3.givenProvider);
  web3.eth.getAccounts().then((e) => setAddr(e[0]));
  let frontend = Web3Listener("frontend");

  var [status, setStatus] = useState("");
  var [txHash, setTxHash] = useState("");
  var [addr, setAddr] = useState("");

  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");

  var [first, setFirst] = useState("");
  var [middle, setMiddle] = useState("");
  var [surname, setSurname] = useState("");
  var [id, setID] = useState("");
  var [secret, setSecret] = useState("");

  const _modifyStatus = () => {
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);
    var rgtRaw = web3.utils.soliditySha3(first, middle, surname, id, secret);
    var rgtHash = web3.utils.soliditySha3(idxHash, rgtRaw);

    console.log("idxHash", idxHash);
    console.log("New rgtRaw", rgtRaw);
    console.log("New rgtHash", rgtHash);

    frontend.methods
      ._modStatus(idxHash, rgtHash, status)
      .send({ from: addr})
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
        //Stuff to do when tx confirms
      });
    console.log(txHash);
  };

  return (
    <div>
      {addr === undefined && (
          <div className="VRresults">
            <h2>WARNING!</h2>
            Injected web3 not connected to form!
          </div>
        )}
      {addr > 0 && (
      <form className="MRform">
        <h2>Update Record Status</h2>
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
        Stauts:
        <input
          type="text"
          name="StatusField"
          placeholder="Status"
          required
          onChange={(e) => setStatus(e.target.value)}
        />
        <br></br>
        <input type="button" value="Update Status" onClick={_modifyStatus} />
      </form>)}
      {txHash > 0 && ( //conditional rendering
        <div className="VRresults">
          No Errors Reported
          <br></br>
          <br></br>
          <a
            href={"https://kovan.etherscan.io/tx/" + txHash}
            target="_blank"
            rel="noopener noreferrer"
          >
            KOVAN Etherscan:{txHash}
          </a>
        </div>
      )}
    </div>
  );
}

export default ModifyRecordStatus;
