import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";


class RetrieveRecord extends Component {
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
      assetClass: undefined,
      ipfs1: "",
      ipfs2: "",
      txHash: "",
      type: "",
      manufacturer: "",
      model: "",
      serial: "",
      first: "",
      middle: "",
      surname: "",
      id: "",
      secret: "",
      status: "",
      ipfsObject: {},
      showDescription: false,
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

    const _toggleDisplay = async () => {
      if (this.state.manufacturer === "" || this.state.type === "" || this.state.model === "" || this.state.serial === "") {
        return alert("Please fill out all fields before submission")
      }
      if (self.state.showDescription === false) {
        await self.setState({descriptionElements: window.utils.seperateKeysAndValues(self.state.ipfsObject)})
        return self.setState({ showDescription: true })
      }
      else {
        return self.setState({ showDescription: false })
      }
    }

    const _retrieveRecord = async () => {
      const self = this;
      var ipfsHash;

      let idxHash = window.web3.utils.soliditySha3(
        String(this.state.type),
        String(this.state.manufacturer),
        String(this.state.model),
        String(this.state.serial),
      );

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      await window.contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call({ from: window.addr }, function (_error, _result) {
          if (_error) {
            console.log(_error)
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            if (Object.values(_result)[0] === '0') { self.setState({ status: 'No status set' }); }
            else if (Object.values(_result)[0] === '1') { self.setState({ status: 'Transferrable' }); }
            else if (Object.values(_result)[0] === '2') { self.setState({ status: 'Non-transferrable' }); }
            else if (Object.values(_result)[0] === '3') { self.setState({ status: 'REPORTED STOLEN' }); }
            else if (Object.values(_result)[0] === '4') { self.setState({ status: 'REPORTED LOST' }); }
            else if (Object.values(_result)[0] === '5') { self.setState({ status: 'Asset in Transfer' }); }
            else if (Object.values(_result)[0] === '6') { self.setState({ status: 'In escrow (block.number locked)' }); }
            else if (Object.values(_result)[0] === '7') { self.setState({ status: 'Out of supervised escrow' }); }
            else if (Object.values(_result)[0] === '50') { self.setState({ status: 'In Locked Escrow (block.number locked)' }); }
            else if (Object.values(_result)[0] === '51') { self.setState({ status: 'Transferable' }); }
            else if (Object.values(_result)[0] === '52') { self.setState({ status: 'Non-transferrable' }); }
            else if (Object.values(_result)[0] === '53') { self.setState({ status: 'REPORTED STOLEN' }); }
            else if (Object.values(_result)[0] === '54') { self.setState({ status: 'REPORTED LOST' }); }
            else if (Object.values(_result)[0] === '55') { self.setState({ status: 'Asset in Transfer' }); }
            else if (Object.values(_result)[0] === '56') { self.setState({ status: 'In escrow (block.number locked)' }); }
            else if (Object.values(_result)[0] === '57') { self.setState({ status: 'Out of supervised escrow' }); }
            else if (Object.values(_result)[0] === '58') { self.setState({ status: 'Out of locked escrow' }); }
            else if (Object.values(_result)[0] === '59') { self.setState({ status: 'Discardable' }); }
            else if (Object.values(_result)[0] === '60') { self.setState({ status: 'Recycleable' }); }
            else if (Object.values(_result)[0] === '70') { self.setState({ status: 'Importable' }); }
            self.setState({ result: Object.values(_result) })
            self.setState({ error: undefined });

            if (Object.values(_result)[5] > 0) { ipfsHash = window.utils.getIpfsHashFromBytes32(Object.values(_result)[5]); }
            console.log("ipfs data in promise", ipfsHash)
            if (Object.values(_result)[6] > 0) {
              console.log("Getting ipfs2 set up...")
              let knownUrl = "https://ipfs.io/ipfs/";
              let hash = String(window.utils.getIpfsHashFromBytes32(Object.values(_result)[6]));
              let fullUrl = knownUrl + hash;
              console.log(fullUrl);
              self.setState({ ipfs2: fullUrl });
            }
          }
        });

      await this.setState({ ipfsObject: window.utils.getIPFSJSONObject(ipfsHash) });
    }

    return (
      <div>
        <Form className="RRform">
          {window.addr === undefined && (
            <div className="errorResults">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}
          {window.addr > 0 && (
            <div>
              <h2 className="Headertext">Search Assets</h2>
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
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
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
                {this.state.status === "" && (
                  <Form.Group>
                    <Button className="buttonDisplay"
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={_retrieveRecord}
                    >
                      Submit
                </Button>
                  </Form.Group>
                )}

                {this.state.status !== "" && this.state.ipfsObject !== undefined && (
                  
                  <Form.Group>
                    {!this.state.showDescription && (
                      <Form.Group>
                        <Button className="ownerButtonDisplay2"
                          variant="primary"
                          type="button"
                          size="lg"
                          onClick={_toggleDisplay}
                        >
                          Show Description
                  </Button>
                  </Form.Group>
                    )}
                    {this.state.showDescription && (
                      <Form.Group>
                        <Button className="ownerButtonDisplay2"
                          variant="primary"
                          type="button"
                          size="lg"
                          onClick={_toggleDisplay}
                        >
                          Show Statistics
                  </Button>
                      </Form.Group>
                    )}
                    {this.state.type !== undefined && this.state.type !== "" && (
                        <Form.Group>
                        <Button className="ownerButtonDisplay2"
                          variant="primary"
                          type="button"
                          size="lg"
                          onClick={_retrieveRecord}
                        >
                          Submit
                  </Button>
                      </Form.Group>
                    )}

                  </Form.Group>
                )}

              </Form.Row>
            </div>
          )}
        </Form>
        {this.state.result[4] === "0" && (
          <div className="RRresultserr">No Asset Found for Given Data</div>
        )}

        {this.state.result[4] > 0 && ( //conditional rendering
          <div className="RRresults">
            Asset Found!
            <br></br>
            {!this.state.showDescription && (
              <>
                Status : {this.state.status}
                <br></br>
              Mod Count : {this.state.result[1]}
                <br></br>
              Asset Class : {this.state.result[2]}
                <br></br>
              Count : {this.state.result[3]} of {this.state.result[4]}
                <br></br>
              Number of transfers : {this.state.result[7]}
                <br></br>
              </>
            )}

            {this.state.ipfs2 !== undefined && this.state.ipfs2 !== "" && (
              <>
                Asset Inscription : {this.state.ipfs2}
                <br></br>
              </>
            )}

            {this.state.showDescription && (
              <>
                {this.state.descriptionElements !== undefined && (<>{window.utils.generateDescription(this.state.descriptionElements)}</>)}
              </>
            )}
          </div>
        )}
      </div>
    );
  }
}

export default RetrieveRecord;
