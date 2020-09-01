import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class MintAssetClass extends Component {
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
        ACAdmin: "",
        ACName: "",
        ACRoot: "",
        ACIndex: "",
        ACCustodyType: "",
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

      const newAC = async () => {

        await window.contracts.AC_MGR.methods.createAssetClass(
            self.state.ACIndex,
            self.state.ACAdmin,
            self.state.ACName,
            self.state.ACIndex,
            self.state.ACRoot,
            self.state.ACCustodyType).send({from: window.addr})
      }
  
      return (
        <div>
          <Form className="MACForm">
            {window.addr === undefined && (
              <div className="VRresults">
                <h2>User address unreachable</h2>
                Please connect web3 provider.
              </div>
            )}
            {window.addr !== undefined && (
              <div>
                <h2 className="Headertext">New Asset Class</h2>
                <br></br>
                <Form.Group as={Col} controlId="formGridNewOwner">
                  <Form.Label className="formFont">AC Admin Address :</Form.Label>
                  <Form.Control
                    placeholder="ACA Address"
                    required
                    onChange={(e) => this.setState({ ACAdmin: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridNewOwner">
                  <Form.Label className="formFont">AC Name :</Form.Label>
                  <Form.Control
                    placeholder="AC Name"
                    required
                    onChange={(e) => this.setState({ ACName: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridNewOwner">
                  <Form.Label className="formFont">AC Index Number:</Form.Label>
                  <Form.Control
                    placeholder="AC Index"
                    required
                    onChange={(e) => this.setState({ ACIndex: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridNewOwner">
                  <Form.Label className="formFont">AC Root Index Number:</Form.Label>
                  <Form.Control
                    placeholder="Root"
                    required
                    onChange={(e) => this.setState({ ACRoot: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridNewOwner">
                  <Form.Label className="formFont">AC Custody Type :</Form.Label>
                  <Form.Control
                    placeholder="Custody Type (1 === C, 2 === NC)"
                    required
                    onChange={(e) => this.setState({ ACCustodyType: e.target.value })}
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
                      onClick={newAC}
                    >
                      Create AC
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
  export default MintAssetClass;
  