import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class ModifyDescription extends Component {
  constructor(props) {
    super(props);

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
      error: undefined,
      NRerror: undefined,
      result: [],
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
      storage: "",
    };
  }

  componentDidMount() {
    //console.log("component mounted")
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    var addrArray = returnAddresses();
    var _frontend_addr = addrArray[1];
    var _storage_addr = addrArray[0];
    const frontEnd_abi = returnFrontEndAbi();
    const storage_abi = returnStorageAbi();

    const _frontend = new _web3.eth.Contract(frontEnd_abi, _frontend_addr);

    const _storage = new _web3.eth.Contract(storage_abi, _storage_addr);
    this.setState({ frontend: _frontend });
    this.setState({ storage: _storage });

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {
    const self = this;
    const _retrieveRecord = () => {
      var idxHash = this.state.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial
      );

      console.log("idxHash", idxHash);
      console.log("addr: ", this.state.addr);

      this.state.storage.methods
        .retrieveRecord(idxHash)
        .call({ from: this.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            self.setState({ result: Object.values(_result) });
            self.setState({ error: undefined });
            console.log(Object.values(_result));
          }
        });

      console.log(this.state.result);
    };

    return (
    <div>
      <Form className="RRform">
        {this.state.addr === undefined && (
          <div className="errorResults">
            <h2>WARNING!</h2>
            <h3>Injected web3 not connected to form!</h3>
          </div>
        )}
        {this.state.addr > 0 && (
          <Form>
            <h2 className="NRheader">Search Records</h2>
            <br></br>
            <Form.Row>
              <Form.Group as={Col} controlId="formGridType">
                <Form.Label className="formFont">Type:</Form.Label>
                <Form.Control
                  placeholder="Type"
                  required
                  onChange={(e) => this.setState({ type: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridManufacturer">
                <Form.Label className="formFont">Manufacturer:</Form.Label>
                <Form.Control
                  placeholder="Manufacturer"
                  required
                  onChange={(e) =>
                    this.setState({ manufacturer: e.target.value })
                  }
                  size="lg"
                />
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

            {/* <Form.Row>
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
            </Form.Row> */}

            <Form.Row>
              <Form.Group className="buttonDisplay">
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={_retrieveRecord}
                >
                  Submit
                </Button>
              </Form.Group>
            </Form.Row>
            
            
          </Form>
        )}
      </Form>
      {this.state.result[5] === "0" && (
              <div className="RRresultserr">
                No Asset Found for Given Data 
              </div>
            )}

            {this.state.result[5] > 0 && ( //conditional rendering
              <div className="RRresults">
                Status:
                {this.state.result[3]}
                <br></br>
                Mod Count:
                {this.state.result[4]}
                <br></br>
                Asset Class :{this.state.result[5]}
                <br></br>
                Count :{this.state.result[6]} of {this.state.result[7]}
                <br></br>
                Ipfs1 Hash :{this.state.result[8]}
                <br></br>
                Ipfs2 Hash :{this.state.result[9]}
                <br></br>
                Token ID :{this.state.result[1]}
              </div>
            )}
      </div>
    );
  }
}

export default ModifyDescription;
