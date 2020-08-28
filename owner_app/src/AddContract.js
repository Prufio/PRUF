import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class AddContract extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      result: "",
      authAddress: "",
      name: "",
      authLevel: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentDidUpdate(){//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;
    const addContract = () => {
      window.contracts.STOR.methods
        .OO_addContract(
          this.state.name,
          this.state.authAddress,
          "0",
          this.state.authLevel
        )
        .send({ from: window.addr })
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
          {window.addr === undefined && (
            <div className="VRresults">
              <h2>User address unreachable</h2>
              Please connect web3 provider.
            </div>
          )}

          {window.addr > 0 && (
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
