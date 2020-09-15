import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";

class GetACData extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      hashPath: "",
      error: undefined,
      NRerror: undefined,
      result: [],
      assetClass: "",
      txHash: "",
      type: "",
      status: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const getAC_data = async () => {
      let tempData;
        let acDoesExist = await window.utils.checkForAC ("id", this.state.assetClass);
        if (acDoesExist) {
            tempData = await window.utils.getACData (this.state.assetClass)
                await this.setState({ACData: tempData});
                console.log(tempData);
        }

        else{alert("Asset class does not exist!")}

        this.forceUpdate()
    };

    return (
      <div>
        <Form className="GACDForm">
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Search AC Data</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Asset Class:</Form.Label>
                  <Form.Control
                    placeholder="Asset Class"
                    required
                    onChange={(e) => this.setState({ assetClass: e.target.value })}
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
                    onClick={getAC_data}
                  >
                    Submit
                  </Button>
                </Form.Group>
              </Form.Row>
            </div>
          )}
        </Form>
        {this.state.ACData !== undefined && ( //conditional rendering
          <div className="GACDresults">
            Asset Class Found!
            <br></br>
            Root AC : {this.state.ACData.root}
            <br></br>
            Custody Type : {this.state.ACData.custodyType}
            <br></br>
            Price Share : {Number (this.state.ACData.discount) / 100}%
            <br></br>
            Extended Data : {this.state.ACData.exData}
          </div>
        )}
      </div>
    );
  }
}

export default GetACData;
