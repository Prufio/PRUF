import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Button";
import ListGroup from "react-bootstrap/ListGroup";
import ListGroupItem from "react-bootstrap/ListGroupItem";
import QrReader from 'react-qr-reader'
import { CornerUpLeft, Home, XSquare, Grid, ArrowRightCircle } from "react-feather";


class RetrieveRecordMobile extends Component {
  constructor(props) {
    super(props);

    this.updateAssets = setInterval(() => {
      if (this.state.ipfsObject !== undefined && this.state.runWatchDog === true && this.state.assetObj === undefined) {
        let tempIPFS = this.state.ipfsObject;
        console.log(tempIPFS)
        this.setState({
          assetObj: {
            idxHash: this.state.idxHash,
            name: tempIPFS.name,
            assetClass: window.assetInfo.assetClass,
            status: window.assetInfo.status,
            description: tempIPFS.text.description,
            text: tempIPFS.text,
            photo: tempIPFS.photo,

          }, selectedImage: tempIPFS.photo.displayImage, moreInfo: true
        })
      }

    }, 100)
    //State declaration.....................................................................................................

    this.getIPFSJSONObject = (lookup) => {
      //console.log(lookup)
      window.ipfs.cat(lookup, async (error, result) => {
        if (error) {
          console.log(lookup, "Something went wrong. Unable to find file on IPFS");
          return this.setState({ ipfsObject: undefined })
        } else {
          console.log(lookup, "Here's what we found for asset description: ", result);
          return this.setState({ ipfsObject: JSON.parse(result) })
        }
      });
    };

    this.generateAssetInfo = (obj) => {
      let images = Object.values(obj.photo)
      let text = Object.values(obj.text)
      let imageNames = Object.keys(obj.photo)
      let textNames = Object.keys(obj.text)
      let status = "";

      if (obj.status === "50") { status="In Locked Escrow" }
      else if (obj.status === "51") { status="Transferrable" }
      else if (obj.status === "52") { status="Non-Transferrable" }
      else if (obj.status === "53") { status="MARKED STOLEN" }
      else if (obj.status === "54") { status="MARKED LOST" }
      else if (obj.status === "55") { status="Transferred/Unclaimed" }
      else if (obj.status === "56") { status="In Escrow" }
      else if (obj.status === "57") { status="Escrow Ended" }
      else if (obj.status === "58") { status="Locked Escrow Ended" }
      else if (obj.status === "59") { status="Discardable" }
      else if (obj.status === "60") { status="Recyclable" }
      else if (obj.status === "70") { status="Exported" }
      else if (obj.status === "0") { status="No Status Set" }
      else if (obj.status === "1") { status="Transferrable" }
      else if (obj.status === "2") { status="Non-Transferrable" }
      else if (obj.status === "3") { status="MARKED STOLEN" }
      else if (obj.status === "4") { status="MARKED LOST" }
      else if (obj.status === "5") { status="Transferred/Unclaimed" }
      else if (obj.status === "6") { status="In Escrow" }
      else if (obj.status === "7") { status="Escrow Ended" }

      else{status = "Invalid Status Retrieved"}

      const showImage = (e) => {
        console.log(this.state.selectedImage)
        console.log(e)
        this.setState({ selectedImage: e })
      }

      const openPhotoNT = (url) => {
        const newWindow = window.open(url, '_blank', 'noopener,noreferrer')
        if (newWindow) { newWindow.opener = null }
      }

      const generateThumbs = () => {
        let component = [];

        for (let i = 0; i < images.length; i++) {
          component.push(
            <button value={images[i]} class="assetImageSelectorButtonMobile" onClick={() => { showImage(images[i]) }}>
              <img src={images[i]} className="imageSelectorImageMobile" />
            </button>
          )
        }

        return component

      }

      const generateTextList = () => {
        let component = [];

        for (let i = 0; i < text.length; i++) {
          component.push(
            <>
              <h4>
                {textNames[i]}: {text[i]}
              </h4>
            </>
          )
        }

        return component
      }

      return (
        <Card style={{ width: '360px', overflowY: "auto", overflowX: "hidden", backgroundColor: "#005480", color: "white" }}>
          <div className="submitButtonRRQR3Mobile">
            <div classname="submitButtonRRQR3-mobile">
              <CornerUpLeft
                color={"#028ed4"}
                size={35}
                onClick={() => { this.setState({ moreInfo: false, ipfsObject: undefined, assetObj: undefined }) }}
              />
            </div>
          </div>
          <Card.Img style={{ width: '360px', height: "360px" }} variant="top" src={this.state.selectedImage} />
          <Card.Body>
            <div className="imageSelectorMobile">
              {generateThumbs()}
            </div>
            <Card.Title>Name : {obj.name}</Card.Title>
            <Card.Title>Asset Class : {obj.assetClass}</Card.Title>
            <Card.Title>Asset Status : {status}</Card.Title>
            <Card.Title>ID : {obj.idxHash}</Card.Title>
            <Card.Title>Asset Information : <br></br>{generateTextList()}</Card.Title>
          </Card.Body>
        </Card>
      )
    }

    this.handlePacket = async () => {
      let idxHash = window.sentPacket;

      this.setState({
        idxHash: window.sentPacket.idxHash,
        wasSentPacket: true,
        name: window.sentPacket.name,
        assetClass: window.sentPacket.assetClass
      })

      window.sentPacket = undefined;
      let hash;
      let assetClass;
      let status;

      await window.contracts.STOR.methods.retrieveShortRecord(idxHash)
        .call((_error, _result) => {
          if (_error) {
            console.log("IN ERROR IN ERROR IN ERROR")
          } else {
            if (Number(Object.values(_result)[5]) > 0) {
              hash = Object.values(_result)[5]

            }
            else {
              return hash = "0"
            }
            assetClass = Object.values(_result)[2]
            status = Object.values(_result)[0]
          }
        })

      return this.getIPFSJSONObject(window.utils.getIpfsHashFromBytes32(hash))

    }

    this._retrieveRecordQR = async () => {

      this.setState({ QRRR: undefined, assetFound: "" })
      const self = this;
      var ipfsHash;
      var tempResult;
      let idxHash = String(this.state.result)
      this.setState({ idxHash: idxHash })
      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      await window.contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call(
          // { from: window.addr },
          function (_error, _result) {
            if (_error) {
              console.log(_error)
              self.setState({ error: _error });
              self.setState({ result: 0 });
            } else {
              self.setState({ result: Object.values(_result) })
              self.setState({ error: undefined });
              tempResult = Object.values(_result);
              if (Object.values(_result)[5] > 0) { ipfsHash = window.utils.getIpfsHashFromBytes32(Object.values(_result)[5]); }
              console.log("ipfs data in promise", ipfsHash)
              if (Object.values(_result)[6] > 0) {
                console.log("Getting ipfs2 set up...")
                let knownUrl = "https://ipfs.io/ipfs/";
                let hash = String(window.utils.getIpfsHashFromBytes32(Object.values(_result)[6]));
                let fullUrl = knownUrl + hash;
                console.log(fullUrl);
                self.setState({ ipfs2: fullUrl, status: Object.values(_result)[0]});
              }
            }
          });

      window.assetClass = tempResult[2]

      window.assetInfo = {
        assetClass: tempResult[2],
        status: tempResult[0],
        idx: idxHash
      }
      await window.utils.resolveACFromID(tempResult[2])
      await this.getACData("id", window.assetClass)

      console.log(window.authLevel);

      await this.getIPFSJSONObject(ipfsHash);

      return this.setState({
        authLevel: window.authLevel,
        QRreader: undefined
      })
    }

    this.getACData = async (ref, ac) => {
      let tempData;
      let tempAC;

      if (window.contracts !== undefined) {

        if (ref === "name") {
          console.log("Using name ref")
          await window.contracts.AC_MGR.methods
            .resolveAssetClass(ac)
            .call((_error, _result) => {
              if (_error) { console.log("Error: ", _error) }
              else {
                if (Number(_result) > 0) { tempAC = Number(_result) }
                else { return 0 }
              }
            });

        }

        else if (ref === "id") { tempAC = ac; }

        await window.contracts.AC_MGR.methods
          .getAC_data(tempAC)
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              let _custodyType;

              if (Object.values(_result)[1] === "1") {
                _custodyType = "Custodial"
              }

              else {
                _custodyType = "Non-Custodial"
              }

              tempData = {
                root: Object.values(_result)[0],
                custodyType: _custodyType,
                discount: Object.values(_result)[2],
                exData: Object.values(_result)[3],
                AC: tempAC
              }
            }
          });
        return tempData;
      }

    }

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      hashPath: "",
      error: undefined,
      NRerror: undefined,
      result: [],
      assetClass: undefined,
      ipfs1: "",
      ipfs2: "",
      txHash: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      status: "",
      assetObj: undefined,
      wasSentPacket: false,
      ipfsObject: undefined,
      showDescription: false,
      QRreader: undefined,
      result: 'No result',
      QRRR: undefined,
      assetFound: undefined
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

    if (window.sentPacket !== undefined) {

      this.handlePacket()
    }

    this.setState({ runWatchDog: true })


  }

  componentDidUpdate() {//stuff to do when state updates


  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }


  handleScan = async (data) => {
    if (data) {
      let tempBool = await window.utils.checkAssetExists(data)
      if (tempBool === true) {
        this.setState({
          result: data,
          QRRR: true,
          assetFound: "Asset Found!"
        })
        console.log(data)
        this._retrieveRecordQR()
      }
      else {
        this.setState({
          assetFound: "Asset Not Found",
        })
      }
    }
  }


  render() {//render continuously produces an up-to-date stateful document  
    const self = this;




    const QRReader = async () => {
      if (this.state.QRreader === undefined) {
        this.setState({ QRreader: true, assetFound: "" })
      }
      else {
        this.setState({ QRreader: undefined })
      }
    }



    const _retrieveRecord = async () => {
      const self = this;
      var ipfsHash;
      var tempResult;

      let idxHash = window.web3.utils.soliditySha3(
        String(this.state.type),
        String(this.state.manufacturer),
        String(this.state.model),
        String(this.state.serial),
      );

      this.setState({ idxHash: idxHash })

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      await window.contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call(function (_error, _result) {
          if (_error) {
            console.log(_error)
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            self.setState({ result: Object.values(_result) })
            self.setState({ error: undefined });
            tempResult = Object.values(_result);
            if (Object.values(_result)[5] > 0) { ipfsHash = window.utils.getIpfsHashFromBytes32(Object.values(_result)[5]); }
            console.log("ipfs data in promise", ipfsHash)
            if (Object.values(_result)[6] > 0) {
              console.log("Getting ipfs2 set up...")
              let knownUrl = "https://ipfs.io/ipfs/";
              let hash = String(window.utils.getIpfsHashFromBytes32(Object.values(_result)[6]));
              let fullUrl = knownUrl + hash;
              console.log(fullUrl);
              self.setState({ ipfs2: fullUrl });
            }
          }
        });

      window.assetClass = tempResult[2]

      window.assetInfo = {
        assetClass: tempResult[2],
        status: tempResult[0],
        idx: idxHash
      }
      await window.utils.resolveACFromID(tempResult[2])
      await this.getACData("id", window.assetClass)

      console.log(window.authLevel);

      await this.getIPFSJSONObject(ipfsHash);

      return this.setState({ authLevel: window.authLevel })
    }

    if (this.state.wasSentPacket === true) {
      return (
        <div>
          <div>
            <div>
              <div className="mediaLinkAD-home">
                <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/' }} /></a>
              </div>
              <h2 className="AssetDashboardHeader">Here's What We Found :</h2>
              <div className="mediaLink-clearForm">
                <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { document.getElementById("MainForm").reset() }} /></a>
              </div>
            </div>
          </div>
          <div className="assetDashboard">
            {this.state.assetObj !== undefined && (<>{this.generateAssetInfo(this.state.assetObj)}</>)}
            {this.state.assetObj === undefined && (<h4 className="loading">Loading Asset</h4>)}
          </div>
          <div className="assetDashboardFooter">
          </div>
        </div >
      )
    }
    return (
      <div>
        {!this.state.moreInfo && this.state.QRreader === undefined && (
          <div>
            <div>
              <div className="mediaLinkAD-home">
                <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/' }} /></a>
              </div>
              <h2 className="FormHeaderMobile">Search Database</h2>
              <div className="mediaLink-clearForm">
                <a className="mediaLinkContent-clearForm" ><XSquare onClick={() => { document.getElementById("MainForm").reset() }} /></a>
              </div>
            </div>
            <Form className="FormMobile" id="MainForm">
              <div>
                <Form.Row>
                  <Form.Label className="formFont">Type:</Form.Label>
                  <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />
                </Form.Row>
                <Form.Row>
                  <Form.Label className="formFont">Manufacturer:</Form.Label>
                  <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
                    size="lg"
                  />
                </Form.Row>
                <Form.Row>
                  <Form.Label className="formFont">Model:</Form.Label>
                  <Form.Control
                    placeholder="Model"
                    required
                    onChange={(e) => this.setState({ model: e.target.value })}
                    size="lg"
                  />
                </Form.Row>
                <Form.Row>
                  <Form.Label className="formFont">Serial:</Form.Label>
                  <Form.Control
                    placeholder="Serial"
                    required
                    onChange={(e) => this.setState({ serial: e.target.value })}
                    size="lg"
                  />
                </Form.Row>
                <Form.Row>
                  <Form.Group>
                    <div className="submitButtonRRMobile">
                      <div className="submitButtonRR-content">
                        <ArrowRightCircle
                          onClick={() => { _retrieveRecord() }}
                        />
                      </div>
                    </div>
                    <div className="submitButtonRRQRMobile">
                      <div className="submitButtonRRQR-content">
                        <Grid
                          onClick={() => { QRReader() }}
                        />
                      </div>
                    </div>
                  </Form.Group>
                </Form.Row>
              </div>
            </Form>
            <div className="assetDashboardFooterMobile"></div>
          </div>
        )}


        {this.state.QRreader === true && (
          <div>
            <div>
              <div className="mediaLinkAD-home">
                <a className="mediaLinkContentAD-home" ><Home onClick={() => { window.location.href = '/' }} /></a>
              </div>
              <h2 className="FormHeaderMobile">Search Database</h2>
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
              {this.state.result !== undefined && (
                <div className="ResultsMobile">
                  {this.state.assetFound}
                </div>
              )}
            </div>
          </div>
        )}

        {this.state.result[2] === "0" && (
          <div className="ResultsMobile">No Asset Found for Given Data</div>
        )}

        {this.state.moreInfo && ( //conditional rendering
          <div>
            <div>
              <h2 className="assetDashboardHeaderMobile">Here's what we found: </h2>
            </div>
            <div className="assetDashboardMobile">
              {this.state.assetObj !== undefined && (<>{this.generateAssetInfo(this.state.assetObj)}</>)}
              {this.state.assetObj === undefined && (<h4 className="loading">Loading Asset</h4>)}
            </div>
            <div className="assetDashboardFooterMobile">
            </div>
          </div >
        )}
      </div>
    );
  }
}

export default RetrieveRecordMobile;
