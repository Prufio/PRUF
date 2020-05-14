//import React, { useState } from "react";
import React from "react";
import "./index.css";

class TransferAsset extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      asset_id: "",
      rights_holder: "",
      new_rights_holder: "",
    };
  }
  mySubmitHandler = (event) => {
    event.preventDefault();
    let asset_id = this.state.asset_id;
    let rights_holder = this.state.rights_holder;
    let new_rights_holder = this.state.new_rights_holder;
    if (new_rights_holder === rights_holder) {
      alert("new rights holder cannot be the same as old rights holder");
    }
    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("New Rights Holder:", new_rights_holder);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="TAform" onSubmit={this.mySubmitHandler}>
        <h2>Transfer Asset{this.state.asset_id}</h2>
        <p>Asset ID:</p>
        <input
          placeholder="Enter Asset ID"
          type="text"
          name="asset_id"
          onChange={this.myChangeHandler}
          required
        />
        <p>Rights Holder:</p>
        <input
          placeholder="Rights Holder"
          type="text"
          name="rights_holder"
          onChange={this.myChangeHandler}
          required
        />
        <p>Rights Holder:</p>
        <input
          placeholder="New Rights Holder"
          type="text"
          name="new_rights_holder"
          onChange={this.myChangeHandler}
          required
        />

        <br />
        <input type="submit" value="Transfer Asset" />
      </form>
    );
  }
}
export default TransferAsset;
