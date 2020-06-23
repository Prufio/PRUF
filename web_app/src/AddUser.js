import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class AddUser extends Component {
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
      authAddr: "",
      userType: "",
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
    var _frontend_addr = addrArray[1];
    var _storage_addr = addrArray[0];
    const storage_abi = returnStorageAbi();
    const frontEnd_abi = returnFrontEndAbi();
    const _storage = new _web3.eth.Contract(storage_abi, _storage_addr);
    const _frontend = new _web3.eth.Contract(frontEnd_abi, _frontend_addr);

    this.setState({ storage: _storage });
    this.setState({ frontend: _frontend });

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {
    const self = this;

    const addUser = () => {
      this.state.frontend.methods
        .OO_addUser(
          this.state.authAddr,
          this.state.userType,
          this.state.assetClass
        )
        .send({ from: this.state.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log(
            "user added succesfully under asset class",
            self.state.assetClass
          );
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
            <Form>
              <h2 className="Headertext">Add User</h2>
              <br></br>

              <Form.Group as={Col} controlId="formGridContractName">
                <Form.Label className="formFont">
                  Authorized Address :
                </Form.Label>
                <Form.Control
                  placeholder="Authorized Address"
                  required
                  onChange={(e) => this.setState({ authAddr: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridACClass">
                <Form.Label className="formFont">User Type :</Form.Label>
                <Form.Control
                  placeholder="User Type"
                  required
                  type="number"
                  onChange={(e) => this.setState({ userType: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridACClass">
                <Form.Label className="formFont">Auth Asset Class :</Form.Label>
                <Form.Control
                  placeholder="Auth Asset Class"
                  required
                  type="number"
                  onChange={(e) =>
                    this.setState({ assetClass: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group className="buttonDisplay">
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={addUser}
                >
                  Submit
                </Button>
              </Form.Group>
            </Form>
          )}
        </Form>
      </div>
    );
  }
}

export default AddUser;
