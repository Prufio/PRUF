import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Card from "react-bootstrap/Card";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./../index.css";

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

      this.setState({ assetObj: e, moreInfo: true })
    }

    this.generateAssetInfo = (obj) => {
      return (
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
  
            `}
          </style>
          <div class="card" value="100">
            <div class="row no-gutters">
              <div className="assetSelecedInfo">
              <button class="assetImageButton">
                <img src={obj.displayImage} className="assetImageSelected" />
                </button>
                <p class="card-name-selected">Name : {obj.name}</p>
                <p class="card-ac-selected">Asset Class : {obj.assetClass}</p>
                <p class="card-status-selected">Status : {obj.status}</p>
                <div className="imageSelector">
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                <button class="assetImageButton">
                <img src={obj.displayImage} className="imageSelectorImage" />
                </button>
                </div>

                <div className="cardDescription-selected">
                  <h4 class="card-description-selected">Description :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Artist :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Origin :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Price : ${obj.description} USD</h4>
                  <br />
                  <h4 class="card-description-selected">Description :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Artist :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Origin :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Description :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Artist :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Origin :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Price : ${obj.description} USD</h4>
                  <br />
                  <h4 class="card-description-selected">Description :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Artist :{obj.description}</h4>
                  <br />
                  <h4 class="card-description-selected">Origin :{obj.description}</h4>
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


      )
    }

    this.generateAssetDash = (obj) => {
      if (obj.names.length > 0) {
        let component = [];

        for (let i = 0; i < obj.ids.length; i++) {
          //console.log(i, "Adding: ", window.assets.descriptions[i], "and ", window.assets.ids[i])
          component.push(
            <div>
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
                        onClick={(e) => {
                          this.moreInfo({
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
                      <br></br>
                      <div className="cardDescription"><h4 class="card-description">Description :{obj.descriptions[i].text.description}</h4></div>
                    </div>
                    <div className="cardButton">
                      <Button
                        variant="primary"
                        value={
                          JSON.stringify({
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
