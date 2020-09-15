import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";

class VerifyRightHolder extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      error: undefined,
      error1: undefined,
      result: "",
      result1: "",
      assetClass: undefined,
      ipfs1: "",
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      isNFA: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
 
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate(){//stuff to do when state updates

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const handleCheckBox = () => {
      let setTo;
      if(this.state.isNFA === false){
        setTo = true;
      }
      else if(this.state.isNFA === true){
        setTo = false;
      }
      this.setState({isNFA: setTo});
      console.log("Setting to: ", setTo);
      this.setState({manufacturer: ""});
      this.setState({type: ""});
    }

    const _verify = async () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})
      var idxHash;
      var rgtRaw;
      
      idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
    );

      rgtRaw = window.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );
      var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      var doesExist = await window.utils.checkAssetExists(idxHash);

      if (!doesExist){
        return alert("Asset doesnt exist! Ensure data fields are correct before submission.")
      }

      window.contracts.STOR.methods
        ._verifyRightsHolder(idxHash, rgtHash)
        .call({ from: window.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            self.setState({ result: _result });
            console.log("verify.call result: ", _result);
            self.setState({ error: undefined });
          }
        });

        window.contracts.STOR.methods
        .blockchainVerifyRightsHolder(idxHash, rgtHash)
        .send({ from: window.addr })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          console.log(this.state.txHash);
        });

      console.log(this.state.result);
      document.getElementById("MainForm").reset();
    };
    return (
      <div>
        <Form className="VRform" id='MainForm'>
        {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}{window.assetClass === undefined && (
            <div className="errorResults">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass > 0 &&(
            <div>
                {window.assetClass === 3 &&(
                <Form.Group>
                <Form.Check
                className = 'checkBox'
                size = 'lg'
                onChange={handleCheckBox}
                id={`NFA Firearm`}
                label={`NFA Firearm`}
                />
                </Form.Group>
                )}
              <h2 className="Headertext">Verify Rights Holder</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>

                  {returnTypes(window.assetClass, this.state.isNFA) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ type: e.target.value })}>
                  {returnTypes(window.assetClass, this.state.isNFA)}
                  </Form.Control>
                  )}

                    {returnTypes(window.assetClass, this.state.isNFA) === '0' &&(
                    <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />)}
                </Form.Group>

                  <Form.Group as={Col} controlId="formGridManufacturer">
                    <Form.Label className="formFont">Manufacturer:</Form.Label>
                    {returnManufacturers(window.assetClass, this.state.isNFA) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ manufacturer: e.target.value })}>
                  {returnManufacturers(window.assetClass, this.state.isNFA)}
                  </Form.Control>
                  )}

                      {returnManufacturers(window.assetClass, this.state.isNFA) === '0' &&(
                    <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
                    size="lg"
                  />)}
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
                <Form.Group as={Col} controlId="formGridFirstName">
                  <Form.Label className="formFont">First Name:</Form.Label>
                  <Form.Control
                    placeholder="First Name"
                    required
                    onChange={(e) => this.setState({ first: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridMiddleName">
                  <Form.Label className="formFont">Middle Name:</Form.Label>
                  <Form.Control
                    placeholder="Middle Name"
                    required
                    onChange={(e) => this.setState({ middle: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridLastName">
                  <Form.Label className="formFont">Last Name:</Form.Label>
                  <Form.Control
                    placeholder="Last Name"
                    required
                    onChange={(e) => this.setState({ surname: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridIdNumber">
                  <Form.Label className="formFont">ID Number:</Form.Label>
                  <Form.Control
                    placeholder="ID Number"
                    required
                    onChange={(e) => this.setState({ id: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridPassword">
                  <Form.Label className="formFont">Password:</Form.Label>
                  <Form.Control
                    placeholder="Password"
                    type="password"
                    required
                    onChange={(e) => this.setState({ secret: e.target.value })}
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
                    onClick={_verify}
                  >
                    Submit
                  </Button>
                </Form.Group>
              </Form.Row>
            </div>
          )}
        </Form>

        {this.state.txHash > 0 && ( //conditional rendering
          <div className="VRHresults">
            {this.state.result === "170"
              ? "Match Confirmed :"
              : "Record does not match :"}
            <a
              href={" https://kovan.etherscan.io/tx/" + this.state.txHash}
              target="_blank"
              rel="noopener noreferrer"
            >
              KOVAN Etherscan:{this.state.txHash}
            </a>
          </div>
        )}
      </div>
    );
  }
}
export default VerifyRightHolder;
