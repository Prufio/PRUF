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

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const getAC_data = async () => {
        let ref;
        let tempData;

        if (
            this.state.assetClass.charAt(0) === "0" ||
            this.state.assetClass.charAt(0) === "1" ||
            this.state.assetClass.charAt(0) === "2" ||
            this.state.assetClass.charAt(0) === "3" ||
            this.state.assetClass.charAt(0) === "4" ||
            this.state.assetClass.charAt(0) === "5" ||
            this.state.assetClass.charAt(0) === "6" ||
            this.state.assetClass.charAt(0) === "7" ||
            this.state.assetClass.charAt(0) === "8" ||
            this.state.assetClass.charAt(0) === "9"
          ) {
              ref = "id"
          }
          else {
              ref ="name"
          }
      
        let acDoesExist = await window.utils.checkForAC (ref, this.state.assetClass);
        if (acDoesExist) {
            let tempData = await window.utils.getACData (ref, this.state.assetClass)
                await this.setState({
                    ACData: tempData
                });
                console.log(tempData);
        }
        else{alert("Asset class does not exist!")}
    };

    return (
      <div>
        <Form className="Form">
          {window.addr === undefined && (
            <div className="VRresults">
              <h2>User address unreachable</h2>
              Please connect web3 provider.
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Search AC Data</h2>
              <br></br>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Asset Class:</Form.Label>
                  <Form.Control
                    placeholder="Asset Class"
                    required
                    onChange={(e) => this.setState({ assetClass: e.target.value })}
                    size="lg"
                  />
                </Form.Group>
                <Form.Group>
                  <Button className="buttonDisplay"
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={getAC_data}
                  >
                    Submit
                  </Button>
                </Form.Group>
            </div>
          )}
        </Form>
        {this.state.ACData !== undefined && ( //conditional rendering
          <div className="Results">
            Asset Class Found!
            <br></br>
            AC : {this.state.ACData.AC}
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
