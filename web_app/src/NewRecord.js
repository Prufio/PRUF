//import React, { useState } from "react";
import React from "react";
import {keccak256} from "js-sha3";
import Main, {senderAddress, newRecordPack} from "./Main";
import "./index.css";

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

    if(asset_id != 0){
    newRecordPack(asset_id, rights_holder, asset_class, count_down, asset_IPFS1, "0.04");
    }

    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("Asset Class:", asset_class);
    console.log("Countdown Start:", count_down);
    console.log("Asset IPFS Tag:", asset_IPFS1);
  };
  myChangeHandler = (event) => {
    let _name = event.target.name;
    let _value = event.target.value;
    this.setState({ [_name]: "0x" + keccak256(_value) });
  };

  myNoHashHandler = (event) => {
    let _name = event.target.name;
    let _value = event.target.value;
    this.setState({ [_name]: _value });
  }
  render() {
    return (
      <form className="NRform" onSubmit={this.mySubmitHandler}>
        <h2>New Asset{}</h2>
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
          onChange={this.myNoHashHandler}
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
          onChange={this.myNoHashHandler}
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
