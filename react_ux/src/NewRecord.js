import React, { Component } from "react";
 
class NewRecord extends Component {
  render() {
    return (
      <div>
        <h2>New Record</h2>
        <p>Continue through the steps to register your asset with it's own unique key</p>
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
    <p>Asset Class</p>
        <input
        type='text'
        />
        <br></br>
    <p>Countdown Start</p>
        <input
        type='text'
        />
        <br></br>
    <p>IPFS</p>
        <input
        type='text'
        />
        </ol>
      </div>
    );
  }
}
 
export default NewRecord;