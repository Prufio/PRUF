import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";


class ModifyDescriptionNC extends Component {
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
      costArray: [0],
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      assetClass: undefined,
      ipfs1: "",
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      to: "",
      hasLoadedAssets: false,
      assets: { descriptions: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] }
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

    const _transferAsset = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;
      let to = this.state.to;

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      window.contracts.A_TKN.methods
        .safeTransferFrom(window.addr, this.state.to, idxHash)
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
          window.recount = true;
          //Stuff to do when tx confirms
        });
      console.log(this.state.txHash);
      document.getElementById("MainForm").reset();
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

              <h2 className="Headertext">Transfer Asset</h2>
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
              <Form.Group as={Col} controlId="formGridTo">
                  <Form.Label className="formFont">To:</Form.Label>
                  <Form.Control
                    placeholder="Recipient Address"
                    required
                    onChange={(e) => this.setState({ to: e.target.value })}
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
                    onClick={_transferAsset}
                  >
                    Transfer
                  </Button>
                </Form.Group>
              </Form.Row>

              <br></br>
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

export default ModifyDescriptionNC;
