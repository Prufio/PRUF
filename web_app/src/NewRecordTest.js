import React, { useState } from "react";
import Web3Listener from "./Web3Listener";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";

function NewRecordTest() {
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
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);
    var rgtRaw = web3.utils.soliditySha3(first, middle, surname, id, secret);
    var rgtHash = web3.utils.soliditySha3(idxHash, rgtRaw);

    console.log("idxHash", idxHash);
    console.log("New rgtRaw", rgtRaw);
    console.log("New rgtHash", rgtHash);

    frontend.methods
      .$newRecord(idxHash, rgtHash, AssetClass, CountDownStart, Ipfs1)
      .send({ from: addr, value: web3.utils.toWei("0.01") })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
        //Stuff to do when tx confirms
      });
    console.log(txHash);
  };

  return (
    <Form className="NRTform">
      <Form.Row>
        <Form.Group as={Col} controlId="formGridType">
          <Form.Label>Type Of Asset</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Asset Type" 
          required
          onChange={(e) => setType(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridManufacturer">
          <Form.Label>Manufacturer</Form.Label>
          <Form.Control 
          type="text"
          placeholder="Manufacturer" 
          required 
          onChange={(e) => setManufacturer(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridModel">
          <Form.Label>Model Number</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Model" 
          required 
          onChange={(e) => setModel(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridSerial#">
          <Form.Label>Serial Number</Form.Label>
          <Form.Control type="text" 
          placeholder="Serial #" 
          required 
          onChange={(e) => setSerial(e.target.value)}/>
        </Form.Group>
      </Form.Row>

      <Form.Row>
        <Form.Group as={Col} controlId="formGridFirstName">
          <Form.Label>First Name</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="First name" 
          required 
          onChange={(e) => setFirst(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridMiddleName">
          <Form.Label>Middle Name</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Middle Name" 
          required 
          onChange={(e) => setMiddle(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridSurname">
          <Form.Label>Last Name</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Surname" 
          required 
          onChange={(e) => setSurname(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridId">
          <Form.Label>Identification</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Id" 
          required 
          onChange={(e) => setID(e.target.value)}/>
        </Form.Group>
      </Form.Row>

      <Form.Row>
        <Form.Group as={Col} controlId="formGridAssetClass">
          <Form.Label>Asset Class</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Asset Class" 
          required 
          onChange={(e) => setAssetClass(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridLogStartValue">
          <Form.Label>Log Start Value</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Log Start Value" 
          required 
          onChange={(e) => setCountDownStart(e.target.value)}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridDescription">
          <Form.Label>Description</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Description" 
          required 
          onChange={(e) => setIPFS1(web3.utils.soliditySha3(e.target.value))}/>
        </Form.Group>

        <Form.Group as={Col} controlId="formGridPassword">
          <Form.Label>Password</Form.Label>
          <Form.Control 
          type="text" 
          placeholder="Password" 
          required 
          onChange={(e) => setSecret(e.target.value)}/>
        </Form.Group>
      </Form.Row>
      
      {txHash > 0 && ( //conditional rendering
        <Form className="VRresultstest">
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
        </Form>
      )}
      <Form className="btn">
        <input type="button" value="New Record" onClick={_newRecord} />
      </Form>
    </Form>
  );
}

export default NewRecordTest;
