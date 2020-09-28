import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";


class ModifyRecordStatusNC extends Component {
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
      isNFA: false,
      transaction: undefined,
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

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;



    const _modifyStatus = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;

      console.log("idxHash", idxHash);

      console.log("addr: ", window.addr);

      var doesExist = await window.utils.checkAssetExists(idxHash);

      if (!doesExist){
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      if (this.state.status !== "53" && this.state.status !== "54" && this.state.status !== "56" && this.state.status !== "59"){
        window.contracts.NP_NC.methods
          ._modStatus(idxHash, this.state.status)
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
            window.resetInfo = true;
            //Stuff to do when tx confirms
          });
      }

      else if (this.state.status === "53" || this.state.status === "54"){
        window.contracts.NP_NC.methods
          ._setLostOrStolen(idxHash, this.state.status)
          .send({ from: window.addr })
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
      }

      else { alert("Invalid status input") }

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
          )}{this.state.idxHash === undefined && (
            <div className="errorResults">
              <h2>No asset selected.</h2>
              <h3>Please select asset in the dashboard to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && this.state.idxHash !== undefined &&(
            <div>

              <h2 className="Headertext">Change Asset Status</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridFormat">
                  <Form.Label className="formFont">New Status:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ status: e.target.value })}>
                    <option value="0">Choose a status</option>
                    <option value="51">Transferrable</option>
                    <option value="52">Non-transferrable</option>
                    <option value="53">Stolen</option>
                    <option value="54">Lost</option>
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
                    Submit
                  </Button>
                </Form.Group>
              </Form.Row>
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

export default ModifyRecordStatusNC;
