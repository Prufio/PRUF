import React, { Component } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from "web3";
import Home from "./Home";
import buildContracts from "./Resources/Contracts";
import buildWindowUtils from "./Resources/WindowUtils";
import NonCustodialComponent from "./Resources/NonCustodialComponent";
import NonCustodialUserComponent from "./Resources/NonCustodialUserComponent";
import AdminComponent from "./Resources/AdminComponent";
import AuthorizedUserComponent from "./Resources/AuthorizedUserComponent";
import BasicComponent from "./Resources/BasicComponent";
import ParticleBox from './Resources/ParticleBox';
import Router from "./Router";
import DropdownButton from 'react-bootstrap/DropdownButton';
import Dropdown from 'react-bootstrap/Dropdown';
import { Twitter } from 'react-feather';
import { GitHub } from 'react-feather';
import { Mail } from 'react-feather';
import { ExternalLink } from "react-feather";


class Main extends Component {
  constructor(props) {
    super(props);

    this.updateWatchDog = setInterval(() => {
      if (this.state.isAuthUser !== window.isAuthUser) {
        this.setState({ isAuthUser: window.isAuthUser })
      }
      if (this.state.isACAdmin !== window.isACAdmin) {
        this.setState({ isACAdmin: window.isACAdmin })
      }
      if (this.state.custodyType !== window.custodyType) {
        this.setState({ custodyType: window.custodyType })
      }

      if (this.state.ETHBalance !== window.ETHBalance) {
        this.setState({ ETHBalance: window.ETHBalance })
      }
      if (this.state.routeRequest !== window.routeRequest) {
        this.setState({
          basicMenuBool: true,
          assetHolderMenuBool: false,
          assetHolderUserMenuBool: false,
          assetClassHolderMenuBool: false,
          authorizedUserMenuBool: false
        })
      }
      if (window.assets.ids.length > 0 && Object.values(window.assets.descriptions).length === window.aTknIDs.length &&
        window.assets.names.length === 0 && this.state.buildReady === true) {
        if (window.resetInfo === false) {
          console.log("WD: rebuilding assets (Last Step)")
          this.buildAssets()
        }

      }
      if (window.resetInfo === true) {
        window.hasLoadedAssets = false;
        this.setState({ buildReady: false, runWatchDog: false })
        window.assets = { descriptions: [], ids: [], assetClasses: [], statuses: [], names: [] };
        window.assetTokenInfo = {
          assetClass: undefined,
          idxHash: undefined,
          name: undefined,
          photos: undefined,
          text: undefined,
          status: undefined,
        }
        console.log("WD: setting up assets (Step one)")
        this.setupAssets()
        window.resetInfo = false
      }
      if (window.aTknIDs !== undefined && this.state.buildReady === false) {
        if (window.ipfsCounter >= window.aTknIDs.length && this.state.runWatchDog === true) {
          console.log("turning on buildready... Window IPFS operation count: ", window.ipfsCounter)
          this.setState({ buildReady: true })
        }
      }
      else if ((this.state.buildReady === true && window.ipfsCounter < window.aTknIDs.length) ||
        (this.state.buildReady === true && this.state.runWatchDog === false)) {
        console.log("Setting buildready to false in watchdog")
        this.setState({ buildReady: false })
      }
    }, 100)

    this.toggleMenu = async (menuChoice) => {
      window.location.href = '/#/';
      if (menuChoice === 'ACAdmin') {
        window.routeRequest = "ACAdmin"
        await this.setState({ routeRequest: "ACAdmin" });
        return this.setState({
          assetClassHolderMenuBool: true,
          assetHolderMenuBool: false,
          assetHolderUserMenuBool: false,
          basicMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'basic') {
        window.routeRequest = "basic"
        await this.setState({ routeRequest: "basic" });
        return this.setState({
          basicMenuBool: true,
          assetHolderMenuBool: false,
          assetHolderUserMenuBool: false,
          assetClassHolderMenuBool: false,
          authorizedUserMenuBool: false
        })
      }

      else if (menuChoice === 'NC') {
        window.routeRequest = "NCAdmin"
        if (this.state.IDHolderBool) {
          await this.setState({ routeRequest: "NCAdmin" })
          return this.setState({
            assetHolderMenuBool: true,
            assetHolderUserMenuBool: false,
            basicMenuBool: false,
            assetClassHolderMenuBool: false,
            authorizedUserMenuBool: false
          })
        }
        else {
          window.routeRequest = "NCUser"
          await this.setState({ routeRequest: "NCUser" })
          return this.setState({
            assetHolderMenuBool: false,
            assetHolderUserMenuBool: true,
            basicMenuBool: false,
            assetClassHolderMenuBool: false,
            authorizedUserMenuBool: false
          })
        }
      }

      else if (menuChoice === 'authUser') {
        window.routeRequest = "authUser"
        await this.setState({ routeRequest: "authUser" });
        return this.setState({
          authorizedUserMenuBool: true,
          assetHolderMenuBool: false,
          assetHolderUserMenuBool: false,
          assetClassHolderMenuBool: false,
          basicMenuBool: false
        })
      }

    }

    this.setupAssets = async () => {
      console.log("SA: In setupAssets")

      window.ipfsCounter = 0;

      let tempDescObj = {}
      let tempDescriptionsArray = [];
      let tempNamesArray = [];

      if (window.recount === true) {
        window.recount = false
        await this.setUpTokenVals()
        return this.setupAssets()
      }

      await window.utils.getAssetTokenInfo()

      for (let i = 0; i < window.aTknIDs.length; i++) {
        tempDescObj["desc" + i] = []
        await this.getIPFSJSONObject(window.ipfsHashArray[i], tempDescObj["desc" + i])
      }

      console.log("Temp description obj: ", tempDescObj)

      for (let x = 0; x < window.aTknIDs.length; x++) {
        let tempArray = tempDescObj["desc" + x]
        await tempDescriptionsArray.push(tempArray)
      }

      window.assets.descriptions = tempDescriptionsArray;
      window.assets.names = tempNamesArray;
      window.assets.ids = window.aTknIDs;

      console.log("Asset setup Complete. Turning on watchDog.")
      this.setState({ runWatchDog: true })
      console.log("window IPFS operation count: ", window.ipfsCounter)
      console.log("window assets: ", window.assets)
      //console.log(window.assets.ids, " aTkn-> ", window.aTknIDs)

    }


    this.buildAssets = () => {
      console.log("BA: In buildAssets. Window IPFS operation count: ", window.ipfsCounter)
      let tempDescArray = [];
      let emptyDesc = { photo: {}, text: {}, name: "" }

      for (let i = 0; i < window.aTknIDs.length; i++) {
        //console.log(window.assets.descriptions[i][0])
        if (window.assets.descriptions[i][0] !== undefined) {
          tempDescArray.push(JSON.parse(window.assets.descriptions[i][0]))
        }
        else {
          tempDescArray.push(emptyDesc)
        }
      }

      let tempNameArray = [];
      for (let x = 0; x < window.aTknIDs.length; x++) {
        tempNameArray.push(tempDescArray[x].name)
      }

    let tempDisplayArray = [];
    for (let j = 0; j < window.aTknIDs.length; j++) {
      if(tempDescArray[j].photo.displayImage === undefined){
        tempDisplayArray.push("https://pruf.io/assets/images/pruf-u-logo-192x255.png")
      }
      else{
        tempDisplayArray.push(tempDescArray[j].photo.displayImage)
      }
    }

    window.assets.descriptions = tempDescArray;
    window.assets.names = tempNameArray;
    window.assets.displayImages = tempDisplayArray;
    window.hasLoadedAssets = true;
    console.log("BA: Assets after rebuild: ", window.assets)
  }

    this.setUpTokenVals = async () => {
      console.log("STV: Setting up balances")

      await window.utils.determineTokenBalance()

      if (window.balances !== undefined) {
        this.setState({
          assetClassBalance: window.balances.assetClassBalance,
          assetBalance: window.balances.assetBalance,
          IDTokenBalance: window.balances.IDTokenBalance,
          assetHolderBool: window.assetHolderBool,
          assetClassHolderBool: window.assetClassHolderBool,
          IDHolderBool: window.IDHolderBool,
          custodyType: window.custodyType,
        })
        return this.setState({ hasFetchedBalances: window.hasFetchedBalances })
      }
    }

    this.getIPFSJSONObject = (lookup, descElement) => {
      //console.log(lookup)
      window.ipfs.cat(lookup, async (error, result) => {
        if (error) {
          console.log(lookup, "Something went wrong. Unable to find file on IPFS");
          descElement.push(undefined)
          window.ipfsCounter++
          console.log(window.ipfsCounter)
        } else {
          console.log(lookup, "Here's what we found for asset description: ", result);
          descElement.push(result)
          window.ipfsCounter++
          console.log(window.ipfsCounter)
        }
      });
    };

    this.acctChanger = async () => {//Handle an address change, update state accordingly
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => {
          if (window.addr !== e[0]) {
            window.addr = e[0];
            window.assetClass = undefined;
            window.isAuthUser = false;
            window.isACAdmin = false;
            self.setState({ addr: e[0], runWatchDog: false })
            self.setupContractEnvironment(window.web3);
            console.log("///////in acctChanger////////")
          }
          else { console.log("Something bit in the acct listener, but no changes made.") }
        });
      });
    };



