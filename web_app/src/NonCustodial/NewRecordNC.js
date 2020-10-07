import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import FormLabel from "react-bootstrap/FormLabel";
import { ArrowRightCircle, Home, XSquare } from 'react-feather'

class NewRecordNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................
    // this.listenForTx = setInterval(() => {
    //   if(this.state.pendingTx === undefined && this.state.transaction === true) {
    //     this.setState({pendingTx: Object.values(window.web3.eth.getPendingTransactions())[0]})
    //   }
    // }, 100)

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      error: undefined,
      NRerror: undefined,
      result: null,
      assetClass: undefined,
      countDownStart: "",
      ipfs1: "",
      txHash: "",
      assetName: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      txStatus: null,
      transaction: undefined,
      // pendingTx: undefined,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }
  componentDidUpdate() {//stuff to do on a re-render

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _newRecord = async () => {//create a new asset record
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ result: "" })
      this.setState({ transaction: true })
      //reset state values before form resubmission
      var idxHash;
      var rgtRaw;

      idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
      );


      rgtRaw = window.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );

      var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
      var ipfsHash = window.web3.utils.soliditySha3(this.state.assetName);
      //rgtHash = tenThousandHashesOf(rgtHash)

      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", window.addr);
      console.log(window.assetClass);

      var doesExist = await window.utils.checkAssetExists(idxHash);

      if (!doesExist) {
        window.contracts.APP_NC.methods
          .$newRecordWithDescription(
            idxHash,
            rgtHash,
            window.assetClass,
            this.state.countDownStart,
            ipfsHash
          )
          .send({ from: window.addr, value: window.costs.newRecordCost })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ transaction: false })
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });

          })
          .on("receipt", (receipt) => {
            self.setState({ transaction: false })
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            window.resetInfo = true;
            window.recount = true;
          });
        // console.log(Object.values(window.web3.eth.getPendingTransactions()))
      }

      else { alert("Record already exists! Try again.") }

      return document.getElementById("MainForm").reset(); //clear form inputs
    };

    return (//default render
      <div>
        <div>
          <div className="mediaLinkAD-home">
            <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
          </div>
          <h2 className="FormHeader">New Record</h2>
          <div className="mediaLink-clearForm">
            <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { document.getElementById("MainForm").reset() }} /></a>
          </div>
        </div>
        <Form className="Form" id='MainForm'>
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
          {window.addr > 0 && window.assetClass > 0 && (
            <div>
              <Form.Row>
                <Form.Label className="formFont">Asset Name:</Form.Label>
                <Form.Control
                    placeholder="Asset Name"
                    required
                    onChange={(e) => this.setState({ assetName: e.target.value })}
                    size="lg"
                  />
              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>

                  {/* {returnTypes(window.assetClass, this.state.isNFA) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ type: e.target.value })}>
                  {returnTypes(window.assetClass, this.state.isNFA)}
                  </Form.Control>
                  )} */}

                  {/* {returnTypes(window.assetClass, this.state.isNFA) === '0' &&( */}
                  <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />{/* )} */}
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
                <Form.Group as={Col} controlId="formGridFirstName">
                  <Form.Label className="formFont">First Name:</Form.Label>
                  <Form.Control
                    placeholder="First Name"
                    required
                    onChange={(e) => this.setState({ first: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridMiddleName">
                  <Form.Label className="formFont">Middle Name:</Form.Label>
                  <Form.Control
                    placeholder="Middle Name"
                    required
                    onChange={(e) => this.setState({ middle: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridLastName">
                  <Form.Label className="formFont">Last Name:</Form.Label>
                  <Form.Control
                    placeholder="Last Name"
                    required
                    onChange={(e) => this.setState({ surname: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridIdNumber">
                  <Form.Label className="formFont">ID Number:</Form.Label>
                  <Form.Control
                    placeholder="ID Number"
                    required
                    onChange={(e) => this.setState({ id: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridPassword">
                  <Form.Label className="formFont">Password:</Form.Label>
                  <Form.Control
                    placeholder="Password"
                    type="password"
                    required
                    onChange={(e) => this.setState({ secret: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridLogStartValue">
                  <Form.Label className="formFont">Log Start Value:</Form.Label>
                  <Form.Control
                    placeholder="Log Start Value"
                    required
                    onChange={(e) =>
                      this.setState({ countDownStart: e.target.value })
                    }
                    size="lg"
                  />
                </Form.Group>

              </Form.Row>
              <Form.Row>
                <div className="submitButtonNR">
                  <div className="submitButtonNR-content">
                    <ArrowRightCircle
                      onClick={() => { _newRecord() }}
                    />
                  </div>
                  <Form.Label className="LittleTextNewRecord"> Cost in AC {window.assetClass}: {Number(window.costs.newRecordCost) / 1000000000000000000} ETH</Form.Label>
                </div>
              </Form.Row>
              <br></br>
            </div>
          )}
        </Form>
        {this.state.transaction === true && this.state.txStatus === undefined && (

          <div className="Results">
            {/* {this.state.pendingTx === undefined && ( */}
            <p class="loading">Transaction In Progress</p>
            {/* )} */}
            {/* {this.state.pendingTx !== undefined && (
              <p class="loading">Transaction In Progress</p>
            )} */}
          </div>)}
        <div className="Results">
          {this.state.txHash > 0 && ( //conditional rendering


            <Form.Row>
              {this.state.txStatus === false && this.state.transaction === undefined && (
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
              {this.state.txStatus === true && this.state.transaction === undefined &&(
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
            </Form.Row>

          )}
        </div>
      </div>
    );
  }
}

export default NewRecordNC;
