import React, { Component } from "react";
import returnContracts from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";
import returnManufacturers from "./Manufacturers";
import returnTypes from "./Types";
import returnActions from "./Actions";

class ModifyDescription extends Component {
  constructor(props) {
    super(props);

    this.getAssetClass = async () => {
      const self = this;
      //console.log("getting asset class");
      if (self.state.assetClass > 0 || self.state.BPappPayable === "") {
      } else {
        self.state.BPappPayable.methods
          .getUserExt(self.state.web3.utils.soliditySha3(self.state.addr))
          .call({ from: self.state.addr }, function (_error, _result) {
            if (_error) {console.log(_error)
            } else {
               console.log("_result: ", _result);  if (_result !== undefined ) {
                self.setState({ assetClass: Object.values(_result)[1] });
              }
            }
          });
    }
    };

    this.returnsContract = async () => {
      const self = this;
      var contractArray = await returnContracts(self.state.web3);
      //console.log("RC RR: ", contractArray)

      if(this.state.storage < 1){self.setState({ storage: contractArray[0] });}
      if(this.state.BPappNonPayable < 1){self.setState({ BPappNonPayable: contractArray[1] });}
      if(this.state.BPappPayable < 1){self.setState({ BPappPayable: contractArray[2] });}
    };

    this.acctChanger = async () => {
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({ addr: e[0] }));
        self.setState({assetClass: undefined})
      });
    };

    //Component state declaration

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      IPFS: require("ipfs-mini"),
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
      web3: null,
      BPappPayable: "",
      BPappNonPayable: "",
      storage: "",
    };
  }

  componentDidMount() {
    var _ipfs = new this.state.IPFS({
      host: "ipfs.infura.io",
      port: 5001,
      protocol: "https",
    });
    this.setState({ ipfs: _ipfs });
    //console.log("component mounted")
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentDidUpdate(){

    if(this.state.ipfs2 > 0) {console.log(this.state.ipfs2);}

    if(this.state.web3 !== null && this.state.BPappPayable < 1){
      this.returnsContract();
    }

    if (this.state.addr > 0 && this.state.assetClass === undefined) {
      this.getAssetClass();
    }
  }

  componentWillUnmount() {
    this.setState({assetClass: undefined})
    //console.log("unmounting component")
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {
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
      /*  await this.state.ipfs.cat(lookup2, (error, result) => {
         if (error) {
           console.log("Something went wrong. Unable to find file on IPFS");
         } else {
           console.log("IPFS2 Here's what we found: ", result);
         }
         self.setState({ ipfs2: result });
       }); */
       self.setState({ipfs2: lookup2});};

    const getIPFS1 = async (lookup1) => {
      await this.state.ipfs.cat(lookup1, (error, result) => {
        if (error) {
          console.log("Something went wrong. Unable to find file on IPFS");
        } else {
          console.log("IPFS1 Here's what we found: ", result);
        }
        self.setState({ ipfs1: result });
      });
    };

    const _retrieveRecord = () => {
      const self = this;
      var idxHash;
      
      idxHash = this.state.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial,
    );

      console.log("idxHash", idxHash);
      console.log("addr: ", this.state.addr);

      this.state.storage.methods
        .retrieveShortRecord(idxHash)
        .call({ from: this.state.addr }, function (_error, _result) {
          if (_error) { console.log(_error)
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            if (Object.values(_result)[2] === '0'){  self.setState({ status: 'No status set' });}
            else if (Object.values(_result)[2] === '1'){  self.setState({ status: 'Transferrable' });}
            else if (Object.values(_result)[2] === '2'){  self.setState({ status: 'Non-transferrable' });}
            else if (Object.values(_result)[2] === '3'){  self.setState({ status: 'ASSET REPORTED STOLEN' });}
            else if (Object.values(_result)[2] === '4'){  self.setState({ status: 'ASSET REPRTED LOST' });}
            else if (Object.values(_result)[2] === '5'){  self.setState({ status: 'Asset in transfer' });}
            else if (Object.values(_result)[2] === '6'){  self.setState({ status: 'In escrow (block.number locked)' });}
            else if (Object.values(_result)[2] === '7'){  self.setState({ status: 'P2P Transferrable' });}
            else if (Object.values(_result)[2] === '8'){  self.setState({ status: 'P2P Non-transferrable' });}
            else if (Object.values(_result)[2] === '9'){  self.setState({ status: 'ASSET REPORTED STOLEN (P2P)' });}
            else if (Object.values(_result)[2] === '10'){  self.setState({ status: 'ASSET REPORTED LOST (P2P)' });}
            else if (Object.values(_result)[2] === '11'){  self.setState({ status: 'In P2P transfer' });}
            else if (Object.values(_result)[2] === '12'){  self.setState({ status: 'In escrow (block.time locked)' });}
            else if (Object.values(_result)[2] === '20'){  self.setState({ status: 'Cusdodial escrow ended' });}
            else if (Object.values(_result)[2] === '21'){  self.setState({ status: 'P2P escrow ended' });}
            self.setState({ result: Object.values(_result)})
            self.setState({ error: undefined });

            if (Object.values(_result)[7] > 0) {getIPFS1(getIpfsHashFromBytes32(Object.values(_result)[7]));}

            if (Object.values(_result)[8] > 0) {
            console.log("Getting ipfs2 set up...")
            let knownUrl = "https://ipfs.io/ipfs/";
            let hash = String(getIpfsHashFromBytes32(Object.values(_result)[8]));
            let fullUrl = knownUrl+hash;
            console.log(fullUrl);
            getIPFS2(fullUrl);}
        }});
    };

    return (
      <div>
        <Form className="RRform">
        {this.state.addr === undefined && (
            <div className="errorResults">
              <h2>WARNING!</h2>
              <h3>Injected web3 not connected to form!</h3>
            </div>
          )}{this.state.assetClass < 1 && (
            <div className="errorResults">
              <h2>No authorized asset class detected at user address.</h2>
              <h3>Unauthorized users do not have access to forms.</h3>
            </div>
          )}
          {this.state.addr > 0 && this.state.assetClass > 0 &&(
            <div>
              <h2 className="Headertext">Search Records</h2>
              <br></br>
              <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                  <Form.Label className="formFont">Type:</Form.Label>

                  {returnTypes(this.state.assetClass) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ type: e.target.value })}>
                  {returnTypes(this.state.assetClass)}
                  </Form.Control>
                  )}

                    {returnTypes(this.state.assetClass) === '0' &&(
                    <Form.Control
                    placeholder="Type"
                    required
                    onChange={(e) => this.setState({ type: e.target.value })}
                    size="lg"
                  />)}
                </Form.Group>

                  <Form.Group as={Col} controlId="formGridManufacturer">
                    <Form.Label className="formFont">Manufacturer:</Form.Label>
                    {returnManufacturers(this.state.assetClass) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ manufacturer: e.target.value })}>
                  {returnManufacturers(this.state.assetClass)}
                  </Form.Control>
                  )}

                      {returnManufacturers(this.state.assetClass) === '0' &&(
                    <Form.Control
                    placeholder="Manufacturer"
                    required
                    onChange={(e) => this.setState({ manufacturer: e.target.value })}
                    size="lg"
                  />)}
                  </Form.Group>
                  
                  {returnActions(this.state.assetClass) !== "0" &&(
                  <Form.Group as={Col} controlId="formGridAction">
                  <Form.Label className="formFont">Action:</Form.Label>
                    {returnActions(this.state.assetClass) !== '0' &&(<Form.Control as="select" size="lg" onChange={(e) => this.setState({ action: e.target.value })}>
                    {returnActions(this.state.assetClass)}
                    </Form.Control>
                    )}
                  </Form.Group>)}

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
            Status:{this.state.status}
            <br></br>
            Mod Count:{this.state.result[3]}
            <br></br>
            Asset Class :{this.state.result[4]}
            <br></br>
            Count :{this.state.result[5]} of {this.state.result[6]}
            <br></br>
            IPFS Description :{this.state.ipfs1}
            <br></br>
            IPFS Note {this.state.ipfs2}
          </div>
        )}
      </div>
    );
  }
}

export default ModifyDescription;
