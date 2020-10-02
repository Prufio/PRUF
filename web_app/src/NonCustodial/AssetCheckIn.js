import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./../index.css";
import { NavLink } from "react-router-dom";
import Dropdown from 'react-bootstrap/Dropdown';
import Nav from 'react-bootstrap/Nav'
import DropdownButton from 'react-bootstrap/DropdownButton';
import { Printer, RefreshCw } from "react-feather";
import { Grid } from "react-feather";
import { X } from "react-feather";
import { Save } from "react-feather";
import { Print } from "react-feather";
import { QRCode } from 'react-qrcode-logo';

class AssetCheckIn extends Component {
  constructor(props) {
    super(props);



    this.updateAssets = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }

      if (this.state.hasLoadedAssets !== window.hasLoadedAssets && this.state.runWatchDog === true) {
        this.setState({ hasLoadedAssets: window.hasLoadedAssets })
      }
    }, 100)

    this.moreInfo = (e) => {
      if (e === "back") { return this.setState({ assetObj: {}, moreInfo: false }) }

      this.setState({ assetObj: e, moreInfo: true, selectedImage: e.displayImage })
    }

    this.sendPacket = (obj, menu, link) => {
      window.sentPacket = obj
      window.menuChange = menu
      window.location.href = '/#/' + link
      // console.log(menu)
    }

    this.generateAssetInfo = (obj) => {
      let images = Object.values(obj.photo)
      let text = Object.values(obj.text)
      let imageNames = Object.keys(obj.photo)
      let textNames = Object.keys(obj.text)

      const showImage = (e) => {
        console.log(this.state.selectedImage)
        console.log(e)
        this.setState({ selectedImage: e })
      }

      const openPhotoNT = (url) => {
        const newWindow = window.open(url, '_blank', 'noopener,noreferrer')
        if (newWindow) { newWindow.opener = null }
      }

      const _printQR = async () => {
        // this.state = {
        //   printQR: undefined,
        // }
        if (this.state.printQR === undefined) {
          this.setState({ printQR: true })
        }
        else {
          this.setState({ printQR: undefined })
        }
      }

      const generateThumbs = () => {
        let component = [];

        for (let i = 0; i < images.length; i++) {
          component.push(
            <button value={images[i]} class="assetImageSelectorButton" onClick={() => { showImage(images[i]) }}>
              <img src={images[i]} className="imageSelectorImage" />
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
              <h4 class="card-description-selected">{textNames[i]}: {text[i]}</h4>
              <br />
            </>
          )
        }

        return component
      }

      return (
        <div>
          <div>
            <div className="assetDashboardSelected">
              <style type="text/css"> {`
  
              .card {
                width: 100%;
                max-width: 100%;
                height: 50rem;
                max-height: 100%;
                background-color: #005480;
                margin-top: 0.3rem;
                color: white;
                word-break: break-all;
              }

              .btn-selectedImage {
                background-color: #005480;
                color: white;
                height: 4rem;
                margin-top: -20rem;
                margin-left: -0.8rem;
                font-weight: bold;
                font-size: 2.2rem;
                border-radius: 0rem 0rem 0.3rem 0.3rem;
              }

              .btn-QR {
                background-color: #002a40;
                color: white;
                height: 2rem;
                width: 17rem;
                margin-top: auto;
                // margin-left: -0.8rem;
                font-weight: bold;
                font-size: 1rem;
                border-radius: 0rem 0rem 0.3rem 0.3rem;
                justify-content: center;
              }
  
            `}
              </style>
              <div class="card" value="100">
                <div class="row no-gutters">
                  <div className="assetSelecedInfo">
                    <div className="mediaLinkADS">
                      <a className="mediaLinkContentADS" ><Grid onClick={() => { _printQR() }} /></a>
                    </div>
                    {this.state.printQR && (
                      <div>
                        <div className="QRdisplay">
                          <div className="QR">
                            <QRCode value={obj.idxHash} size="140" />
                          </div>
                        </div>
                        <div className="QRdisplay-footer">
                          <div className="mediaLinkQRdisplay">
                            <a className="mediaLinkQRdisplayContent" ><Save onClick={() => { _printQR() }} /></a>
                            <a className="mediaLinkQRdisplayContent" ><Printer onClick={() => { _printQR() }} /></a>
                            <a className="mediaLinkQRdisplayContent" ><X onClick={() => { _printQR() }} /></a>
                          </div>
                        </div>
                      </div>
                    )}
                    <button class="assetImageButtonSelected" onClick={() => { openPhotoNT(this.state.selectedImage) }}>
                      <img src={this.state.selectedImage} className="assetImageSelected" />
                    </button>
                    <p class="card-name-selected">Name : {obj.name}</p>
                    <p class="card-ac-selected">Asset Class : {obj.assetClass}</p>
                    <p class="card-status-selected">Status : {obj.status}</p>
                    <div className="imageSelector">
                      {generateThumbs()}
                    </div>
                    <div className="cardSelectedIdxForm">
                      <h4 class="card-idx-selected">IDX : {obj.idxHash}</h4>
                    </div>
                    <div className="cardDescription-selected">
                      {generateTextList()}
                    </div>
                  </div>
                  <div className="cardButton-selected">
                    {this.state.moreInfo && (
                      <Button
                        variant="primary"
                        onClick={() => { this.moreInfo("back") }}
                      >
                        Back to list
                      </Button>
                    )}

                  </div>
                </div>
              </div >
            </div >
          </div>
          <div
            className="assetSelectedRouter"
          >
            <Nav className="headerSelected">
              <li>
                <Button variant="selectedImage" onClick={() => { this.sendPacket(obj, "NC", "transfer-asset-NC") }}>Transfer</Button>
              </li>
              <li>
                <Button variant="selectedImage" onClick={() => { this.sendPacket(obj, "NC", "export-asset-NC") }}>Export</Button>
              </li>
              <li>
                <Button variant="selectedImage" onClick={() => { this.sendPacket(obj, "NC", "manage-escrow-NC") }}>Escrow</Button>
              </li>
              <li>
                <DropdownButton title="Modify" drop="up" variant="selectedImage">
                  <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "modify-record-status-NC") }}>Modify Status</Dropdown.Item>
                  <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "decrement-counter-NC") }}>Decrement Counter</Dropdown.Item>
                  <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "modify-description-NC") }}>Modify Description</Dropdown.Item>
                  <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "add-note-NC") }}>Add Note</Dropdown.Item>
                  <Dropdown.Item id="header-dropdown" as={Button} onClick={() => { this.sendPacket(obj, "NC", "force-modify-record-NC") }}>Modify Rightsholder</Dropdown.Item>
                </DropdownButton>
              </li>
            </Nav>
          </div>
        </div>


      )
    }

    this.generateAssetDash = (obj) => {
      if (obj.names.length > 0) {
        let component = [];

        for (let i = 0; i < obj.ids.length; i++) {
          //console.log(i, "Adding: ", window.assets.descriptions[i], "and ", window.assets.ids[i])
          component.push(
            <div key={"asset" + String(i)}>
              <style type="text/css"> {`
  
              .card {
                width: 100%;
                max-width: 100%;
                height: 12rem;
                max-height: 100%;
                background-color: #005480;
                margin-top: 0.3rem;
                color: white;
                word-break: break-all;
              }
  
             `}
              </style>
              <div class="card" >
                <div class="row no-gutters">
                  <div class="col-auto">
                    <button
                      class="assetImageButton"
                      // value={
                      //   JSON.stringify()}
                      onClick={() => {
                        this.moreInfo({
                          idxHash: obj.ids[i],
                          descriptionObj: obj.descriptions[i],
                          displayImage: obj.displayImages[i],
                          name: obj.names[i],
                          assetClass: obj.assetClasses[i],
                          status: obj.statuses[i],
                          description: obj.descriptions[i].text.description,
                          text: obj.descriptions[i].text,
                          photo: obj.descriptions[i].photo
                        })
                      }}
                    >
                      <img src={obj.displayImages[i]} className="assetImage" />
                    </button>
                  </div>
                  <div>
                    <p class="card-name">Name : {obj.names[i]}</p>
                    <p class="card-ac">Asset Class : {obj.assetClasses[i]}</p>
                    <p class="card-status">Status : {obj.statuses[i]}</p>
                    <h4 class="card-idx">IDX : {obj.ids[i]}</h4>
                    <br></br>
                    <div className="cardDescription"><h4 class="card-description">Description :{obj.descriptions[i].text.description}</h4></div>
                  </div>
                  <div className="cardButton">
                    <Button
                      variant="primary"
                      value={
                        JSON.stringify({
                          idxHash: obj.ids[i],
                          descriptionObj: obj.descriptions[i],
                          displayImage: obj.displayImages[i],
                          name: obj.names[i],
                          assetClass: obj.assetClasses[i],
                          status: obj.statuses[i],
                          description: obj.descriptions[i].text.description,
                          text: obj.descriptions[i].text,
                          photo: obj.descriptions[i].photo
                        })}
                      onClick={(e) => { this.moreInfo(JSON.parse(e.target.value)) }}
                    >
                      More Info
                        </Button>
                  </div>
                </div>
              </div>
            </div>

          );
        }

        return component
      }

      else { return <></> }

    }

    this.state = {
      addr: undefined,
      web3: null,
      APP: "",
      NP: "",
      STOR: "",
      AC_MGR: "",
      ECR_NC: "",
      ECR_MGR: "",
      AC_TKN: "",
      A_TKN: "",
      APP_NC: "",
      NP_NC: "",
      ECR2: "",
      authLevel: "",
      PIP: "",
      RCLR: "",
      showDescription: false,
      descriptionElements: undefined,
      assets: { descriptions: [0], ids: [0], assetClasses: [0], statuses: [0], names: [0] },
      contractArray: [],
      hasLoadedAssets: false,
    };
  }

  componentDidMount() {
    this.setState({
      addr: window.addr,
      runWatchDog: true,
      assetTokenInfo: {}
    })
  }

  componentDidUpdate() {

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {


    const _refresh = () => {
      window.resetInfo = true;
      window.recount = true;
      this.setState({ assets: { descriptions: [], ids: [], assetClasses: [], statuses: [], names: [] } })
    }

    return (

      <div>
        <div>
          <h2 className="assetDashboardHeader">My Assets</h2>
          <div className="mediaLinkAD">
            <a className="mediaLinkContentAD" ><RefreshCw onClick={() => { window.resetInfo = true; window.recount = true }} /></a>
          </div>
        </div>
        <div className="assetDashboard">
          {this.state.hasLoadedAssets && !this.state.moreInfo && (<>{this.generateAssetDash(window.assets)}</>)}
          {this.state.hasLoadedAssets && this.state.moreInfo && (<>{this.generateAssetInfo(this.state.assetObj)}</>)}
          {!this.state.hasLoadedAssets && (<div className="VRText"><h2 class="loading">Loading Assets</h2></div>)}
        </div>
        <div className="assetDashboardFooter">
        </div>
      </div >

    );
  }
}

export default AssetCheckIn;
