import React, { Component } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from "web3";
import Home from "./Home";
import AddNote from "./AddNote";
import DecrementCounter from "./DecrementCounter";
import ForceModifyRecord from "./ForceModifyRecord";
import ModifyDescription from "./ModifyDescription";
import ModifyRecordStatus from "./ModifyRecordStatus";
import NewRecord from "./NewRecord";
import RetrieveRecord from "./RetrieveRecord";
import TransferAsset from "./TransferAsset";
import VerifyRightsholder from "./VerifyRightsholder";
import AddContract from "./AddContract";
import AddUser from "./AddUser";
import Ownership from "./Ownership";
import SetCosts from "./SetCosts";
import returnContracts from "./Contracts";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import EscrowManager from "./EscrowManager";

class Main extends Component {
  constructor(props) {
    super(props);

    this.returnsContract = async () => {
      const self = this;
      var contracts = await returnContracts(self.state.web3);
      //console.log("RC NR: ", contractArray)

      if(this.state.storage < 1){self.setState({ storage: contracts.storage });}
      if(this.state.BPappNonPayable < 1){self.setState({ BPappNonPayable: contracts.nonPayable });}
      if(this.state.BPappPayable < 1){self.setState({ BPappPayable: contracts.payable });}
    };

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

    this.getOwner = async () => {
      const self = this;

      if(this.state.storage === "" || this.state.web3 === null || this.state.storageOwner !== ""){}else{
        console.log("Getting storage owner")
        this.state.storage.methods
          .owner()
          .call({ from: self.state.addr }, function (_error, _result) {
            if (_error) {
              console.log(_error);
            } else {
              self.setState({ storageOwner: _result });

              if (_result === self.state.addr) {
                self.setState({ isStorageOwner: true });
              } else {
                self.setState({ isStorageOwner: false });
              }
            }
          });
        }

        if(this.state.BPappPayable === "" || this.state.web3 === null || this.state.BPPOwner !== ""){}else{
          console.log("Getting BPP owner")
          this.state.BPappPayable.methods
            .owner()
            .call({ from: self.state.addr }, function (_error, _result) {
              if (_error) {
                console.log(_error);
              } else {
                self.setState({ BPPOwner: _result });
  
                if (_result === self.state.addr) {
                  self.setState({ isBPPOwner: true });
                } else {
                  self.setState({ isBPPOwner: false });
                }
              }
            });
          }

          if(this.state.BPappNonPayable === "" || this.state.web3 === null || this.state.BPNPOwner !== ""){}else{
            console.log("Getting BPNP owner")
            this.state.BPappNonPayable.methods
              .owner()
              .call({ from: self.state.addr }, function (_error, _result) {
                if (_error) {
                  console.log(_error);
                } else {
                  self.setState({ BPNPOwner: _result });
    
                  if (_result === self.state.addr) {
                    self.setState({ isBPNPOwner: true });
                  } else {
                    self.setState({ isBPNPOwner: false });
                  }
                }
              });
            }
    };

    this.acctChanger = async () => {
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({ addr: e[0] }));
        /* self.setState({assetClass: undefined}) */
      });
    /*   if (self.state.addr !== this.state.owner) {
        self.setState({ isOwner: false });
      } */
      self.setState({ isOwner: false });
    };
    //Component state declaration

    this.state = {
      isStorageOwner: undefined,
      isBPPOwner: undefined,
      isBPNPOwner: undefined,
      addr: undefined,
      web3: null,
      ownerMenu: false,
      storageOwner: "",
      BPPOwner: "",
      BPNPOwner: "",
      BPappPayable: "",
      BPappNonPayable: "",
      storage: "",
      assetClass: undefined,
      contractArray: [],
    };
  }

  componentDidMount() {
    const ethereum = window.ethereum;
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    ethereum.enable();
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    document.addEventListener("accountListener", this.acctChanger());
    for (let i = 0; i < 5; i++) {
      this.getOwner();
    }
  }

  componentDidCatch(error, info){
    console.log(info.componentStack)
  }
  
  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  componentDidUpdate() {

    /* if (this.state.addr > 0 && this.state.assetClass === undefined && this.state.BPappPayable !== "") {
      for (let i = 0; i < 5; i++) {
        this.getAssetClass();
      }
    }  */

    if (this.state.web3 !== null){
    for (let i = 0; i < 5; i++) {
      this.getOwner();}
    }

    if(this.state.web3 !== null && this.state.storageOwner < 1){
      this.returnsContract();
    }
  }

  componentWillUnmount() {
    console.log("unmounting component");
    document.removeEventListener("accountListener", this.acctChanger());
    //document.removeEventListener("ownerGetter", this.getOwner());
  }

  render() {
    const toggleAdmin = () => {
      if (this.state.isStorageOwner || this.state.isBPPOwner || this.state.isBPNPOwner) {
        if (this.state.ownerMenu === false) {
          this.setState({ ownerMenu: true });
        } else {
          this.setState({ ownerMenu: false });
        }
      }
    };

    return (
      <HashRouter>
        <div>
          <div className="imageForm">
            <img src={require("./BP Logo.png")} alt="Bulletproof Logo" />
            <div className="userData">
              {this.state.addr > 0 && (
                <div className="banner">
                  Currently serving :{this.state.addr} {/* Asset Class: {this.state.assetClass} */}
                </div>
              )}
              {this.state.addr === undefined && (
                <div className="banner">
                  Currently serving: NOBODY! Log into web3 provider!
                </div>
              )}
            </div>
          </div>
          <div className="BannerForm">
            <div className="page">
              <ul className="header">
                {this.state.ownerMenu === false && (
                  <nav>
                    <li>
                      <NavLink exact to="/">
                        Home
                      </NavLink>
                    </li>
                    <li>
                      <NavLink to="/new-record">New</NavLink>
                    </li>
                    <li>
                      <NavLink to="/verify-rights-holder">Verify</NavLink>
                    </li>
                    <li>
                      <NavLink to="/retrieve-record">Search</NavLink>
                    </li>
                    <li>
                      <NavLink to="/transfer-asset">Transfer</NavLink>
                    </li>
                    <li>
                      <NavLink to="/modify-record-status">Status</NavLink>
                    </li>
                    <li>
                      <NavLink to="/decrement-counter">Countdown</NavLink>
                    </li>
                    <li>
                      <NavLink to="/modify-description">Description</NavLink>
                    </li>
                    <li>
                      <NavLink to="/add-note">Add Note</NavLink>
                    </li>
                    <li>
                      <NavLink to="/force-modify-record">Modify</NavLink>
                    </li>
                    <li>
                      <NavLink to="/manage-escrow">Escrow</NavLink>
                    </li>
                  </nav>
                )}

                {this.state.ownerMenu === true && (
                  <nav>
                    <li>
                      <NavLink exact to="/">
                        Home
                      </NavLink>
                    </li>
                    <li>
                      <NavLink to="/add-user">Add User</NavLink>
                    </li>
                    <li>
                      <NavLink to="/set-costs">Set Costs</NavLink>
                    </li>
                    <li>
                      <NavLink to="/add-contract">Add Contract</NavLink>
                    </li>
                    <li>
                      <NavLink to="/ownership">Ownership</NavLink>
                    </li>
                  </nav>
                )}
              </ul>
              <div className="content">
                <Route exact path="/" component={Home} />
                <Route path="/new-record" component={NewRecord} />
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route
                  path="/force-modify-record"
                  component={ForceModifyRecord}
                />
                <Route path="/transfer-asset" component={TransferAsset} />
                <Route
                  path="/modify-record-status"
                  component={ModifyRecordStatus}
                />
                <Route path="/decrement-counter" component={DecrementCounter} />
                <Route
                  path="/modify-description"
                  component={ModifyDescription}
                />
                <Route path="/add-note" component={AddNote} />
                <Route
                  path="/verify-rights-holder"
                  component={VerifyRightsholder}
                />
                <Route
                  path="/manage-escrow"
                  component={EscrowManager}
                />
                <Route path="/add-user" component={AddUser} />
                <Route path="/set-costs" component={SetCosts} />
                <Route path="/add-contract" component={AddContract} />
                <Route path="/ownership" component={Ownership} />
              </div>
            </div>
          </div>
          <NavLink to="/">
            {(this.state.isStorageOwner === true || this.state.isBPPOwner === true || this.state.isBPNPOwner === true) && (
              <Form className="buttonDisplay2">
                <Button
                  variant="danger"
                  type="button"
                  size="lg"
                  onClick={toggleAdmin}
                >
                  Toggle Admin
                </Button>
              </Form>
            )}
          </NavLink>
        </div>
      </HashRouter>
    );
  }
}

export default Main;
