import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";

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
      self.setState({ ipfs2: lookup2 });
    };

    const getIPFS1 = async (lookup1) => {
      console.log(lookup1)
      await window.ipfs.cat(lookup1, (error, result) => {
        if (error) {
          console.log("Something went wrong. Unable to find file on IPFS");
        } else {
          console.log("IPFS1 Here's what we found: ", result);
        }
        console.log(JSON.parse(result));
        self.setState({ipfsObject: JSON.parse(result)})
      });
    };

    const _seperateKeysAndValues = (obj) => {
      console.log (obj)
      let textPairsArray = [];
      let photoPairsArray = [];

      let photoKeys = Object.keys(obj.photo);
      let photoVals = Object.values(obj.photo);
      let textKeys = Object.keys(obj.text);
      let textVals = Object.values(obj.text);

      for(let i = 0; i < photoKeys.length; i++){
        photoPairsArray.push(photoKeys[i] + ": " + photoVals[i])
      }

      for(let i = 0; i < textKeys.length; i++){
        textPairsArray.push(textKeys[i] + ": " + textVals[i])
      }

      self.setState({descriptionElements: {photo: photoPairsArray, text: textPairsArray}})
    }

    const generateDescription = (obj) => {

    console.log(self.state.descriptionElements)

    let component = [<><h4>Images Found:</h4> <br></br></>];

      for(let i = 0; i < obj.photo.length; i++){
        console.log("adding photo", obj.photo[i])
        component.push (<> {String(obj.photo[i])} <br></br></>);
      }

      component.push(<> <br></br> <h4>Text Values Found:</h4> <br></br> </>);
      for(let x = 0; x < obj.text.length; x++){
      console.log("adding text ", obj.text[x])
      component.push (<>{String(obj.text[x])} <br></br></>);
      } 

      console.log(component)
      return component
    }

    const _toggleDisplay = () => {
      if (self.state.showDescription === false){
        _seperateKeysAndValues(self.state.ipfsObject);
        self.setState({showDescription: true})
      }
      else{
      self.setState({showDescription: false})
      }
    }

    const _retrieveRecord = async () => {
      const self = this;
      var idxHash;
      var ipfsHash;

      idxHash = window.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
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

            if (Object.values(_result)[5] > 0) {ipfsHash = getIpfsHashFromBytes32(Object.values(_result)[5]); }
            console.log("ipfs data in promise", ipfsHash)
            if (Object.values(_result)[6] > 0) {
              console.log("Getting ipfs2 set up...")
              let knownUrl = "https://ipfs.io/ipfs/";
              let hash = String(getIpfsHashFromBytes32(Object.values(_result)[6]));
              let fullUrl = knownUrl + hash;
              console.log(fullUrl);
              getIPFS2(fullUrl);
            }
          }
        });

        await getIPFS1(ipfsHash); 
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
              <h2 className="Headertext">Search Records</h2>
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
                {this.state.status === ""&& (
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
                )}

                {this.state.status !== "" && this.state.ipfsObject !== undefined &&(
                  <Form.Group className="buttonDisplay">
                  {!this.state.showDescription &&(
                    <>
                    <Button
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_toggleDisplay}
                  >
                   Show Description
                  </Button>
                  <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={_retrieveRecord}
                >
                  Submit
                </Button>
                </>
                  )}
                  {this.state.showDescription &&(
                    <>
                    <Button
                    variant="primary"
                    type="button"
                    size="lg"
                    onClick={_toggleDisplay}
                  >
                   Show Statistics
                  </Button>
                  <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={_retrieveRecord}
                >
                  Submit
                </Button>
                </>
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
            {!this.state.showDescription &&(
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

            {this.state.ipfs2 !== undefined && this.state.ipfs2 !== "" &&(
            <>
            Asset Inscription : {this.state.ipfs2}
            <br></br>
            </>
            )}

            {this.state.showDescription &&(
            <>
            {this.state.descriptionElements !== undefined && (generateDescription(this.state.descriptionElements))}
            </>
            )}
          </div>
        )}
      </div>
    );
  }
}

export default RetrieveRecord;
