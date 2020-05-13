import React, { Component } from "react";

class ModifyRecordStatus extends Component {
    render() {
      return (
        <div>
          <h2>Modify Record Status</h2>
          <p>Continue through the steps to modify the status of an exisiting record</p>
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
      <p>Record Status:</p>
          <input
          type='text'
          />
          </ol>
        </div>
      );
    }
  }
   
  export default ModifyRecordStatus;