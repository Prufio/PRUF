import React, { Component } from "react";
import Button from "react-bootstrap/Button";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from "web3";
import Home from "./Home";
import buildContracts from "./Resources/Contracts";
import NonCustodialComponent from "./Resources/NonCustodialComponent";
import AdminComponent from "./Resources/AdminComponent";
import AuthorizedUserComponent from "./Resources/AuthorizedUserComponent";
import BasicComponent from "./Resources/BasicComponent"
import ParticleBox from './Resources/ParticleBox';
import Router from "./Router";



class Main extends Component {
  constructor(props) {
    super(props);

    this.toggleMenu = (menuChoice) => {
      if(window.ipfs === undefined){return}
      if (menuChoice === 'ACAdmin') {
        return this.setState({
          assetClassHolderMenuBool: true,
          assetHolderMenuBool: false,
          basicMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'basic') {
        return this.setState({
          basicMenuBool: true,
          assetHolderMenuBool: false,
          assetClassHolderMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'NC') {
        return this.setState({
          assetHolderMenuBool: true,
          basicMenuBool: false,
          assetClassHolderMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'authUser') {
        return this.setState({
          authorizedUserMenuBool: true,
          assetHolderMenuBool: false,
          assetClassHolderMenuBool: false,
          basicMenuBool: false
        })

      }
    }

    this.determineTokenBalance = async () => {
      let _assetClassBal;
      let _assetBal;
      console.log("getting balance info from token contracts...")
      await window.contracts.A_TKN.methods.balanceOf(window.addr).call({ from: window.addr }, (error, result) => {
        if (error) { console.log(error) }
        else { _assetBal = result; console.log("assetBal: ", _assetBal); }
      });

      await window.contracts.AC_TKN.methods.balanceOf(window.addr).call({ from: window.addr }, (error, result) => {
        if (error) { console.log(error) }
        else { _assetClassBal = result; console.log("assetClassBal", _assetClassBal); }
      });

      console.log(await window.contracts.A_TKN.methods.balanceOf(window.addr));
      console.log(await window.contracts.AC_TKN.methods.balanceOf(window.addr));

      if (Number(_assetBal) > 0) {
        this.setState({ assetHolderBool: true })
      }

      if (Number(_assetClassBal) > 0) {
        this.setState({ assetClassHolderBool: true })
      }

      window.balances = {
        assetBal: Number(_assetBal),
        assetClassBal: Number(_assetClassBal)
      }

      console.log("token balances: ", window.balances)
    }

    this.setupContractEnvironment = async (_web3) => {
      console.log("Setting up contracts")
      window._contracts = await buildContracts(_web3)
      await this.setState({ contracts: window._contracts })
      return this.getContracts()
    }

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
        ECR2: window._contracts.content[8],
        ECR_NC: window._contracts.content[9],
        APP_NC: window._contracts.content[10],
        NP_NC: window._contracts.content[11],
        RCLR: window._contracts.content[12],
      }

      console.log("contracts: ", window.contracts)
      return this.determineTokenBalance();
    };

    this.acctChanger = async () => {//Handle an address change, update state accordingly
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => {
          window.addr = e[0];
          self.setState({ addr: e[0] })
          self.setupContractEnvironment(window.web3);
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
      isAuthUser: false,
      assetHolderBool: false,
      assetClassHolderBool: false,
      assetHolderMenuBool: false,
      assetClassHolderMenuBool: false,
      basicMenuBool: true,
      authorizedUserMenuBool: false
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
    var _ipfs = new this.state.IPFS({
      host: "ipfs.infura.io",
      port: 5001,
      protocol: "https",
    });
    window.ipfs = _ipfs
    //console.log(window.ipfs)
    _web3.eth.getAccounts().then((e) => { this.state.addr = e[0]; window.addr = e[0] });
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

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    console.log("unmounting component");
    document.removeEventListener("accountListener", this.acctChanger());
    //document.removeEventListener("ownerGetter", this.getOwner());
  }

  render() {//render continuously produces an up-to-date stateful document  

    if (this.state.hasError === true) {
      return (<div> Error Occoured. Try reloading the page. </div>)
    }

    const buttonWrangler = (menuChoice) => {
      if (this.state.hasMounted === undefined){return}
      else{this.toggleMenu(menuChoice)}
    }

    return (
      <div>
        <ParticleBox />
        <HashRouter>
          <div>
            <div className="imageForm">
              <img className="downSizeLogo" src={require("./Pruf.png")} alt="Pruf Logo" />
              <div className="headerButtons">
              {this.state.assetClassHolderBool === true && (
                <Button
                  variant="primary"
                  type="button"
                  size=""
                  onClick={buttonWrangler("ACAdmin")}
                >
                  AC Admin Menu
                </Button>)}

              {this.state.assetHolderBool === true && (
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={buttonWrangler("NC")}
                >
                  NonCustodial Menu
                </Button>)}

              {this.state.basicMenuBool === false && (
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={buttonWrangler("basic")}
                >
                  Basic Menu
                </Button>)}

              {this.state.isAuthUser === true && (
                <Button
                  variant="primary"
                  type="button"
                  size="lg"
                  onClick={buttonWrangler("authUser")}
                >
                  Authorized User Menu
                </Button>)}
                </div>
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
                      <li>
                        <NavLink exact to="/">Home</NavLink>
                      </li>
                      {this.state.assetHolderMenuBool === true && (<NonCustodialComponent />)}
                      {this.state.assetClassHolderMenuBool === true && (<AdminComponent />)}
                      {this.state.authorizedUserMenuBool === true && (<AuthorizedUserComponent />)}
                      {this.state.basicMenuBool === true && (<BasicComponent />)}
                    </nav>
                  )}
                </ul>
                <div className="content">
                  <Route exact path="/" component={Home} />
                  <Router />
                </div>
              </div>
            </div>
            <NavLink to="/">
            </NavLink>
          </div>
        </HashRouter>
      </div>
    );
  }
}

export default Main;
