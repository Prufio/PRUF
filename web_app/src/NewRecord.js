import React, { Component } from "react";
import Web3Listener from "./Web3Listener";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import Web3 from "web3";

class NewRecord extends React.Component {

  constructor(props){
    super(props);
    //Component state declaration

    this.state = {
      addr: "",
      error: undefined,
      NRerror: undefined,
      result: "",
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
  /* var web3 = require("web3");
  web3 = new Web3(web3.givenProvider);
  web3.eth.getAccounts().then((e) => setAddr(e[0]));
  var frontend = Web3Listener('frontend'); */

/*   var [addr, setAddr] = useState("");
  var [error, setError] = useState(undefined);
  
  var [AssetClass, setAssetClass] = useState("");
  var [CountDownStart, setCountDownStart] = useState("");
  var [Ipfs1, setIPFS1] = useState("");
  var [txHash, setTxHash] = useState("");
  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");

  var [first, setFirst] = useState("");
  var [middle, setMiddle] = useState("");
  var [surname, setSurname] = useState("");
  var [id, setID] = useState("");
  var [secret, setSecret] = useState(""); */

  componentDidMount() {

    const ethereum = window.ethereum;
    const self = this;
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({web3: _web3});
    _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
    var _frontend_addr = "0x9Ef2BBF052A5b61eBD1452d48B515BE7659a200B";
    
    var _storage_addr = "0x926c75761f8e68133c4A7140Bd079ce65A935ad0";

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

    window.addEventListener("load", async () => {  
      ethereum.on("accountsChanged", function(accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({addr: e[0]}));
      });
    });

  }

  render(){
    const self = this;

    async function checkExists(idxHash) { 
      await self.state.storage.methods
        .retrieveRecord(idxHash)
        .call({ from: self.state.addr }, function(_error, _result){
          if(_error){self.setState({error: _error});self.setState({result: 0})}
          else{self.setState({result: _result});alert("WARNING: Record already exists, transaction will fail!")}
          console.log("check debug, _result, _error: ", _result, _error)
    });

    }

    const _newRecord = () => {
      var idxHash = this.state.web3.utils.soliditySha3(this.state.type, this.state.manufacturer, this.state.model, this.state.serial);
      var rgtRaw = this.state.web3.utils.soliditySha3(this.state.first, this.state.middle, this.state.surname, this.state.id, this.state.secret);
      var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);
      
      checkExists(idxHash);

      /* this.state.storage.methods
        .retrieveRecord(idxHash)
        .call({ from: this.state.addr }, function(_error, _result){
          if(_error){self.setState({error: _error})}
          else{self.setState({result: _result})}
          console.log("check debug, _result, _error: ", _result, _error)
    }); */
    
/*       if(this.state.result != 0){
        return(alert("Record already exists at index"))
      } */

     
      this.state.frontend.methods
        .$newRecord(idxHash, rgtHash, this.state.AssetClass, this.state.CountDownStart, this.state.web3.utils.soliditySha3(this.state.ipfs1))
        .send({ from: this.state.addr, value: this.state.web3.utils.toWei("0.01") }).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
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
