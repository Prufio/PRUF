import React, { Component } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from "web3";
import Home from "./Home";
import AddContract from "./AddContract";
import Ownership from "./Ownership";
import THEWORKS from "./TheWorks";
import MintAssetClass from "./MintAssetClass"
import SetupAndResolveContracts from "./SetupAndResolveContracts"
import buildContracts from "./Contracts";
import ParticleBox from "./ParticleBox";
import DropdownButton from "react";
import Dropdown from "react";

class Main extends Component {
  constructor(props) {
    super(props);

    this.setupContractEnvironment = async (_web3) => {
      console.log("Setting up contracts");
      window._contracts = await buildContracts(_web3);
      await this.setState({ contracts: window._contracts });
      return this.getContracts();
    };

    //State declaration....................................................................................................
    this.getContracts = async () => {
      window.contracts = {
        STOR: window._contracts.content[0],
        APP: window._contracts.content[1],
        NP: window._contracts.content[2],
        AC_MGR: window._contracts.content[3],
        AC_TKN: window._contracts.content[4],
        A_TKN: window._contracts.content[5],
        ECR_MGR: window._contracts.content[6],
        ECR: window._contracts.content[7],
        VERIFY: window._contracts.content[8],
        ECR_NC: window._contracts.content[9],
        APP_NC: window._contracts.content[10],
        NP_NC: window._contracts.content[11],
        RCLR: window._contracts.content[12],
        NAKED: window._contracts.content[13],
      };

      return console.log("contracts: ", window.contracts);
    };

    this.acctChanger = async () => {
      //Handle an address change, update state accordingly
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => {
          window.addr = e[0];
          self.setState({ addr: e[0] });
        });
      });
    };
    //Component state declaration

    this.state = {
      IPFS: require("ipfs-mini"),
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

  componentDidMount() {
    //stuff to do when component mounts in window
    const ethereum = window.ethereum;
    var _web3 = require("web3");
    _web3 = new Web3(_web3.givenProvider);
    this.setupContractEnvironment(_web3);
    this.setState({ web3: _web3 });
    window.web3 = _web3;
    ethereum.enable();
    var _ipfs = new this.state.IPFS({
      host: "ipfs.infura.io",
      port: 5001,
      protocol: "https",
    });
    window.ipfs = _ipfs;
    //console.log(window.ipfs)
    _web3.eth.getAccounts().then((e) => {
      this.state.addr = e[0];
      window.addr = e[0];
    });
    document.addEventListener("accountListener", this.acctChanger());
  }

  componentDidCatch(error, info) {
    console.log(info.componentStack);
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  componentDidUpdate() {
    //stuff to do when state updates
  }

  componentWillUnmount() {
    //stuff do do when component unmounts from the window
    console.log("unmounting component");
    document.removeEventListener("accountListener", this.acctChanger());
    //document.removeEventListener("ownerGetter", this.getOwner());
  }

  render() {
    //render continuously produces an up-to-date stateful document

    if (this.state.hasError === true) {
      return <div> Error Occoured. Try reloading the page. </div>;
    }

    return (
      <div>
        <ParticleBox />
        <HashRouter>
          <div>
            <div className="imageForm">
              <img
                className="downSizeLogo"
                src={require("./Pruf.png")}
                alt="Pruf Logo"
              />
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
                  {window._contracts !== undefined && (
                    <nav>
                     {/*  <DropdownButton
                        id="dropdown-basic-button"
                        title="Menu Selection"
                      >
                        <Dropdown.Item href="#/action-1">Action</Dropdown.Item>
                        <Dropdown.Item href="#/action-2">
                          Another action
                        </Dropdown.Item>
                        <Dropdown.Item href="#/action-3">
                          Something else
                        </Dropdown.Item>
                      </DropdownButton> */}
                      <li>
                        <NavLink exact to="/">
                          Home
                        </NavLink>
                      </li>
                      <li>
                        <NavLink to="/setup">Setup Contracts</NavLink>
                      </li>
                      <li>
                        <NavLink to="/add-contract">Add Contract</NavLink>
                      </li>
                      <li>
                        <NavLink to="/ownership">Ownership</NavLink>
                      </li>
                      <li>
                        <NavLink to="/mint-ac">Create AC</NavLink>
                      </li>
                      <li>
                        <NavLink to="/the-works">THE WORKS</NavLink>
                      </li>
                    </nav>
                  )}
                </ul>
                <div className="content">
                  <Route exact path="/" component={Home} />
                  <Route exact path="/setup" component={SetupAndResolveContracts} />
                  <Route path="/add-contract" component={AddContract} />
                  <Route path="/ownership" component={Ownership} />
                  <Route path="/mint-ac" component={MintAssetClass}/>
                  <Route path="/the-works" component={THEWORKS} />
                </div>
              </div>
            </div>
            <NavLink to="/"></NavLink>
          </div>
        </HashRouter>
      </div>
    );
  }
}

export default Main;
