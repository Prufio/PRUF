import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class EscrowManagerNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      costArray: [0],
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      assetClass: undefined,
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      newStatus: "",
      agent: "",
      timeFormat: "",
      isSettingEscrow: "0",
      escrowData: [],
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

    this.setState({
      idxHash: window.assetTokenInfo.idxHash,
      oldDescription: window.assetTokenInfo.description,
      assetClass: window.assetTokenInfo.assetClass,
      name: window.assetTokenInfo.name,
      status: window.assetTokenInfo.status
    })

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _accessAsset = async () => {
      const self = this;
      return this.setState({ 
        accessPermitted: true,
        escrowData: window.utils.getEscrowData(this.state.idxHash)
       })
    }

    const _setEscrow = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })

      var idxHash = this.state.idxHash;

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);
      console.log("time: ", this.state.escrowTime, "format: ", this.state.timeFormat);

      window.contracts.ECR_NC.methods
        .setEscrow(idxHash, window.web3.utils.soliditySha3(this.state.agent), window.utils.convertTimeTo(this.state.escrowTime, this.state.timeFormat), this.state.newStatus)
        .send({ from: window.addr})
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
          window.resetInfo = true;
          //Stuff to do when tx confirms
        });
      console.log(this.state.txHash);
      return document.getElementById("MainForm").reset();
    };

    const _endEscrow = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})

        var idxHash = this.state.idxHash;
  
        console.log("idxHash", idxHash);
        console.log("addr: ", window.addr);
  
        window.contracts.ECR_NC.methods
          .endEscrow(idxHash)
          .send({ from: window.addr})
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ transaction: false })
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            self.setState({ transaction: false })
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            window.resetInfo = true;
            //Stuff to do when tx confirms
          });
        console.log(this.state.txHash);

        await this.setState({
          accessPermitted: false,
          isSettingEscrow: "0",
          agent: "",
          newStatus: "",
          escrowTime: "",
          timeFormat: ""
        })

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
          )}{this.state.idxHash === undefined && (
            <div className="errorResults">
              <h2>No asset selected.</h2>
              <h3>Please select asset in the dashboard to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && this.state.idxHash !== undefined &&(
            <div>
              <h2 className="Headertext">Manage Escrow</h2>
              <br></br>
              {!this.state.accessPermitted && (
                <>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridFormatSetOrEnd">
                  <Form.Label className="formFont">Set or End?:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ isSettingEscrow: e.target.value })}>
                    <option value="0">Select an Action</option>
                    <option value="true">Set Escrow</option>
                    <option value="false">End Escrow</option>
                  </Form.Control>
                </Form.Group>
                </Form.Row>
              <Form.Row>
                  <Form.Group>
                  <Button
                    className="ownerButtonDisplay5"
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
              {this.state.accessPermitted && this.state.isSettingEscrow ==="true" && (
                <>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridAgent">
                  <Form.Label className="formFont">Agent Address:</Form.Label>
                  <Form.Control
                    placeholder="agent"
                    required
                    onChange={(e) => this.setState({ agent: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridStatus">
                  <Form.Label className="formFont">Escrow Status:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ newStatus: e.target.value })}>
                    <option value="0">Select an Escrow Status</option>
                    <option value="6">Supervised Escrow</option>
                    <option value="50">Locked Escrow</option>
                  </Form.Control>
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridTime">
                  <Form.Label className="formFont">Duration:</Form.Label>
                  <Form.Control
                    placeholder="setEscrow duration"
                    required
                    onChange={(e) => this.setState({ escrowTime: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridFormat">
                  <Form.Label className="formFont">Time Unit:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ timeFormat: e.target.value })}>
                    <option value="0">Select a time unit</option>
                    <option value="seconds">Seconds</option>
                    <option value="minutes">Minutes</option>
                    <option value="hours">Hours</option>
                    <option value="days">Days</option>
                    <option value="weeks">Weeks</option>
                  </Form.Control>
                </Form.Group>
              </Form.Row>
                <Form.Row>
                  <Form.Group>
                  <Button
                    className="ownerButtonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_setEscrow}
                  >
                    Set Escrow
                  </Button>
                </Form.Group>
                </Form.Row>
                </>
              )}
              {this.state.accessPermitted && this.state.isSettingEscrow === "false" && (
                <Form.Row>
                  <h2 fontWeight="bold" color="white">Escrow Agent: {this.state.escrowData[1]} 
                  <br></br> Escrow TimeLock: {this.state.escrowData[2]}<br></br></h2>
                  <Form.Group>
                  <Button
                    className="ownerButtonDisplay5"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_endEscrow}
                  >
                    End Escrow
                  </Button>
                </Form.Group>
                </Form.Row>
              )}
            </div>
          )}
        </Form>
        <div className="assetSelectedResults">
          <Form.Row>
            <Form.Group>
              <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{window.assetTokenInfo.idxHash}</span> </div>
              <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{window.assetTokenInfo.name}</span> </div>
              <div className="assetSelectedContentHead"> Asset Description: <span className="assetSelectedContent">{window.assetTokenInfo.oldDescription}</span> </div>
              <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{window.assetTokenInfo.assetClass}</span> </div>
              <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{window.assetTokenInfo.status}</span> </div>
            </Form.Group>
          </Form.Row>
        </div>
        {this.state.transaction === true && (

<div className="Results">
  {/* {this.state.pendingTx === undefined && ( */}
    <p class="loading">Transaction In Progress, Please Confirm Transaction</p>
  {/* )} */}
  {/* {this.state.pendingTx !== undefined && (
    <p class="loading">Transaction In Progress</p>
  )} */}
</div>)}
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

export default EscrowManagerNC;
