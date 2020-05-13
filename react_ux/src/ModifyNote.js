import React, { Component } from "react";

class ModifyNote extends Component {
    render() {
      return (
        <div>
          <h2>Modify IPFS Note</h2>
          <p>Continue through the steps to an existing note on an existing record</p>
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
      <p>New IPFS Note Input:</p>
          <input
          type='text'
          />
          </ol>
        </div>
      );
    }
  }
   
  export default ModifyNote;