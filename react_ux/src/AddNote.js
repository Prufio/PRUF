import React, { Component } from "react";

class AddNote extends Component {
    render() {
      return (
        <div>
          <h2>Add IPFS Note</h2>
          <p>Continue through the steps to add a note to an existing record</p>
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
      <p>IPFS Note:</p>
          <input
          type='text'
          />
          </ol>
        </div>
      );
    }
  }
   
  export default AddNote;