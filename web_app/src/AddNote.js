//import React, { useState } from "react";
import React from "react";
import "./index.css";

class AddNote extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      asset_id: "",
      rights_holder: "",
      asset_IPFS2: "",
    };
  }
  mySubmitHandler = (event) => {
    event.preventDefault();
    let asset_id = this.state.asset_id;
    let rights_holder = this.state.rights_holder;
    let asset_IPFS2 = this.state.asset_IPFS2;
    if (asset_id === "1") {
      alert("Asset id is equal to one.");
    }
    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("Asset IPFS Tag:", asset_IPFS2);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="ANform" onSubmit={this.mySubmitHandler}>
        <h2>Add Note{this.state.asset_id}</h2>
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
        <p>IPFS2 (Note):</p>
        <input
          placeholder="IPFS Resource (NOTE)"
          type="text"
          name="asset_IPFS2"
          onChange={this.myChangeHandler}
          required
        />
        <p>
          This will add a permanant note to this record. Once it has been
          submitted, it cannot be changed
        </p>

        <input type="submit" value="Add Note Permanantly" />
      </form>
    );
  }
}

export default AddNote;
