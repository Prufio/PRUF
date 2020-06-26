import React, { Component } from "react";
import returnStorageAbi from "./Storage_ABI";
import returnBPFAbi from "./BPappNonPayable_ABI";
import returnBPPAbi from "./BPappPayable_ABI";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";
import returnAC from "./AssetClasses";
import returnActions from "./Actions";

class NewRecord extends Component {
  constructor(props) {
    super(props);

    this.getCosts = async () => {
      const self = this;
      if (self.state.costArray[0] > 0 || self.state.storage === "") {
      } else {
        for (var i = 0; i < 1; i++) {
          self.state.storage.methods
            .retrieveCosts(3)
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

    this.returnsContract = (contract) => {
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      var addrArray = returnAddresses();
      var _BPFreeAddr = addrArray[1]
      var _BPPayableAaddr = addrArray[2];
      var _storage_addr = addrArray[0];
      const storage_abi = returnStorageAbi();
      const BPFreeAbi = returnBPFAbi();
      const BPPayableAbi = returnBPPAbi();

      const _storage = new _web3.eth.Contract(storage_abi, _storage_addr);
      const _BPFree = new _web3.eth.Contract(BPFreeAbi, _BPFreeAddr);
      const _BPPayable = new _web3.eth.Contract(BPPayableAbi, _BPPayableAaddr)

      if (contract === "BPF") {
        return _BPFree;
      } else if (contract === "storage") {
        return _storage;
      } else if (contract === "BPP"){
        return _BPPayable;
      }
    };

    this.acctChanger = async () => {
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({ addr: e[0] }));
      });
    };

    //Component state declaration

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
      assetClass: "",
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
      asset: "3",
      cost: "",
      frontendPayable: "",
      frontendFree: "",
      storage: "",
      txStatus: null,
    };
  }

  componentDidMount() {
    var _ipfs = new this.state.IPFS({
      host: "ipfs.infura.io",
      port: 5001,
      protocol: "https",
    });
    this.setState({ ipfs: _ipfs });
    this.setState({ storage: this.returnsContract("storage") });
    this.setState({ frontendFree: this.returnsContract("BPF") });
    this.setState({ frontendPayable: this.returnsContract("BPP") });
    //console.log("component mounted")

    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate() {
    if (this.state.addr > 0) {
      if (this.state.costArray[0] < 1) {
        this.getCosts();
      }
    }
  }
  render() {
    const self = this;

    const getBytes32FromIpfsHash = (ipfsListing) => {
      return "0x" + bs58.decode(ipfsListing).slice(2).toString("hex");
    };

    const publishIPFS1 = async () => {
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

    async function checkExists(idxHash) {
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

    const _newRecord = () => {
      let _cost = this.state.costArray[0];
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
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);
      console.log("Cost: ", _cost);
      console.log(this.state.assetClass);

      checkExists(idxHash);

      this.state.frontendPayable.methods
        .$newRecord(
          idxHash,
          rgtHash,
          this.state.assetClass,
          this.state.CountDownStart,
          this.state.hashPath
        )
        .send({ from: this.state.addr, value: _cost })
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
          //Stuff to do when tx confirms
        });
    };

    return (
      <div>
        <Form className="NRform">
          {this.state.addr === undefined && (
            <div className="errorResults">
              <h2>WARNING!</h2>
              <h3>Injected web3 not connected to form!</h3>
            </div>
          )}
          {this.state.addr > 0 && (
            <div>
              <h2 className="Headertext">New Record</h2>
              <br></br>
              <Form.Row>

              <Form.Group as={Col} controlId="formGridFormat">
                <Form.Label className="formFont">Asset Class:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ assetClass: e.target.value })}>
                  <>
                    <option value="10">Choose an asset class</option>
                    <option value={"3"}>Firearms Class 01</option>
                    <option value="4">Firearms Class 02</option>
                    <option value="5">Firearms Class 03</option>
                    <option value="6">Firearms Class 09</option>
                    <option value="7">Motor Vehicles</option>
                    <option value="8">Art Collectables</option>
                    <option value="9">Electronics</option>
                  </>
                  </Form.Control>
                </Form.Group>
                </Form.Row>
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
                      this.setState({ CountDownStart: e.target.value })
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
