import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

class ImportAssetNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

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
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _importAsset = async () => {

      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      var idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial
      );

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      var doesExist = await window.utils.checkAssetExists(idxHash);
      if (!doesExist){
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      window.contracts.APP_NC.methods
        .$importAsset(idxHash, this.window.assetClass)
        .send({ from: window.addr, value: window.costs.newRecordCost })
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
          //Stuff to do when tx confirms
        });
      console.log(this.state.txHash);
      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        <Form className="IANCform" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}{window.assetClass === undefined && (
            <div className="errorResults">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass !== undefined && (
            <div>
              <h2 className="Headertext">Import Asset</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>
                  <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridManufacturer">
                  <Form.Label className="formFont">Manufacturer:</Form.Label>
                  <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridModel">
                  <Form.Label className="formFont">Model:</Form.Label>
                  <Form.Control
                    placeholder="Model"
                    required
                    onChange={(e) => this.setState({ model: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridSerial">
                  <Form.Label className="formFont">Serial:</Form.Label>
                  <Form.Control
                    placeholder="Serial"
                    required
                    onChange={(e) => this.setState({ serial: e.target.value })}
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
                      onClick={_importAsset}
                    >
                      Import
                  </Button>
                    <div className="LittleTextImport"> Cost in AC {window.assetClass}: {Number(window.costs.newRecordCost) / 1000000000000000000} ETH</div>
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

export default ImportAssetNC;
