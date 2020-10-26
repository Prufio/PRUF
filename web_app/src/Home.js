import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./index.css";
import { ArrowRightCircle } from 'react-feather'
import { connect } from 'react-redux';
import {setGlobalAddr, setGlobalWeb3, setGlobalAssetClass, setGlobalAssetClassName, setMenuBasic } from './Actions'

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
    if (this.props.globalAddr !== undefined) {
      this.setState({ addr: this.props.globalAddr })
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

      this.props.setMenuBasic()

      if (this.state.assetClass === "0" || this.state.assetClass === undefined) { this.props.setGlobalAssetClass(undefined); return this.forceUpdate() }
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

          this.props.setGlobalAssetClass(this.state.assetClass);
          await window.utils.resolveACFromID(this.state.assetClass)
          await window.utils.getACData("id", this.state.assetClass)

          console.log(window.authLevel);
          return this.setState({ authLevel: window.authLevel });
        }

        else {
          acDoesExist = await window.utils.checkForAC("name", this.state.assetClass);
          await console.log("Exists?", acDoesExist)

          if (!acDoesExist && window.confirm("Asset class does not currently exist. Consider minting it yourself! Click OK to route to our website for more information.")) {
            window.location.href = 'https://www.pruf.io'
          }

          this.props.setGlobalAssetClassName(this.state.assetClass);
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
          <div> {this.props.globalAddr !== undefined && this.state.assetClass > 0 && (<div>Operating in asset class {this.state.assetClass} ({this.state.assetClass}) as {window.authLevel}</div>)}</div>
          <br></br>
          {this.props.globalContracts !== undefined && this.props.globalAddr !== undefined && (
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
                <div className="submitButtonHome">
                  <div className="submitButton-content">
                    <ArrowRightCircle
                      onClick={() => { _setWindowAC() }}
                    />
                  </div>
                </div>
              </Form.Row>
            </div>
          )}
          {this.props.globalContracts === undefined && this.props.globalAddr !== undefined && (<div className="VRText"> <Form.Row><h1 className="loading">Connecting to the Blockchain</h1></Form.Row></div>)}
          {this.props.globalContracts === undefined && this.props.globalAddr === undefined && (<div className="VRText"> <Form.Row><h1 className="loading">Connecting to the Blockchain</h1></Form.Row></div>)}
          {this.props.globalContracts !== undefined && this.props.globalAddr === undefined && (<div className="VRText"> <Form.Row><h1 >Unable to Get User Address</h1></Form.Row></div>)}
        </div>
      </div>
    );
  }
}

const mapStateToProps = (state) => {

  return{
    globalAddr: state.globalAddr,
    web3: state.web3,
    globalAssetClass: state.globalAssetClass,
    globalAssetClassName: state.globalAssetClassName,
    globalContracts: state.globalContracts,
  }

}

const mapDispatchToProps = () => {
  return {
    setGlobalAddr,
    setGlobalWeb3,
    setGlobalAssetClass,
    setGlobalAssetClassName,
    setMenuBasic,
  }
}



export default connect(mapStateToProps, mapDispatchToProps())(Home);
