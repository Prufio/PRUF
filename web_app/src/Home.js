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
    window.assetClassName = "unresolved";
  }

  componentDidUpdate() {

  }

  render() {

    const _setAC = async () => {
      if (this.state.assetClass === "0") { window.assetClass = undefined; return this.forceUpdate() }
      else {
        if(
          this.state.assetClass.charAt(0) === "0" ||
          this.state.assetClass.charAt(0) === "1" ||
          this.state.assetClass.charAt(0) === "2" ||
          this.state.assetClass.charAt(0) === "3" ||
          this.state.assetClass.charAt(0) === "4" ||
          this.state.assetClass.charAt(0) === "5" || 
          this.state.assetClass.charAt(0) === "6" ||
          this.state.assetClass.charAt(0) === "7" ||
          this.state.assetClass.charAt(0) === "8" ||
          this.state.assetClass.charAt(0) === "9"
          ){
        window.assetClass = this.state.assetClass;
        await window.utils.checkCreds();
        await window.utils.getCosts(6);
        console.log(window.authLevel);
        return this.setState({ authLevel: window.authLevel });
        }

        else{
          window.assetClassName = this.state.assetClass
          await window.utils.resolveAC();
          return this.setState({ authLevel: window.authLevel });
        }
      }
    }

    return (
      <div className="home">
        <img src={require("./Resources/Pruf AR cropped.png")} alt="Pruf Logo Home" />
        <p> V 1.0.1</p>

        <div> {window.assetClass > 0 && (<div>Operating in asset class {window.assetClass} ({window.assetClassName}) as {window.authLevel}</div>)}</div>
        {window._contracts !== undefined && (
          <div>
            <br></br>
            <Form.Group as={Col} controlId="formGridAC">
              <Form.Label className="formFont">Input desired asset class index # or name : </Form.Label>
              <Form.Control
                placeholder="Asset Class"
                required
                type="text"
                onChange={(e) => this.setState({ assetClass: e.target.value })}
                size="lg"
              />
            </Form.Group>
            <Form.Row>
              <Button
                className="buttonDisplayHome"
                variant="primary"
                type="button"
                size="lg"
                onClick={_setAC}
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

export default Home;
