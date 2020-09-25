import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./../index.css";

class AssetCheckIn extends Component {
  constructor(props) {
    super(props);

    this.updateAuthLevel = setInterval(() => {
      if (this.state.assets !== window.assets && this.state.runWatchDog === true) {
        this.setState({ assets: window.assets })
      }
      if (this.state.assetTokenInfo !== window.assetTokenInfo && this.state.runWatchDog === true) {
        this.setState({ assetTokenInfo: window.assetTokenInfo })
      }
    }, 100)

    this.generateAssets = () => {
      if (window.assets.names.length > 0) {
        let component = [];

        for (let i = 0; i < window.assets.ids.length; i++) {
          //console.log(i, "Adding: ", window.assets.descriptions[i], "and ", window.assets.ids[i])
          component.push(<option key={"asset " + String(i)} value={i}>Name: {window.assets.descriptions[i].name}, ID: {window.assets.ids[i]} </option>);
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
      assets: undefined,
      contractArray: [],
    };
  }

  componentDidMount() {
    this.setState({
      addr: window.addr,
      runWatchDog: true,
      assets: undefined,
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
      this.setState({ assets: undefined })
    }

    const _checkIn = async () => {
      console.log("Changed window idx to: ", window.assets.ids[this.state.selectedAsset])

      window.assetTokenInfo = {
        assetClass: window.assets.assetClasses[this.state.selectedAsset],
        idxHash: window.assets.ids[this.state.selectedAsset],
        name: window.assets.descriptions[this.state.selectedAsset].name,
        photos: window.assets.descriptions[this.state.selectedAsset].photo,
        text: window.assets.descriptions[this.state.selectedAsset].text,
        description: window.assets.descriptions[this.state.selectedAsset],
        status: window.assets.statuses[this.state.selectedAsset],
      }

      /* this.setState({ descriptionElements: window.utils.seperateKeysAndValues(this.state.assetTokenInfo.description) })
      this.setState({ showDescription: true }) */
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
                    onChange={(e) => this.setState({ selectedAsset: e.target.value })}
                  >
                    <option value="null"> Select an asset </option>
                    {this.generateAssets()}
                  </Form.Control>
                </Form.Group>
              </Form.Row>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridStats">
                  <h3 className="assetDashboardContent">Asset Name: {this.state.assetTokenInfo.name} </h3>
                  <h3 className="assetDashboardContent2"> Asset Status: {this.state.assetTokenInfo.status} </h3>
                  <h3 className="assetDashboardContent">Asset Class: {this.state.assetTokenInfo.assetClass} </h3>
                </Form.Group>
              </Form.Row>
              <Form.Row>
                <Button
                  className="buttonDisplay"
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={_checkIn}
                >
                  Access PRuF
                </Button>
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
