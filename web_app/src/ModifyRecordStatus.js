//import React, { useState } from "react";
import React from "react";
import "./index.css";

class ModifyRecordStatus extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      asset_id: "",
      rights_holder: "",
      status: "",
    };
  }
  mySubmitHandler = (event) => {
    event.preventDefault();
    let asset_id = this.state.asset_id;
    let rights_holder = this.state.rights_holder;
    let status = this.state.status;
    if (asset_id === "1") {
      alert("Asset id is equal to one.");
    }
    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("New Status:", status);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="USform" onSubmit={this.mySubmitHandler}>
        <h2>New Status{this.state.asset_id}</h2>
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
        Updated Status:
        <input
          placeholder="Enter New Status"
          type="text"
          name="status"
          onChange={this.myChangeHandler}
          required
        />
        {/* <label form="asset_class">Asset Class:</label>
          <select id="asset_class" name="asset_class">
            <option asset_class="1">Firearms</option>
            <option asset_class="2">NFA/AOW</option>
            <option asset_class="3">Special</option>
          </select> */}

        <br />
        <input type="submit" value="Update Status" />
      </form>
    );
  }
}

export default ModifyRecordStatus;
