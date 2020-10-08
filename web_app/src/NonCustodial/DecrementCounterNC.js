import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import { ArrowRightCircle, Home, XSquare } from 'react-feather'

class DecrementCounterNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.updateAssets = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }

      if (this.state.hasLoadedAssets !== window.hasLoadedAssets && this.state.runWatchDog === true) {
        this.setState({ hasLoadedAssets: window.hasLoadedAssets })
      }
    }, 100)

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
      hasLoadedAssets: false,
      assets: { descriptions: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] },
      transaction: undefined,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    if (window.sentPacket !== undefined) {
      this.setState({ name: window.sentPacket.name })
      this.setState({ idxHash: window.sentPacket.idxHash })
      this.setState({ assetClass: window.sentPacket.assetClass })
      this.setState({ status: window.sentPacket.status })
      window.sentPacket = undefined
      this.setState({ wasSentPacket: true })
    }

    this.setState({runWatchDog: true})

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ idxHash: undefined, txStatus: undefined, txHash: "0" })
    }

    const _checkIn = async (e) => {
      if (e === "null" || e === undefined) { 
        return clearForm()
      }
      else if (e === "reset") {
        return window.resetInfo = true;
      }
      else if (e === "assetDash"){
        return window.location.href = "/#/asset-dashboard"
      }
      this.setState({ selectedAsset: e })
      console.log("Changed component idx to: ", window.assets.ids[e])

      this.setState({
        assetClass: window.assets.assetClasses[e],
        idxHash: window.assets.ids[e],
        name: window.assets.descriptions[e].name,
        photos: window.assets.descriptions[e].photo,
        text: window.assets.descriptions[e].text,
        description: window.assets.descriptions[e],
        status: window.assets.statuses[e],
      })
    }

    const _decrementCounter = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);
      console.log("Data: ", this.state.countDown);

      await window.contracts.NP_NC.methods
        ._decCounter(idxHash, this.state.countDown)
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

      console.log(this.state.txHash);
      return document.getElementById("MainForm").reset();
    };
    if (this.state.wasSentPacket) {
      return (
        <div>
          <div>
            <div className="mediaLinkAD-home">
              <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
            </div>
            <h2 className="FormHeader">Decrement Counter</h2>
            <div className="mediaLink-clearForm">
              <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { clearForm() }} /></a>
            </div>
          </div>
          <Form className="Form" id='MainForm'>
            {window.addr === undefined && (
              <div className="Results">
                <h2>User address unreachable</h2>
                <h3>Please connect web3 provider.</h3>
              </div>
            )}
            {window.addr > 0 && (
              <div>
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
                  <div className="submitButtonDC2">
                    <div className="submitButtonDC2-content">
                      <ArrowRightCircle
                        onClick={() => { _decrementCounter() }}
                      />
                    </div>
                  </div>
                </Form.Row>
              </div>
            )}
          </Form>
          <div className="assetSelectedResults">
            <Form.Row>
              {this.state.idxHash !== undefined && (
                <Form.Group>
                  <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                  <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                  {/* <div className="assetSelectedContentHead"> Asset Description: <span className="assetSelectedContent">{this.state.description}</span> </div> */}
                  <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                  <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
                </Form.Group>
              )}
            </Form.Row>
          </div>
          {this.state.transaction === true && (

            <div className="Results">
              {/* {this.state.pendingTx === undefined && ( */}
              <p class="loading">Transaction In Progress</p>
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
    return (
      <div>
        <div>
          <div className="mediaLinkAD-home">
            <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
          </div>
          <h2 className="FormHeader">Decrement Counter</h2>
          <div className="mediaLink-clearForm">
            <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { clearForm() }} /></a>
          </div>
        </div>
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="Results">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridAsset">
                  <Form.Label className="formFont"> Select an Asset to Modify :</Form.Label>
                  <Form.Control
                    as="select"
                    size="lg"
                    onChange={(e) => { _checkIn(e.target.value) }}
                  >
                    {this.state.hasLoadedAssets && (
                    <optgroup className="optgroup">

                    {window.utils.generateAssets()}
                    </optgroup>)}
                    {!this.state.hasLoadedAssets && (<optgroup ><option value="null"> Loading Assets... </option></optgroup>)}

                  </Form.Control>
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
                <div className="submitButtonDC">
                  <div className="submitButtonDC-content">
                    <ArrowRightCircle
                      onClick={() => { _decrementCounter() }}
                    />
                  </div>
                </div>
              </Form.Row>
            </div>
          )}
        </Form>
        <div className="assetSelectedResults">
          <Form.Row>
            {this.state.idxHash !== undefined && (
              <Form.Group>
                <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                {/* <div className="assetSelectedContentHead"> Asset Description: <span className="assetSelectedContent">{this.state.description}</span> </div> */}
                <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
              </Form.Group>
            )}
          </Form.Row>
        </div>
        {this.state.transaction === true && (

          <div className="Results">
            {/* {this.state.pendingTx === undefined && ( */}
            <p class="loading">Transaction In Progress</p>
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

export default DecrementCounterNC;
