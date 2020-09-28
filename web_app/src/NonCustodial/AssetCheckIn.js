import React, { Component } from "react";
import Form from "react-bootstrap/Form";
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
      if(e === "0" || e === undefined){return}
      this.setState({ selectedAsset: e })
      console.log("Changed component idx to: ", window.assets.ids[e])

      this.setState({assetTokenInfo: {
        assetClass: window.assets.assetClasses[e],
        idxHash: window.assets.ids[e],
        name: window.assets.descriptions[e].name,
        photos: window.assets.descriptions[e].photo,
        text: window.assets.descriptions[e].text,
        description: window.assets.descriptions[e],
        status: window.assets.statuses[e],
      }})
    }

    return (
      <div>
        <Form className="assetDashboard" id="MainForm">
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {this.state.assets !== undefined && window.addr > 0 && (
            <div>
              <h2 className="Headertext">Asset Dashboard</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridAsset">
                  <Form.Label className="formFont"> Select an Asset to Modify :</Form.Label>
                  <Form.Control
                    as="select"
                    size="lg"
                    onChange={(e) => {_checkIn(e.target.value)}}
                  >
                    {window.hasLoadedAssets && (<option value="null"> Select an asset </option>)}
                    {!window.hasLoadedAssets && (<option value="null"> Loading Assets... </option>)}
                    {window.utils.generateAssets()}
                  </Form.Control>
                </Form.Group>
              </Form.Row>
              {this.state.assetTokenInfo !== undefined && (
                <Form.Row>
                <Form.Group as={Col} controlId="formGridStats">
                  <h3 className="assetDashboardContentHead">Asset Name: <h3 className="assetDashboardContent">{this.state.assetTokenInfo.name}</h3> </h3>
                  <h3 className="assetDashboardContentHead"> Asset Status: <h3 className="assetDashboardContent">{this.state.assetTokenInfo.status}</h3> </h3>
                  <h3 className="assetDashboardContentHead">Asset Class: <h3 className="assetDashboardContent">{this.state.assetTokenInfo.assetClass}</h3> </h3>
                </Form.Group>
              </Form.Row>
              )}
              
              <Form.Row>
                <Button
                  className="buttonDisplay"
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={_refresh}
                >
                  Refresh List
                </Button>
              </Form.Row>
            </div>
          )}

          {/* {this.state.showDescription && (
          <>
            {this.state.descriptionElements !== undefined && (<>{window.utils.generateDescription(this.state.descriptionElements)}</>)}
          </>
        )} */}
          {this.state.assets === undefined && (<div> <Form.Row><h1>Loading asset list. This may take a while...</h1></Form.Row></div>)}
        </Form>
      </div>
    );
  }
}

export default AssetCheckIn;
