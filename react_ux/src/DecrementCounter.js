//import React, { useState } from "react";
import React from "react";
import "./index.css";

class DecrementCounter extends React.Component {
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
    let count_down = this.state.count_down;
    if (asset_id === "1") {
      alert("Asset id is equal to one.");
    }
    console.log("Form data:");
    console.log("Asset:", asset_id);
    console.log("Rights Holder:", rights_holder);
    console.log("Decrement Amount:", count_down);
  };
  myChangeHandler = (event) => {
    let nam = event.target.name;
    let val = event.target.value;
    this.setState({ [nam]: val });
  };
  render() {
    return (
      <form className="DCform" onSubmit={this.mySubmitHandler}>
        <h2>Countdown{this.state.asset_id}</h2>
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
        <p>Countdown:</p>
        <input
          placeholder="Decrement by..."
          type="text"
          name="count_down"
          onChange={this.myChangeHandler}
          required
        />
        <br />
        <input type="submit" value="Decrement Countdown" />
      </form>
    );
  }
}
export default DecrementCounter;
