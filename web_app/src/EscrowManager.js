import React, { Component } from "react";
import returnContracts from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";
import returnActions from "./Actions";

class EscrowManager extends Component {
  constructor(props) {
    super(props);

    this.getCosts = async () => {
      const self = this;
      if (self.state.costArray[0] > 0 || self.state.storage === "" || self.state.assetClass === undefined) {
      } else {
        for (var i = 0; i < 1; i++) {
          self.state.storage.methods
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

    this.getAssetClass = async () => {
      const self = this;
      //console.log("getting asset class");
      if (self.state.assetClass > 0 || self.state.BPappPayable === "") {
      } else {
        self.state.BPappPayable.methods
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

    this.returnsContract = async () => {
      const self = this;
      var contractArray = await returnContracts(self.state.web3);
      //console.log("RC EM: ", contractArray)

      if(this.state.storage < 1){self.setState({ storage: contractArray[0] });}
      if(this.state.BPappNonPayable < 1){self.setState({ BPappNonPayable: contractArray[1] });}
      if(this.state.BPappPayable < 1){self.setState({ BPappPayable: contractArray[2] });}
    };

    this.acctChanger = async () => {
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
      costArray: [0],
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      assetClass: undefined,
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
      newFirst: "",
      newMiddle: "",
      newSurname: "",
      newId: "",
      newSecret: "",
      web3: null,
      BPappPayable: "",
      BPappNonPayable: "",
      storage: "",
      timeFormat: "",
    };
  }

  componentDidMount() {

    //console.log("component mounted")

    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {
    this.setState({assetClass: undefined})
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

   componentDidUpdate() {

    if(this.state.web3 !== null && this.state.BPappPayable < 1){
      this.returnsContract();
    }

    if (this.state.addr > 0 && this.state.assetClass === undefined) {
      this.getAssetClass();
    }
  } 

  render() {
    const self = this;

    async function checkExistsSet(idxHash) {
      await self.state.storage.methods
        .retrieveShortRecord(idxHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
            alert(
              "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
            );
          }else {
            if (Object.values(_result)[2] === '6' || Object.values(_result)[2] === '12'){
                alert("WARNING: Asset already in escrow! Reject in metamask and wait for active escrow status to expire.")}
            self.setState({ result1: _result });
          }
          console.log("check debug, _result, _error: ", _result, _error);
        });
    }

    async function checkExistsEnd(idxHash) {
        await self.state.storage.methods
          .retrieveShortRecord(idxHash)
          .call({ from: self.state.addr }, function (_error, _result) {
            if (_error) {
              self.setState({ error: _error });
              self.setState({ result: 0 });
              alert(
                "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
              );
            }else {
              if (Object.values(_result)[2] !== '6' && Object.values(_result)[2] !== '12'){
                  alert("WARNING: Asset is not in escrow! Reject in metamask and check status in search.")}
              self.setState({ result1: _result });
            }
            console.log("check debug, _result, _error: ", _result, _error);
          });
      }
    const _convertTimeTo = (rawTime, to) => {
        var time;

        if      (to === "seconds") {time = rawTime}
        else if (to === "minutes") {time = rawTime*60}
        else if (to === "hours") {time = rawTime*3600}
        else if (to === "days") {time = rawTime*86400}
        else if (to === "weeks") {time = rawTime*604800}
        else{alert("Invalid time unit")}
        return (time);
    }

    const _setEscrow = () => {
      var idxHash;
      
      idxHash = this.state.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
    );

      console.log("idxHash", idxHash);
      console.log("addr: ", this.state.addr);
      console.log("time: ", this.state.escrowTime, "format: ", this.state.timeFormat);

      checkExistsSet(idxHash);

      this.state.BPappNonPayable.methods
        .setEscrow(idxHash, _convertTimeTo(this.state.escrowTime, this.state.timeFormat))
        .send({ from: this.state.addr})
        .on("error", function (_error) {
          // self.setState({ NRerror: _error });
          self.setState({ txHash: Object.values(_error)[0].transactionHash });
          self.setState({ txStatus: false });
          console.log(Object.values(_error)[0].transactionHash);
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          console.log(receipt.status);
          //Stuff to do when tx confirms
        });
      console.log(this.state.txHash);
    };

    const _endEscrow = () => {
        var idxHash = this.state.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial
        );
  
        console.log("idxHash", idxHash);
        console.log("addr: ", this.state.addr);
  
        checkExistsEnd(idxHash);
  
        this.state.BPappNonPayable.methods
          .endEscrow(idxHash)
          .send({ from: this.state.addr})
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            //Stuff to do when tx confirms
          });
        console.log(this.state.txHash);
      };

    return (
      <div>
        <Form className="ANform">
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
              <h2 className="Headertext">Manage Escrow</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>

                  {returnTypes(this.state.assetClass) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ type: e.target.value })}>
                  {returnTypes(this.state.assetClass)}
                  </Form.Control>
                  )}

                    {returnTypes(this.state.assetClass) === '0' &&(
                    <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />)}
                </Form.Group>

                  <Form.Group as={Col} controlId="formGridManufacturer">
                    <Form.Label className="formFont">Manufacturer:</Form.Label>
                    {returnManufacturers(this.state.assetClass) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ manufacturer: e.target.value })}>
                  {returnManufacturers(this.state.assetClass)}
                  </Form.Control>
                  )}

                      {returnManufacturers(this.state.assetClass) === '0' &&(
                    <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
                    size="lg"
                  />)}
                  </Form.Group>
                  
                  {returnActions(this.state.assetClass) !== "0" &&(
                  <Form.Group as={Col} controlId="formGridAction">
                  <Form.Label className="formFont">Action:</Form.Label>
                    {returnActions(this.state.assetClass) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ action: e.target.value })}>
                    {returnActions(this.state.assetClass)}
                    </Form.Control>
                    )}
                  </Form.Group>)}

              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridModel">
                  <Form.Label className="formFont">Model:</Form.Label>
                  <Form.Control
                    placeholder="Model"
                    required
                    onChange={(e) => this.setState({ model: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridSerial">
                  <Form.Label className="formFont">Serial:</Form.Label>
                  <Form.Control
                    placeholder="Serial"
                    required
                    onChange={(e) => this.setState({ serial: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridTime">
                  <Form.Label className="formFont">Duration:</Form.Label>
                  <Form.Control
                    placeholder="setEscrow duration"
                    required
                    onChange={(e) => this.setState({ escrowTime: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridFormat">
                <Form.Label className="formFont">Time Unit:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ timeFormat: e.target.value })}>
                    <option value="0">Select a time unit</option>
                    <option value="seconds">Seconds</option>
                    <option value="minutes">Minutes</option>
                    <option value="hours">Hours</option>
                    <option value="days">Days</option>
                    <option value="weeks">Weeks</option>
                  </Form.Control>
                </Form.Group>
                </Form.Row>
                <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_setEscrow}
                  >
                    begin escrow
                  </Button>
                </Form.Group>
              </div>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay2"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_endEscrow}
                  >
                    end escrow
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}
        </Form>
        {this.state.txHash > 0 && ( //conditional rendering
          <div className="Results">
            {this.state.txStatus === false && (
              <div>
                !ERROR! :
                <a
                  href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  KOVAN Etherscan:{this.state.txHash}
                </a>
              </div>
            )}
            {this.state.txStatus === true && (
              <div>
                {" "}
                No Errors Reported :
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
      </div>
    );
  }
}

export default EscrowManager;
