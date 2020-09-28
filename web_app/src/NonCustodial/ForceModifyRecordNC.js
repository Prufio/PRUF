import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class ForceModifyRecordNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.updateAssets = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }

      if(this.state.hasLoadedAssets !== window.hasLoadedAssets){
        this.setState({hasLoadedAssets: window.hasLoadedAssets})
      }
    }, 100)

    this.mounted = false;
    this.state = {
      addr: "",
      costArray: [0],
      error: undefined,
      NRerror: undefined,
      result: "",
      assetClass: undefined,
      CountDownStart: "",
      ipfs1: "",
      txHash: "",
      txStatus: false,
      isNFA: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      newFirst: "",
      newMiddle: "",
      newSurname: "",
      newId: "",
      newSecret: "",
      hasLoadedAssets: false,
      assets: { descriptions: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] }
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

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _checkIn = async (e) => {
      if(e === "0" || e === undefined){return}
      else if(e === "reset"){
        return window.resetInfo = true;
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

    const _editRgtHash = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;
      var newRgtRaw;

      newRgtRaw = window.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );

      var newRgtHash = window.web3.utils.soliditySha3(idxHash, newRgtRaw);

      console.log("idxHash", idxHash);
      console.log("New rgtHash", newRgtHash);
      console.log("addr: ", window.addr);

      window.contracts.NP_NC.methods
        ._changeRgt(idxHash, newRgtHash)
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
          //Stuff to do when tx confirms
        });

      console.log(this.state.txHash);
      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <Form className="twoRowForm" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Modify Rightsholder</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridAsset">
                  <Form.Label className="formFont"> Select an Asset to Modify :</Form.Label>
                  <Form.Control
                    as="select"
                    size="lg"
                    onChange={(e) => {_checkIn(e.target.value)}}
                  >
                    {this.state.hasLoadedAssets && (<><option value="null"> Select an asset </option><option value="reset">Refresh Assets</option>{window.utils.generateAssets()}</>)}
                    {!this.state.hasLoadedAssets && (<option value="null"> Loading Assets... </option>)}
                    
                  </Form.Control>
                </Form.Group>
              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridNewFirstName">
                  <Form.Label className="formFont">New First Name:</Form.Label>
                  <Form.Control
                    placeholder="New First Name"
                    required
                    onChange={(e) => this.setState({ first: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridNewMiddleName">
                  <Form.Label className="formFont">New Middle Name:</Form.Label>
                  <Form.Control
                    placeholder="New Middle Name"
                    required
                    onChange={(e) => this.setState({ middle: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridNewLastName">
                  <Form.Label className="formFont">New Last Name:</Form.Label>
                  <Form.Control
                    placeholder="New Last Name"
                    required
                    onChange={(e) => this.setState({ surname: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridNewIdNumber">
                  <Form.Label className="formFont">New ID Number:</Form.Label>
                  <Form.Control
                    placeholder="New ID Number"
                    required
                    onChange={(e) => this.setState({ id: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridNewPassword">
                  <Form.Label className="formFont">New Password:</Form.Label>
                  <Form.Control
                    placeholder="New Password"
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
                      variant="danger"
                      type="button"
                      size="lg"
                      onClick={_editRgtHash}
                    >
                      Modify
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

export default ForceModifyRecordNC;
