import React, { Component } from "react";
import returnStorageAbi from "./Storage_ABI";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class AddContract extends Component {
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
      result: "",
      authAddress: "",
      name: "",
      authLevel: "",
      storage: "",
    };
  }

  componentDidMount() {
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    var addrArray = returnAddresses();
    var _storage_addr = addrArray[0];
    const storage_abi = returnStorageAbi();

    const _storage = new _web3.eth.Contract(storage_abi, _storage_addr);

    this.setState({ storage: _storage });

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {
    const self = this;
    const addContract = () => {
      this.state.storage.methods
        .OO_addContract(
          this.state.name,
          this.state.authAddress,
          this.state.authLevel
        )
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("contract added under authLevel:", self.state.authLevel);
          console.log("tx receipt: ", receipt);
        });

      console.log(this.state.txHash);
    };

    return (
      <div>
        <Form className="ACForm">
          {this.state.addr === undefined && (
            <div className="VRresults">
              <h2>WARNING!</h2>
              Injected web3 not connected to form!
            </div>
          )}

          {this.state.addr > 0 && (
            <div>
              <h2 className="Headertext">Add Contract</h2>
              <br></br>

              <Form.Group as={Col} controlId="formGridContractName">
                <Form.Label className="formFont">Contract Name :</Form.Label>
                <Form.Control
                  placeholder="Contract Name"
                  required
                  onChange={(e) => this.setState({ name: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridContractAddress">
                <Form.Label className="formFont">Contract Address :</Form.Label>
                <Form.Control
                  placeholder="Contract Address"
                  required
                  onChange={(e) => this.setState({ authAddress: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridAuthLevel">
                <Form.Label className="formFont">Auth Level :</Form.Label>
                <Form.Control
                  placeholder="AuthLevel"
                  required
                  type="number"
                  onChange={(e) => this.setState({ authLevel: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group className="buttonDisplay">
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={addContract}
                >
                  Submit
                </Button>
              </Form.Group>
            </div>
          )}
        </Form>
      </div>
    );
  }
}

export default AddContract;
