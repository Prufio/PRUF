import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";

class NewRecord extends Component {

  constructor(props){
    super(props);

    this.getCosts = async (storage) => {
      const self = this;
      /* var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      var addrArray = returnAddresses(); 
      var _frontend_addr = addrArray[1];
      var _storage_addr = addrArray[0];
      const storage_abi = returnStorageAbi();
      const frontEnd_abi = returnFrontEndAbi();
      const _storage = new _web3.eth.Contract(
        storage_abi, 
        _storage_addr);
      const _frontend = new _web3.eth.Contract(
        frontEnd_abi,
        _frontend_addr); */

      if(self.state.costArray[0] > 0 || self.state.storage === ""){}else{for(var i = 0; i < 1; i++){
      self.state.storage.methods
      .retrieveCosts(3)
      .call({from: self.state.addr}, function(_error, _result){
        if(_error){}
        else{console.log("_result: ", _result);if (_result !== undefined) {self.setState({costArray: Object.values(_result)});}}
       /*  console.log("In getCosts, _result, _error: ", _result, _error) */})
          }
        }
    }
    this.returnsContract = (contract) => {
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      var addrArray = returnAddresses(); 
      var _frontend_addr = addrArray[1];
      var _storage_addr = addrArray[0];
      const storage_abi = returnStorageAbi();
      const frontEnd_abi = returnFrontEndAbi();
      const _storage = new _web3.eth.Contract(
        storage_abi, 
        _storage_addr);
      const _frontend = new _web3.eth.Contract(
        frontEnd_abi,
        _frontend_addr);

        if (contract === 'frontend'){
          return(_frontend);
        }
        else if (contract === 'storage'){
          return(_storage);
        }
    }

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
      result: null,
      costResult: {},
      costArray: [0],
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
      asset: "3",
      cost: "",
      storage: ""
    }

  }

  componentDidMount() {
    this.setState({storage: this.returnsContract("storage")})
    this.setState({frontend: this.returnsContract("frontend")})
    console.log("component mounted")

     var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({web3: _web3});
    _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
    /*var addrArray = returnAddresses(); 
    var _frontend_addr = addrArray[1];
    var _storage_addr = addrArray[0];
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
    this.setState({storage: _storage}) */

    document.addEventListener("accountListener", this.acctChanger()); 
    //this.getCosts();
      
     /*  this.state.storage.methods
      .retrieveCosts(3)
      .call({from: self.state.addr}, function(_error, _result){
        if(_error){}
        else{console.log("_result: ", _result); self.setState({costArray: Object.values(_result)});}
        console.log("In getCosts, _result, _error: ", _result, _error) })
        
        console.log("Cost of TX in CDM: ", this.state.costArray[0]); */
  }

  componentWillUnmount() { 
    console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger())
    document.removeEventListener("costListener", this.getCosts());
}

componentDidUpdate() {
  if(this.state.addr > 0){
  if (this.state.costArray[0] < 1){this.getCosts()}}
}
  render(){
    const self = this;

    async function checkExists(idxHash) { 
      self.state.storage.methods
        .retrieveRecord(idxHash)
        .call({ from: self.state.addr }, function(_error, _result){
          if(_error){self.setState({error: _error.message});self.setState({result: 0})}
          else if (Object.values(_result)[0] === "0x0000000000000000000000000000000000000000000000000000000000000000"){}
          else{self.setState({result: _result});alert("WARNING: Record already exists! Reject in metamask and change asset info.")}
          console.log("In checkExists, _result, _error: ", _result, _error)
    });

    }

    const _newRecord = () => {
      //getCosts();
      let _cost = this.state.costArray[0];
      var idxHash = this.state.web3.utils.soliditySha3(this.state.type, this.state.manufacturer, this.state.model, this.state.serial);
      var rgtRaw = this.state.web3.utils.soliditySha3(this.state.first, this.state.middle, this.state.surname, this.state.id, this.state.secret);
      var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);
      console.log("Cost: ", _cost);
      
      checkExists(idxHash);

      this.state.frontend.methods
        .$newRecord(idxHash, rgtHash, this.state.AssetClass, this.state.CountDownStart, this.state.web3.utils.soliditySha3(this.state.ipfs1))
        .send({from: this.state.addr, value: _cost}).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
        .on("receipt", (receipt) => {
          this.setState({txHash: receipt.transactionHash});
          //Stuff to do when tx confirms
        });
    
      //console.log("txHash",this.state.txHash);
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
        <form className="NRform">
        <h2>New Asset</h2>
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
        First Name:
        <input
          type="text"
          name="first"
          placeholder="First name"
          required
          onChange={(e) => this.setState({first: e.target.value})}
        />
        <br></br>
        Middle Name:
        <input
          type="text"
          name="middle"
          placeholder="Middle name"
          required
          onChange={(e) => this.setState({middle: e.target.value})}
        />
        <br></br>
        Surname:
        <input
          type="text"
          name="surname"
          placeholder="Surname"
          required
          onChange={(e) => this.setState({surname: e.target.value})}
        />
        <br></br>
        ID:
        <input
          type="text"
          name="id"
          placeholder="ID"
          required
          onChange={(e) => this.setState({id: e.target.value})}
        />
        <br></br>
        Password:
        <input
          type="text"
          name="secret"
          placeholder="Secret"
          required
          onChange={(e) => this.setState({secret: e.target.value})}
        />
        <br></br>
        Asset Class:
        <input
          type="text"
          name="AssetClassField"
          placeholder="Asset Class"
          required
          onChange={(e) => this.setState({AssetClass: e.target.value})}
        />
        <br></br>
        Log Start Value:
        <input
          type="text"
          name="CountDownStartField"
          placeholder="Countdown Start"
          required
          onChange={(e) => this.setState({CountDownStart: e.target.value})}
        />
        <br></br>
        Description:
        <input
          type="text"
          name="IPFS1Field"
          placeholder="Description IPFS hash"
          required
          onChange={(e) => this.setState({ipfs1: e.target.value})}
        />
        <br />
        <input type="button" value="New Record" onClick={_newRecord} />
        <br></br>
      </form>
      )}
      {this.state.txHash > 0 && ( //conditional rendering
        <div className="VRresults">
          {this.state.NRerror !== undefined && (
            <div>
              ERROR! Please check etherscan
              <br></br>
              {this.state.NRerror.message}
            </div>
            )}
            {this.state.NRerror === undefined && (<div> No Errors Reported </div>)}
          <br></br>
          <br></br>
          <a
            href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
            target="_blank"
            rel="noopener noreferrer"
          >
            KOVAN Etherscan:{this.state.txHash}
          </a>
        </div>
      )}
    </div>
  )}
}

export default NewRecord;