import React, { Component } from "react";

class TransferAsset extends Component {
    render() {
      return (
        <div>
          <h2>Transfer Asset</h2>
          <p>Continue through the steps to transfer the ownership of an existing record</p>
          <ol>
      <p>IDX:</p>
          <input
          type='text'
          />
      <br></br>
      <p>Regristrant:</p>
          <input
           type='text'
          />
      <br></br>
      <p>New Registrant:</p>
          <input
          type='text'
          />
          </ol>
        </div>
      );
    }
  }
   
  export default TransferAsset;