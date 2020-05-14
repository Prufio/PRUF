//import React, { useState } from "react";
import React from "react";
import "./index.css";

class ForceModifyRecord extends React.Component {
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
    let new_rights_holder = this.state.new_rights_holder;
    if (asset_id === "1") {
      alert("Asset id is equal to one.");
    }
    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("New Rights Holder:", new_rights_holder);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="FMRform" onSubmit={this.mySubmitHandler}>
        <h2>MODIFY RECORD{this.state.asset_id}</h2>
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
          placeholder="New Rights Holder"
          type="text"
          name="new_rights_holder"
          onChange={this.myChangeHandler}
          required
        />
        <p>
          I am an authorized licenseholder associated with this account, and I
          certify that the possesor of this asset is the owner of record.
        </p>

        <input type="submit" value="I AGREE" />
      </form>
    );
  }
}

export default ForceModifyRecord;
