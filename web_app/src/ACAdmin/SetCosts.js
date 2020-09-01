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
      remintCost: 0,
      importCost: 0,
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
      window.contracts.AC_MGR.methods
        .ACTH_setCosts(
          window.assetClass,
          Number(this.state.newRecordCost)*1000000000000000000,
          Number(this.state.transferRecordCost)*1000000000000000000,
          Number(this.state.createNoteCost)*1000000000000000000,
          Number(this.state.remintCost)*1000000000000000000,
          Number(this.state.importCost)*1000000000000000000,
          Number(this.state.forceModCost)*1000000000000000000,
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
            window.assetClass
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
          {window.assetClass === undefined && (
            <div className="errorResults">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass > 0 &&(
            <div>
              <h2 className="Headertext">Set Costs</h2>
              <br></br>

              <Form.Group as={Col} controlId="formGridNewRecordCost">
                <Form.Label className="formFont">New record :</Form.Label>
                <Form.Control
                  placeholder="New Record Cost (ETH)"
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
                  placeholder="Transfer Asset Cost (ETH)"
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
                  placeholder="Add Note Cost (ETH)"
                  required
                  onChange={(e) =>
                    this.setState({ createNoteCost: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridRemintCost">
                <Form.Label className="formFont">Remint Asset :</Form.Label>
                <Form.Control
                  placeholder="Remint Asset Cost (ETH)"
                  required
                  onChange={(e) => this.setState({ remintCost: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridImportCost">
                <Form.Label className="formFont">Import Asset :</Form.Label>
                <Form.Control
                  placeholder="Import Asset Cost (ETH)"
                  required
                  onChange={(e) => this.setState({ importCost: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridForceModCost">
                <Form.Label className="formFont">
                  Force Modify Record :
                </Form.Label>
                <Form.Control
                  placeholder="Force Modify Record Cost (ETH)"
                  required
                  onChange={(e) =>
                    this.setState({ forceModCost: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridPaymentAddr">
                <Form.Label className="formFont">
                  Beneficiary Address :
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
