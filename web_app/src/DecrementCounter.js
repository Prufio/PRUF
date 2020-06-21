import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";

class DecrementCounter extends Component {

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
      result: "",
      AssetClass: "",
      CountDownStart: "",
      CountDown: "",
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
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({web3: _web3});
    _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
    var addrArray = returnAddresses(); 
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
    this.setState({storage: _storage})

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() { 
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger())
}

  render(){
    const self = this;

    async function checkExists(idxHash) { 
      await self.state.storage.methods
        .retrieveRecord(idxHash)
        .call({ from: self.state.addr }, function(_error, _result){
          if(_error){self.setState({error: _error});self.setState({result: 0});alert("WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields.")}
          else{self.setState({result: _result})}
          console.log("check debug, _result, _error: ", _result, _error)
    });

    }

    async function checkMatch(idxHash, rgtHash) { 
      await self.state.storage.methods
        ._verifyRightsHolder(idxHash, rgtHash)
        .call({ from: self.state.addr }, function(_error, _result){
          if(_error){self.setState({error: _error})}
          else if(_result === "0"){;self.setState({result: 0});alert("WARNING: Record DOES NOT MATCH supplied owner info! Reject in metamask and review owner info fields.")}
          else{self.setState({result: _result});}
          console.log("check debug, _result, _error: ", _result, _error)
    });
    }

    const _decrementCounter = () => {
      var idxHash = this.state.web3.utils.soliditySha3(this.state.type, this.state.manufacturer, this.state.model, this.state.serial);
      var rgtRaw = this.state.web3.utils.soliditySha3(this.state.first, this.state.middle, this.state.surname, this.state.id, this.state.secret);
      var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);
      console.log("Data: ", this.state.CountDown)
      
      checkExists(idxHash);
      checkMatch(idxHash, rgtHash);

      this.state.frontend.methods
        ._decCounter(idxHash, rgtHash, this.state.CountDown)
        .send({ from: this.state.addr}).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
        .on("receipt", (receipt) => {
          this.setState({txHash: receipt.transactionHash});
          //Stuff to do when tx confirms
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
        <form className="DCform">
          <h2>Countdown</h2>
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
          Countdown Amount:
          <input
            type="number"
            name="CountDownAmountField"
            placeholder="Countdown by"
            required
            onChange={(e) => this.setState({CountDown: e.target.value})}
          />
          <br></br>
          <input type="button" value="Countdown" onClick={_decrementCounter} />
        </form>)}
        {this.state.txHash > 0 && ( //conditional rendering
          <div className="VRresults">
            No Errors Reported
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

export default DecrementCounter;
