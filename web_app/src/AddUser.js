import React, { Component } from "react";
import returnContracts from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class AddUser extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

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
      PRUF_APP: "",
      PRUF_NP: "",
      PRUF_AC_manager: "",
      PRUF_simpleEscrow: "",
      web3: null,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    document.addEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate(){//stuff to do when state updates
    if(this.state.web3 !== null && this.state.web3 !== undefined && this.state.storage < 1){
      this.returnsContract();
    }

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const addUser = () => {
      this.state.PRUF_AC_manager.methods
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
            <div>
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
            </div>
          )}
        </Form>
      </div>
    );
  }
}

export default AddUser;
