import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import { ArrowRightCircle, Home, TrendingUp, XSquare } from 'react-feather'

class EscrowManagerNC extends Component {
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
      hasLoadedAssets: false,
      assets: { descriptions: [0], notes: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] },
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    if (window.sentPacket !== undefined) {
      this.setState({ 
        name: window.sentPacket.name,
        idxHash: window.sentPacket.idxHash,
        assetClass: window.sentPacket.assetClass,
        status: window.sentPacket.status,
        wasSentPacket: true
       })
      window.sentPacket = undefined
    }

    this.setState({ runWatchDog: true })

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _accessAsset = async () => {
      if (this.state.isSettingEscrow === undefined || this.state.isSettingEscrow === "null") {
        return alert("Please Select an Action From the Dropdown")
      }
      return this.setState({
        accessPermitted: true,
        escrowData: window.utils.getEscrowData(this.state.idxHash)
      })
    }

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ idxHash: undefined, txStatus: undefined, txHash: "0", accessPermitted: undefined, wasSentPacket: undefined })
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

      if(this.state.newStatus <= 49){return alert("Cannot set status under 50 in non-custodial AC")}
      if(this.state.agent.substring(0,2) !== "0x"){return alert("Agent address invalid")}
      

      window.contracts.ECR_NC.methods
        .setEscrow(idxHash, window.web3.utils.soliditySha3(this.state.agent), window.utils.convertTimeTo(this.state.escrowTime, this.state.timeFormat), this.state.newStatus)
        .send({ from: window.addr })
        .on("error", function (_error) {
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

    const _checkIn = async (e) => {
      if (e === "0" || e === undefined) { return }
      else if (e === "reset") {
        return window.resetInfo = true;
      }
      else if (e === "assetDash"){
        return window.location.href = "/#/asset-dashboard"
      }
      this.setState({ selectedAsset: e })
      console.log("Changed component idx to: ", window.assets.ids[e])

      if(window.assets.statuses[e] === 6 || window.assets.statuses[e] === 50){
        this.setState({isSettingEscrow: false})
      }
      else if(window.assets.statuses[e] !== 6 && window.assets.statuses[e] !== 50 && window.assets.statuses[e] !== 56){
        this.setState({isSettingEscrow: true})
      }

      this.setState({
        assetClass: window.assets.assetClasses[e],
        idxHash: window.assets.ids[e],
        name: window.assets.descriptions[e].name,
        photos: window.assets.descriptions[e].photo,
        text: window.assets.descriptions[e].text,
        description: window.assets.descriptions[e],
        status: window.assets.statuses[e],
        note: window.assets.notes[e]
      })
    }

    const _endEscrow = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })

      var idxHash = this.state.idxHash;

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      window.contracts.ECR_NC.methods
        .endEscrow(idxHash)
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
    if (this.state.wasSentPacket) {
      return (
        <div>
          <div>
            <div className="mediaLinkAD-home">
              <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
            </div>
            <h2 className="FormHeader">Manage Escrow</h2>
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
                {!this.state.accessPermitted && (
                  <>
                    <Form.Row>
                      <Form.Label className="formFont">Set or End?:</Form.Label>
                      <Form.Control as="select" size="lg" onChange={(e) => this.setState({ isSettingEscrow: e.target.value })}>

                        <option value="null">Select an Action</option>
                        
                          <option value="true">Set Escrow</option>
                          <option value="false">End Escrow</option>
                        
                      </Form.Control>
                    </Form.Row>
                    <Form.Row>
                      <div className="submitButtonME2">
                        <div className="submitButtonME2-content">
                          <ArrowRightCircle
                            onClick={() => { _accessAsset() }}
                          />
                        </div>
                      </div>
                    </Form.Row>
                  </>
                )}
                {this.state.accessPermitted === true && this.state.isSettingEscrow === "true" && (
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
                      <div className="submitButton">
                        <div className="submitButton-content">
                          <ArrowRightCircle
                            onClick={() => { _setEscrow() }}
                          />
                        </div>
                      </div>
                    </Form.Row>
                  </>
                )}
                {this.state.accessPermitted === true && this.state.isSettingEscrow === "false" && (
                  <>
                    <Form.Row>
                      <h2 className="escrowDetails">Escrow Agent: {this.state.escrowData[1]}</h2>
                    </Form.Row>
                    <Form.Row>
                      <h2 className="escrowDetails"> Escrow TimeLock: {this.state.escrowData[2]}</h2>
                    </Form.Row>
                    <Form.Row>
                      <div className="submitButtonEM">
                        <div className="submitButtonEM-content">
                          <ArrowRightCircle
                            onClick={() => { _endEscrow() }}
                          />
                        </div>
                      </div>
                    </Form.Row>
                  </>
                )}
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
              <p className="loading">Transaction In Progress</p>
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
          <h2 className="FormHeader">Manage Escrow</h2>
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
              {!this.state.accessPermitted && (
                <>
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
                            <option value="null"> Select an asset </option>
                            <option value="assetDash">View Assets in Dashboard</option>
                            <option value="reset">Refresh Assets</option>
                            {window.utils.generateAssets()}
                          </optgroup>)}
                        {!this.state.hasLoadedAssets && (<optgroup ><option value="null"> Loading Assets... </option></optgroup>)}

                      </Form.Control>
                    </Form.Group>
                  </Form.Row>
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
                    <div className="submitButtonME">
                      <div className="submitButtonME-content">
                        <ArrowRightCircle
                          onClick={() => { _accessAsset() }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                </>
              )}
              {this.state.accessPermitted && this.state.isSettingEscrow === "true" && (
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
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <ArrowRightCircle
                          onClick={() => { _setEscrow() }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                </>
              )}
              {this.state.accessPermitted && this.state.isSettingEscrow === "false" && (
                <>
                  <Form.Row>
                    <h2 className="escrowDetails">Escrow Agent: {this.state.escrowData[1]}</h2>
                  </Form.Row>
                  <Form.Row>
                    <h2 className="escrowDetails"> Escrow TimeLock: {this.state.escrowData[2]}</h2>
                  </Form.Row>
                  <Form.Row>
                    <div className="submitButtonEM">
                      <div className="submitButtonEM-content">
                        <ArrowRightCircle
                          onClick={() => { _endEscrow() }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                </>
              )}
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
            <p className="loading">Transaction In Progress</p>
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
