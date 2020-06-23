import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class Ownership extends Component {
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
      newOwner: "",
      toggle: false,
      assetClass: "",
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

    const toggleRenounce = () => {
      if (this.state.toggle === false) {
        this.setState({ toggle: true });
        alert(
          "You are about to renounce the current storage contract. Proceed with caution."
        );
      } else {
        this.setState({ toggle: false });
      }
    };

    const renounce = () => {
      this.state.storage.methods
        .renounceOwnership()
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("Ownership renounced");
          console.log("tx receipt: ", receipt);
        });

      console.log(this.state.txHash);
    };

    const transfer = () => {
      this.state.storage.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("Ownership Transferred to: ", self.state.newOwner);
          console.log("tx receipt: ", receipt);
        });

      console.log(this.state.txHash);
    };

    return (
      <div>
        <Form className="OForm">
          {this.state.addr === undefined && (
            <div className="VRresults">
              <h2>WARNING!</h2>
              Injected web3 not connected to form!
            </div>
          )}

          {this.state.addr > 0 && this.state.toggle === false && (
            <div>
              <h2 className="Headertext">Transfer Ownership</h2>
              <br></br>
              <Form.Group as={Col} controlId="formGridNewOwner">
                <Form.Label className="formFont">New Owner :</Form.Label>
                <Form.Control
                  placeholder="New Owner Address"
                  required
                  onChange={(e) => this.setState({ newOwner: e.target.value })}
                  size="lg"
                />
              </Form.Group>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={transfer}
                  >
                    Transfer
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
                    onClick={toggleRenounce}
                  >
                    Renounce
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}

          {this.state.addr > 0 && this.state.toggle === true && (
            <div>
              <h2 className="Headertext">Renounce Ownership?</h2>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay3"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={renounce}
                  >
                    Confirm
                  </Button>
                </Form.Group>
              </div>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay4"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={toggleRenounce}
                  >
                    Go Back
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}
        </Form>
      </div>
    );
  }
}
export default Ownership;
