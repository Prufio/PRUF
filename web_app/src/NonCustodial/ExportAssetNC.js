import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import returnManufacturers from "../Resources/Manufacturers";

class ExportAssetNC extends Component {
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

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      error: undefined,
      NRerror: undefined,
      result: null,
      assetClass: undefined,
      ipfs1: "",
      txHash: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      importAgent: "",
      isNFA: false,
      txStatus: null,
      hasLoadedAssets: false,
      assets: { descriptions: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] },
      transaction: undefined,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    if (window.sentPacket !== undefined) {
      this.setState({ name: window.sentPacket.name })
      this.setState({idxHash: window.sentPacket.idxHash})
      this.setState({assetClass: window.sentPacket.assetClass})
      this.setState({status: window.sentPacket.status})
      window.sentPacket = undefined
      this.setState({ wasSentPacket: true })
    }
 
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }
  componentDidUpdate() {//stuff to do on a re-render

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

    const _exportAsset = async () => {//create a new asset record
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      //reset state values before form resubmission
      var idxHash = this.state.idxHash;

      console.log("idxHash", idxHash);
      console.log("addr: ", this.state.agentAddress);

      window.contracts.NP_NC.methods
        .exportAsset(
          idxHash
        )
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
          window.resetInfo = true;
        });

        return document.getElementById("MainForm").reset(); //clear form inputs
    };
    if (this.state.wasSentPacket){
      return (//default render
        <div>
          <Form className="Form" id='MainForm'>
            {window.addr === undefined && (
              <div className="errorResults">
                <h2>User address unreachable</h2>
                <h3>Please connect web3 provider.</h3>
              </div>
            )}
            {window.addr > 0 && (
              <div>
                <h2 className="Headertext">Export</h2>
                <br></br>
                <Form.Row>
                  <Form.Group>
                    <Button className="buttonDisplay"
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={_exportAsset}
                    >
                      Export Asset
                      </Button>
                  </Form.Group>
                </Form.Row>
  
              </div>
            )}
          </Form>
          <div className="assetSelectedResults">
            <Form.Row>
            {this.state.idxHash !== undefined &&(
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
    return (//default render
      <div>
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Export</h2>
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
                <Form.Group>
                  <Button className="buttonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_exportAsset}
                  >
                    Export Asset
                    </Button>
                </Form.Group>
              </Form.Row>

            </div>
          )}
        </Form>
        <div className="assetSelectedResults">
          <Form.Row>
          {this.state.idxHash !== undefined &&(
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

export default ExportAssetNC;
