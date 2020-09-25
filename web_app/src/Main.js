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




class Main extends Component {
  constructor(props) {
    super(props);

    this.updateAuthLevel = setInterval(() => {
      if (this.state.isAuthUser !== window.isAuthUser) {
        this.setState({ isAuthUser: window.isAuthUser })
      }
      if (this.state.isACAdmin !== window.isACAdmin) {
        this.setState({ isACAdmin: window.isACAdmin })
      }
      if (this.state.custodyType !== window.custodyType) {
        this.setState({ custodyType: window.custodyType })
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
      if(window.assets.ids.length > 0 && window.assets.descriptions[0][0] !== undefined && 
        window.assets.names.length === 0 && this.state.buildReady === true){
        this.buildAssets()
      }
      if(window.resetInfo === true){
        this.setState({buildReady: false})
        window.assets = { descriptions: [], ids: [], assetClasses: [], statuses: [], names: [] };
        window.assetTokenInfo = {
          assetClass: undefined,
          idxHash: undefined,
          name: undefined,
          photos: undefined,
          text: undefined,
          status: undefined,
        }
        this.setupAssets()
        window.resetInfo = false
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
      let tempDescObj = {}
      let tempDescriptionsArray = [];
      let tempNamesArray = [];

        await window.utils.getAssetTokenInfo()

        for (let i = 0; i < window.aTknIDs.length; i++) {
          console.log(i)
          console.log(window.aTknIDs[i])
          console.log(window.ipfsHashArray[i])
          //await this.getIPFSJSONObject(window.ipfsHashArray[i], tempDescriptionsArray, tempNamesArray) //FIX DESC OUT OF ORDER

          tempDescObj["desc"+i] = [] 
          await this.getIPFSJSONObject(window.ipfsHashArray[i], tempDescObj["desc"+i])
        }

        console.log(tempDescObj)

        for (let x = 0; x < window.aTknIDs.length; x++ ){
          let tempArray = tempDescObj["desc"+x]
          await tempDescriptionsArray.push(tempArray)
        }

        window.assets.descriptions = tempDescriptionsArray;
        window.assets.names = tempNamesArray;
        window.assets.ids = window.aTknIDs;

        console.log(window.assets.ids, " aTkn-> ", window.aTknIDs)
        this.setState({buildReady: true})
    }

    this.buildAssets = () => {
      let tempDescArray = [];
      let emptyDesc = {photo:{}, text:{}, name: ""}

      for(let i = 0; i < window.aTknIDs.length; i++){
        console.log(window.assets.descriptions[i][0])
        if(window.assets.descriptions[i][0] !== undefined){
         tempDescArray.push(JSON.parse(window.assets.descriptions[i][0]))
        }
        else{
         tempDescArray.push(emptyDesc)
        }
      }

      let tempNameArray = []; 
      for(let x = 0; x < window.aTknIDs.length; x++){
         tempNameArray.push(tempDescArray[x].name)
      }

      window.assets.descriptions = tempDescArray;
      window.assets.names = tempNameArray;

      console.log("Assets after rebuild: ",window.assets)
    }

    this.getIPFSJSONObject = (lookup, descElement) => { 
      //console.log(lookup)
         window.ipfs.cat(lookup, async (error, result) => {
          if (error) {
             console.log(lookup, "Something went wrong. Unable to find file on IPFS");
             descElement.push(undefined)
          } else {
             console.log(lookup, "Here's what we found for asset description: ", result);
             descElement.push(result)
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
          window.addr = e[0];
          window.assetClass = undefined;
          window.isAuthUser = false;
          window.isACAdmin = false;
          self.setState({ addr: e[0] })
          self.setupContractEnvironment(window.web3);
        });
      });
    };

    

    this.setupContractEnvironment = async (_web3) => {
      const self = this;
      console.log("Setting up contracts")

      await this.setState({
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
      await this.setupAssets()


      console.log("bools...", window.assetHolderBool, window.assetClassHolderBool, window.IDHolderBool)

      console.log("window assets: ", window.assets)

      if (window.balances !== undefined) {
        await this.setState({
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

      else { return console.log("Ethereum not enabled... Will try again on address change.") }

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
      routeRequest: "basic"
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    buildWindowUtils()
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
        window.assets = { descriptions: [], ids: [], assetClasses: [], statuses: [], names: [] };
  
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
        <ParticleBox/>
        <HashRouter>

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
              <div className="userInfoBox">
                <div>
                  AssetClass Token Balance: {this.state.assetClassBalance}
                </div>
                <br></br>
                <div>
                  Asset Token Balance: {this.state.assetBalance}
                </div>
                <br></br>
                <div>
                  ID Token Balance : {this.state.IDTokenBalance}
                </div>
                <div>
                  <style type="text/css">
                    {`
                        .btn-primary {
                          background-color: #00a8ff;
                          color: white;
                        }
                        .btn-primary:hover {
                          background-color: #00a8ff;
                          color: white;
                        }
                        .btn-primary:focus {
                          background: #00a8ff;
                        }
                        .btn-primary:active {
                          background: #00a8ff;
                        }
                     `}
                  </style>
                  <DropdownButton
                    title="Toggle Menu"
                    className="headerButton"
                    variant="primary"
                    drop="up"
                    flip="false"
                  >
                    {this.state.isACAdmin === true && this.state.assetClassHolderMenuBool === false && (
                      <Dropdown.Item
                        as="button"
                        variant="primary"
                        onClick={() => { this.toggleMenu("ACAdmin") }}
                      >
                        AC Admin Menu
                      </Dropdown.Item>)}

                      {this.state.IDHolderBool === false && this.state.assetHolderBool === true && this.state.assetHolderUserMenuBool === false && (
                        <Dropdown.Item
                          as="button"
                          variant="primary"
                          onClick={() => { this.toggleMenu("NC") }}
                        >
                          Token Holder Menu
                        </Dropdown.Item>
                      )}

                      {this.state.IDHolderBool === true && this.state.assetHolderMenuBool === false && (
                        <Dropdown.Item
                          as="button"
                          variant="primary"
                          onClick={() => { this.toggleMenu("NC") }}
                        >
                          Token Minter Menu
                        </Dropdown.Item>
                      )}

                    {this.state.basicMenuBool === false && (
                      <Dropdown.Item
                        as="button"
                        variant="primary"
                        onClick={() => { this.toggleMenu("basic") }}
                      >
                        Basic Menu
                      </Dropdown.Item>)}

                    {this.state.isAuthUser === true && this.state.authorizedUserMenuBool === false && (
                      <Dropdown.Item
                        as="button"
                        variant="primary"
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
            </div>
            <NavLink to="/">
            </NavLink>

        </HashRouter>
      </div>

    );
  }
}

export default Main;
