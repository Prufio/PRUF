import React, { Component } from "react";
import RCFJ from "./RetrieveContractsFromJSON"
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";

let contracts;

async function setupContractEnvironment(_web3) {
    contracts = window.contracts;
}

class THEWORKS extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.getCosts = async () => {//under the condition that prices are not stored in state, get prices from STOR
      const self = this;
      if (self.state.costArray[0] > 0 || self.state.AC_MGR === "" || self.state.assetClass === undefined) {
      } else {
        for (var i = 0; i < 1; i++) {
          self.state.AC_MGR.methods
            .retrieveCosts(self.state.assetClass)
            .call({ from: self.state.addr }, function (_error, _result) {
              if (_error) {
              } else {
                /* console.log("_result: ", _result); */ if (
                  _result !== undefined
                ) {
                  self.setState({ costArray: Object.values(_result) });
                }
              }
            });
        }
      }
    };

    this.getAssetClass = async () => {//under the condition that asset class has not been retrieved and stored in state, get it from user data
      const self = this;
      //console.log("getting asset class");
      if (self.state.assetClass > 0 || self.state.AC_MGR === "") {
      } else {
        self.state.AC_MGR.methods
          .getUserExt(self.state.web3.utils.soliditySha3(self.state.addr))
          .call({ from: self.state.addr }, function (_error, _result) {
            if (_error) {console.log(_error)
            } else {
               console.log("_result: ", _result);  if (_result !== undefined ) {
                self.setState({ assetClass: Object.values(_result)[1] });
              }
            }
          });
    }
    };

    this.getContracts = async () => {
          const self = this;
          self.setState({STOR: contracts.content[0]});
          self.setState({APP: contracts.content[1]});
          self.setState({NP: contracts.content[2]});
          self.setState({AC_MGR: contracts.content[3]});
          self.setState({AC_TKN: contracts.content[4]});
          self.setState({A_TKN: contracts.content[5]});
          self.setState({ECR_MGR: contracts.content[6]});
          self.setState({ECR: contracts.content[7]});
          self.setState({ECR2: contracts.content[8]});
          self.setState({ECR_NC: contracts.content[9]});
          self.setState({APP_NC: contracts.content[10]});
          self.setState({NP_NC: contracts.content[11]});
          self.setState({RCLR: contracts.content[12]});
    };

    this.acctChanger = async () => {//Handle an address change, update state accordingly
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({ addr: e[0] }));
        self.setState({assetClass: undefined})
        self.setState({costArray: [0]})
      });
    };

    //Component state declaration

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      IPFS: require("ipfs-mini"),
      hashPath: "",
      error: undefined,
      NRerror: undefined,
      result: null,
      RRresult: [0],
      
      costResult: {},
      costArray: [0],
      assetClass: undefined,
      countDownStart: "6000",
      countDown:"555",
      ipfs1: "a",
      txHash: "",
      txStatus: false,

      status: "1",
      boolBuddy: false,

      type: "",
      manufacturer: "",
      model: "",
      serial: "",

      first: "a",
      middle: "a",
      surname: "a",
      id: "a",
      secret: "a",

      newFirst: "b",
      newMiddle: "b",
      newSurname: "b",
      newId: "b",
      newSecret: "b",

      web3: null,
      APP: "",
      NP: "",
      STOR: "",
      AC_MGR: "",
      ECR_NC: "",
      ECR_MGR: "",
      AC_TKN: "",
      A_TKN: "",
      APP_NC: "",
      NP_NC: "",
      ECR2: "",
      NAKED: "",
      RCLR: "",
      txStatus: null,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    setupContractEnvironment(_web3);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    document.addEventListener("accountListener", this.acctChanger());
    let _type = String(Math.round(Math.random()*100000000));

    console.log("asset idx info: ", _type);

    this.setState({type: _type})
    this.setState({manufacturer: _type})
    this.setState({model: _type})
    this.setState({serial: _type})

    
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    this.setState({assetClass: undefined})
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate() {//stuff to do when state updates

    if(this.state.web3 !== null && this.state.APP < 1){
      this.getContracts();
    }

    if (this.state.addr > 0 && this.state.assetClass === undefined && this.state.APP !== "") {
        this.getAssetClass();
    } 

    if (this.state.addr > 0) {
      if (this.state.costArray[0] < 1) {
        this.getCosts();
      }
    }
  }
  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _retrieveRecord = () => {
        const self = this;
        var idxHash;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        console.log("idxHash", idxHash);
        console.log("addr: ", this.state.addr);
  
        this.state.STOR.methods
          .retrieveShortRecord(idxHash)
          .call({ from: this.state.addr }, function (_error, _result) {
            if (_error) { console.log(_error)
              self.setState({ error: _error });
              self.setState({ RRresult: 0 });
            } else {
              if (Object.values(_result)[2] === '0'){  self.setState({ status: 'No status set' });}
              else if (Object.values(_result)[2] === '1'){  self.setState({ status: 'Transferrable' });}
              else if (Object.values(_result)[2] === '2'){  self.setState({ status: 'Non-transferrable' });}
              else if (Object.values(_result)[2] === '3'){  self.setState({ status: 'ASSET REPORTED STOLEN' });}
              else if (Object.values(_result)[2] === '4'){  self.setState({ status: 'ASSET REPRTED LOST' });}
              else if (Object.values(_result)[2] === '5'){  self.setState({ status: 'Asset in transfer' });}
              else if (Object.values(_result)[2] === '6'){  self.setState({ status: 'In escrow (block.number locked)' });}
              else if (Object.values(_result)[2] === '7'){  self.setState({ status: 'P2P Transferrable' });}
              else if (Object.values(_result)[2] === '8'){  self.setState({ status: 'P2P Non-transferrable' });}
              else if (Object.values(_result)[2] === '9'){  self.setState({ status: 'ASSET REPORTED STOLEN (P2P)' });}
              else if (Object.values(_result)[2] === '10'){  self.setState({ status: 'ASSET REPORTED LOST (P2P)' });}
              else if (Object.values(_result)[2] === '11'){  self.setState({ status: 'In P2P transfer' });}
              else if (Object.values(_result)[2] === '12'){  self.setState({ status: 'In escrow (block.time locked)' });}
              else if (Object.values(_result)[2] === '20'){  self.setState({ status: 'Cusdodial escrow ended' });}
              else if (Object.values(_result)[2] === '21'){  self.setState({ status: 'P2P escrow ended' });}
              self.setState({ RRresult: Object.values(_result)})
              self.setState({ error: undefined });
          }});
      };

    const _setIPFS2 = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = this.state.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
  
        var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("addr: ", this.state.addr);
  
        this.state.APP.methods
          .$addIpfs2Note(idxHash, rgtHash, this.state.web3.utils.soliditySha3(this.state.ipfs1))
          .send({ from: this.state.addr, value: this.state.costArray[2] })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ ANstats: "AN failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ ANstats: "AN success" });
            _retrieveRecord()
          });
  
        console.log(this.state.txHash);
      };

    const _updateDescription = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = this.state.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
        var _ipfs1 = this.state.web3.utils.soliditySha3("LETS GOOOOOOOO");
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", this.state.addr);
        console.log("new desc: ", _ipfs1);
  
        this.state.NP.methods
          ._modIpfs1(idxHash, rgtHash, _ipfs1)
          .send({ from: this.state.addr })
          .on("error", function (_error) {
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ UDstats: "UD failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ UDstats: "UD success" });
            _setIPFS2()
          });
  
        console.log(this.state.txHash);
      };

    const _decrementCounter = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = this.state.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", this.state.addr);
        console.log("CountDown amt: ", this.state.countDown);
  
        this.state.NP.methods
          ._decCounter(idxHash, rgtHash, this.state.countDown)
          .send({ from: this.state.addr })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ CDstats: "CD failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ CDstats: "CD success" });
            _updateDescription()
          });
  
        console.log(this.state.txHash);
      };

    const _forceModifyRecord = () => {
        var idxHash;
        var newRgtRaw;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        newRgtRaw = this.state.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var newRgtHash = this.state.web3.utils.soliditySha3(idxHash, newRgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", newRgtRaw);
        console.log("New rgtHash", newRgtHash);
        console.log("addr: ", this.state.addr);
  
        this.state.APP.methods
          .$forceModRecord(idxHash, newRgtHash)
          .send({ from: this.state.addr, value: this.state.costArray[5] })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ FMRstats: "FMR failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ FMRstats: "FMR success" });
            _decrementCounter()
          });
  
        console.log(this.state.txHash);
      };

    const _transferAsset = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = this.state.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        var newRgtRaw = this.state.web3.utils.soliditySha3(
          this.state.newFirst,
          this.state.newMiddle,
          this.state.newSurname,
          this.state.newId,
          this.state.newSecret
        );
        var newRgtHash = this.state.web3.utils.soliditySha3(idxHash, newRgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", this.state.addr);
  
        this.state.APP.methods
          .$transferAsset(idxHash, rgtHash, newRgtHash)
          .send({ from: this.state.addr, value: this.state.costArray[1] })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ TAstats: "TA failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ TAstats: "TA success" });
            _forceModifyRecord()
          });
        console.log(this.state.txHash);
      };

    const _modifyStatus = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = this.state.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", this.state.addr);
  

        this.state.NP.methods
          ._modStatus(idxHash, rgtHash, this.state.status)
          .send({ from: this.state.addr })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ MSstats: "MS failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ MSstats: "MS success" });
            _transferAsset()
          });
  
        console.log(this.state.txHash);
      };

    const _verify = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = this.state.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("addr: ", this.state.addr);
  
        this.state.STOR.methods
          ._verifyRightsHolder(idxHash, rgtHash)
          .call({ from: this.state.addr }, function (_error, _result) {
            if (_error) {
              self.setState({ error: _error });
              self.setState({ result: 0 });
            } else {
              self.setState({ result: _result });
              console.log("verify.call result: ", _result);
              self.setState({ error: undefined });
            }
          });
  
        this.state.STOR.methods
          .blockchainVerifyRightsHolder(idxHash, rgtHash)
          .send({ from: this.state.addr })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ VRHstats: "VRH failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            console.log(this.state.txHash);
            this.setState({ VRHstats: "VRH success" });
            _modifyStatus()
          });
  
        console.log(this.state.result);
      };

    const _newRecord = () => {
      var idxHash;
      var rgtRaw;
      
      idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );


      rgtRaw = this.state.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );

      var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);

      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);
      console.log(this.state.assetClass);

      this.state.APP.methods
        .$newRecord(
          idxHash,
          rgtHash,
          this.state.assetClass,
          this.state.countDownStart,
          this.state.web3.utils.soliditySha3(this.state.ipfs1)
        )
        .send({ from: this.state.addr, value: this.state.costArray[0]})
        .on("error", function (_error) {
          // self.setState({ NRerror: _error });
          self.setState({ txHash: Object.values(_error)[0].transactionHash });
          self.setState({ txStatus: false });
          self.setState({ NRstats: "NR failure" });
          console.log(Object.values(_error)[0].transactionHash);
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          this.setState({ NRstats: "NR success" });

          _verify()
        });
    };

    const batchTest = () => {
        if(this.state.APP !== ""){
            _newRecord();
        }
        else{
        this.forceUpdate()}
    }

    return (
      <div>
          {this.state.addr === undefined && (
            <div className="errorResults">
              <h2>WARNING!</h2>
              <h3>Injected web3 not connected to form!</h3>
            </div>
          )}{this.state.assetClass < 1 && (
            <div className="errorResults">
              <h2>No authorized asset class detected at user address.</h2>
              <h3>Unauthorized users do not have access to forms.</h3>
            </div>
          )}
          {this.state.addr > 0 && this.state.assetClass > 0 &&(
            <div>
                
            <Form className="TWform">
                

                <div className="TWResults">
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.NRstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.VRHstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.MSstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.TAstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.FMRstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.CDstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.UDstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.ANstats}
                </Form.Group>
                </Form.Row>
                </div>
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={batchTest}>
                      LETS GOOOOO
                    </Button>
                  </Form.Group>
                </Form.Row>
            </Form>
            

        </div>)}

        {this.state.RRresult[4] === "0" && (
          <div className="RRresultserr">No Asset Found for Given Data</div>
        )}

        {this.state.RRresult[4] > 0 && ( //conditional rendering
          <div className="RRresults">
            Asset Found!
            <br></br>
            Status:{this.state.status}
            <br></br>
            Mod Count:{this.state.RRresult[3]}
            <br></br>
            Asset Class :{this.state.RRresult[4]}
            <br></br>
            Count :{this.state.RRresult[5]} of {this.state.RRresult[6]}
            <br></br>
            IPFS Description :{this.state.RRresult[7]}
            <br></br>
            IPFS Note {this.state.RRresult[8]}
          </div>
        )}
        </div>
        
    )
  }
}

export default THEWORKS;
