import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Row from "react-bootstrap/Row";
import { Home, XSquare, ArrowRightCircle, Grid, CornerUpLeft, Repeat } from "react-feather";
import QrReader from 'react-qr-reader'
import { connect } from 'react-redux';
import {setGlobalAddr, setGlobalWeb3} from '../actions'

class RecycleAssetNC extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.accessAsset = async () => {
      let idxHash;
      if (this.state.QRreader === false && this.state.Checkbox === false) {
        if (this.state.manufacturer === ""
          || this.state.type === ""
          || this.state.model === ""
          || this.state.serial === "") {
          return alert("Please fill out all fields before submission")
        }

        else if (!this.state.Checkbox) {
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
      }
      if (this.state.Checkbox) {
        idxHash = this.state.idxHash
      }

      let resArray = await window.utils.checkStats(idxHash, [0, 2])

      console.log(resArray)


      if (Number(resArray[1]) === 0) {
        alert("Asset does not exist at given IDX");
        this.setState({
          idxHash: undefined, txStatus: undefined, txHash: "", accessPermitted: false, transaction: false
        })
      }

      if (Number(resArray[0]) !== 60) {
        alert("Asset not in recyclable status");
        this.setState({
          idxHash: undefined, txStatus: undefined, txHash: "", accessPermitted: false, transaction: false
        })
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
      selectedAssetClass: "",
      assetClassSelected: false,
      CountDownStart: "",
      ipfs1: "",
      txHash: "",
      txStatus: false,
      isNFA: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      transaction: false,
      QRreader: false,
      Checkbox: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    if (window.assetClass > 0) {
      this.setState({ assetClass: window.assetClass, assetClassSelected: true })
    }

    else {
      this.setState({ assetClassSelected: false })
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

    const _setAC = async () => {
      let acDoesExist;
      let destinationACData;

      if (this.state.selectedAssetClass === "0" || this.state.selectedAssetClass === undefined) { return alert("Selected AC Cannot be Zero") }
      else {
        if (
          this.state.selectedAssetClass.charAt(0) === "0" ||
          this.state.selectedAssetClass.charAt(0) === "1" ||
          this.state.selectedAssetClass.charAt(0) === "2" ||
          this.state.selectedAssetClass.charAt(0) === "3" ||
          this.state.selectedAssetClass.charAt(0) === "4" ||
          this.state.selectedAssetClass.charAt(0) === "5" ||
          this.state.selectedAssetClass.charAt(0) === "6" ||
          this.state.selectedAssetClass.charAt(0) === "7" ||
          this.state.selectedAssetClass.charAt(0) === "8" ||
          this.state.selectedAssetClass.charAt(0) === "9"
        ) {
          acDoesExist = await window.utils.checkForAC("id", this.state.selectedAssetClass);
          destinationACData = await window.utils.getACData("id", this.state.selectedAssetClass);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.open('https://www.pruf.io')
          }

          this.setState({ assetClass: this.state.selectedAssetClass });
          await window.utils.resolveACFromID(this.state.selectedAssetClass)
          await window.utils.getACData("id", this.state.selectedAssetClass)

          await this.setState({ ACname: window.assetClassName });
        }

        else {
          acDoesExist = await window.utils.checkForAC("name", this.state.selectedAssetClass);
          destinationACData = await window.utils.getACData("name", this.state.selectedAssetClass);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.open('https://www.pruf.io')
          }

          this.setState({ ACname: this.state.selectedAssetClass });
          await window.utils.resolveAC(this.state.selectedAssetClass);
          await this.setState({ assetClass: window.assetClass });
        }
        if (this.state.wasSentPacket) {
          let resArray = await window.utils.checkStats(this.state.idxHash, [0, 2])
          console.log(resArray)

          if (Number(resArray[0]) !== 70) {
            alert("Asset is not exported! Owner must export the assset in order to import.");
             window.sentPacket = undefined;
            return window.location.href = "/#/asset-dashboard"
          }

          console.log(destinationACData.root)

          if (resArray[1] !== destinationACData.root) {
            alert("Import destination AC must have same root as origin!");
             window.sentPacket = undefined;
            return window.location.href = "/#/asset-dashboard"
          }
        }

        return this.setState({ assetClassSelected: true, acData: window.tempACData, txHash: "" })
      }
    }

    const QRReader = async () => {
      if (this.state.QRreader === false) {
        this.setState({ QRreader: true, assetFound: "" })
      }
      else {
        this.setState({ QRreader: false })
      }
    }


    const Checkbox = async () => {
      if (this.state.Checkbox === false) {
        this.setState({ Checkbox: true })
      }
      else {
        this.setState({ Checkbox: false })
      }
    }

    const clearForm = async () => {
      document.getElementById("MainForm").reset();
      this.setState({ idxHash: undefined, txStatus: false, txHash: "", accessPermitted: false, assetClassSelected: false, Checkbox: false })
    }

    const _recycleAsset = async () => {

      if (
        this.state.first === "" ||
        this.state.middle === "" ||
        this.state.surname === "" ||
        this.state.id === "" ||
        this.state.secret === ""
      ) { return alert("Please fill out all forms") }

      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({ error: undefined })
      this.setState({ resultRA: "" })
      this.setState({ transaction: true })
      if (this.state.result !== "") {
        var idxHash = this.state.result;
      }
      else {
        var idxHash = window.web3.utils.soliditySha3(
          String(this.state.type),
          String(this.state.manufacturer),
          String(this.state.model),
          String(this.state.serial),
        );
      }
      var rgtRaw;

      rgtRaw = window.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );

      console.log(idxHash)
      console.log(this.state.selectedAssetClassW)
      let isSameRoot = await window.utils.checkAssetRootMatch(this.state.selectedAssetClass, this.state.idxHash);
      console.log(isSameRoot)
      if (!isSameRoot) {
        this.setState({
          QRreader: false
        })
        return alert("Import destination AC must have same root as previous AC"), clearForm()
      }

      let rgtHash;

      console.log(rgtRaw, idxHash)

      if (idxHash.length % 2 !== 0) {
        rgtHash = window.web3.utils.soliditySha3((idxHash + "0"), rgtRaw);
      }

      else {
        rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
      }



      console.log("rgtHash", rgtHash);
      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      window.contracts.RCLR.methods
        .$recycle(idxHash, rgtHash, this.state.selectedAssetClass)
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

      return clearForm();
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
          {window.addr > 0 && !this.state.assetClassSelected && this.state.QRreader === false && (
            <Form.Row>
              <Form.Label className="formFontRow">Asset Class:</Form.Label>
              <Form.Group as={Row} controlId="formGridAC">

                <Form.Control
                  className="singleFormRow"
                  placeholder="Submit an asset class name or #"
                  onChange={(e) => this.setState({ selectedAssetClass: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <div className="submitButtonNRAC">
                <div className="submitButtonNR-content">
                  <ArrowRightCircle
                    onClick={() => { _setAC() }}
                  />
                </div>
              </div>
            </Form.Row>
          )}
          {window.addr > 0 && (
            <div>
              {!this.state.accessPermitted && this.state.QRreader === false && this.state.assetClassSelected === true && (
                <>
                  <div>
                    <Form.Check
                      type="checkbox"
                      className="CheckBox2"
                      id="inlineFormCheck"
                      onChange={() => { Checkbox() }}
                    />
                    <Form.Label className="CheckBoxformFont">Input Raw Idx Hash</Form.Label>
                    {this.state.Checkbox === true && (
                      <Form.Row>
                        <Form.Label className="formFont">Idx Hash:</Form.Label>
                        <Form.Control
                          placeholder="Idx Hash"
                          required
                          onChange={(e) => this.setState({ idxHash: e.target.value })}
                          size="lg"
                        />
                      </Form.Row>
                    )}
                  </div>
                  {this.state.Checkbox === false && (
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
                    </>
                  )}
                </>
              )}
              {this.state.QRreader === false && !this.state.accessPermitted && this.state.assetClassSelected === true && (
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
                      <Form.Label className="LittleTextRecycle"> Cost To Recycle Asset in AC {this.state.selectedAssetClass}: {Number(window.costs.newRecordCost) / 1000000000000000000} ETH</Form.Label>
                    </div>
                  </Form.Row>
                </>
              )}
            </div>
          )}
        </Form>
        { this.state.QRreader === false && this.state.transaction === false && this.state.txHash === "" && (
          <div className="assetSelectedResults">
            <Form.Row>
              {this.state.idxHash !== undefined && this.state.txHash === "" && (
                <Form.Group>
                  <div className="assetSelectedContentHead">Asset IDX: <span className="assetSelectedContent">{this.state.idxHash}</span> </div>
                  <div className="assetSelectedContentHead">Being Recycled Into Asset Class: <span className="assetSelectedContent">{this.state.selectedAssetClass}</span> </div>
                </Form.Group>
              )}
            </Form.Row>
          </div>
        )}
        {this.state.transaction === true && this.state.QRreader === false && (
          <div className="Results">
            <p className="loading">Transaction In Progress</p>
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


const mapStateToProps = (state) => {

  return{
    globalAddr: state.globalAddr,
    web3: state.web3
  }

}

const mapDispatchToProps = () => {
  return {
    setGlobalAddr,
    setGlobalWeb3,
  }
}



export default connect(mapStateToProps, mapDispatchToProps())(RecycleAssetNC);
