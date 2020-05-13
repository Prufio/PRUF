import React, { Component } from "react";

class ForceModifyRecord extends Component {
    render() {
      return (
        <div>
          <h2>Force Modify Record</h2>
          <p>Continue through the steps to Forcefully modify an existing record</p>
          <ol>
      <p>IDX:</p>
          <input
          type='text'
          />
      <br></br>
      <p>New Regristrant:</p>
          <input
           type='text'
          />
          </ol>
        </div>
      );
    }
  }
   
  export default ForceModifyRecord;