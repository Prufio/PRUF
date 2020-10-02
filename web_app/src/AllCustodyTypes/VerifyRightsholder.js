import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class VerifyRightHolder extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      error1: undefined,
      result: "",
      result1: "",
      assetClass: undefined,
      ipfs1: "",
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      isNFA: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _accessAsset = async () => {

      if (this.state.manufacturer === ""
        || this.state.type === ""
        || this.state.model === ""
        || this.state.serial === "") {
        return alert("Please fill out all fields before submission")
      }

      let idxHash = window.web3.utils.soliditySha3(
        String(this.state.type),
        String(this.state.manufacturer),
        String(this.state.model),
        String(this.state.serial),
      );

      // let rgtRaw = window.web3.utils.soliditySha3(
      //   String(this.state.first),
      //   String(this.state.middle),
      //   String(this.state.surname),
      //   String(this.state.id),
      //   String(this.state.secret)
      // );

      // console.log("idxHash", idxHash);
      // console.log("rgtHash", rgtHash);

      // let rgtHash = window.web3.utils.soliditySha3(String(idxHash), String(rgtRaw));

      let doesExist = await window.utils.checkAssetExists(idxHash);

      if (!doesExist) {
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      console.log("idxHash", idxHash);
      // console.log("rgtHash", rgtHash);

      return this.setState({
        idxHash: idxHash,
        // rgtHash: rgtHash,
        accessPermitted: true
      })

    }

    const _verify = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;


      let rgtRaw = window.web3.utils.soliditySha3(
        String(this.state.first),
        String(this.state.middle),
        String(this.state.surname),
        String(this.state.id),
        String(this.state.secret)
      );
      let rgtHash = window.web3.utils.soliditySha3(String(idxHash), String(rgtRaw));


      // var rgtHash = this.state.rgtHash;

      console.log("idxHash", idxHash);
      console.log("rgtHash", rgtHash);
      console.log("addr: ", window.addr);

      window.contracts.STOR.methods
        .blockchainVerifyRightsHolder(idxHash, rgtHash)
        .send({ from: window.addr })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          console.log(receipt.events.REPORT.returnValues._msg);
          this.setState({ result: receipt.events.REPORT.returnValues._msg })
        });

      console.log(this.state.result);

      await this.setState({
        idxHash: "",
        rgtHash: "",
        accessPermitted: false
      })

      document.getElementById("MainForm").reset();

    };
    return (
      <div>
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="Results">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Deep Verify:</h2>
              <br></br>
              {!this.state.accessPermitted && (
                <>
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
                    <Form.Group>
                      <Button className="buttonDisplay"
                        variant="primary"
                        type="button"
                        size="lg"
                        onClick={_accessAsset}
                      >
                        Access Asset
                  </Button>
                    </Form.Group>
                  </Form.Row>
                </>
              )}
              {this.state.accessPermitted && (
                <>
                  <Form.Row>
                    <Form.Group as={Col} controlId="formGridFirstName">
                      <Form.Label className="formFont">First Name:</Form.Label>
                      <Form.Control
                        placeholder="First Name"
                        required
                        onChange={(e) => this.setState({ first: e.target.value })}
                        size="lg"
                      />
                    </Form.Group>

                    <Form.Group as={Col} controlId="formGridMiddleName">
                      <Form.Label className="formFont">Middle Name:</Form.Label>
                      <Form.Control
                        placeholder="Middle Name"
                        required
                        onChange={(e) => this.setState({ middle: e.target.value })}
                        size="lg"
                      />
                    </Form.Group>

                    <Form.Group as={Col} controlId="formGridLastName">
                      <Form.Label className="formFont">Last Name:</Form.Label>
                      <Form.Control
                        placeholder="Last Name"
                        required
                        onChange={(e) => this.setState({ surname: e.target.value })}
                        size="lg"
                      />
                    </Form.Group>
                  </Form.Row>

                  <Form.Row>
                    <Form.Group as={Col} controlId="formGridIdNumber">
                      <Form.Label className="formFont">ID Number:</Form.Label>
                      <Form.Control
                        placeholder="ID Number"
                        required
                        onChange={(e) => this.setState({ id: e.target.value })}
                        size="lg"
                      />
                    </Form.Group>

                    <Form.Group as={Col} controlId="formGridPassword">
                      <Form.Label className="formFont">Password:</Form.Label>
                      <Form.Control
                        placeholder="Password"
                        type="password"
                        required
                        onChange={(e) => this.setState({ secret: e.target.value })}
                        size="lg"
                      />
                    </Form.Group>
                  </Form.Row>
                  <Form.Row>
                    <Form.Group>
                      <Button className="buttonDisplay"
                        variant="primary"
                        type="button"
                        size="lg"
                        onClick={_verify}
                      >
                        Verify Match
                  </Button>
                    </Form.Group>
                  </Form.Row>
                </>
              )}
            </div>
          )}
        </Form>
        <div className="Results">
        {this.state.txHash > 0 && ( //conditional rendering
          <Form.Row>
            {this.state.result === "Match confirmed"
              ? "Match Confirmed"
              : "No Match Found"}
            <a
              href={" https://kovan.etherscan.io/tx/" + this.state.txHash}
              target="_blank"
              rel="noopener noreferrer"
            >
              KOVAN Etherscan:{this.state.txHash}
            </a>
          </Form.Row>
        )}
        </div>
      </div>
    );
  }
}
export default VerifyRightHolder;
