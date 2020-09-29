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

      if(this.state.hasLoadedAssets !== window.hasLoadedAssets){
        this.setState({hasLoadedAssets: window.hasLoadedAssets})
      }
    }, 100)

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

    const _checkIn = async (e) => {
      if (e === "0" || e === undefined) { return }
      this.setState({ selectedAsset: e })
      console.log("Changed component idx to: ", window.assets.ids[e])

      this.setState({
        assetTokenInfo: {
          assetClass: window.assets.assetClasses[e],
          idxHash: window.assets.ids[e],
          name: window.assets.descriptions[e].name,
          photos: window.assets.descriptions[e].photo,
          text: window.assets.descriptions[e].text,
          description: window.assets.descriptions[e],
          status: window.assets.statuses[e],
        }
      })
    }

    return (
      <div className="assetDashboard">
        <div>
          <h2 className="Headertext">My Assets</h2>
        </div>
        <br></br>
        {this.state.hasLoadedAssets && (<>{window.utils.generateAssetDash()}</>)}
        {!this.state.hasLoadedAssets && (<><h2>Loading Asssets...</h2></>)}
      </div >
    );
  }
}

export default AssetCheckIn;
