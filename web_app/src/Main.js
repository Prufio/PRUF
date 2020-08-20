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
import THEWORKS from "./TheWorks";
import buildContracts from "./Contracts";
import Button from "react-bootstrap/Button";
import Form from "react-bootstrap/Form";
import EscrowManager from "./EscrowManager";
import RCFJ from "./RetrieveContractsFromJSON"



class Main extends Component {
  constructor(props) {
    super(props);

    this.setupContractEnvironment = async (_web3) => {
      console.log("Setting up contracts")
      window.contracts = await buildContracts(_web3)
      await this.setState({contracts: window.contracts})
      return this.getContracts()
  }

    //State declaration....................................................................................................
    this.getContracts = async () => {
      const self = this;
        await self.setState({ STOR: window.contracts.content[0] });
        await self.setState({ APP: window.contracts.content[1] });
        await self.setState({ NP: window.contracts.content[2] });
        await self.setState({ AC_MGR: window.contracts.content[3] });
        await self.setState({ AC_TKN: window.contracts.content[4] });
        await self.setState({ A_TKN: window.contracts.content[5] });
        await self.setState({ ECR_MGR: window.contracts.content[6] });
        await self.setState({ ECR: window.contracts.content[7] });
        await self.setState({ ECR2: window.contracts.content[8] });
        await self.setState({ ECR_NC: window.contracts.content[9] });
        await self.setState({ APP_NC: window.contracts.content[10] });
        await self.setState({ NP_NC: window.contracts.content[11] });
        await self.setState({ RCLR: window.contracts.content[12] });
        await self.setState({ NAKED: window.contracts.content[13] });

        console.log("contracts: ", window.contracts)

    };

    this.acctChanger = async () => {//Handle an address change, update state accordingly
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => 
        {
          window.addr = e[0];
          return self.setState({ addr: e[0] })});
      });
      /*   if (self.state.addr !== this.state.owner) {
          self.setState({ isOwner: false });
        } */
      self.setState({ isOwner: false });
    };
    //Component state declaration

    this.state = {
      isSTOROwner: undefined,
      isBPPOwner: undefined,
      isBPNPOwner: undefined,
      addr: undefined,
      web3: null,
      ownerMenu: false,
      STOROwner: "",
      BPPOwner: "",
      BPNPOwner: "",
      APP: "",
      NP: "",
      STOR: "",
      AC_MGR: "",
      ECR_NC: "",
      ECR_MGR: "",
      AC_TKN: "",
      A_TKN: "",
      APP_NC: "",
      NP_NC: "",
      ECR2: "",
      NAKED: "",
      RCLR: "",
      assetClass: undefined,
      contractArray: [],
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    const ethereum = window.ethereum;
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setupContractEnvironment(_web3);
    this.setState({ web3: _web3 });
    window.web3 = _web3;
    ethereum.enable();
    _web3.eth.getAccounts().then((e) => window.addr = e[0]);
    document.addEventListener("accountListener", this.acctChanger());
  }

  componentDidCatch(error, info) {
    console.log(info.componentStack)
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  componentDidUpdate() {//stuff to do when state updates

    /* if (this.state.addr > 0 && this.state.assetClass === undefined && this.state.APP !== "") {
      for (let i = 0; i < 5; i++) {
        //this.getAssetClass();
      }
    }  */

   /*  console.log(window.contracts) */

    /* if (this.state.web3 !== null) {
      this.getOwner();
    } */

    if (this.state.web3 !== null && window.contracts > 0) {
      //this.getContracts();
    }
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    console.log("unmounting component");
    document.removeEventListener("accountListener", this.acctChanger());
    //document.removeEventListener("ownerGetter", this.getOwner());
  }

  render() {//render continuously produces an up-to-date stateful document  
    /* const toggleAdmin = () => {
      if (this.state.isSTOROwner || this.state.isBPPOwner || this.state.isBPNPOwner) {
        if (this.state.ownerMenu === false) {
          this.setState({ ownerMenu: true });
        } else {
          this.setState({ ownerMenu: false });
        }
      }
    }; */

    return (
      <HashRouter>
        <div>
          <div className="imageForm">
            <img src={require("./BP Logo.png")} alt="Bulletproof Logo" />
            <div className="userData">
              {window.addr > 0 && (
                <div className="banner">
                  Currently serving :{window.addr}
                </div>
              )}
              {window.addr === undefined && (
                <div className="banner">
                  Currently serving: NOBODY! Log into web3 provider!
                </div>
              )}
            </div>
          </div>
          <div className="BannerForm">
            <div className="page">
              <ul className="header">
                {window.contracts !== undefined && (
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
                    <li>
                      <NavLink to="/the-works">THE WORKS</NavLink>
                    </li>
                  </nav>
                )}

                {/* {this.state.ownerMenu === true && (
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
                )} */}
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
                {/* <Route path="/add-user" component={AddUser} />
                <Route path="/set-costs" component={SetCosts} />
                <Route path="/add-contract" component={AddContract} />
                <Route path="/ownership" component={Ownership} /> */}
                <Route path="/the-works" component={THEWORKS} />
              </div>
            </div>
          </div>
          <NavLink to="/">
            {/* {(this.state.isSTOROwner === true || this.state.isBPPOwner === true || this.state.isBPNPOwner === true) && (
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
            )} */}
          </NavLink>
        </div>
      </HashRouter>
    );
  }
}

export default Main;
