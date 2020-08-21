import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./index.css";

class Home extends Component {
  constructor(props) {
    super(props);

    this._checkCreds = () => {
      console.log(window.contracts.content[3]);
      console.log(window.web3)
      console.log(window.addr)
      console.log(window.assetClass)
      window.contracts.content[3].methods
      .getUserType(window.web3.utils.soliditySha3(window.addr), window.assetClass)
      .call({from: window.addr}, (_error, _result) => {
        if(_error){console.log("Error: ", _error)}
        else{this.setState({authLevel: _result})
            console.log(_result)
        }
      }); 
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
      NAKED: "",
      RCLR: "",
      assetClass: undefined,
      contractArray: [],
    };
  }

  componentDidMount() {
    console.log(window)

  }

  componentDidUpdate() {
    if(window.contracts > 0){
      this.getContracts();
    }
  }

  render() {

    
    const _setAC = async () => {
      window.assetClass = this.state.assetClass;
      this._checkCreds();
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

    <div> {window.assetClass > 0 && (<div>You are in asset class {window.assetClass} as {this.state.authLevel}</div>)}</div>
        {window.contracts !== undefined && (
          <div>
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
        {window.contracts === undefined && (<div> <Form.Row><h1>Connecting to the blockchain...</h1></Form.Row></div>)}
      </div>
    );
  }
}

export default Home;
