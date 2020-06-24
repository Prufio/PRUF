import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";
import bs58 from "bs58";

class ModifyDescription extends Component {
  constructor(props) {
    super(props);

    this.acctChanger = async () => {
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({ addr: e[0] }));
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
      AssetClass: "",
      CountDownStart: "",
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
      web3: null,
      frontend: "",
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
    var addrArray = returnAddresses();
    var _frontend_addr = addrArray[1];
    var _storage_addr = addrArray[0];
    const frontEnd_abi = returnFrontEndAbi();
    const storage_abi = returnStorageAbi();

    const _frontend = new _web3.eth.Contract(frontEnd_abi, _frontend_addr);

    const _storage = new _web3.eth.Contract(storage_abi, _storage_addr);
    this.setState({ frontend: _frontend });
    this.setState({ storage: _storage });

    document.addEventListener("accountListener", this.acctChanger());
  }

  componentWillUnmount() {
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
      await this.state.ipfs.cat(lookup2, (error, result) => {
        if (error) {
          console.log("Something went wrong. Unable to find file on IPFS");
        } else {
          console.log("IPFS2 Here's what we found: ", result);
        }
        self.setState({ ipfs2: result });
      });
    };
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
      var idxHash = this.state.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial
      );

      console.log("idxHash", idxHash);
      console.log("addr: ", this.state.addr);

      this.state.storage.methods
        .retrieveShortRecord(idxHash)
        .call({ from: this.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else {
            self.setState({ result: Object.values(_result) });
            self.setState({ error: undefined });

            if (Object.values(_result)[7] > 0) {getIPFS1(getIpfsHashFromBytes32(Object.values(_result)[7]));}

            if (Object.values(_result)[8] > 0) {getIPFS2(getIpfsHashFromBytes32(Object.values(_result)[8]));}

            console.log(Object.values(_result));
          }
        });
    };

    return (
      <div>
        <Form className="RRform">
          {this.state.addr === undefined && (
            <div className="errorResults">
              <h2>WARNING!</h2>
              <h3>Injected web3 not connected to form!</h3>
            </div>
          )}
          {this.state.addr > 0 && (
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
                    onChange={(e) =>
                      this.setState({ manufacturer: e.target.value })
                    }
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
            Status:
            {this.state.result[2]}
            <br></br>
            Mod Count:
            {this.state.result[3]}
            <br></br>
            Asset Class :{this.state.result[4]}
            <br></br>
            Count :{this.state.result[5]} of {this.state.result[6]}
            <br></br>
            Ipfs1 :{this.state.ipfs1}
            <br></br>
            Ipfs2 :{this.state.ipfs2}
          </div>
        )}
      </div>
    );
  }
}

export default ModifyDescription;
