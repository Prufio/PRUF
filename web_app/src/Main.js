import React, { Component } from "react";
import Button from "react-bootstrap/Button";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from "web3";
import Home from "./Home";
import buildContracts from "./Resources/Contracts";
import buildWindowUtils from "./Resources/WindowUtils";
import NonCustodialComponent from "./Resources/NonCustodialComponent";
import AdminComponent from "./Resources/AdminComponent";
import AuthorizedUserComponent from "./Resources/AuthorizedUserComponent";
import BasicComponent from "./Resources/BasicComponent";
import ParticleBox from './Resources/ParticleBox';
import Router from "./Router";




class Main extends Component {
  constructor(props) {
    super(props);

    this.updateAuthLevel = setInterval(() => {
      if (this.state.isAuthUser != window.isAuthUser) {
        this.setState({ isAuthUser: window.isAuthUser })
      }
    }, 200)

    this.toggleMenu = (menuChoice) => {
      this.setState({ routeRequest: "ACAdmin" });
      if (menuChoice === 'ACAdmin') {
        return this.setState({
          assetClassHolderMenuBool: true,
          assetHolderMenuBool: false,
          basicMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'basic') {
        this.setState({ routeRequest: "basic" });
        return this.setState({
          basicMenuBool: true,
          assetHolderMenuBool: false,
          assetClassHolderMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'NC') {
        this.setState({ routeRequest: "NC" });
        return this.setState({
          assetHolderMenuBool: true,
          basicMenuBool: false,
          assetClassHolderMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'authUser') {
        this.setState({ routeRequest: "authUser" });
        return this.setState({
          authorizedUserMenuBool: true,
          assetHolderMenuBool: false,
          assetClassHolderMenuBool: false,
          basicMenuBool: false
        })
      }

    }

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

    this.setupContractEnvironment = async (_web3) => {
      console.log("Setting up contracts")
      await this.setState({
        isAuthUser: undefined,
        assetHolderBool: false,
        assetClassHolderBool: false,
        assetHolderMenuBool: false,
        assetClassHolderMenuBool: false,
        basicMenuBool: true,
        authorizedUserMenuBool: false,
        hasFetchedBalances: false,
        routeRequest: "basic"
      })
      window._contracts = await buildContracts(_web3)
      await this.setState({ contracts: window._contracts })
      await window.utils.getContracts()
      await window.utils.determineTokenBalance()
      console.log("bools...", window.assetHolderBool, window.assetClassHolderBool, window.hasFetchedBalances)
      this.setState({ assetHolderBool: window.assetHolderBool })
      this.setState({ assetClassHolderBool: window.assetClassHolderBool })
      return this.setState({ hasFetchedBalances: window.hasFetchedBalances })
    }

    //Component state declaration

    this.state = {
      IPFS: require("ipfs-mini"),
      isSTOROwner: undefined,
      isBPPOwner: undefined,
      isBPNPOwner: undefined,
      addr: undefined,
      web3: null,
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
      PIP: "",
      RCLR: "",
      assetClass: undefined,
      contractArray: [],
      isAuthUser: undefined,
      assetHolderBool: false,
      assetClassHolderBool: false,
      assetHolderMenuBool: false,
      assetClassHolderMenuBool: false,
      basicMenuBool: true,
      authorizedUserMenuBool: false,
      hasFetchedBalances: false,
      routeRequest: "basic"
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window

    buildWindowUtils()
    if (window.ethereum) {

      const ethereum = window.ethereum;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      this.setupContractEnvironment(_web3);
      this.setState({ web3: _web3 });
      window.web3 = _web3;

      ethereum.enable()

      var _ipfs = new this.state.IPFS({
        host: "ipfs.infura.io",
        port: 5001,
        protocol: "https",
      });
      window.ipfs = _ipfs

      _web3.eth.getAccounts().then((e) => { this.setState({ addr: e[0] }); window.addr = e[0] });
      window.addEventListener("accountListener", this.acctChanger());
      //window.addEventListener("authLevelListener", this.updateAuthLevel());
    }
    else {
      this.setState({ hasError: true })
    }
  }

  componentDidCatch(error, info) {
    console.log(info.componentStack)
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  componentDidUpdate() {//stuff to do when state updates
    if (window.addr !== undefined && !this.state.hasFetchedBalances && window.contracts > 0) {
      this.setupContractEnvironment(window.web3);
    }


  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    console.log("unmounting component");
    window.removeEventListener("accountListener", this.acctChanger());
    //window.removeEventListener("authLevelListener", this.updateAuthLevel());
    //window.removeEventListener("ownerGetter", this.getOwner());
  }

  render() {//render continuously produces an up-to-date stateful webpage  

    if (this.state.hasError === true) {
      return (<div><h1>)-:</h1><h2> An error occoured. Ensure you are connected to metamask and reload the page. Mobile support coming soon.</h2></div>)
    }

    return (
      <div>
        <ParticleBox />
        <HashRouter>
          <div>
            <div className="imageForm">
              <img className="downSizeLogo" src={require("./Resources/pruf ar long.png")} alt="Pruf Logo" />
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
                  {Router(this.state.routeRequest)}
                </div>

                <div className="headerButtons">
                  {this.state.assetClassHolderBool === true && this.state.assetClassHolderMenuBool === false && (
                    <Button className="btn3"
                      variant="primary"
                      type="button"
                      onClick={() => { this.toggleMenu("ACAdmin") }}
                    >
                      AC Admin Menu
                    </Button>)}

                  {this.state.assetHolderBool === true && this.state.assetHolderMenuBool === false && (
                    <Button className="btn3"
                      variant="primary"
                      type="button"
                      onClick={() => { this.toggleMenu("NC") }}
                    >
                      NonCustodial Menu
                    </Button>)}

                  {this.state.basicMenuBool === false && (
                    <Button className="btn3"
                      variant="primary"
                      type="button"
                      onClick={() => { this.toggleMenu("basic") }}
                    >
                      Basic Menu
                    </Button>)}

                  {this.state.isAuthUser === true && this.state.authorizedUserMenuBool === false && (
                    <Button className="btn3"
                      variant="primary"
                      type="button"
                      onClick={() => { this.toggleMenu("authUser") }}
                    >
                      Authorized User Menu
                      </Button>)}
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
