import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./../index.css";

class AssetCheckIn extends Component {
  constructor(props) {
    super(props);

    this.generateAssets = () => {
      if (window.assets.names.length > 0) {
        let component = [];
        //console.log(window.assets)

        for (let i = 0; i < window.assets.ids.length; i++) {
          component.push(<option value={i}>Name: {window.assets.descriptions[i].name} ID: {window.assets.ids[i]} </option>);
        }

        //console.log(component)

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
      assetClass: undefined,
      contractArray: [],
    };
  }

  componentDidMount() {
    this.setState({ addr: window.addr })
  }

  componentDidUpdate() {

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {

    const _checkIn = async () => {
      window.idxHash = this.state.selectedAsset
      console.log("Changed window idx to: ", window.idxHash)

      window.assetTokenInfo = {
        assetClass: window.assets.assetClasses[this.state.selectedAsset],
        idxHash: window.assets.ids[this.state.selectedAsset],
        name: window.assets.descriptions[this.state.selectedAsset].name,
        photos: window.assets.descriptions[this.state.selectedAsset].photo,
        text: window.assets.descriptions[this.state.selectedAsset].text,
        status: window.assets.statuses[this.state.selectedAsset],
      }
    }

    return (
      <div className="home">
        {window.assets.assetClasses.length > 0 && (
          <>
          <h1>Asset Name: {window.assetTokenInfo.name}</h1>
          <br></br>
          <h1>Asset Status: {window.assetTokenInfo.status}</h1>
          <br></br>
          <h1>Asset Class: {window.assetTokenInfo.assetClass}</h1>
          </>

        )}
        
        {window.assets.assetClasses.length > 0 && (
          <div>
          <br></br>
          <Form.Group as={Col} controlId="formGridAC">
            <Form.Label className="formFont">Choose an asset to modify : </Form.Label>
            <Form.Control
              as="select"
              size="lg"
              onChange={(e) => this.setState({ selectedAsset: e.target.value })}
            >
              <option value="0"> Select an asset </option>
              {this.generateAssets()}

            </Form.Control>
          </Form.Group>
          <Form.Row>
            <Button
              className="buttonDisplayAssetCheckIn"
              variant="primary"
              type="button"
              size="lg"
              onClick={_checkIn}
            >
              Access PRuF
                </Button>
          </Form.Row>
        </div>
        )}

          
        {window.assets.assetClasses.length === 0 && (<div> <Form.Row><h1>Loading asset list. This may take a while...</h1></Form.Row></div>)}
      </div>
    );
  }
}

export default AssetCheckIn;
