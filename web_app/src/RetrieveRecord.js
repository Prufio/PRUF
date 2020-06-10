import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import Web3 from "web3";

class ModifyDescription extends React.Component {

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
      NRerror: undefined,
      result: [],
      AssetClass: "",
      CountDownStart: "",
      ipfs1: "",
      txHash: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      web3: null,
      frontend: "",
      storage: ""
    }

  }

  componentDidMount() {
    console.log("component mounted")
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({web3: _web3});
    _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
    var _frontend_addr = "0x2E70fB5908C6541d13Ac356D0C1AEc4C59fb6F75";
    
    var _storage_addr = "0x37259b5A5FbAC8D855d1283a7F5D542208Bd9412";

    const frontEnd_abi = returnFrontEndAbi();
    const storage_abi = returnStorageAbi();

    const _frontend = new _web3.eth.Contract(
    frontEnd_abi,
    _frontend_addr
    );

    const _storage = new _web3.eth.Contract(
    storage_abi, 
    _storage_addr
    );
    this.setState({frontend: _frontend})
    this.setState({storage: _storage})

    document.addEventListener("accountListener", this.acctChanger());

  }

  componentWillUnmount() { 
    console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger())
}

  render(){
    const self = this;
    const _retrieveRecord = () => {
      var idxHash = this.state.web3.utils.soliditySha3(this.state.type, this.state.manufacturer, this.state.model, this.state.serial);
  
      console.log("idxHash", idxHash);
      console.log("addr: ", this.state.addr);

      this.state.storage.methods
      .retrieveRecord(idxHash)
      .call({ from: this.state.addr }, function(_error, _result){
        if(_error){self.setState({error: _error});self.setState({result: 0})}
        else{self.setState({result: _result});self.setState({error: undefined})}
    });
    
      console.log(this.state.result);
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
          <form className="RRform">
          <h2>Search for Record</h2>
          Type:
          <input
            type="text"
            name="type"
            placeholder="Type"
            required
            onChange={(e) => this.setState({type: e.target.value})}
          />
          <br></br>
          Manufacturer:
          <input
            type="text"
            name="manufacturer"
            placeholder="Manufacturer"
            required
            onChange={(e) => this.setState({manufacturer: e.target.value})}
          />
          <br></br>
          Model:
          <input
            type="text"
            name="model"
            placeholder="Model"
            required
            onChange={(e) => this.setState({model: e.target.value})}
          />
          <br></br>
          Serial:
          <input
            type="text"
            name="serial"
            placeholder="Serial Number"
            required
            onChange={(e) => this.setState({serial: e.target.value})}
          />
          <br></br>
          <input
            type="button"
            value="Retrieve Record"
            onClick={_retrieveRecord}
          />
        </form>
        )}
        {this.state.error !== undefined && (
          <div className="RRresults">
            ERROR: {this.state.error.message}
            <br></br>
          </div>
        )}
        {this.state.result > 0 && (
          <div className="RRresults">
          {this.state.result}
          </div>
        )}
        {this.state.result[5] > 0 && ( //conditional rendering
          <div className="RRresults">
            Status:
            {this.state.result[3]}
            <br></br>
            Mod Count:
            {this.state.result[4]}
            <br></br>
            Asset Class :{this.state.result[5]}
            <br></br>
            Count :{this.state.result[6]} of {this.state.result[7]}
            <br></br>
            <br></br>
            Description Hash :<br></br>
            {this.state.result[8]}
            <br></br>
            <br></br>
            Note Hash :<br></br>
            {this.state.result[9]}
            <br></br>
            <br></br>
            Token ID :<br></br>
            {this.state.result[1]}
          </div>
        )}
      </div>
    )}
}

export default ModifyDescription;
