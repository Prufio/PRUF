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

  render() {

    const _checkCreds = () => {
      window.AC_MGR.methods
      .getUserType(window.web3.utils.soliditySha3(window.addr, window.assetClass))
      .call({from: window.addr}, (_error, _result) => {
        if(_error){console.log("Error: ", _error)}
        else{this.setState({authLevel: _result})
            console.log(_result)
        }
      });
    }
    
    const _setAC = () => {
      window.assetClass = this.state.assetClass;
      _checkCreds();
      return this.forceUpdate()
    }

    return (
      <div className="home">
        <p>
          PRuF
          <br />
          Blockchain
          <br />
          Provenance
        </p>
        <p> V 0.2.3</p>

    <p> {window.assetClass > 0 && (<div>You are in asset class {window.assetClass} as {this.state.authLevel}</div>)}</p>
        <br></br>
        <Form.Group as={Col} controlId="formGridAC">
          <Form.Label className="formFont">Input desired asset class index # : </Form.Label>
          <Form.Control
            placeholder="Asset Class"
            required
            type="number" 
            onChange={(e) => this.setState({ assetClass: e.target.value })}
            size="lg"
          />
        </Form.Group>
        <br></br>
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
    );
  }
}

export default Home;
