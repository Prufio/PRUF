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
      beneficiary: "",
      userType: "",
      assetClass: "",
      web3: null,
      serviceIndex: "",

      serviceCost: 0,

    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const setCosts = () => {
      window.contracts.AC_MGR.methods
        .ACTH_setCosts(
          window.assetClass,
          this.state.serviceIndex,
          Number(this.state.serviceCost) * 1000000000000000000,
          this.state.beneficiary
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
              <h2 className="Headertext">Set Costs</h2>
              <br></br>

              <Form.Group as={Col} controlId="formGridService">
                <Form.Label className="formFont">Service index # :</Form.Label>
                <Form.Control
                  placeholder="Service Index Number"
                  required
                  onChange={(e) =>
                    this.setState({ serviceIndex: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridNewCost">
                <Form.Label className="formFont">New Service Cost :</Form.Label>
                <Form.Control
                  placeholder="New Service Cost (ETH)"
                  required
                  onChange={(e) =>
                    this.setState({ serviceCost: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridBeneficiary">
                <Form.Label className="formFont">Beneficiary Address :</Form.Label>
                <Form.Control
                  placeholder="Beneficiary Address"
                  required
                  onChange={(e) =>
                    this.setState({ beneficiary: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group>
                <Button className="buttonDisplay"
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={setCosts}
                >
                  Update Cost
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
