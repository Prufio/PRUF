import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";


class ModifyRecordStatus extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      assetClass: undefined,
      ipfs1: "",
      status: "0",
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

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

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
      || this.state.serial === "" 
      || this.state.first === "" 
      || this.state.middle === "" 
      || this.state.surname === "" 
      || this.state.id === "" 
      || this.state.secret === "") {
        return alert("Please fill out all fields before submission")
      }

      let idxHash = window.web3.utils.soliditySha3(
        String(this.state.type),
        String(this.state.manufacturer),
        String(this.state.model),
        String(this.state.serial),
      );

      let rgtRaw = window.web3.utils.soliditySha3(
        String(this.state.first),
        String(this.state.middle),
        String(this.state.surname),
        String(this.state.id),
        String(this.state.secret)
      );

      let rgtHash = window.web3.utils.soliditySha3(String(idxHash), String(rgtRaw));

      var doesExist = await window.utils.checkAssetExists(idxHash);
      var infoMatches = await window.utils.checkMatch(idxHash, rgtHash);

      if (!doesExist) {
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      if (!infoMatches) {
        return alert("Owner data fields do not match data on record. Ensure data fields are correct before submission.")
      }

      return this.setState({ 
        idxHash: idxHash,
        rgtHash: rgtHash,
        accessPermitted: true
       })

    }

    const _modifyStatus = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;
      var rgtHash = this.state.rgtHash;

      console.log("idxHash", idxHash);
      console.log("rgtHash", rgtHash);
      console.log("addr: ", window.addr);

      if (this.state.status !== "3" && this.state.status !== "4" && this.state.status !== "6" && this.state.status !== "9" && this.state.status !== "10"){
        window.contracts.NP.methods
          ._modStatus(idxHash, rgtHash, this.state.status)
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
      }

      else if (this.state.status === "3" || this.state.status === "4" || this.state.status === "10" || this.state.status === "10") {
        window.contracts.NP.methods
          ._setLostOrStolen(idxHash, rgtHash, this.state.status)
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
      }

      else { alert("Invalid status input") }

      console.log(this.state.txHash);

      await this.setState({
        idxHash: "",
        rgtHash: "",
        accessPermitted: false
      })

      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}{window.assetClass === undefined && (
            <div className="errorResults">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass > 0 && (
            <div>

              <h2 className="Headertext">Change Asset Status</h2>
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
                <Form.Group >
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
                <Form.Group as={Col} controlId="formGridFormat">
                  <Form.Label className="formFont">New Status:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ status: e.target.value })}>
                    <option value="0">Choose a status</option>
                    <option value="1">Transferrable</option>
                    <option value="2">Non-transferrable</option>
                    <option value="3">Stolen</option>
                    <option value="4">Lost</option>
                    <option value="51">Export-ready</option>
                  </Form.Control>
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group >
                    <Button className="buttonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_modifyStatus}
                  >
                    Update Status
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
          </Form.Row>
        )}
        </div>
      </div>
    );
  }
}

export default ModifyRecordStatus;
