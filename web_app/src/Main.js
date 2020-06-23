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
import ResetFMC from "./ResetFMC";
import SetCosts from "./SetCosts";
import returnStorageAbi from "./stor_abi";
import returnAddresses from "./Contracts";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";

class Main extends Component {
  constructor(props) {
    super(props);

    this.getOwner = async () => {
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      var addrArray = returnAddresses();
      var _storage_addr = addrArray[0];
      const storage_abi = returnStorageAbi();
      const _storage = new _web3.eth.Contract(storage_abi, _storage_addr);

      if (this.state.owner === "") {
        _storage.methods
          .owner()
          .call({ from: self.state.addr }, function (_error, _result) {
            if (_error) {
              console.log(_error);
            } else {
              self.setState({ owner: _result });

              if (self.state.owner === self.state.addr) {
                self.setState({ isOwner: true });
              } else {
                self.setState({ isOwner: false });
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
      });
      if (self.state.addr !== this.state.owner) {
        self.setState({ isOwner: false });
      }
    };
    //Component state declaration

    this.state = {
      isOwner: undefined,
      addr: undefined,
      web3: null,
      ownerMenu: false,
      owner: "",
    };
  }

  componentDidMount() {
    const ethereum = window.ethereum;
    console.log("component mounted");
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setState({ web3: _web3 });
    ethereum.enable();
    _web3.eth.getAccounts().then((e) => this.setState({ addr: e[0] }));
    document.addEventListener("accountListener", this.acctChanger());
    document.addEventListener("ownerGetter", this.getOwner());
  }

  componentWillUnmount() {
    console.log("unmounting component");
    document.removeEventListener("accountListener", this.acctChanger());
    document.removeEventListener("ownerGetter", this.getOwner());
  }

  render() {
    const toggleAdmin = () => {
      if (this.state.isOwner) {
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
                  Currently serving :{this.state.addr}
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
                <li>
                  <NavLink exact to="/">
                    Home
                  </NavLink>
                </li>

                {this.state.ownerMenu === false && (
                  <li>
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
                  </li>
                )}

                {this.state.ownerMenu === true && (
                  <li>
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
                    <li>
                      <NavLink to="/reset-fmc">Reset FMC</NavLink>
                    </li>
                  </li>
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
                <Route path="/add-user" component={AddUser} />
                <Route path="/set-costs" component={SetCosts} />
                <Route path="/add-contract" component={AddContract} />
                <Route path="/ownership" component={Ownership} />
                <Route path="/reset-fmc" component={ResetFMC} />
              </div>
            </div>
          </div>
          {this.state.isOwner === true && (
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
        </div>
      </HashRouter>
    );
  }
}

export default Main;
