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

class ForceModifyRecord extends Component {
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
        self.setState({costArray: [0]})
      });
    };

    //Component state declaration

    this.mounted = false;
    this.state = {
      addr: "",
      costArray: [0],
      error: undefined,
      NRerror: undefined,
      result: "",
      assetClass: undefined,
      CountDownStart: "",
      ipfs1: "",
      txHash: "",
      txStatus: false,
      isNFA: false,
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

  componentDidUpdate() {//stuff to do when state updates

    if(this.state.web3 !== null && this.state.APP < 1){
      this.getContracts();
    }
    
    if (this.state.addr > 0 && this.state.assetClass === undefined) {
      //this.getAssetClass();
    }

    if (this.state.addr > 0) {
      if (this.state.costArray[0] < 1) {
        this.getCosts();
      }
    }
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    async function checkExists(idxHash) {
      await self.state.STOR.methods
        .retrieveShortRecord(idxHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          console.log(_result);
          if (_error) {
          } else if (Object.values(_result)[4] === "0") {
            self.setState({ error: _error });
            self.setState({ result: 0 });
            alert(
              "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
            );
          } else {
            self.setState({ result: _result });
            alert(
              "WARNING: Modifying a record will permanently delete existing owner data."
            );
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

    const _reimportAsset = () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})
      var idxHash = this.state.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial
      );

      var rgtRaw = this.state.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );

      var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);

      console.log("idxHash", idxHash);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);

      checkExists(idxHash);

      this.state.APP.methods
        .$reimportRecord(idxHash, rgtHash)
        .send({ from: this.state.addr, value: this.state.costArray[3] })
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

    const _forceModifyRecord = () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})
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

      checkExists(idxHash);

      this.state.APP.methods
        .$forceModRecord(idxHash, newRgtHash)
        .send({ from: this.state.addr, value: this.state.costArray[5] })
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
      document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <Form className="FMRform" id='MainForm'>
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
              <h2 className="Headertext">Force Modify/Reimport Asset</h2>
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
                <Form.Group as={Col} controlId="formGridNewFirstName">
                  <Form.Label className="formFont">New First Name:</Form.Label>
                  <Form.Control
                    placeholder="New First Name"
                    required
                    onChange={(e) => this.setState({ first: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridNewMiddleName">
                  <Form.Label className="formFont">New Middle Name:</Form.Label>
                  <Form.Control
                    placeholder="New Middle Name"
                    required
                    onChange={(e) => this.setState({ middle: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridNewLastName">
                  <Form.Label className="formFont">New Last Name:</Form.Label>
                  <Form.Control
                    placeholder="New Last Name"
                    required
                    onChange={(e) => this.setState({ surname: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridNewIdNumber">
                  <Form.Label className="formFont">New ID Number:</Form.Label>
                  <Form.Control
                    placeholder="New ID Number"
                    required
                    onChange={(e) => this.setState({ id: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridNewPassword">
                  <Form.Label className="formFont">New Password:</Form.Label>
                  <Form.Control
                    placeholder="New Password"
                    type="password"
                    required
                    onChange={(e) => this.setState({ secret: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>
              <Form.Row>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay"
                    variant="danger"
                    type="button"
                    size="lg"
                    onClick={_forceModifyRecord}
                  >
                    Force modify
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
                    onClick={_reimportAsset}
                  >
                    Re-import
                  </Button>
                </Form.Group>
              </div>
                {/* <ButtonGroup className="buttonGroupDisplay" aria-label="choices">
                <Button variant="danger"
                    type="button"
                    size="lg"
                    onClick={_forceModifyRecord}>
                      
                      Force Modify
                    </Button> 

                    <Button variant="primary"
                    type="button"
                    size="lg"
                    onClick={_reimportAsset}
                  >
                    Re-import
                    </Button>
                </ButtonGroup> */}
              </Form.Row>
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

export default ForceModifyRecord;
