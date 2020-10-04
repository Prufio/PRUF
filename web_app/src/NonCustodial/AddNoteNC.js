import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";

class AddNoteNC extends Component {
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
      lookup: "",
      hashPath: "",
      ipfsID: "",
      costArray: [0],
      error: undefined,
      result: "",
      assetClass: undefined,
      ipfs1: "",
      ipfs2: "",
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
      hashUrl: "",
      hasError: false,
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

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const getBytes32FromIpfsHash = (ipfsListing) => {
      return "0x" + bs58.decode(ipfsListing).slice(2).toString("hex");
    };

    const publishIPFS2Photo = async () => {
      if (document.getElementById("ipfs2File").files[0] !== undefined) {
        const self = this;
        const reader = new FileReader();
        reader.readAsArrayBuffer(document.getElementById("ipfs2File").files[0])
        reader.onloadend = async (event) => {
          const buffer = Buffer(event.target.result);
          console.log("Uploading file to IPFS...", buffer);
          await window.ipfs.add(buffer, (error, hash) => {
            if (error) {
              console.log("Something went wrong. Unable to upload to ipfs");
            } else {
              console.log("uploaded at hash: ", hash);
            }
            let _hashUrl = "https://ipfs.io/ipfs/";
            self.setState({ hashPath: getBytes32FromIpfsHash(hash) });
            console.log(_hashUrl + hash)
            self.setState({ hashUrl: _hashUrl + hash })
          });
        }
      }
      else { alert("No file chosen for upload!") }
    };

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

    const setIPFS2 = async () => {

      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = this.state.idxHash;

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);
      
      var noteExists = await window.utils.checkNoteExists(idxHash);

      if (noteExists){
        return alert("Asset note already exists! Cannot overwrite existing note.")
      }

        await window.contracts.APP_NC.methods
        .$addIpfs2Note(idxHash, this.state.hashPath)
        .send({ from: window.addr, value: window.costs.createNoteCost })
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
    if (this.state.wasSentPacket){
      return (
        <div>
        <h2 className="FormHeader"> Add Note </h2>
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
                  <Form.Group as={Col} controlId="formGridIpfs2File">
                    <Form.File onChange={(e) => this.setState({ hashPath: "" })} size="lg" className="btn2" id="ipfs2File" />
                  </Form.Group>
                </Form.Row>
  
                {this.state.hashPath !== "" && (
                  <Form.Row>
                    <Form.Group >
                      <Button className="buttonDisplay"
                        variant="primary"
                        type="button"
                        size="lg"
                        onClick={setIPFS2}
                      >
                        Add Note
                      </Button>
                      <div className="LittleText"> Cost in AC {window.assetClass}: {Number(window.costs.createNoteCost) / 1000000000000000000} ETH</div>
                    </Form.Group>
                  </Form.Row>
                )}
                {this.state.hashPath === "" && (
                  <Form.Row>
                    <Form.Group >
                      <Button className="buttonDisplay"
                        variant="primary"
                        type="button"
                        size="lg"
                        onClick={publishIPFS2Photo}
                      >
                        Load to IPFS
                      </Button>
                    </Form.Group>
                  </Form.Row>
                )}
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
                  <a>
                    <img src={this.state.hashUrl} alt="" />
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
        <h2 className="FormHeader"> Add Note </h2>
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
                    onChange={(e) => {_checkIn(e.target.value)}}
                  >
                    {this.state.hasLoadedAssets && (<><option value="null"> Select an asset </option><option value="reset">Refresh Assets</option>{window.utils.generateAssets()}</>)}
                    {!this.state.hasLoadedAssets && (<option value="null"> Loading Assets... </option>)}
                    
                  </Form.Control>
                </Form.Group>
              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridIpfs2File">
                  <Form.File onChange={(e) => this.setState({ hashPath: "" })} size="lg" className="btn2" id="ipfs2File" />
                </Form.Group>
              </Form.Row>

              {this.state.hashPath !== "" && (
                <Form.Row>
                  <Form.Group >
                    <Button className="buttonDisplay"
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={setIPFS2}
                    >
                      Add Note
                    </Button>
                    <div className="LittleText"> Cost in AC {window.assetClass}: {Number(window.costs.createNoteCost) / 1000000000000000000} ETH</div>
                  </Form.Group>
                </Form.Row>
              )}
              {this.state.hashPath === "" && (
                <Form.Row>
                  <Form.Group >
                    <Button className="buttonDisplay"
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={publishIPFS2Photo}
                    >
                      Load to IPFS
                    </Button>
                  </Form.Group>
                </Form.Row>
              )}
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
                <a>
                  <img src={this.state.hashUrl} alt="" />
                </a>
              </div>
            )}
          </div>
        )}
      </div>
    );
  }
}

export default AddNoteNC;
