import React, { Component } from "react";
import returnContracts from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";

class NewRecord extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.getCosts = async () => {//under the condition that prices are not stored in state, get prices from storage
      const self = this;
      if (self.state.costArray[0] > 0 || self.state.PRUF_AC_manager === "" || self.state.assetClass === undefined) {
      } else {
        for (var i = 0; i < 1; i++) {
          self.state.PRUF_AC_manager.methods
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
      if (self.state.assetClass > 0 || self.state.PRUF_AC_manager === "") {
      } else {
        self.state.PRUF_AC_manager.methods
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

    this.returnsContract = async () => {//request contracts from returnContracts, which returns an object full of contracts
      const self = this;
      var contracts = await returnContracts(self.state.web3);
      //console.log("RC NR: ", contractArray)

      if(this.state.storage < 1){self.setState({ storage: contracts.storage });}
      if(this.state.PRUF_NP < 1){self.setState({ PRUF_NP: contracts.nonPayable });}
      if(this.state.PRUF_APP < 1){self.setState({ PRUF_APP: contracts.payable });}
      if(this.state.PRUF_simpleEscrow < 1){self.setState({ PRUF_simpleEscrow: contracts.simpleEscrow });}
      if(this.state.PRUF_AC_manager < 1){self.setState({ PRUF_AC_manager: contracts.actManager });}
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

    this.state = {
      addr: "",
      action: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      IPFS: require("ipfs-mini"),
      hashPath: "",
      error: undefined,
      NRerror: undefined,
      result: null,
      costResult: {},
      costArray: [0],
      assetClass: undefined,
      countDownStart: "",
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
      web3: null,
      asset: "3",
      cost: "",
      PRUF_APP: "",
      PRUF_NP: "",
      storage: "",
      PRUF_AC_manager: "",
      PRUF_simpleEscrow: "",
      isNFA: false,
      txStatus: null,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    var _ipfs = new this.state.IPFS({
      host: "ipfs.infura.io",
      port: 5001,
      protocol: "https",
    });
    this.setState({ ipfs: _ipfs });

    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    this.setState({assetClass: undefined})
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate() {//stuff to do on a re-render

    if(this.state.web3 !== null && this.state.PRUF_APP < 1){
      this.returnsContract();
    }

    if (this.state.addr > 0 && this.state.assetClass === undefined && this.state.PRUF_APP !== "") {
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

    const getBytes32FromIpfsHash = (ipfsListing) => {// uses bs58 deps to make a bytes 32 out of a bs58 hash
      return "0x" + bs58.decode(ipfsListing).slice(2).toString("hex");
    };

    const publishIPFS1 = async () => {//post text field contents to ipfs
      console.log("Uploading file to IPFS...");
      await this.state.ipfs.add(this.state.ipfs1, (error, hash) => {
        if (error) {
          console.log("Something went wrong. Unable to upload to ipfs");
        } else {
          console.log("uploaded at hash: ", hash);
        }
        self.setState({ hashPath: getBytes32FromIpfsHash(hash) });
      });
    };

    async function checkExists(idxHash) {//check whether record of asset exists in the database
      self.state.storage.methods
        .retrieveShortRecord(idxHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error){ console.log("IN ERROR IN ERROR IN ERROR")
            self.setState({ error: _error.message });
            self.setState({ result: 0 });
          } else if (
            Object.values(_result)[4] ===
            "0"
          ) {
          } else {
            self.setState({ result: _result });
            alert(
              "WARNING: Record already exists! Reject in metamask and change asset info."
            );
          }
          console.log("In checkExists, _result, _error: ", _result, _error);
        });
    }

    const handleCheckBox = () => {//checkbox logic
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

    const _newRecord = () => {//create a new asset record
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})
      //reset state values before form resubmission
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

      checkExists(idxHash);

      this.state.PRUF_APP.methods
        .$newRecord(
          idxHash,
          rgtHash,
          this.state.assetClass,
          this.state.countDownStart,
          this.state.hashPath
        )
        .send({ from: this.state.addr, value: this.state.costArray[0]})
        .on("error", function (_error) {
          // self.setState({ NRerror: _error });
          self.setState({ txHash: Object.values(_error)[0].transactionHash });
          self.setState({ txStatus: false });
          console.log(Object.values(_error)[0].transactionHash);
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          //console.log(receipt.status);
          self.setState({ hashPath: ""});
        });

        document.getElementById("MainForm").reset(); //clear form inputs
    };

    return (//default render
      <div>
        <Form className="NRform" id='MainForm'>
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
              <h2 className="Headertext">New Record</h2>
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
                <Form.Group as={Col} controlId="formGridLogStartValue">
                  <Form.Label className="formFont">Log Start Value:</Form.Label>
                  <Form.Control
                    placeholder="Log Start Value"
                    required
                    onChange={(e) =>
                      this.setState({ countDownStart: e.target.value })
                    }
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridDescription">
                  <Form.Label className="formFont">Description:</Form.Label>
                  <Form.Control
                    placeholder="Description"
                    required
                    onChange={(e) => this.setState({ ipfs1: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>
              {this.state.hashPath === "" && this.state.ipfs1 !== "" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={publishIPFS1}
                    >
                      Load to IPFS
                    </Button>
                  </Form.Group>
                </Form.Row>
              )}
              {this.state.hashPath !== "" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={_newRecord}
                    >
                      New Record
                    </Button>
                  </Form.Group>
                </Form.Row>
              )}

              {this.state.ipfs1 === "" && this.state.hashPath === "" && (
                <Form.Row>
                  <Form.Group className="buttonDisplay">
                    <Button
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={_newRecord}
                    >
                      New Record
                    </Button>
                  </Form.Group>
                </Form.Row>
              )}
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

export default NewRecord;
