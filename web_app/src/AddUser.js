import React, { Component } from "react";
import RCFJ from "./RetrieveContractsFromJSON"
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

let contracts;

async function setupContractEnvironment(_web3) {
    contracts = window.contracts;
}

class AddUser extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

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
      web3: null,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    setupContractEnvironment(_web3)
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    document.addEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate(){//stuff to do when state updates
    if(this.state.web3 !== null && this.state.web3 !== undefined && this.state.STOR < 1){
      this.getContracts();
    }

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const addUser = () => {
      this.state.AC_MGR.methods
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
