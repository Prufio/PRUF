import React, {useState} from "react";
import "./index.css";

class NewRecord extends React.Component {
    constructor(props) {
      super(props);
      this.state = {
        asset_id: '',
        rights_holder: '',
        asset_class: '',
        count_down: '',
        IPFS1: '',
      };
    }
    mySubmitHandler = (event) => {
      event.preventDefault();
      let asset_id = this.state.asset_id;
      let rights_holder = this.state.rights_holder;
      let asset_class = this.state.asset_class;
      let count_down = this.state.count_down;
      let asset_IPFS1 = this.state.asset_IPFS1;
      if (asset_id === '1' ) {
        alert("Asset id is equal to one.");
      }
      console.log ('Form data:');
      console.log ('Asset:' , asset_id);
      console.log ('Rights Holder:' , rights_holder);
      console.log ('Asset Class:' , asset_class);
      console.log ('Countdown Start:' , count_down);
      console.log ('Asset IPFS Tag:' , asset_IPFS1);
  
    }
    myChangeHandler = (event) => {
      let nam = event.target.name;
      let val = event.target.value;
      this.setState({[nam]: val});
    }
    render() {
      return (
        <form onSubmit={this.mySubmitHandler}>
         <h1>Create record {this.state.asset_id}</h1>
        Asset ID:
        <input
          type='text'
          name='asset_id'
          onChange={this.myChangeHandler}
        />
        Rights Holder:
        <input
          type='text'
          name='rights_holder'
          onChange={this.myChangeHandler}
        />
        Asset Class:
        <input
          type='text'
          name='asset_class'
          onChange={this.myChangeHandler}
        />
        Countdown:
        <input
          type='text'
          name='countdown_start'
          onChange={this.myChangeHandler}
        />
        IPFS1 (Description):
        <input
          type='text'
          name='asset_IPFS1'
          onChange={this.myChangeHandler}
        />
        <br/>
        <br/>
        <input type='submit' />
        </form>
      );
    }
}

export default NewRecord;