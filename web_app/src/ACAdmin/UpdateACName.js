import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class UpdateACName extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      result: "",
      newACName: "",
      assetClass: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    console.log("component mounted")
  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const updateName = async () => {
      var alreadyExists = await window.utils.checkACName(this.state.newACName)

      if (alreadyExists) {
        return (alert("AC name already exists! Choose a different name and try again"))
      }
      else {
        await window.contracts.AC_MGR.methods
          .updateACname(
            this.state.newACName,
            window.assetClass
          )
          .send({ from: window.addr })
          .on("error", function (_error) {
            self.setState({ error: _error });
            self.setState({ result: _error.transactionHash });
          })
          .on("receipt", (receipt) => {
            console.log(
              "updated name to ", self.state.newACName, " in AC ",
              window.assetClass
            );
            console.log("tx receipt: ", receipt);
          });

        console.log(this.state.txHash);
      };
    }


    return (
      <div>
        <Form className="Form">
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
              <h2 className="Headertext">Update AC Name</h2>
              <br></br>
              <Form.Group as={Col} controlId="formGridContractName">
                <Form.Label className="formFont">New AC Name :</Form.Label>
                <Form.Control
                  placeholder="AC Name"
                  required
                  onChange={(e) => this.setState({ newACName: e.target.value })}
                  size="lg"
                />
              </Form.Group>
              
              <Form.Group>
                <Button className="buttonDisplay"
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={updateName}
                >
                  Update
                </Button>
              </Form.Group>
            </div>
          )}
        </Form>
      </div>
    );
  }
}

export default UpdateACName;
