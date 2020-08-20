import React, { Component } from "react";
import RCFJ from "./RetrieveContractsFromJSON"
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";

let contracts;

async function setupContractEnvironment(_web3) {
    contracts = window.contracts;
}

class VerifyRightHolder extends Component {
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

    /* this.getAssetClass = async () => {//under the condition that asset class has not been retrieved and stored in state, get it from user data
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
    }; */

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
      });
    };

    //Component state declaration

    this.state = {
      addr: "",
      error: undefined,
      error1: undefined,
      result: "",
      result1: "",
      assetClass: undefined,
      ipfs1: "",
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      isNFA: false,
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
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    //console.log("component mounted")
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    setupContractEnvironment(_web3);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    this.setState({assetClass: undefined})
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate(){//stuff to do when state updates

    if(this.state.web3 !== null && this.state.APP < 1){
      this.getContracts();
    }

    if (this.state.addr > 0 && this.state.assetClass === undefined) {
      //this.getAssetClass();
  }
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    async function checkExists(idxHash) {
      await self.state.STOR.methods
        .retrieveShortRecord(idxHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error1: _error });
            self.setState({ result1: 0 });
            alert(
              "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
            );
          } else {
            self.setState({ result1: _result });
          }
          console.log("check debug, _result, _error: ", _result, _error);
        });
    }

    const handleCheckBox = () => {
      let setTo;
      if(this.state.isNFA === false){
        setTo = true;
      }
      else if(this.state.isNFA === true){
        setTo = false;
      }
      this.setState({isNFA: setTo});
      console.log("Setting to: ", setTo);
      this.setState({manufacturer: ""});
      this.setState({type: ""});
    }

    const _verify = () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})
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

      checkExists(idxHash);

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
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          console.log(this.state.txHash);
        });

      console.log(this.state.result);
      document.getElementById("MainForm").reset();
    };
    return (
      <div>
        <Form className="VRform" id='MainForm'>
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
                {this.state.assetClass === 3 &&(
                <Form.Group>
                <Form.Check
                className = 'checkBox'
                size = 'lg'
                onChange={handleCheckBox}
                id={`NFA Firearm`}
                label={`NFA Firearm`}
                />
                </Form.Group>
                )}
              <h2 className="Headertext">Verify Rights Holder</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>

                  {returnTypes(this.state.assetClass, this.state.isNFA) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ type: e.target.value })}>
                  {returnTypes(this.state.assetClass, this.state.isNFA)}
                  </Form.Control>
                  )}

                    {returnTypes(this.state.assetClass, this.state.isNFA) === '0' &&(
                    <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />)}
                </Form.Group>

                  <Form.Group as={Col} controlId="formGridManufacturer">
                    <Form.Label className="formFont">Manufacturer:</Form.Label>
                    {returnManufacturers(this.state.assetClass, this.state.isNFA) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ manufacturer: e.target.value })}>
                  {returnManufacturers(this.state.assetClass, this.state.isNFA)}
                  </Form.Control>
                  )}

                      {returnManufacturers(this.state.assetClass, this.state.isNFA) === '0' &&(
                    <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
                    size="lg"
                  />)}
                  </Form.Group>

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
                <Form.Group as={Col} controlId="formGridFirstName">
                  <Form.Label className="formFont">First Name:</Form.Label>
                  <Form.Control
                    placeholder="First Name"
                    required
                    onChange={(e) => this.setState({ first: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridMiddleName">
                  <Form.Label className="formFont">Middle Name:</Form.Label>
                  <Form.Control
                    placeholder="Middle Name"
                    required
                    onChange={(e) => this.setState({ middle: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridLastName">
                  <Form.Label className="formFont">Last Name:</Form.Label>
                  <Form.Control
                    placeholder="Last Name"
                    required
                    onChange={(e) => this.setState({ surname: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridIdNumber">
                  <Form.Label className="formFont">ID Number:</Form.Label>
                  <Form.Control
                    placeholder="ID Number"
                    required
                    onChange={(e) => this.setState({ id: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridPassword">
                  <Form.Label className="formFont">Password:</Form.Label>
                  <Form.Control
                    placeholder="Password"
                    type="password"
                    required
                    onChange={(e) => this.setState({ secret: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group className="buttonDisplay">
                  <Button
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_verify}
                  >
                    Submit
                  </Button>
                </Form.Group>
              </Form.Row>
            </div>
          )}
        </Form>

        {this.state.txHash > 0 && ( //conditional rendering
          <div className="VRHresults">
            {this.state.result === "170"
              ? "Match Confirmed :"
              : "Record does not match :"}
            <a
              href={" https://kovan.etherscan.io/tx/" + this.state.txHash}
              target="_blank"
              rel="noopener noreferrer"
            >
              KOVAN Etherscan:{this.state.txHash}
            </a>
          </div>
        )}
      </div>
    );
  }
}
export default VerifyRightHolder;
