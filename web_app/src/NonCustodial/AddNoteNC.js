import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";
import { ArrowRightCircle, CheckCircle, Home, XSquare } from 'react-feather'


class AddNoteNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.setInscription = async () => {
      const self = this;
      window.isInTx = true;

      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      this.setState({ transaction: true })
      var idxHash = this.state.idxHash;

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      await window.contracts.APP_NC.methods
        .$addIpfs2Note(idxHash, this.state.hashPath)
        .send({ from: window.addr, value: window.costs.createNoteCost })
        .on("error", function (_error) {
          // self.setState({ NRerror: _error });
          self.setState({ transaction: false })
          self.setState({ txHash: Object.values(_error)[0].transactionHash });
          self.setState({ txStatus: false });
          console.log(Object.values(_error)[0].transactionHash);
          window.isInTx = false;
          if (this.state.wasSentPacket) {
            return window.location.href = '/#/asset-dashboard'
          }
        })
        .on("receipt", (receipt) => {
          self.setState({ transaction: false })
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          console.log(receipt.status);
          window.resetInfo = true;
          window.isInTx = false;
          if (this.state.wasSentPacket) {
            return window.location.href = '/#/asset-dashboard'
          }
          //Stuff to do when tx confirms
        });

      this.setState({hashPath: ""})

      console.log(this.state.txHash);
      return document.getElementById("MainForm").reset();
    }

    this.updateAssets = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }

      if (this.state.hasLoadedAssets !== window.hasLoadedAssets && this.state.runWatchDog === true) {
        this.setState({ hasLoadedAssets: window.hasLoadedAssets })
      }

      if (this.state.hashPath !== "" && this.state.runWatchDog === true && window.isInTx !== true) {
        this.setInscription()
      }
    }, 100)

    this.setAC = async (AC) => {
      let acDoesExist;

      if (AC === "0" || AC === undefined) { return alert("Selected AC Cannot be Zero") }
      else {
        if (
          AC.charAt(0) === "0" ||
          AC.charAt(0) === "1" ||
          AC.charAt(0) === "2" ||
          AC.charAt(0) === "3" ||
          AC.charAt(0) === "4" ||
          AC.charAt(0) === "5" ||
          AC.charAt(0) === "6" ||
          AC.charAt(0) === "7" ||
          AC.charAt(0) === "8" ||
          AC.charAt(0) === "9"
        ) {
          acDoesExist = await window.utils.checkForAC("id", AC);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.open('https://www.pruf.io')
          }

          this.setState({ assetClass: AC });
          await window.utils.resolveACFromID(AC)
          await window.utils.getACData("id", AC)

          await this.setState({ ACname: window.assetClassName });
        }

        else {
          acDoesExist = await window.utils.checkForAC("name", AC);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.open('https://www.pruf.io')
          }

          this.setState({ ACname: AC });
          await window.utils.resolveAC(AC);
          await this.setState({ assetClass: window.assetClass });
        }

        return this.setState({ assetClassSelected: true, acData: window.tempACData })
      }
    }

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
      transaction: false,
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

    this.setState({ runWatchDog: true })
  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ idxHash: undefined, txStatus: false, txHash: "", wasSentPacket: false, assetClass: undefined })
    }

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
      if (e === "null" || e === undefined) {
        return clearForm()
      }
      else if (e === "reset") {
        return window.resetInfo = true;
      }
      else if (e === "assetDash") {
        return window.location.href = "/#/asset-dashboard"
      }

      let resArray = await window.utils.checkStats(window.assets.ids[e], [6, 0])

      console.log(resArray)

      if (Number(resArray[1]) === 3 || Number(resArray[1]) === 4 || Number(resArray[1]) === 53 || Number(resArray[1]) === 54) {
        alert("Cannot edit asset in lost or stolen status"); return clearForm()
      }

      if (Number(resArray[0]) > 0) {
        alert("Note already enscribed on this asset! Cannot overwrite existing note."); return clearForm()
      }

      if (Number(resArray[1]) === 50 || Number(resArray[1]) === 56) {
        alert("Cannot edit asset in escrow! Please wait until asset has met escrow conditions")
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
        note: window.assets.notes[e]
      })

      this.setAC(window.assets.assetClasses[e])
    }


    if (this.state.wasSentPacket) {
      return (
        <div>
          <div>
            <div className="mediaLinkAD-home">
              <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
            </div>
            <h2 className="FormHeader">Add Note</h2>
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
                  <Form.Group as={Col} controlId="formGridIpfs2File">
                    <Form.File onChange={(e) => this.setState({ hashPath: "" })} size="lg" className="btn2" id="ipfs2File" />
                  </Form.Group>
                </Form.Row>

                {this.state.hashPath === "" && this.state.transaction === false && (
                  <Form.Row>
                    <Form.Group >
                      <div className="submitButton">
                        <div className="submitButton-content">
                          <CheckCircle
                            onClick={() => { publishIPFS2Photo() }}
                          />
                        </div>
                        {this.state.assetClass !== undefined && (
                          <Form.Label className="LittleTextNewRecord"> Cost To Add Note in AC {this.state.assetClass}: {Number(window.costs.createNoteCost) / 1000000000000000000} ETH</Form.Label >
                        )}
                      </div>
                    </Form.Group>
                  </Form.Row>
                )}
              </div>
            )}
          </Form>
          {this.state.transaction === false && this.state.transaction === false && (
            <div className="assetSelectedResults">
              <Form.Row>
                {this.state.idxHash !== undefined && this.state.txHash === "" && (
                  <Form.Group>
                    <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                    <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                    <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                    <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
                  </Form.Group>
                )}
              </Form.Row>
            </div>
          )}
          {this.state.transaction === true && (

            <div className="Results">
              <p className="loading">Transaction In Progress</p>
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
        <div>
          <div className="mediaLinkAD-home">
            <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
          </div>
          <h2 className="FormHeader">Add Note</h2>
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
                <Form.Group as={Col} controlId="formGridIpfs2File">
                  <Form.File onChange={(e) => this.setState({ hashPath: "" })} size="lg" className="btn2" id="ipfs2File" />
                </Form.Group>
              </Form.Row>

              {this.state.hashPath === "" && this.state.transaction === false && (
                <Form.Row>
                  <Form.Group >
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <CheckCircle
                          onClick={() => { publishIPFS2Photo() }}
                        />
                      </div>
                      {this.state.assetClass !== undefined && (
                        <Form.Label className="LittleTextNewRecord"> Cost To Add Note in AC {this.state.assetClass}: {Number(window.costs.createNoteCost) / 1000000000000000000} ETH</Form.Label >
                      )}
                    </div>
                  </Form.Group>
                </Form.Row>
              )}
            </div>
          )}
        </Form>
        {this.state.transaction === false && this.state.txHash === "" && (
          <div className="assetSelectedResults">
            <Form.Row>
              {this.state.idxHash !== undefined && this.state.txHash === "" && (
                <Form.Group>
                  <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                  <div className="assetSelectedContentHead">Asset Name: <span className="assetSelectedContent">{this.state.name}</span> </div>
                  <div className="assetSelectedContentHead">Asset Class: <span className="assetSelectedContent">{this.state.assetClass}</span> </div>
                  <div className="assetSelectedContentHead">Asset Status: <span className="assetSelectedContent">{this.state.status}</span> </div>
                </Form.Group>
              )}
            </Form.Row>
          </div>
        )}
        {this.state.transaction === true && (
          <div className="Results">
            <p className="loading">Transaction In Progress</p>
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
