import React, {useState} from "react";
import "./index.css";

class Transfer extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        asset_id: '',
        rights_holder: '',
      };
    }
    mySubmitHandler = (event) => {
      event.preventDefault();
      let asset_id = this.state.asset_id;
      let rights_holder = this.state.rights_holder;
      if (asset_id === '1' ) {
        alert("Asset id is equal to one.");
      }
      console.log ('Form data:');
      console.log ('Asset:' , asset_id);
      console.log ('Rights Holder:' , rights_holder);
  
    }
    myChangeHandler = (event) => {
      let nam = event.target.name;
      let val = event.target.value;
      this.setState({[nam]: val});
    }
    render() {
      return (
        <form onSubmit={this.mySubmitHandler}>
        {/* <h1>Hello {this.state.username} {this.state.age}</h1> */}
        <p>Asset ID:</p>
        <input
          type='text'
          name='asset_id'
          onChange={this.myChangeHandler}
        />
        <p>Rights Holder:</p>
        <input
          type='text'
          name='rights_holder'
          onChange={this.myChangeHandler}
        />
        <br/>
        <br/>
        <input type='submit' />
        </form>
      );
    }
}

  export default Transfer;