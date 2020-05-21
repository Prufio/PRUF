import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function AddNote() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");

  var [Ipfs2, setIPFS2] = useState("");
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

  const _addNote = () => {
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);
    var rgtRaw = web3.utils.soliditySha3(first, middle, surname, id, secret);
    var rgtHash = web3.utils.soliditySha3(idxHash, rgtRaw);

    console.log("idxHash", idxHash);
    console.log("New rgtRaw", rgtRaw);
    console.log("New rgtHash", rgtHash);

    frontend.methods
      .$addIpfs2Note(idxHash, rgtHash, Ipfs2)
      .send({ from: addr, value: web3.utils.toWei("0.01") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
        //Stuff to do when tx confirms
      });
    console.log(txHash);
  };

  return (
    <div>
      <form className="ANform">
        <h2>Add Permanent Note</h2>
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
        Description:
        <input
          type="text"
          name="IPFS2Field"
          placeholder="Permanent Note"
          required
          onChange={(e) => setIPFS2(web3.utils.soliditySha3(e.target.value))}
        />
        <br />
        <input type="button" value="Add Note" onClick={_addNote} />
      </form>
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

export default AddNote;
