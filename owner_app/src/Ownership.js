import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class Ownership extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      isSTOROwner: undefined,
      isBPPOwner: undefined,
      isBPNPOwner: undefined,
      STOROwner: "",
      BPPOwner: "",
      BPNPOwner: "",
      addr: "",
      error: undefined,
      result: "",
      newOwner: "",
      toggle: false,
      assetClass: "",
      web3: null,
      isTxfrSTOR: false,
      isTxfrBPP: false,
      isTxfrBPNP: false,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentDidUpdate(){//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const handleCheckBox = (e) => {
      let setTo;
      if(e === `STOR`){
        if(this.state.isTxfrSTOR === false){
          setTo = true;
        }
        else if(this.state.isTxfrSTOR === true){
          setTo = false;
        }
        this.setState({isTxfrSTOR: setTo});
        console.log("Setting txfr", e, "to: ", setTo);
      }

      else if(e === `APP`){
        if(this.state.isTxfrBPP === false){
          setTo = true;
        }
        else if(this.state.isTxfrBPP === true){
          setTo = false;
        }
        this.setState({isTxfrBPP: setTo});
        console.log("Setting txfr", e, "to: ", setTo);
      }

      else if(e === `NP`){
        if(this.state.isTxfrBPNP === false){
          setTo = true;
        }
        else if(this.state.isTxfrBPNP === true){
          setTo = false;
        }
        this.setState({isTxfrBPNP: setTo});
        console.log("Setting txfr", e, "to: ", setTo);
      }
    }

    const toggleRenounce = () => {
      if (this.state.toggle === false) {
        this.setState({ toggle: true });
        alert(
          "You are about to renounce the current STOR contract. Proceed with caution."
        );
      } else {
        this.setState({ toggle: false });
      }
    };

    const renounce = () => {
      window.contracts.STOR.methods
        .renounceOwnership()
        .send({ from: window.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("Ownership renounced");
          console.log("tx receipt: ", receipt);
        });

      console.log(this.state.txHash);
    };

    const transfer = () => {
      if(this.state.newOwner < 1){return(alert("Can not transfer to zero address"))}

      if(this.state.isTxfrSTOR === true){
        window.contracts.STOR.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: window.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("STOR ownership Transferred to: ", self.state.newOwner);
          self.setState({isSTOROwner: false})
          console.log("tx receipt: ", receipt);
        });}

        if(this.state.isTxfrBPP === true){
          window.contracts.APP.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: window.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("BP app ownership Transferred to: ", self.state.newOwner);
          self.setState({isBPPOwner: false})
          console.log("tx receipt: ", receipt);
        });}

        if(this.state.isTxfrBPNP === true){
          window.contracts.NP.methods
        .transferOwnership(this.state.newOwner)
        .send({ from: window.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("BP app (non-APP) ownership Transferred to: ", self.state.newOwner);
          self.setState({isBPNPOwner: false})
          console.log("tx receipt: ", receipt);
        });}

        else{alert("please check boxes corresponding to the contract(s) you'd like to transfer")}

      console.log(this.state.txHash);
    };

    return (
      <div>
        <Form className="OForm">
          {window.addr === undefined && (
            <div className="VRresults">
              <h2>User address unreachable</h2>
              Please connect web3 provider.
            </div>
          )}

          {window.addr > 0 && this.state.toggle === false && (
            <div>
              <Form.Group>
                {this.state.isSTOROwner === true && (
                <Form.Check
                className = 'checkBox'
                onChange={(e)=>{handleCheckBox(e.target.id)}}
                id={`STOR`}
                label={`STOR`}
                />)}
                {this.state.isBPPOwner === true && (
                <Form.Check
                className = 'checkBox'
                onChange={(e)=>{handleCheckBox(e.target.id)}}
                id={`APP`}
                label={`APP`}
                />)}
                {this.state.isBPNPOwner === true && (
                <Form.Check
                className = 'checkBox'
                onChange={(e)=>{handleCheckBox(e.target.id)}}
                id={`NP`}
                label={`NP`}
                />)}
                </Form.Group>
              <h2 className="Headertext">Manage Ownership</h2>
              <br></br>
              <Form.Group as={Col} controlId="formGridNewOwner">
                <Form.Label className="formFont">New Owner :</Form.Label>
                <Form.Control
                  placeholder="New Owner Address"
                  required
                  onChange={(e) => this.setState({ newOwner: e.target.value })}
                  size="lg"
                />
              </Form.Group>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={transfer}
                  >
                    Transfer
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
                    onClick={toggleRenounce}
                  >
                    Renounce
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}

          {window.addr > 0 && this.state.toggle === true && (
            <div>
              <h2 className="Headertext">Renounce Ownership?</h2>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay3"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={renounce}
                  >
                    Confirm
                  </Button>
                </Form.Group>
              </div>
              <div>
                <Form.Group>
                  <Button
                    className="ownerButtonDisplay4"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={toggleRenounce}
                  >
                    Go Back
                  </Button>
                </Form.Group>
              </div>
            </div>
          )}
        </Form>
      </div>
    );
  }
}
export default Ownership;
