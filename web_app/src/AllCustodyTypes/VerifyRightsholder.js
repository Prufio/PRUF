import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import { Home, XSquare, ArrowRightCircle, Grid, CornerUpLeft, CheckCircle } from "react-feather";
import QrReader from 'react-qr-reader'
class VerifyRightHolder extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.accessAsset = async () => {
      let idxHash;
      if (this.state.QRreader === false) {
        if (this.state.manufacturer === ""
          || this.state.type === ""
          || this.state.model === ""
          || this.state.serial === "") {
          return alert("Please fill out all fields before submission")
        }


        idxHash = window.web3.utils.soliditySha3(
          String(this.state.type),
          String(this.state.manufacturer),
          String(this.state.model),
          String(this.state.serial),
        );
      }
      else {
        idxHash = this.state.result
      }

      let doesExist = await window.utils.checkAssetExists(idxHash);

      if (!doesExist) {
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      console.log("idxHash", idxHash);
      // console.log("rgtHash", rgtHash);

      return this.setState({
        idxHash: idxHash,
        QRreader: false,
        accessPermitted: true
      })

    }

    this.state = {
      addr: "",
      error: undefined,
      error1: undefined,
      result: "",
      DVresult: "",
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
      QRreader: false,
      isNFA: false,
      transaction: false,
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

  handleScan = async (data) => {
    if (data) {
      let tempBool = await window.utils.checkAssetExists(data)
      if (tempBool === true) {
        this.setState({
          result: data,
          QRRR: true,
          assetFound: "Asset Found!"
        })
        console.log(data)
        this.accessAsset()
      }
      else {
        this.setState({
          assetFound: "Asset Not Found",
        })
      }
    }
  }

  handleError = err => {
    console.error(err)
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;


    const QRReader = async () => {
      if (this.state.QRreader === false) {
        this.setState({ QRreader: true, assetFound: "" })
      }
      else {
        this.setState({ QRreader: false })
      }
    }


    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ DVresult: "", accessPermitted: false, transaction: false, txHash: ""})
    }

    const _verify = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ DVresult: "" })
      this.setState({ transaction: true })
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
          this.setState({ transaction: false })
          console.log(receipt.events.REPORT.returnValues._msg);
          this.setState({ DVresult: receipt.events.REPORT.returnValues._msg })
        });

      console.log(this.state.DVresult);

      await this.setState({
        idxHash: "",
        rgtHash: "",
        accessPermitted: false
      })

      document.getElementById("MainForm").reset();

    };
    return (
      <div>
        {this.state.QRreader === false && (
          <div>
            <div className="mediaLinkAD-home">
              <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
            </div>
            <h2 className="FormHeader">Deep Verify</h2>
            <div className="mediaLink-clearForm">
              <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { clearForm() }} /></a>
            </div>
          </div>
        )}
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="Results">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              {!this.state.accessPermitted && this.state.QRreader === false && (
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
                  {this.state.transaction === false && (
                  <Form.Row>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <ArrowRightCircle
                          onClick={() => { this.accessAsset() }}
                        />
                      </div>
                    </div>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <Grid
                          onClick={() => { QRReader() }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                  )}
                </>
              )}
              {this.state.QRreader === true && (
                <div>
                  <div>
                    <div className="mediaLinkAD-home">
                      <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
                    </div>
                    <h2 className="FormHeader">Scan QR</h2>
                    <div className="mediaLink-back">
                      <a className="mediaLinkContent-back" ><CornerUpLeft onClick={() => { QRReader() }} /></a>
                    </div>
                  </div>
                  <div className="QRreader">
                    <QrReader
                      delay={300}
                      onError={this.handleError}
                      onScan={this.handleScan}
                      style={{ width: '100%', height: "100%" }}
                    />
                    {this.state.result !== undefined && (
                      <div className="Results">
                        {this.state.assetFound}
                      </div>
                    )}
                  </div>
                </div>
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
                  {this.state.transaction === false && (
                  <Form.Row>
                    <div className="submitButtonVRH2">
                      <div className="submitButtonVRH2-content">
                        <CheckCircle
                          onClick={() => { _verify() }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                  )}
                </>
              )}
            </div>
          )}
        </Form>
        {this.state.transaction === true && (
            <div className="Results">
              <p className="loading">Transaction In Progress</p>
            </div>
          )}
        {this.state.QRreader === false && this.state.transaction === false && (
          <div className="Results">
            {this.state.txHash > 0 && ( //conditional rendering
              <Form.Row>
                {this.state.DVresult === "Match confirmed"
                  ? "Match Confirmed :"
                  : "No Match Found :"}
                <a
                className="ResultLink"
                  href={" https://kovan.etherscan.io/tx/" + this.state.txHash}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  KOVAN Etherscan:{this.state.txHash}
                </a>
              </Form.Row>
            )}
          </div>
        )}
      </div>
    );
  }
}
export default VerifyRightHolder;
