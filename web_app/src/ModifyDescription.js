//import React, { useState } from "react";
import React from "react";
import "./index.css";

class ModifyDescription extends React.Component {
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
    let asset_IPFS1 = this.state.asset_IPFS1;
    if (asset_id === "1") {
      alert("Asset id is equal to one.");
    }
    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("Asset IPFS Tag:", asset_IPFS1);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="MDform" onSubmit={this.mySubmitHandler}>
        <h2>Description{this.state.asset_id}</h2>
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
        IPFS1 (Description):
        <input
          placeholder="IPFS Resource (Desc)"
          type="text"
          name="asset_IPFS1"
          onChange={this.myChangeHandler}
          required
        />

        <br />
        <input type="submit" value="Update Description" />
      </form>
    );
  }
}

export default ModifyDescription;
