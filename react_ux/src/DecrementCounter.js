import React, { Component } from "react";

class DecrementCounter extends Component {
    render() {
      return (
        <div>
          <h2>Decrement Counter</h2>
          <p>Continue through the steps to decrement your asset's countdown number</p>
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
      <p>Decrement Amount:</p>
          <input
          type='text'
          />
          </ol>
        </div>
      );
    }
  }
   
  export default DecrementCounter;