import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./index.css";

class Home extends Component {
  constructor(props) {
    super(props);

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
      NAKED: "",
      RCLR: "",
      assetClass: undefined,
      contractArray: [],
    };
  }

  componentDidMount() {
    if (window.AuthLevel !== undefined) {
      this.setState({ authLevel: window.authLevel })
    }
  }

  componentDidUpdate() {

  }

  render() {

    const _setAC = async () => {
      if (this.state.assetClass === "0") { window.assetClass = undefined; return this.forceUpdate() }
      else {
        window.assetClass = this.state.assetClass;
        await window.utils.checkCreds();
        await window.utils.getCosts(6);
        console.log(window.authLevel);
        return this.setState({ authLevel: window.authLevel });
      }
    }

    return (
      <div className="home">
        <img src={require("./Pruf AR cropped.png")} alt="Pruf Logo Home" />
        <p> V 1.0.1</p>

    <div> {window.assetClass > 0 && (<div>Operating in asset class {window.assetClass} as {this.state.authLevel}</div>)}</div>
        {window._contracts !== undefined && (
          <div>
          <Form.Group as={Col} controlId="formGridAC">
          <Form.Label className="formFont">Input desired asset class index # : </Form.Label>
          <Form.Control
            placeholder="Asset Class"
            required
            type="text" 
            onChange={(e) => this.setState({ assetClass: e.target.value })}
            size="lg"
          />
        </Form.Group>
        <Form.Row>
          <Form.Group className="buttonDisplay">
            <Button
              variant="primary"
              type="button"
              size="lg"
              onClick={_setAC}
            >
              Access PRuF
                  </Button>
          </Form.Group>
        </Form.Row>
        </div>
        )}
        {window._contracts === undefined && (<div> <Form.Row><h1>Connecting to the blockchain...</h1></Form.Row></div>)}
      </div>
    );
  }
}

export default Home;
