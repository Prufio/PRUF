import React, { Component } from "react";

class RetrieveRecord extends Component {
    render() {
      return (
        <div>
          <h2>Retrieve Record</h2>
          <p>Continue through the steps to retrieve record information of a specific asset</p>
          <ol>
      <p>IDX Hash:</p>
          <input
          type='text'
          />
          </ol>
        </div>
      );
    }
  }
   
  export default RetrieveRecord;