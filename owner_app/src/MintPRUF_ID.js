import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Button from "react-bootstrap/Button";
import Col from "react-bootstrap/Col";

class MintPRUF_IDToken extends Component {
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
        Recipient: "",
        TokenId: "",
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

      const newIDTKN = async () => {
        await console.log(window.contracts.ID_TKN.methods)
        await window.contracts.ID_TKN.methods.mint(
            self.state.Recipient,
            self.state.TokenId).send({from: window.addr})
      }
  
      return (
        <div>
          <Form className="MIDTKNForm">
            {window.addr === undefined && (
              <div className="VRresults">
                <h2>User address unreachable</h2>
                Please connect web3 provider.
              </div>
            )}
            {window.addr !== undefined && (
              <div>
                <h2 className="Headertext">New ID Token</h2>
                <br></br>
                <Form.Group as={Col} controlId="formGridRecipient">
                  <Form.Label className="formFont">Recipient Address :</Form.Label>
                  <Form.Control
                    placeholder="Token Recipient"
                    required
                    onChange={(e) => this.setState({ Recipient: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group as={Col} controlId="formGridTokenId">
                  <Form.Label className="formFont">PRUF_ID TokenId :</Form.Label>
                  <Form.Control
                    placeholder="TokenId"
                    required
                    onChange={(e) => this.setState({ TokenId: e.target.value })}
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
                      onClick={newIDTKN}
                    >
                      Mint ID_Token
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
  export default MintPRUF_IDToken;
  