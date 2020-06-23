import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class ResetFMC extends Component {

  constructor(props){
    super(props);

    this.acctChanger = async () => {
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
        ethereum.on("accountsChanged", function(accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({addr: e[0]}));
      });
      }

    //Component state declaration

    this.state = {
      addr: undefined,
      error: undefined,
      result: "",
      model: "",
      manufacturer: "",
      type: "",
      serial: "",
      storage: ""
    }

  }

  componentDidMount() {
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({web3: _web3});
    _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
    var addrArray = returnAddresses(); 
    var _storage_addr = addrArray[0];
    const storage_abi = returnStorageAbi();

    const _storage = new _web3.eth.Contract(
    storage_abi, 
    _storage_addr
    );

    this.setState({storage: _storage})

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() { 
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger())
  }

  render(){
    const self = this;
    const resetCount = () => {
      var idxHash = this.state.web3.utils.soliditySha3(this.state.type, this.state.manufacturer, this.state.model, this.state.serial);
      this.state.storage.methods
        .ADMIN_resetFMC(idxHash)
        .send({ from: this.state.addr}).on("error", function(_error){self.setState({error: _error});self.setState({result: _error.transactionHash});})
        .on("receipt", (receipt) => {
          console.log("user added succesfully under asset class", self.state.assetClass)
          console.log("tx receipt: ", receipt)
        });
    
      console.log(this.state.txHash);
    };

    return (
      <div>
        <Form className="RFMCForm">
          {this.state.addr === undefined && (
            <div className="errorResults">
              <h2>WARNING!</h2>
              <h3>Injected web3 not connected to form!</h3>
            </div>
          )}
          {this.state.addr > 0 && (
            <Form>
              <h2 className="Headertext">Reset FMC</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>
                  <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridManufacturer">
                  <Form.Label className="formFont">Manufacturer:</Form.Label>
                  <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) =>
                      this.setState({ manufacturer: e.target.value })
                    }
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridModel">
                  <Form.Label className="formFont">Model:</Form.Label>
                  <Form.Control
                    placeholder="Model"
                    required
                    onChange={(e) => this.setState({ model: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridSerial">
                  <Form.Label className="formFont">Serial:</Form.Label>
                  <Form.Control
                    placeholder="Serial"
                    required
                    onChange={(e) => this.setState({ serial: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group className="buttonDisplay">
                  <Button
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={resetCount}
                  >
                    Submit
                  </Button>
                </Form.Group>
              </Form.Row>
            </Form>
          )}
          </Form>
      </div>
      // <div>
      //   {this.state.addr === undefined && (
      //       <div className="VRresults">
      //         <h2>WARNING!</h2>
      //         Injected web3 not connected to form!
      //       </div>
      //     )}
      //   {this.state.addr > 0 && (
      //   <form className="ANform">
      //     <h2>Reset FMC</h2>
      //   Type:
      //   <input
      //     type="text"
      //     name="type"
      //     placeholder="type"
      //     required
      //     onChange={(e) => this.setState({name: e.target.value})}
      //   />
      //   <br></br>
      //   Manufacturer:
      //   <input
      //     type="text"
      //     name="manufacturer"
      //     placeholder="manufacturer"
      //     required
      //     onChange={(e) => this.setState({authAddress: e.target.value})}
      //   />
      //   <br></br>
      //   Model:
      //   <input
      //     type="text"
      //     name="model"
      //     placeholder="model #"
      //     required
      //     onChange={(e) => this.setState({authLevel: e.target.value})}
      //   />
      //   <br></br>
      //   Serial:
      //   <input
      //     type="text"
      //     name="serial"
      //     placeholder="serial #"
      //     required
      //     onChange={(e) => this.setState({authLevel: e.target.value})}
      //   />
      //   <br></br>
      //     <input type="button" value="Reset FMC" onClick={resetCount} />
      //   </form>)}
      // </div>
    );}
}

export default ResetFMC;