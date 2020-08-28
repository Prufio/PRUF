import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";

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

    const getIpfsHashFromBytes32 = (bytes32Hex) => {
      
      // Add our default ipfs values for first 2 bytes:
      // function:0x12=sha2, size:0x20=256 bits
      // and cut off leading "0x"
      const hashHex = "1220" + bytes32Hex.slice(2);
      const hashBytes = Buffer.from(hashHex, "hex");
      const hashStr = bs58.encode(hashBytes);
      return hashStr;
    };

    const getIPFS2 = async (lookup2) => {
      /*  await window.ipfs.cat(lookup2, (error, result) => {
         if (error) {
           console.log("Something went wrong. Unable to find file on IPFS");
         } else {
           console.log("IPFS2 Here's what we found: ", result);
         }
         self.setState({ ipfs2: result });
       }); */
       self.setState({ipfs2: lookup2});};

    const getIPFS1 = async (lookup1) => {
      await window.ipfs.cat(lookup1, (error, result) => {
        if (error) {
          console.log("Something went wrong. Unable to find file on IPFS");
        } else {
          console.log("IPFS1 Here's what we found: ", result);
        }
        self.setState({ ipfs1: result });
      });
    };

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

    const _retrieveRecord = () => {
      const self = this;
      var idxHash;
      
      idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
    );

      console.log("idxHash", idxHash);
      console.log("addr: ", window.addr);

      window.contracts.STOR.methods
        .retrieveShortRecord(idxHash)
        .call({ from: window.addr }, function (_error, _result) {
          if (_error) { console.log(_error)
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            if (Object.values(_result)[0] === '0'){  self.setState({ status: 'No status set' });}
            else if (Object.values(_result)[0] === '1'){  self.setState({ status: 'Transferrable' });}
            else if (Object.values(_result)[0] === '2'){  self.setState({ status: 'Non-transferrable' });}
            else if (Object.values(_result)[0] === '3'){  self.setState({ status: 'ASSET REPORTED STOLEN' });}
            else if (Object.values(_result)[0] === '4'){  self.setState({ status: 'ASSET REPRTED LOST' });}
            else if (Object.values(_result)[0] === '5'){  self.setState({ status: 'Asset in transfer' });}
            else if (Object.values(_result)[0] === '6'){  self.setState({ status: 'In escrow (block.number locked)' });}
            else if (Object.values(_result)[0] === '7'){  self.setState({ status: 'P2P Transferrable' });}
            else if (Object.values(_result)[0] === '8'){  self.setState({ status: 'P2P Non-transferrable' });}
            else if (Object.values(_result)[0] === '9'){  self.setState({ status: 'ASSET REPORTED STOLEN (P2P)' });}
            else if (Object.values(_result)[0] === '10'){  self.setState({ status: 'ASSET REPORTED LOST (P2P)' });}
            else if (Object.values(_result)[0] === '11'){  self.setState({ status: 'In P2P transfer' });}
            else if (Object.values(_result)[0] === '12'){  self.setState({ status: 'In escrow (block.time locked)' });}
            else if (Object.values(_result)[0] === '20'){  self.setState({ status: 'Cusdodial escrow ended' });}
            else if (Object.values(_result)[0] === '21'){  self.setState({ status: 'P2P escrow ended' });}
            else if (Object.values(_result)[0] === '51'){  self.setState({ status: 'Transferrable, export eligible' });}
            self.setState({ result: Object.values(_result)})
            self.setState({ error: undefined });

            if (Object.values(_result)[5] > 0) {getIPFS1(getIpfsHashFromBytes32(Object.values(_result)[5]));}

            if (Object.values(_result)[6] > 0) {
            console.log("Getting ipfs2 set up...")
            let knownUrl = "https://ipfs.io/ipfs/";
            let hash = String(getIpfsHashFromBytes32(Object.values(_result)[6]));
            let fullUrl = knownUrl+hash;
            console.log(fullUrl);
            getIPFS2(fullUrl);}
        }});
    };

    return (
      <div>
        <Form className="RRform">
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
              <h2 className="Headertext">Search Records</h2>
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
                <Form.Group className="buttonDisplay">
                  <Button
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_retrieveRecord}
                  >
                    Submit
                  </Button>
                </Form.Group>
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
            Status : {this.state.status}
            <br></br>
            Mod Count : {this.state.result[1]}
            <br></br>
            Asset Class : {this.state.result[2]}
            <br></br>
            Count : {this.state.result[3]} of {this.state.result[4]}
            <br></br>
            IPFS Description : {this.state.ipfs1}
            <br></br>
            IPFS Note : {this.state.ipfs2}
            <br></br>
            Number of transfers : {this.state.result[7]}
          </div>
        )}
      </div>
    );
  }
}

export default RetrieveRecord;
