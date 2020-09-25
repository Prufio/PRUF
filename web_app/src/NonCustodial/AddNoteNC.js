import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";

class AddNoteNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

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

    return (
      <div>
        <Form className="fourRowFormWithPrice" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}{this.state.idxHash === undefined && (
            <div className="errorResults">
              <h2>No asset selected.</h2>
              <h3>Please asset in the dashboard to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && this.state.idxHash !== undefined &&(
            <div>
              <h2 className="Headertext">Add Note</h2>
              <br></br>
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
