import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class IncreaseACShare extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      result: "",
      authAddress: "",
      amount: "",
      assetClass: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    if (window.assetClass !== undefined) {
      this.setState({ assetClass: window.assetClass })
      console.log("updating AC")
    }
  }

  componentDidUpdate() {//stuff to do when state updates
    if (window.assetClass !== undefined && this.state.assetClass < 1) {
      this.setState({ assetClass: window.assetClass })
      console.log("updating AC")
    }

    if (window.assetClass === undefined) {
      console.log("window not serving AC")
    }
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    //console.log("unmounting component")
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;
    const increaseACShare = () => {
      console.log(this.state.amount)
      console.log(this.state.assetClass)
      window.contracts.UTIL_TKN.methods
        .increaseShare(
          this.state.assetClass,
          this.state.amount
        )
        .send({ from: window.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("tx receipt: ", receipt);
        });

      console.log(this.state.txHash);
    };

    return (
      <div>
        <Form className="ECForm">
          {window.addr === undefined && (
            <div className="VRresults">
              <h2>User address unreachable</h2>
              Please connect web3 provider.
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Increase Share</h2>
              <br></br>
              <Form.Group as={Col} controlId="formGridAssetClass">
                <Form.Label className="formFont">Asset Class :</Form.Label>
                <Form.Control
                  placeholder="Asset Class"
                  required
                  onChange={(e) => this.setState({ assetClass: e.target.value })}
                  size="lg"
                />
              </Form.Group>
              <Form.Group as={Col} controlId="formGridShareIncrease">
                <Form.Label className="formFont">Share Increase Amount :</Form.Label>
                <Form.Control
                  placeholder="Share Increase"
                  required
                  type="text"
                  onChange={(e) => this.setState({ amount: e.target.value })}
                  size="lg"
                />
              </Form.Group>
              <Form.Group className="buttonDisplay">
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={increaseACShare}
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

export default IncreaseACShare;
