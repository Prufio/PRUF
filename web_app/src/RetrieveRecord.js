//import React, { useState } from "react";
import React from "react";
import "./index.css";

class RetrieveRecord extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      asset_id: "",
      rights_holder: "",
      status: "",
      count_down: "",
      asset_IPFS1: "",
      asset_IPFS2: "",
    };
  }
  mySubmitHandler = (event) => {
    event.preventDefault();
    let asset_id = this.state.asset_id;
    let rights_holder = this.state.rights_holder;
    let status = this.state.status;
    let count_down = this.state.count_down;
    let asset_IPFS1 = this.state.asset_IPFS1;
    let asset_IPFS2 = this.state.asset_IPFS2;
    if (asset_id === "1") {
      //do stuff
      alert("Asset id is equal to one.");
    }

    console.log("Asset data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("status:", status);
    console.log("Count:", count_down);
    console.log("Asset IPFS description:", asset_IPFS1);
    console.log("Asset IPFS note:", asset_IPFS2);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="RRform" onSubmit={this.mySubmitHandler}>
        <h2>Search{this.state.asset_id}</h2>
        Asset ID:
        <input
          placeholder="Enter Asset ID"
          type="text"
          name="asset_id"
          onChange={this.myChangeHandler}
          required
        />

        <br />
        <input type="submit" value="Retrieve Record" />
      </form>
    );
  }
}

export default RetrieveRecord;
