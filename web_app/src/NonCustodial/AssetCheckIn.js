import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./../index.css"; 

class AssetCheckIn extends Component {
  constructor(props) {
    super(props);

    this.generateAssets = () => {
        let component = [];
        console.log(window.assets)
    
        for (let i = 0; i < window.assets.ids.length; i++) {
        component.push(<option value={String(window.assets.ids[i])}>Name: {window.assets.names[i]} ID: {window.assets.ids[i]} </option>);
        }
    
        console.log(component)
    
        return component
        
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
    this.setState({addr: window.addr})
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
        await window.utils.getACFromIdx(this.state.selectedAsset)
    }

    return (
      <div className="home">
        <img src={require("./../Resources/Pruf AR cropped.png")} alt="Pruf Logo AssetCheckIn" />
        <p> V 1.0.1</p>

        <div> {window.assetClass > 0 && (<div>Operating in asset class {window.assetClass} ({window.assetClassName}) as {window.authLevel}</div>)}</div>
        {window._contracts !== undefined && (
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
        {window._contracts === undefined && (<div> <Form.Row><h1>Connecting to Blockchain Provider...</h1></Form.Row></div>)}
      </div>
    );
  }
}

export default AssetCheckIn;