    this.setupContractEnvironment = async (_web3) => {
      if(window.isSettingUpContracts){return(console.log("Already in the middle of setup..."))}
      window.isSettingUpContracts = true;
      const self = this;
      console.log("Setting up contracts")
      if (window.ethereum !== undefined) {
        await this.setState({
          assetHolderMenuBool: false,
          assetClassHolderMenuBool: false,
          basicMenuBool: true,
          authorizedUserMenuBool: false,
          hasFetchedBalances: false,
          routeRequest: "basic"
        })

        

        window._contracts = await buildContracts(_web3)

        await window.utils.getETHBalance();
        await this.setState({ contracts: window._contracts })
        await window.utils.getContracts()
        await this.setUpTokenVals()
        await this.setupAssets()
        
        console.log("bools...", window.assetHolderBool, window.assetClassHolderBool, window.IDHolderBool)
        console.log("Wallet balance in ETH: ", window.ETHBalance)
        window.isSettingUpContracts = false;
        return this.setState({ runWatchDog: true })
      }
      
      else { window.isSettingUpContracts = false; return console.log("Ethereum not enabled... Will try again on address change.") }

    }

    //Component state declaration

    this.state = {
      IPFS: require("ipfs-mini"),
      isSTOROwner: undefined,
      isBPPOwner: undefined,
      isBPNPOwner: undefined,
      addr: undefined,
      web3: null,
      nameArray: [],
      notAvailable: "N/A",
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
      IDHolderBool: false,
      assetClassHolderBool: false,
      assetHolderMenuBool: false,
      assetHolderUserMenuBool: false,
      assetClassHolderMenuBool: false,
      basicMenuBool: true,
      authorizedUserMenuBool: false,
      hasFetchedBalances: false,
      isACAdmin: undefined,
      runWatchDog: false,
      buildReady: false,
      hasMounted: false,
      routeRequest: "basic"
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    buildWindowUtils()
    window.isSettingUpContracts = false;
    window.hasLoadedAssets = false;
    window.location.href = '/#/';

    if (window.ethereum) {
      window.additionalElementArrays = {
        photo: [],
        text: [],
        name: ""
      }
      window.assetTokenInfo = {
        assetClass: undefined,
        idxHash: undefined,
        name: undefined,
        photos: undefined,
        text: undefined,
        status: undefined,
      }
      window.assets = { descriptions: [], ids: [], assetClasses: [], statuses: [], names: [], displayImages: [] };
      window.resetInfo = false;
      const ethereum = window.ethereum;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      this.setupContractEnvironment(_web3)
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
      this.setState({hasMounted: true})
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

          <div className="imageForm">
            <button
              class="imageButton"
              onClick={() => { this.toggleMenu("basic") }}
            >
              <img
                className="downSizeLogo"
                src={require("./Resources/pruf ar long.png")}
                alt="Pruf Logo" />
            </button>
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
          <div>
            <div className="BannerForm">
              <ul className="header">
                {window._contracts !== undefined && (
                  <nav>
                    {this.state.assetHolderMenuBool === true && (<NonCustodialComponent />)}
                    {this.state.assetHolderUserMenuBool === true && (<NonCustodialUserComponent />)}
                    {this.state.assetClassHolderMenuBool === true && (<AdminComponent />)}
                    {this.state.authorizedUserMenuBool === true && (<AuthorizedUserComponent />)}
                    {this.state.basicMenuBool === true && (<BasicComponent />)}
                  </nav>
                )}
              </ul>
            </div>
          </div>
          <div className="pageForm">
            <div
              className="tokenBalances"
            >
              <DropdownButton
                title="Token Balances"
                variant="toggle"
                size="lg">
                <Dropdown.Item size="lg">
                  ETH Balance : {this.state.ETHBalance}
                </Dropdown.Item>
                <Dropdown.Item size="lg">
                  AssetClass Token Balance: {this.state.assetClassBalance}
                </Dropdown.Item>
                <Dropdown.Item size="lg">
                  Asset Token Balance: {this.state.assetBalance}
                </Dropdown.Item>
                <Dropdown.Item size="lg">
                  ID Token Balance : {this.state.IDTokenBalance}
                </Dropdown.Item>
              </DropdownButton>
              <div>
                <style type="text/css">
                  {`
                        .btn-primary {
                          background-color: #00a8ff;
                          color: white;
                        }
                        .btn-primary:hover {
                          background-color: #23b6ff;
                          color: white;
                        }
                        .btn-primary:focus {
                          background: #00a8ff;
                        }
                        .btn-primary:active {
                          background: #00a8ff;
                        }

                        .btn-toggle {
                          background-color: #005480;
                          color: white;
                          height: 4rem;
                          margin-top: 0.4rem;
                          margin-left: -0.8rem;
                          font-weight: bold;
                          font-size: 2.2rem;
                          border-radius: 0rem 0rem 0.3rem 0rem;
                        }
                        .btn-toggle:hover {
                          background-color: #23b6ff;
                          color: white;
                        }
                        .btn-toggle:focus {
                          background: #00a8ff;
                          font-size: 1.4rem;
                        }
                        .btn-toggle:active {
                          background: #00a8ff;
                          font-size: 1.4rem;
                        }
                        .dropdown-toggle{
                          margin-top: 0.4rem;
                          width: 19.8rem;
                          font-size: 1.4rem;
                        }
                        .dropdown-menu {
                          width: 19.8rem;
                          font-size: 1.4rem;
                          background-color: #00a8ff;
                          color: white;
                          -webkit-transition: all .25s ease;
                          -moz-transition: all .25s ease;
                           -ms-transition: all .25s ease;
                            -o-transition: all .25s ease;
                               transition: all .25s ease;
                        }
                     `}
                </style>
                <DropdownButton
                  title="Toggle Menu"
                  variant="toggle"
                  drop="down"
                  flip="false"
                  size="lg"
                >
                  {this.state.isACAdmin === true && this.state.assetClassHolderMenuBool === false && (
                    <Dropdown.Item
                      as="button"
                      size="lg"
                      onClick={() => { this.toggleMenu("ACAdmin") }}
                    >
                      AC Admin Menu
                    </Dropdown.Item>)}

                  {this.state.IDHolderBool === false && this.state.assetHolderBool === true && this.state.assetHolderUserMenuBool === false && (
                    <Dropdown.Item
                      as="button"
                      size="lg"
                      onClick={() => { this.toggleMenu("NC") }}
                    >
                      Token Holder Menu
                    </Dropdown.Item>
                  )}

                  {this.state.IDHolderBool === true && this.state.assetHolderMenuBool === false && (
                    <Dropdown.Item
                      as="button"
                      size="lg"
                      onClick={() => { this.toggleMenu("NC") }}
                    >
                      Token Minter Menu
                    </Dropdown.Item>
                  )}

                  {this.state.basicMenuBool === false && (
                    <Dropdown.Item
                      as="button"
                      size="lg"
                      onClick={() => { this.toggleMenu("basic") }}
                    >
                      Basic Menu
                    </Dropdown.Item>)}

                  {this.state.isAuthUser === true && this.state.authorizedUserMenuBool === false && (
                    <Dropdown.Item
                      as="button"
                      size="lg"
                      onClick={() => { this.toggleMenu("authUser") }}
                    >
                      Authorized User Menu
                    </Dropdown.Item>)}
                </DropdownButton>
              </div>
            </div>

            <div>
              <Route exact path="/" component={Home} />
              {Router(this.state.routeRequest)}
            </div>
            <div className="mediaLink">
              <a className="mediaLinkContent"><GitHub onClick={() => { window.open("https://github.com/vdmprojects/Bulletproof", "_blank") }} /></a>
              <a className="mediaLinkContent"><Mail onClick={() => { window.open("mailto:drake@pruf.io", "_blank") }} /></a>
              <a className="mediaLinkContent"><Twitter onClick={() => { window.open("https://twitter.com/umlautchair", "_blank") }} /></a>
              <a className="mediaLinkContent" ><ExternalLink onClick={() => { window.open("https://www.pruf.io", "_blank") }} /></a>
            </div>
          </div>
          <NavLink to="/">
          </NavLink>

        </HashRouter>

      </div>
    );
  }
}

export default Main;
