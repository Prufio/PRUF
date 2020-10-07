import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./index.css";
import { ArrowRightCircle } from 'react-feather'
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
      PIP: "",
      RCLR: "",
      assetClass: undefined,
      contractArray: [],
    };
  }

  componentDidMount() {
    if (window.addr !== undefined) {
      this.setState({ addr: window.addr })
    }

  }

  componentDidUpdate() {

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {

    const _setWindowAC = async () => {
      let acDoesExist;

      window.routeRequest = "basic"

      if (this.state.assetClass === "0" || this.state.assetClass === undefined) { window.assetClass = undefined; return this.forceUpdate() }
      else {
        if (
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
        ) {
          acDoesExist = await window.utils.checkForAC("id", this.state.assetClass);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.location.href = 'https://www.pruf.io'
          }

          window.assetClass = this.state.assetClass;
          await window.utils.resolveACFromID(window.assetClass)
          await window.utils.getACData("id", window.assetClass)

          console.log(window.authLevel);
          return this.setState({ authLevel: window.authLevel });
        }

        else {
          acDoesExist = await window.utils.checkForAC("name", this.state.assetClass);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click ok to route to our website for more information.")) {
            window.location.href = 'https://www.pruf.io'
          }

          window.assetClassName = this.state.assetClass
          await window.utils.resolveAC(this.state.assetClass);

          return this.setState({ authLevel: window.authLevel });
        }
      }
    }

    return (
      <div>
        <div className="home">
          <img className="prufARCroppedForm" src={require("./Resources/Pruf AR (2).png")} alt="Pruf Logo Home" />
          <br></br>
          <div> {window.addr !== undefined && window.assetClass > 0 && (<div>Operating in asset class {window.assetClass} ({window.assetClassName}) as {window.authLevel}</div>)}</div>
          <br></br>
          {window._contracts !== undefined && window.addr !== undefined && (
            <div>
              <Form.Group as={Col} controlId="formGridAC">
                <Form.Label className="formFont">Input desired asset class # or name : </Form.Label>
                <Form.Control
                  placeholder="Asset Class"
                  required
                  type="text"
                  onChange={(e) => this.setState({ assetClass: e.target.value })}
                  size="lg"
                />
              </Form.Group>
              <Form.Row>
                <div className="submitButton">
                  <div className="submitButton-content">
                    <ArrowRightCircle
                      onClick={() => { _setWindowAC() }}
                    />
                  </div>
                </div>
              </Form.Row>
            </div>
          )}
          {window._contracts === undefined && window.addr !== undefined && (<div className="VRText"> <Form.Row><h1 className="loading">Connecting to the Blockchain</h1></Form.Row></div>)}
          {window._contracts === undefined && window.addr === undefined && (<div className="VRText"> <Form.Row><h1 className="loading">Connecting to the Blockchain</h1></Form.Row></div>)}
          {window._contracts !== undefined && window.addr === undefined && (<div className="VRText"> <Form.Row><h1 >Unable to Get User Address</h1></Form.Row></div>)}
        </div>
      </div>
    );
  }
}

export default Home;
