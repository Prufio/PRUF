//import React, { useState } from "react";
import React from "react";
import {senderAddress} from "./Main";
import "./index.css";
import Web3 from "web3";
import returnAbi from "./abi";
import returnSAbi from "./sAbi";

function sendNewRecord(
  tx_val,
  asset_id,
  rights_holder,
  asset_class,
  count_down,
  asset_IPFS1
) {
  let web3 = require("web3");
  const keccak256 = require("js-sha3").keccak256;
  const bulletproof_frontend_addr =
    "0xD097ce9cC3f8402a7311c576c60f7CeE44baf711";

  const bulletproof_storage_addr = 
    "0x124B7F075b9b18aCd8Fb1C7C4c14A5EA959dDB82";

  web3 = new Web3(web3.givenProvider);
  //var [txHash, setTxHash] = useState('');
  var txHash;


  const myAbi = returnAbi();
  const sAbi = returnSAbi();
  const bulletproof = new web3.eth.Contract(myAbi, bulletproof_frontend_addr);
  const storage = new web3.eth.Contract(sAbi, bulletproof_storage_addr);

  console.log("Adding new asset...");
  console.log("Using data: ", asset_id, rights_holder, asset_class, count_down, asset_IPFS1);
  bulletproof.methods
    .$newRecord(asset_id, rights_holder, asset_class, count_down, asset_IPFS1)
    .send({ from: senderAddress, value: web3.utils.toWei(tx_val) })
    .then((_txHash) => txHash);
}

class NewRecord extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      asset_id: "",
      rights_holder: "",
      asset_class: "",
      count_down: "",
      asset_IPFS1: "",
    };
  }
  mySubmitHandler = (event) => {
    event.preventDefault();
    let asset_id = this.state.asset_id;
    let rights_holder = this.state.rights_holder;
    let asset_class = this.state.asset_class;
    let count_down = this.state.count_down;
    let asset_IPFS1 = this.state.asset_IPFS1;

    if (asset_id !== "0") {
      var addr = ''; //MUST GET ADDRESS FROM Main.js
      sendNewRecord(
        addr, 
        '0.04',
        asset_id,
        rights_holder,
        asset_class,
        count_down,
        asset_IPFS1
      )
    }

    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("Asset Class:", asset_class);
    console.log("Countdown Start:", count_down);
    console.log("Asset IPFS Tag:", asset_IPFS1);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="NRform" onSubmit={this.mySubmitHandler}>
        <h2>New Asset{this.state.asset_id}</h2>
        Asset ID:
        <input
          placeholder="Enter Asset ID"
          type="text"
          name="asset_id"
          onChange={this.myChangeHandler}
          required
        />
        Rights Holder:
        <input
          placeholder="Rights Holder"
          type="text"
          name="rights_holder"
          onChange={this.myChangeHandler}
          required
        />
        Asset Class:
        <input
          placeholder="Asset Class"
          type="text"
          name="asset_class"
          onChange={this.myChangeHandler}
          required
        />
        {/* <label form="asset_class">Asset Class:</label>
          <select id="asset_class" name="asset_class">
            <option asset_class="1">Firearms</option>
            <option asset_class="2">NFA/AOW</option>
            <option asset_class="3">Special</option>
        </select> */}
        Countdown:
        <input
          placeholder="Countdown Start"
          type="text"
          name="count_down"
          onChange={this.myChangeHandler}
          required
        />
        IPFS1 (Description):
        <input
          placeholder="IPFS Resource"
          type="text"
          name="asset_IPFS1"
          onChange={this.myChangeHandler}
          required
        />
        <p>
          I am an authorized licenseholder associated with this account, and I
          certify that the possesor of this asset is the owner of record.
        </p>
        <input type="submit" value="Create New Record" />
      </form>
    );
  }
}

export default NewRecord;
