import React, { useState } from "react";
import Web3Listener from "./Web3Listener";
import Web3 from "web3";

function TransferRecord() {
  var web3 = require("web3");
  web3 = new Web3(web3.givenProvider);
  web3.eth.getAccounts().then((e) => setAddr(e[0]));
  let frontend = Web3Listener("frontend");
  let storage = Web3Listener("storage");

  var [txHash, setTxHash] = useState("");

  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");
  var [addr, setAddr] = useState("");

  var [first, setFirst] = useState("");
  var [middle, setMiddle] = useState("");
  var [surname, setSurname] = useState("");
  var [id, setID] = useState("");
  var [secret, setSecret] = useState("");

  var [newFirst, setNewFirst] = useState("");
  var [newMiddle, setNewMiddle] = useState("");
  var [newSurname, setNewSurname] = useState("");
  var [newId, setNewID] = useState("");
  var [newSecret, setNewSecret] = useState("");
  var [resultTemp, setResultTemp] = useState();

    const checkProvenance = () => {
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);
    var rgtRaw = web3.utils.soliditySha3(first, middle, surname, id, secret);
    var rgtHash = web3.utils.soliditySha3(idxHash, rgtRaw);
    var resultCheck;

    console.log(idxHash);
    console.log(rgtHash);

    storage.methods
    ._verifyRightsHolder(idxHash, rgtHash)
    .call({ from: addr }, function(_error, _result){
      setResultTemp(_result);
      console.log("result:", _result);
      })
      console.log("set resultTemp to: ", resultTemp)

  }

  const changeHandle = (value) => {
    checkProvenance()
    return(value);
  }

  const _transferAsset = () => {
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);
    var rgtRaw = web3.utils.soliditySha3(first, middle, surname, id, secret);
    var rgtHash = web3.utils.soliditySha3(idxHash, rgtRaw);
      
    var newRgtRaw = web3.utils.soliditySha3(newFirst, newMiddle, newSurname, newId, newSecret);
    var newRgtHash = web3.utils.soliditySha3(idxHash, newRgtRaw);

    console.log("resultTemp: ",resultTemp);
    console.log("idxHash: ", idxHash);
    console.log("New rgtRaw: ", rgtRaw);
    console.log("New rgtHash: ", rgtHash);

    if (resultTemp === '170'){
    frontend.methods
      .$transferAsset(idxHash, rgtHash, newRgtHash)
      .send({ from: addr, value: web3.utils.toWei("0.01") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
        //Stuff to do when tx confirms
      });
    console.log(txHash);
    }

    else{
      alert("Failed to pair current rights holder with asset");
      //return(console.log("Failed to pair current rights holder with asset"));
    }
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
      <form className="TAform">
        <h2>Transfer Asset</h2>
        Type:
        <input
          type="text"
          name="type"
          placeholder="Type"
          required
          onChange={(e) => setType(changeHandle(e.target.value))}
        />
        <br></br>
        Manufacturer:
        <input
          type="text"
          name="manufacturer"
          placeholder="Manufacturer"
          required
          onChange={(e) => setManufacturer(changeHandle(e.target.value))}
        />
        <br></br>
        Model:
        <input
          type="text"
          name="model"
          placeholder="Model"
          required
          onChange={(e) => setModel(changeHandle(e.target.value))}
        />
        <br></br>
        Serial:
        <input
          type="text"
          name="serial"
          placeholder="Serial Number"
          required
          onChange={(e) => setSerial(changeHandle(e.target.value))}
        />
        <br></br>
        First Name:
        <input
          type="text"
          name="first"
          placeholder="First name"
          required
          onChange={(e) => setFirst(changeHandle(e.target.value))}
        />
        <br></br>
        Middle Name:
        <input
          type="text"
          name="middle"
          placeholder="Middle name"
          required
          onChange={(e) => setMiddle(changeHandle(e.target.value))}
        />
        <br></br>
        Surname:
        <input
          type="text"
          name="surname"
          placeholder="Surname"
          required
          onChange={(e) => setSurname(changeHandle(e.target.value))}
        />
        <br></br>
        ID:
        <input
          type="text"
          name="id"
          placeholder="ID"
          required
          onChange={(e) => setID(changeHandle(e.target.value))}
        />
        <br></br>
        Password:
        <input
          type="text"
          name="secret"
          placeholder="Secret"
          required
          onChange={(e) => setSecret(changeHandle(e.target.value))}
        />
        <br></br>
        New First Name:
        <input
          type="text"
          name="first"
          placeholder="New First name"
          required
          onChange={(e) => setNewFirst(changeHandle(e.target.value))}
        />
        <br></br>
        New Middle Name:
        <input
          type="text"
          name="middle"
          placeholder="New Middle name"
          required
          onChange={(e) => setNewMiddle(changeHandle(e.target.value))}
        />
        <br></br>
        New Surname:
        <input
          type="text"
          name="surname"
          placeholder="New Surname"
          required
          onChange={(e) => setNewSurname(changeHandle(e.target.value))}
        />
        <br></br>
        New ID:
        <input
          type="text"
          name="id"
          placeholder="New ID"
          required
          onChange={(e) => setNewID(changeHandle(e.target.value))}
        />
        <br></br>
        New Password:
        <input
          type="text"
          name="secret"
          placeholder="New Password"
          required
          onChange={(e) => setNewSecret(changeHandle(e.target.value))}
        />
        <br></br>
        <input type="button" value="Transfer Asset" onClick={_transferAsset} />
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

export default TransferRecord;
