import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";

class EscrowManager extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      costArray: [0],
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      assetClass: undefined,
      CountDownStart: "",
      ipfs1: "",
      txHash: "",
      txStatus: false,
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      isNFA: false,
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      newFirst: "",
      newMiddle: "",
      newSurname: "",
      newId: "",
      newSecret: "",
      newStatus: "",
      agent: "",
      timeFormat: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

   componentDidUpdate() {//stuff to do when state updates

  } 

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    async function checkExistsSet(idxHash) {
      await window.contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
            alert(
              "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
            );
          }else {
            if (Object.values(_result)[2] === '6' || Object.values(_result)[2] === '12'){
                alert("WARNING: Asset already in escrow! Reject in metamask and wait for active escrow status to expire.")}
            self.setState({ result1: _result });
          }
          console.log("check debug, _result, _error: ", _result, _error);
        });
    }

    async function checkExistsEnd(idxHash) {
        await window.contracts.STOR.methods
          .retrieveShortRecord(idxHash)
          .call({ from: self.state.addr }, function (_error, _result) {
            if (_error) {
              self.setState({ error: _error });
              self.setState({ result: 0 });
              alert(
                "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
              );
            }else {
              if (Object.values(_result)[2] !== '6' && Object.values(_result)[2] !== '12'){
                  alert("WARNING: Asset is not in escrow! Reject in metamask and check status in search.")}
              self.setState({ result1: _result });
            }
            console.log("check debug, _result, _error: ", _result, _error);
          });
      }
    const _convertTimeTo = (rawTime, to) => {
        var time;

        if      (to === "seconds") {time = rawTime}
        else if (to === "minutes") {time = rawTime*60}
        else if (to === "hours") {time = rawTime*3600}
        else if (to === "days") {time = rawTime*86400}
        else if (to === "weeks") {time = rawTime*604800}
        else{alert("Invalid time unit")}
        return (time);
    }

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

    const _setEscrow = () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})
      var idxHash;
      
      idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
    );

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);
      console.log("time: ", this.state.escrowTime, "format: ", this.state.timeFormat);

      checkExistsSet(idxHash);

      window.contracts.ECR.methods
        .setEscrow(idxHash, _convertTimeTo(this.state.escrowTime, this.state.timeFormat), this.state.newStatus, window.web3.utils.soliditySha3(this.state.agent))
        .send({ from: window.addr})
        .on("error", function (_error) {
          // self.setState({ NRerror: _error });
          self.setState({ txHash: Object.values(_error)[0].transactionHash });
          self.setState({ txStatus: false });
          console.log(Object.values(_error)[0].transactionHash);
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          console.log(receipt.status);
          //Stuff to do when tx confirms
        });
      console.log(this.state.txHash);
      document.getElementById("MainForm").reset();
    };

    const _endEscrow = () => {
      this.setState({ txStatus: false });
      this.setState({ txHash: "" });
      this.setState({error: undefined})
      this.setState({result: ""})
        var idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial
        );
  
        console.log("idxHash", idxHash);
        console.log("addr: ", window.addr);
  
        checkExistsEnd(idxHash);
  
        window.contracts.ECR.methods
          .endEscrow(idxHash)
          .send({ from: window.addr})
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            //Stuff to do when tx confirms
          });
        console.log(this.state.txHash);
        document.getElementById("MainForm").reset();
      };

    return (
      <div>
        <Form className="MEform" id='MainForm'>
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
              <h2 className="Headertext">Manage Escrow</h2>
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
                <Form.Group as={Col} controlId="formGridAgent">
                  <Form.Label className="formFont">Agent Address:</Form.Label>
                  <Form.Control
                    placeholder="agent"
                    required
                    onChange={(e) => this.setState({ agent: e.target.value })}
                    size="lg"
                  />
                </Form.Group>

                <Form.Group as={Col} controlId="formGridStatus">
                  <Form.Label className="formFont">Escrow Status:</Form.Label>
                  <Form.Control
                    placeholder="status"
                    required
                    onChange={(e) => this.setState({ newStatus: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
              </Form.Row>

              <Form.Row>
                <Form.Group as={Col} controlId="formGridTime">
                  <Form.Label className="formFont">Duration:</Form.Label>
                  <Form.Control
                    placeholder="setEscrow duration"
                    required
                    onChange={(e) => this.setState({ escrowTime: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridFormat">
                <Form.Label className="formFont">Time Unit:</Form.Label>
                  <Form.Control as="select" size="lg" onChange={(e) => this.setState({ timeFormat: e.target.value })}>
                    <option value="0">Select a time unit</option>
                    <option value="seconds">Seconds</option>
                    <option value="minutes">Minutes</option>
                    <option value="hours">Hours</option>
                    <option value="days">Days</option>
                    <option value="weeks">Weeks</option>
                  </Form.Control>
                </Form.Group>
                </Form.Row>
                <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_setEscrow}
                  >
                    begin escrow
                  </Button>
                </Form.Group>
              </div>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay2"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_endEscrow}
                  >
                    end escrow
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}
        </Form>
        {this.state.txHash > 0 && ( //conditional rendering
          <div className="Results">
            {this.state.txStatus === false && (
              <div>
                !ERROR! :
                <a
                  href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  KOVAN Etherscan:{this.state.txHash}
                </a>
              </div>
            )}
            {this.state.txStatus === true && (
              <div>
                {" "}
                No Errors Reported :
                <a
                  href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  KOVAN Etherscan:{this.state.txHash}
                </a>
              </div>
            )}
          </div>
        )}
      </div>
    );
  }
}

export default EscrowManager;
