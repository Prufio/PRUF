import React, { Component } from "react";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";
import returnAddresses from "./Contracts";
import Web3 from "web3";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";

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
      error: undefined,
      NRerror: undefined,
      result1: "",
      result2: "",
      AssetClass: "",
      CountDownStart: "",
      ipfs1: "",
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
      newFirst: "",
      newMiddle: "",
      newSurname: "",
      newId: "",
      newSecret: "",
      web3: null,
      frontend: "",
      storage: "",
    };
  }

  componentDidMount() {
    console.log("component mounted");
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
    console.log("unmounting component");
    document.removeEventListener("accountListener", this.acctChanger());
  }

  render() {
    const self = this;

    async function checkExists(idxHash) {
      await self.state.storage.methods
        .retrieveRecord(idxHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
            alert(
              "WARNING: Record DOES NOT EXIST! Reject in metamask and review asset info fields."
            );
          } else {
            self.setState({ result1: _result });
          }
          console.log("check debug, _result, _error: ", _result, _error);
        });
    }

    async function checkMatch(idxHash, rgtHash) {
      await self.state.storage.methods
        ._verifyRightsHolder(idxHash, rgtHash)
        .call({ from: self.state.addr }, function (_error, _result) {
          if (_error) {
            self.setState({ error: _error });
            self.setState({ result: 0 });
          } else if (_result === "0") {
            self.setState({ result: 0 });
            self.setState({ error: undefined });
            alert(
              "WARNING: Record DOES NOT MATCH supplied owner info! Reject in metamask and review owner fields."
            );
          } else {
            self.setState({ result2: _result });
          }
          console.log("check debug, _result, _error: ", _result, _error);
        });
    }

    const _transferAsset = () => {
      var idxHash = this.state.web3.utils.soliditySha3(
        this.state.type,
        this.state.manufacturer,
        this.state.model,
        this.state.serial
      );
      var rgtRaw = this.state.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );
      var rgtHash = this.state.web3.utils.soliditySha3(idxHash, rgtRaw);

      var newRgtRaw = this.state.web3.utils.soliditySha3(
        this.state.newFirst,
        this.state.newMiddle,
        this.state.newSurname,
        this.state.newId,
        this.state.newSecret
      );
      var newRgtHash = this.state.web3.utils.soliditySha3(idxHash, newRgtRaw);

      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", this.state.addr);

      checkExists(idxHash);
      checkMatch(idxHash, rgtHash);

      this.state.frontend.methods
        .$transferAsset(idxHash, rgtHash, newRgtHash)
        .send({
          from: this.state.addr,
          value: this.state.web3.utils.toWei("0.01"),
        })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          //Stuff to do when tx confirms
        });
      console.log(this.state.txHash);
    };

    return (
      <Form className="TAform">
        {this.state.addr === undefined && (
          <div className="errorResults">
            <h2>WARNING!</h2>
            <h3>Injected web3 not connected to form!</h3>
          </div>
        )}
        {this.state.addr > 0 && (
          <Form>
            <h2 className="NRheader">Transfer Record</h2>
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
              <Form.Group as={Col} controlId="formGridFirstName">
                <Form.Label className="formFont">First Name:</Form.Label>
                <Form.Control
                  placeholder="First Name"
                  required
                  onChange={(e) => this.setState({ firstName: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridMiddleName">
                <Form.Label className="formFont">Middle Name:</Form.Label>
                <Form.Control
                  placeholder="Middle Name"
                  required
                  onChange={(e) =>
                    this.setState({ middleName: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridLastName">
                <Form.Label className="formFont">Last Name:</Form.Label>
                <Form.Control
                  placeholder="Last Name"
                  required
                  onChange={(e) => this.setState({ surname: e.target.value })}
                  size="lg"
                />
              </Form.Group>
            </Form.Row>

            <Form.Row>
              <Form.Group as={Col} controlId="formGridIdNumber">
                <Form.Label className="formFont">ID Number:</Form.Label>
                <Form.Control
                  placeholder="ID Number"
                  required
                  onChange={(e) => this.setState({ id: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridPassword">
                <Form.Label className="formFont">Password:</Form.Label>
                <Form.Control
                  placeholder="Password"
                  type="password"
                  required
                  onChange={(e) => this.setState({ secret: e.target.value })}
                  size="lg"
                />
              </Form.Group>
            </Form.Row>
            <Form.Row>
              <Form.Group as={Col} controlId="formGridNewFirstName">
                <Form.Label className="formFont">New First Name:</Form.Label>
                <Form.Control
                  placeholder="New First Name"
                  required
                  onChange={(e) => this.setState({ firstName: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridNewMiddleName">
                <Form.Label className="formFont">New Middle Name:</Form.Label>
                <Form.Control
                  placeholder="New Middle Name"
                  required
                  onChange={(e) =>
                    this.setState({ middleName: e.target.value })
                  }
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridNewLastName">
                <Form.Label className="formFont">New Last Name:</Form.Label>
                <Form.Control
                  placeholder="New Last Name"
                  required
                  onChange={(e) => this.setState({ surname: e.target.value })}
                  size="lg"
                />
              </Form.Group>
            </Form.Row>

            <Form.Row>
              <Form.Group as={Col} controlId="formGridNewIdNumber">
                <Form.Label className="formFont">New ID Number:</Form.Label>
                <Form.Control
                  placeholder="New ID Number"
                  required
                  onChange={(e) => this.setState({ id: e.target.value })}
                  size="lg"
                />
              </Form.Group>

              <Form.Group as={Col} controlId="formGridNewPassword">
                <Form.Label className="formFont">New Password:</Form.Label>
                <Form.Control
                  placeholder="New Password"
                  type="password"
                  required
                  onChange={(e) => this.setState({ secret: e.target.value })}
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
                  onClick={_transferAsset}
                >
                  Submit
                </Button>
              </Form.Group>
            </Form.Row>

            {this.state.txHash > 0 && ( //conditional rendering
              <div className="VRresults">
                {this.state.NRerror !== undefined && (
                  <div>
                    ERROR! Please check etherscan
                    <br></br>
                    {this.state.NRerror.message}
                  </div>
                )}
                {this.state.NRerror === undefined && (
                  <div>
                    {" "}
                    No Errors Reported :
                    <a
                      href={
                        "https://kovan.etherscan.io/tx/" + this.state.txHash
                      }
                      target="_blank"
                      rel="noopener noreferrer"
                    >
                      KOVAN Etherscan:{this.state.txHash}
                    </a>
                  </div>
                )}
              </div>
            )}
          </Form>
        )}
      </Form>
    );
  }
}

//       <div>
//         {this.state.addr === undefined && (
//             <div className="VRresults">
//               <h2>WARNING!</h2>
//               Injected web3 not connected to form!
//             </div>
//           )}
//         {this.state.addr > 0 && (
//         <form className="TAform">
//           <h2>Transfer Asset</h2>
//           Type:
//           <input
//             type="text"
//             name="type"
//             placeholder="Type"
//             required
//             onChange={(e) => this.setState({type: e.target.value})}
//           />
//           <br></br>
//           Manufacturer:
//           <input
//             type="text"
//             name="manufacturer"
//             placeholder="Manufacturer"
//             required
//             onChange={(e) => this.setState({manufacturer: e.target.value})}
//           />
//           <br></br>
//           Model:
//           <input
//             type="text"
//             name="model"
//             placeholder="Model"
//             required
//             onChange={(e) => this.setState({model: e.target.value})}
//           />
//           <br></br>
//           Serial:
//           <input
//             type="text"
//             name="serial"
//             placeholder="Serial Number"
//             required
//             onChange={(e) => this.setState({serial: e.target.value})}
//           />
//           <br></br>
//           First Name:
//           <input
//             type="text"
//             name="first"
//             placeholder="First name"
//             required
//             onChange={(e) => this.setState({first: e.target.value})}
//           />
//           <br></br>
//           Middle Name:
//           <input
//             type="text"
//             name="middle"
//             placeholder="Middle name"
//             required
//             onChange={(e) => this.setState({middle: e.target.value})}
//           />
//           <br></br>
//           Surname:
//           <input
//             type="text"
//             name="surname"
//             placeholder="Surname"
//             required
//             onChange={(e) => this.setState({surname: e.target.value})}
//           />
//           <br></br>
//           ID:
//           <input
//             type="text"
//             name="id"
//             placeholder="ID"
//             required
//             onChange={(e) => this.setState({id: e.target.value})}
//           />
//           <br></br>
//           Password:
//           <input
//             type="text"
//             name="secret"
//             placeholder="Secret"
//             required
//             onChange={(e) => this.setState({secret: e.target.value})}
//           />
//           <br></br>
//           New First Name:
//           <input
//             type="text"
//             name="first"
//             placeholder="New First name"
//             required
//             onChange={(e) => this.setState({newFirst: e.target.value})}
//           />
//           <br></br>
//           New Middle Name:
//           <input
//             type="text"
//             name="middle"
//             placeholder="New Middle name"
//             required
//             onChange={(e) => this.setState({newMiddle: e.target.value})}
//           />
//           <br></br>
//           New Surname:
//           <input
//             type="text"
//             name="surname"
//             placeholder="New Surname"
//             required
//             onChange={(e) => this.setState({newSurname: e.target.value})}
//           />
//           <br></br>
//           New ID:
//           <input
//             type="text"
//             name="id"
//             placeholder="New ID"
//             required
//             onChange={(e) => this.setState({newId: e.target.value})}
//           />
//           <br></br>
//           New Password:
//           <input
//             type="text"
//             name="secret"
//             placeholder="New Password"
//             required
//             onChange={(e) => this.setState({newSecret: e.target.value})}
//           />
//           <br></br>
//           <input type="button" value="Transfer Asset" onClick={_transferAsset} />
//         </form>)}
//         {this.state.txHash > 0 && ( //conditional rendering
//           <div className="VRresults">
//             No Errors Reported
//             <br></br>
//             <br></br>
//             <a
//               href={"https://kovan.etherscan.io/tx/" + this.state.txHash}
//               target="_blank"
//               rel="noopener noreferrer"
//             >
//               KOVAN Etherscan:{this.state.txHash}
//             </a>
//           </div>
//         )}
//       </div>
//     )}
// }

export default ModifyDescription;
