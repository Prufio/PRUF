import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";
import "./index.css";

class Home extends Component {
  constructor(props) {
    super(props);

    this.getCosts = async () => {
      //console.log("Getting cost array");
      await window.contracts.AC_MGR.methods
      .retrieveCosts(window.assetClass)
      .call({from: window.addr}, (_error, _result) => {
        if (_error){console.log("Error: ", _error)}
        else {
          //console.log("result in getCosts: ", Object.values(_result));
          window.costArray = Object.values(_result)
          return window.authLevel = this.state.authLevel
        }
      })
      //console.log("before setting window-level costs")
      window.costs = {
        newRecordCost: window.costArray[0],
        transferAssetCost: window.costArray[1],
        createNoteCost: window.costArray[2],
        remintAssetCost: window.costArray[3],
        importAssetCost: window.costArray[4],
        forceTransferCost: window.costArray[5],
        beneficiaryAddress: window.costArray[6]
      }
      //console.log("window costs object: ", window.costs);
      //console.log("this should come last");
    }

    this._checkCreds = () => {
      //console.log(window.contracts.AC_MGR);
      //console.log(window.web3)
      //console.log(window.addr)
      //console.log(window.assetClass)
      window.contracts.AC_MGR.methods
      .getUserType(window.web3.utils.soliditySha3(window.addr), window.assetClass)
      .call({from: window.addr}, (_error, _result) => {
        if(_error){console.log("Error: ", _error)}
        else{
          if (_result === "0"){this.setState({authLevel: "Standard User (read-only access)"})}
          else if(_result === "1"){this.setState({authLevel: "Administrator"})}
          else if(_result === "9"){this.setState({authLevel: "Robot"})}
            //console.log(_result)
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
    if (window.authLevel !== undefined){
      this.setState({authLevel: window.authLevel})
    }

  }

  componentDidUpdate() {

  }

  render() {

    
    const _setAC = async () => {
      if(this.state.assetClass === "0" || this.state.assetClass === undefined){window.assetClass = undefined; return this.forceUpdate()}
      else{
      window.assetClass = this.state.assetClass;
      await this._checkCreds();
      await this.getCosts();
      return this.forceUpdate()
      }
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
        <p> V 1.0.0</p>

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
