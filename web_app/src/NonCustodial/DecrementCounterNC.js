import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class DecrementCounterNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      NRerror: undefined,
      result: "",
      assetClass: undefined,
      countDown: "",
      txHash: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      txStatus: false,
      id: "",
      secret: "",
      isNFA: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    async function checkExists(idxHash) {
      await window.contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
            alert(
              "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
            );
          } else {
            self.setState({ result: _result });
          }
          console.log("check debug, _result, _error: ", _result, _error);
        });
    }

    async function checkMatch(idxHash, rgtHash) {
      await window.contracts.STOR.methods
        ._verifyRightsHolder(idxHash, rgtHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
          } else if (_result === "0") {
            self.setState({ result: 0 });
            alert(
              "WARNING: Record DOES NOT MATCH supplied owner info! Reject in metamask and review owner info fields."
            );
          } else {
            self.setState({ result: _result });
          }
          console.log("check debug, _result, _error: ", _result, _error);
        });
    }

    const _decrementCounter = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash;

      idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
      );

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);
      console.log("Data: ", this.state.countDown);

      var doesExist = await window.utils.checkAssetExists(idxHash);
      var noteExists = await window.utils.checkNoteExists(idxHash);

      if (!doesExist){
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      window.contracts.NP_NC.methods
        ._decCounter(idxHash, this.state.countDown)
        .send({ from: window.addr })
        .on("error", function (_error) {
          // self.setState({ NRerror: _error });
          self.setState({ txHash: Object.values(_error)[0].transactionHash });
          self.setState({ txStatus: false });
          console.log(Object.values(_error)[0].transactionHash);
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          console.log(receipt.status);
          //Stuff to do when tx confirms
        });

      console.log(this.state.txHash);
      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <Form className="threeRowForm" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Decrement Counter</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>
                  <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridManufacturer">
                  <Form.Label className="formFont">Manufacturer:</Form.Label>
                  <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridModel">
                  <Form.Label className="formFont">Model:</Form.Label>
                  <Form.Control
                    placeholder="Model"
                    required
                    onChange={(e) => this.setState({ model: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridSerial">
                  <Form.Label className="formFont">Serial:</Form.Label>
                  <Form.Control
                    placeholder="Serial"
                    required
                    onChange={(e) => this.setState({ serial: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>
            <Form.Row>
                <Form.Group as={Col} controlId="formGridCountdown">
                  <Form.Label className="formFont">
                    Countdown Amount:
                  </Form.Label>
                  <Form.Control
                    placeholder="Countdown Amount"
                    required
                    onChange={(e) =>
                      this.setState({ countDown: e.target.value })
                    }
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>
              <Form.Row>
                <Form.Group >
                    <Button className="buttonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_decrementCounter}
                  >
                    Submit
                  </Button>
                </Form.Group>
              </Form.Row>
            </div>
          )}
        </Form>
        {this.state.txHash > 0 && ( //conditional rendering
          <div className="Results">
            {this.state.txStatus === false && (
              <div>
                !ERROR! :
                <a
                  href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  KOVAN Etherscan:{this.state.txHash}
                </a>
              </div>
            )}
            {this.state.txStatus === true && (
              <div>
                {" "}
                No Errors Reported :
                <a
                  href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  KOVAN Etherscan:{this.state.txHash}
                </a>
              </div>
            )}
          </div>
        )}
      </div>
    );
  }
}

export default DecrementCounterNC;
