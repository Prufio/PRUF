import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class SetCosts extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    //Component state declaration

    this.state = {
      addr: "",
      error: undefined,
      result: "",
      authAddr: "",
      paymentAddr: "",
      userType: "",
      assetClass: "",
      web3: null,

      newRecordCost: 0,
      transferRecordCost: 0,
      createNoteCost: 0,
      cost4: 0,
      cost5: 0,
      forceModCost: 0,
 
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
  
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate(){//stuff to do when state updates

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const setCosts = () => {
      window.contracts.STOR.methods
        .ACTH_setCosts(
          window.assetClass,
          this.state.newRecordCost,
          this.state.transferRecordCost,
          this.state.createNoteCost,
          this.state.cost4,
          this.state.cost5,
          this.state.forceModCost,
          this.state.paymentAddr
        )

        .send({ from: window.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log(
            "costs succesfully updated under asset class",
            self.state.assetClass
          );
          console.log("tx receipt: ", receipt);
        });

      console.log(this.state.txHash);
    };

    return (
      <div>
        <Form className="SCForm">
          {window.addr === undefined && (
            <div className="VRresults">
              <h2>User address unreachable</h2>
              Please connect web3 provider.
            </div>
          )}

          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Set Function Costs</h2>
              <br></br>

              <Form.Group as={Col} controlId="formGridAssetClassCost">
                <Form.Label className="formFont">Asset Class :</Form.Label>
                <Form.Control
                  placeholder="Asset Class Cost"
                  required
                  onChange={(e) =>
                    this.setState({ assetClass: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridNewRecordCost">
                <Form.Label className="formFont">New record :</Form.Label>
                <Form.Control
                  placeholder="New Record Cost"
                  required
                  onChange={(e) =>
                    this.setState({ newRecordCost: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridTransferAssetCost">
                <Form.Label className="formFont">Transfer Asstet :</Form.Label>
                <Form.Control
                  placeholder="Transfer Asset Cost"
                  required
                  onChange={(e) =>
                    this.setState({ transferRecordCost: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridAddNoteCost">
                <Form.Label className="formFont">Add Note :</Form.Label>
                <Form.Control
                  placeholder="Add Note Cost"
                  required
                  onChange={(e) =>
                    this.setState({ createNoteCost: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridCost4Cost">
                <Form.Label className="formFont">Cost 4 :</Form.Label>
                <Form.Control
                  placeholder="Cost 4 Cost"
                  required
                  onChange={(e) => this.setState({ cost4: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridCost5Cost">
                <Form.Label className="formFont">Cost 5 :</Form.Label>
                <Form.Control
                  placeholder="Cost 5 Cost"
                  required
                  onChange={(e) => this.setState({ cost5: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridForceModCost">
                <Form.Label className="formFont">
                  Force Modify Record :
                </Form.Label>
                <Form.Control
                  placeholder="Force Modify Record Cost"
                  required
                  onChange={(e) =>
                    this.setState({ forceModCost: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridPaymentAddr">
                <Form.Label className="formFont">
                  Payment Address :
                </Form.Label>
                <Form.Control
                  placeholder="Payment Address"
                  required
                  onChange={(e) =>
                    this.setState({ paymentAddr: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group className="buttonDisplay">
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={setCosts}
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

export default SetCosts;
