import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import { Home, XSquare, ArrowRightCircle, Grid, CornerUpLeft, Repeat } from "react-feather";
import QrReader from 'react-qr-reader'

class RecycleAssetNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................
    this.setAC = async () => {
      let acDoesExist;

      const AC = window.assetClass

      console.log(AC)

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

    this.accessAsset = async () => {
      let idxHash;
      if (this.state.QRreader === false) {
        if (this.state.manufacturer === ""
          || this.state.type === ""
          || this.state.model === ""
          || this.state.serial === "") {
          return alert("Please fill out all fields before submission")
        }


        idxHash = window.web3.utils.soliditySha3(
          String(this.state.type),
          String(this.state.manufacturer),
          String(this.state.model),
          String(this.state.serial),
        );
      }

      else {
        idxHash = this.state.result
      }

      let resArray = await window.utils.checkStats(idxHash, [0,2])

      console.log(resArray)

      
      if (Number(resArray[1]) === 0) {
        alert("Asset does not exist at given IDX");
      }

      if (Number(resArray[0]) !== 60) {
        alert("Asset not in recyclable status");
      }

      console.log("idxHash", idxHash);
      // console.log("rgtHash", rgtHash);

      await this.setState({
        idxHash: idxHash,
        QRreader: false,
        accessPermitted: true,
      })

    }

    this.mounted = false;
    this.state = {
      addr: "",
      costArray: [0],
      error: undefined,
      NRerror: undefined,
      result: "",
      resultRA: "",
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
      transaction: undefined,
      QRreader: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    if (window.assetClass > 0){
      this.setState({ assetClass: window.assetClass, assetClassSelected: true, accessPermitted: false })
    }

    else{
      this.setState({assetClassSelected: false})
    }
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  handleScan = async (data) => {
    if (data) {
      let tempBool = await window.utils.checkAssetExists(data)
      let doesExist = await window.utils.checkAssetExists(data);
      if (tempBool === true) {
        this.setState({
          result: data,
          QRRR: true,
          assetFound: "Asset Found!"
        })
        console.log(data)
        this.accessAsset()
      }
      else {
        this.setState({
          assetFound: "Asset Not Found",
          QRreader: false,
        })
        if (!doesExist) {
          this.setState({
            QRreader: false,
          })
          return alert("Asset doesnt exist!")
        }
      }
    }
  }

  handleError = err => {
    console.error(err)
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const QRReader = async () => {
      if (this.state.QRreader === false) {
        this.setState({ QRreader: true, assetFound: "" })
      }
      else {
        this.setState({ QRreader: false })
      }
    }

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ idxHash: undefined, txStatus: undefined, txHash: "0", accessPermitted: false, transaction: undefined})
    }

    const _recycleAsset = async () => {

      if(
        this.state.first === "" ||
        this.state.middle === "" ||
        this.state.surname === "" ||
        this.state.id === "" ||
        this.state.secret === ""
      ) {return alert ("Please fill out all forms")}

      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ resultRA: "" })
      this.setState({ transaction: true })

      var idxHash = this.state.result;
      var rgtRaw;

      rgtRaw = window.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );

      //console.log(this.state.assetClass)

      let isSameRoot = await window.utils.checkAssetRootMatch(window.assetClass, idxHash);

      if (!isSameRoot) {
        this.setState({
          QRreader: false
        })
        return alert("Import destination AC must have same root as previous AC")
      }

      let rgtHash;

      console.log(rgtRaw, idxHash)

      if(idxHash.length % 2 !== 0){
        rgtHash = window.web3.utils.soliditySha3((idxHash+"0"), rgtRaw);
      }

      else{
        rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
      }

      

      console.log("rgtHash", rgtHash);
      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      window.contracts.RCLR.methods
        .$recycle(idxHash, rgtHash, window.assetClass)
        .send({ from: window.addr, value: window.costs.newRecordCost })
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
          window.recount = true;
          window.resetInfo = true;
          
          //Stuff to do when tx confirms
        });
      console.log(this.state.txHash);

      await this.setState({
        idxHash: "",
        accessPermitted: false
      })

      return document.getElementById("MainForm").reset();
    };

    return (
      <div>
        {this.state.QRreader === false && (
        <div>
          <div className="mediaLinkAD-home">
            <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
          </div>
          <h2 className="FormHeader">Recycle Asset</h2>
          <div className="mediaLink-clearForm">
            <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { clearForm() }} /></a>
          </div>
        </div>
        )}
        <Form className="Form" id='MainForm'>
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
        
          {window.addr > 0 && (
            <div>
              {!this.state.accessPermitted &&  this.state.QRreader === false &&(
                <>
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
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <ArrowRightCircle
                          onClick={() => { this.accessAsset() }}
                        />
                      </div>
                    </div>
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <Grid
                          onClick={() => { QRReader() }}
                        />
                      </div>
                    </div>
                  </Form.Row>
                </>
              )}
              {this.state.QRreader === true && (
                <div>
                  <div>
                    <div className="mediaLinkAD-home">
                      <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/#/' }} /></a>
                    </div>
                    <h2 className="FormHeader">Scan QR</h2>
                    <div className="mediaLink-back">
                      <a className="mediaLinkContent-back" ><CornerUpLeft onClick={() => { QRReader() }} /></a>
                    </div>
                  </div>
                  <div className="QRreader">
                    <QrReader
                      delay={300}
                      onError={this.handleError}
                      onScan={this.handleScan}
                      style={{ width: '100%' }}
                    />
                    {this.state.resultIA !== undefined && (
                      <div className="Results">
                        {this.state.assetFound}
                      </div>
                    )}
                  </div>
                </div>
              )}
              {this.state.accessPermitted && (
                <>
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
                    <div className="submitButton">
                      <div className="submitButton-content">
                        <Repeat
                          onClick={() => { _recycleAsset() }}
                        />
                      </div>
                      <Form.Label className="LittleTextNewRecord"> Cost in AC {window.assetClass}: {Number(window.costs.newRecordCost) / 1000000000000000000} ETH</Form.Label>
                    </div>
                  </Form.Row>
                </>
              )}
              <br></br>
            </div>
          )}
        </Form>
        { this.state.QRreader === false && this.state.transaction === undefined && (
        <div className="assetSelectedResults">
          <Form.Row>
            {this.state.idxHash !== undefined && this.state.txHash === "" && (
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
        )}
        {this.state.transaction === true && this.state.QRreader === false && (

          <div className="Results">
            {/* {this.state.pendingTx === undefined && ( */}
            <p className="loading">Transaction In Progress</p>
            {/* )} */}
            {/* {this.state.pendingTx !== undefined && (
    <p class="loading">Transaction In Progress</p>
  )} */}
          </div>)}
        {this.state.txHash > 0 && this.state.QRreader === false && ( //conditional rendering
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
            {this.state.txStatus === true && this.state.QRreader === false && (
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

export default RecycleAssetNC;
