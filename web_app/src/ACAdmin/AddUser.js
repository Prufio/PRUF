import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class AddUser extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      result: "",
      authAddr: "",
      userType: "",
      assetClass: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const addUser = () => {
      window.contracts.AC_MGR.methods
        .OO_addUser(
          this.state.authAddr,
          this.state.userType,
          window.assetClass
        )
        .send({ from: window.addr })
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
        <Form className="AUForm">
          {window.addr === undefined && (
            <div className="VRresults">
              <h2>User address unreachable</h2>
              Please connect web3 provider.
            </div>
          )}
          {window.assetClass === undefined && (
            <div className="errorResults">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass > 0 && (
            <div>
              <h2 className="Headertext">Add User</h2>
              <br></br>

              <Form.Group as={Col} controlId="formGridContractName">
                <Form.Label className="formFont">
                  User Address :
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
                  type="text"
                  onChange={(e) => this.setState({ userType: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group>
                <Button className="buttonDisplay"
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
