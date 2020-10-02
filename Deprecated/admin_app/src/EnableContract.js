import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class enableContract extends Component {
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
      assetClass: undefined,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    if (window.assetClass !== undefined){
      this.setState({assetClass: window.assetClass})
      console.log("updating AC")
    }
  }

  componentDidUpdate(){//stuff to do when state updates
    if (window.assetClass !== undefined && this.state.assetClass < 1){
      this.setState({assetClass: window.assetClass})
      console.log("updating AC")
    }

    if (window.assetClass === undefined){
      console.log("window not serving AC")
    }
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;
    const enableContract = () => {
      console.log(this.state.name)
      console.log(this.state.assetClass)
      console.log(this.state.authLevel)
      window.contracts.STOR.methods
        .enableContractForAC(
          this.state.name,
          this.state.assetClass,
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
          {window.assetClass === undefined && (
            <div className="Results">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass > 0 &&(
            <div>
              <h2 className="Headertext">Enable Contract</h2>
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

              <Form.Group>
                <Button className="buttonDisplay"
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={enableContract}
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

export default enableContract;
