import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";

class Ownership extends Component {

  constructor(props){
    super(props);

    this.acctChanger = async () => {
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
        ethereum.on("accountsChanged", function(accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({addr: e[0]}));
      });
      }

    //Component state declaration

    this.state = {
      addr: "",
      error: undefined,
      result: "",
      newOwner: "",
      toggle: false,
      assetClass: "",
      storage: ""
    }

  }

  componentDidMount() {
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({web3: _web3});
    _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
    var addrArray = returnAddresses(); 
    var _storage_addr = addrArray[0];
    const storage_abi = returnStorageAbi();

    const _storage = new _web3.eth.Contract(
    storage_abi, 
    _storage_addr
    );

    this.setState({storage: _storage})

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() { 
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger())
}

  render(){
    const self = this;

    const toggleRenounce = () => {
        if(this.state.toggle === false){this.setState({toggle: true});alert("You are about to renounce the current storage contract. Proceed with caution.")}
        else{this.setState({toggle: false})}
    }

    const renounce = () => {
        this.state.storage.methods
        .renounceOwnership()
        .send({ from: this.state.addr}).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
        .on("receipt", (receipt) => {
          console.log("Ownership renounced")
          console.log("tx receipt: ", receipt)
        });
    
      console.log(this.state.txHash);
    }

    const transfer = () => {
      this.state.storage.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: this.state.addr}).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
        .on("receipt", (receipt) => {
          console.log("Ownership Transferred to: ", self.state.newOwner)
          console.log("tx receipt: ", receipt)
        });
    
      console.log(this.state.txHash);
    };

    return (
      <div>
        {this.state.addr === undefined && (
            <div className="VRresults">
              <h2>WARNING!</h2>
              Injected web3 not connected to form!
            </div>
          )}

        {this.state.addr > 0 && (

        this.state.toggle === false && (
        <form className="ANform">
        <h2>Handle Ownership</h2>
          <p>New Owner:</p>
        <input
          type="text"
          name="authAddr"
          placeholder="address"
          required
          onChange={(e) => this.setState({newOwner: e.target.value})}/>
        <input type="button" value="Transfer" onClick={transfer} /><input type="button" value="Renounce" onClick={toggleRenounce} />
        <br></br>
        </form>)
        )}

        {this.state.addr > 0 && (
        this.state.toggle === true && (
        <form className="ANform">
        <h2>RENOUNCE</h2>
        <p>Are you sure?</p>
        <input type="button" value="Yes, I'm sure" onClick={renounce} /><input type="button" value="Go Back" onClick={toggleRenounce} />
        <br></br>
        </form>)
        )}
        </div>
        );
    }
}
export default Ownership;