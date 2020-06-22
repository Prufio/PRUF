import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";

class SetCosts extends Component {

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
      authAddr: "",
      userType: "",
      assetClass: "",
      storage: "",

      newRecordCost: 0,
      transferRecordCost: 0,
      createNoteCost: 0,
      cost4: 0,
      cost5: 0,
      forceModCost: 0
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
      const storage_abi = returnStorageAbi();
      const frontEnd_abi = returnFrontEndAbi();
      const _storage = new _web3.eth.Contract(
        storage_abi, 
        _storage_addr);
      const _frontend = new _web3.eth.Contract(
        frontEnd_abi,
        _frontend_addr
        );

    this.setState({storage: _storage})
    this.setState({frontend: _frontend})

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() { 
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger())
}

  render(){
    const self = this;

    const setCosts = () => {
      this.state.storage.methods
        .OO_setCosts(
          
          this.state.assetClass, 
          this.state.newRecordCost, 
          this.state.transferRecordCost, 
          this.state.createNoteCost, 
          this.state.cost4, 
          this.state.cost5, 
          this.state.forceModCost)

        .send({ from: this.state.addr}).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
        .on("receipt", (receipt) => {
          console.log("costs succesfully updated under asset class", self.state.assetClass)
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
        <form className="ANform">
          <h2>Set Costs</h2>
          Asset Class:
        <input
          type="text"
          name="assetClass"
          placeholder="asset class"
          required
          onChange={(e) => this.setState({assetClass: e.target.value})}
        />
        <br></br>
        New Record:
        <input
          type="text"
          name="NRcost"
          placeholder="cost"
          required
          onChange={(e) => this.setState({newRecordCost: e.target.value})}
        />
        <br></br>
        Transfer Asset:
        <input
          type="text"
          name="TAcost"
          placeholder="cost"
          required
          onChange={(e) => this.setState({transferRecordCost: e.target.value})}
        />
        <br></br>
        Etch note:
        <input
          type="text"
          name="CNcost"
          placeholder="cost"
          required
          onChange={(e) => this.setState({createNoteCost: e.target.value})}
        />
        <br></br>
        Cost4:
        <input
          type="text"
          name="cost4"
          placeholder="cost"
          required
          onChange={(e) => this.setState({cost4: e.target.value})}
        />
        <br></br>
        Cost5:
        <input
          type="text"
          name="cost5"
          placeholder="cost"
          required
          onChange={(e) => this.setState({cost5: e.target.value})}
        />
        <br></br>
        Force Modify:
        <input
          type="text"
          name="FMcost"
          placeholder="cost"
          required
          onChange={(e) => this.setState({forceModCost: e.target.value})}
        />
        <br></br>
          <input type="button" value="Set Costs" onClick={setCosts} />
        </form>)}
      </div>
    );}
}

export default SetCosts;