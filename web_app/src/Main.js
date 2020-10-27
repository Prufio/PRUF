import React, { Component } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from "web3";
import Home from "./Home";
import HomeMobile from "./Mobile/HomeMobile";
import buildContracts from "./Resources/Contracts";
import buildWindowUtils from "./Resources/WindowUtils";
import NonCustodialComponent from "./Resources/NonCustodialComponent";
import NonCustodialUserComponent from "./Resources/NonCustodialUserComponent";
import AdminComponent from "./Resources/AdminComponent";
import AuthorizedUserComponent from "./Resources/AuthorizedUserComponent";
import NoAddressComponent from "./Resources/NoAddressComponent";
import BasicComponent from "./Resources/BasicComponent";
import ParticleBox from './Resources/ParticleBox';
import Router from "./Router";
import DropdownButton from 'react-bootstrap/DropdownButton';
import Button from 'react-bootstrap/Button';
import Dropdown from 'react-bootstrap/Dropdown';
import { Twitter } from 'react-feather';
import { GitHub } from 'react-feather';
import { Mail } from 'react-feather';
import { Video } from "react-feather";
import { Menu } from 'react-feather';
import { User } from 'react-feather';
import { Settings } from 'react-feather';
import {
  BrowserView,
  MobileView,
  isBrowser,
  isMobile
} from "react-device-detect";
import { connect } from 'react-redux';
import {
  setHasLoadedAssets,
  setHolderBools,
  setGlobalAddr, 
  setGlobalWeb3,
  setIPFS,
  setContracts,
  setIsAdmin,
  setBalances,
  setMenuInfo,
  setIsACAdmin,
  setCustodyType,
  setEthBalance,
  setAssets,
  setAssetsToDefault,
  setAssetTokenIds,
  setIPFSHashArray,
  setHasAssets,
  setHasFetchedBals,
  setGlobalAssetClass,
  setAssetTokenInfo,
  setIsAuthUser,
  setCosts
} from './Actions'

class Main extends Component {
  constructor(props) {
    super(props);

    this.renderContent = () => {
      
      if (isMobile) {
        return (
          <div>
            <HashRouter>
              <div>
                <div className="BannerForm">
                  <ul className="header">
                    {this.props.contracts !== undefined && (
                      <nav>
                        {this.state.menuInfo.bools.noAddrMenuBool === true && (<NoAddressComponent />)}
                      </nav>
                    )}
                  </ul>
                </div>
              </div>
              <div className="pageForm">
                <div key={this.state.menuInfo.route}>
                  <Route exact path="/" component={HomeMobile} />
                  {Router(this.state.menuInfo.route)}
                </div>
              </div>
              <NavLink to="/">
              </NavLink>
            </HashRouter>
          </div >
        );
      }
      return (
        <div>
          <HashRouter>
          

            <div className="imageForm">
              <button
                className="imageButton"
                title="Back to Home!"
                onClick={() => { this.toggleMenu("basic") }}
              >
                <img
                  className="downSizeLogo"
                  src={require("./Resources/pruf ar long.png")}
                  alt="Pruf Logo" />
              </button>
            </div>
            <div>
              <div className="BannerForm">
                <div className="currentMenuOption">
                  <div>
                    {this.state.menuInfo.bools.noAddrMenuBool === true && (<div className="currentMenuOptionContent"> Read Only Access</div>)}
                    {this.state.menuInfo.bools.assetHolderMenuBool === true && (<div className="currentMenuOptionContent">Token Minter Menu</div>)}
                    {this.state.menuInfo.bools.assetHolderUserMenuBool === true && (<div className="currentMenuOptionContent">Token Holder Menu</div>)}
                    {this.state.menuInfo.bools.assetClassHolderMenuBool === true && (<div className="currentMenuOptionContent">AC Admin Menu</div>)}
                    {this.state.menuInfo.bools.authorizedUserMenuBool === true && (<div className="currentMenuOptionContent">Asset Minter Menu</div>)}
                    {this.state.menuInfo.bools.basicMenuBool === true && (<div className="currentMenuOptionContent">Basic Menu</div>)}
                  </div>
                </div>
                <div className="hamburgerMenu">
                  <a className="hamburgerMenu-content" ><Menu size={35} onClick={() => { this.hamburgerMenu() }} /></a>
                </div>
                {this.state.hamburgerMenu !== undefined && (
                  <div className="hamburgerDropdown">
                    <div className="mediaLink">
                      <a className="mediaLinkContent"><GitHub size={20} onClick={() => { window.open("https://github.com/vdmprojects/Bulletproof", "_blank") }} /></a>
                      <a className="mediaLinkContent"><Mail size={20} onClick={() => { window.open("mailto:drake@pruf.io", "_blank") }} /></a>
                      <a className="mediaLinkContent"><Twitter size={20} onClick={() => { window.open("https://www.twitter.com/prufteam", "_blank") }} /></a>
                      <a className="mediaLinkContent" ><Video size={20} onClick={() => { window.open("https://www.youtube.com/channel/UC9HzR9-dAzHtPKOqlVqwOuw", "_blank") }} /></a>
                    </div>
                    <button
                      className="imageButtonU"
                      onClick={() => { window.open("https://www.pruf.io", "_blank") }}
                    >
                      <img
                        className="imageFormU"
                        title="Find out More!"
                        src={require("./Resources/favicon pruf no bg.png")}
                        alt="Pruf U" />
                    </button>
                    <div className="siteInfoBox">
                      <h3 className="siteInfoBoxContent">
                        Website last updated:
                  </h3>
                      <h3 className="siteInfoBoxContent">
                        October 19, 2020
                  </h3>
                    </div>
                    <div className="hamburgerMenuLink">
                      <a className="hamburgerMenuLink-content-user" ><User size={48} onClick={() => { this.userMenu() }} /></a>
                    </div>
                    <div className="hamburgerMenuLink">
                      <a className="hamburgerMenuLink-content-settings" ><Settings size={35} onClick={() => { this.settingsMenu() }} /></a>
                    </div>
                    <div>
                      {this.state.settingsMenu !== undefined && (
                        <div>
                          <div className="hamburgerDropdownSettings">
                            {this.state.holderBools.assetClassHolderBool === true && this.state.menuInfo.bools.assetClassHolderMenuBool === false && (
                              <Button
                                size="lg"
                                variant="toggle"
                                onClick={() => { this.toggleMenu("ACAdmin") }}
                              >
                                AC Admin Menu
                              </Button>)}

                            {this.state.holderBools.IDHolderBool === false && this.state.holderBools.assetHolderBool === true && this.state.menuInfo.bools.assetHolderUserMenuBool === false && (
                              <Button
                                size="lg"
                                variant="toggle"
                                onClick={() => { this.toggleMenu("NCUser") }}
                              >
                                Token Holder Menu
                              </Button>
                            )}

                            {this.state.holderBools.IDHolderBool === true && this.state.menuInfo.bools.assetHolderMenuBool === false && (
                              <Button
                                size="lg"
                                variant="toggle"
                                onClick={() => { this.toggleMenu("NC") }}
                              >
                                Token Minter Menu
                              </Button>
                            )}

                            {this.state.menuInfo.bools.basicMenuBool === false && (
                              <Button
                                size="lg"
                                variant="toggle"
                                onClick={() => { this.toggleMenu("basic") }}
                              >
                                Basic Menu
                              </Button>)}

                            {this.props.isAuthUser === true && this.state.menuInfo.bools.authorizedUserMenuBool === false && (
                              <Button
                                size="lg"
                                variant="toggle"
                                onClick={() => { this.toggleMenu("authUser") }}
                              >
                                Asset Minter Menu
                              </Button>)}
                          </div>
                        </div>
                      )}
                    </div>
                    <div>
                      {this.state.userMenu !== undefined && (
                        <div className="hamburgerDropdownUserInfo">
                          {this.state.addr > 0 && (
                            <h4>
                              Currently serving :
                              <Button
                                variant="etherscan"
                                title="Check it out on Etherscan!"
                                onClick={() => { window.open("https://kovan.etherscan.io/address/" + this.props.globalAddr) }}>
                                {this.props.globalAddr.substring(0, 6) + "..." + this.props.globalAddr.substring(37, 42)}
                              </Button>
                            </h4>
                          )}
                          {this.props.globalAddr === "" && (
                            <h4>
                              Currently serving: NOBODY! Log into web3 provider!
                            </h4>
                          )}
                          <br></br>
                          {this.props.ETHBalance === undefined && (
                            <h4>
                              ETH Balance : Please Log In
                            </h4>
                          )}
                          {this.props.ETHBalance && (
                            <h4>
                              ETH Balance : {String(this.props.ETHBalance).substring(0, 6)}
                            </h4>
                          )}
                          <br></br>
                          {this.props.globalBalances.assetClassBalance === undefined && (
                            <h4>
                              AssetClass Token Balance: Please Log In
                            </h4>
                          )}
                          {this.props.globalBalances.assetClassBalance && (
                            <h4>
                              AssetClass Token Balance: {this.props.globalBalances.assetClassBalance}
                            </h4>
                          )}
                          <br></br>
                          {this.props.globalBalances.assetBalance === undefined && (
                            <h4>
                              Asset Token Balance: Please Log In
                            </h4>
                          )}
                          {this.props.globalBalances.assetBalance && (
                            <h4>
                              Asset Token Balance:
                              <Button
                                variant="assetDashboard"
                                title="Asset Dashboard"
                                onClick={() => { window.location.href = '/#/asset-dashboard' }}>
                                {this.props.globalBalances.assetBalance}
                              </Button>
                            </h4>
                          )}
                          <br></br>
                          {this.props.globalBalances.IDTokenBalance === undefined && (
                            <h4>
                              ID Token Balance : Please Log In
                            </h4>
                          )}
                          {this.props.globalBalances.IDTokenBalance && (
                            <h4>
                              ID Token Balance : {this.props.globalBalances.IDTokenBalance}
                            </h4>
                          )}
                          <br></br>
                        </div>
                      )}
                    </div>
                  </div>
                )}
                <ul key = {this.state.menuInfo.bools + "_renderNav"} className="header">
                    <nav>
                      {this.state.menuInfo.bools.noAddrMenuBool === true && (<NoAddressComponent />)}
                      {this.state.menuInfo.bools.assetHolderMenuBool === true && (<NonCustodialComponent />)}
                      {this.state.menuInfo.bools.assetHolderUserMenuBool === true && (<NonCustodialUserComponent />)}
                      {this.state.menuInfo.bools.assetClassHolderMenuBool === true && (<AdminComponent />)}
                      {this.state.menuInfo.bools.authorizedUserMenuBool === true && (<AuthorizedUserComponent />)}
                      {this.state.menuInfo.bools.basicMenuBool === true && (<BasicComponent />)}
                    </nav>
                </ul>
              </div>
            </div>
            <div className="pageForm">
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

                      .btn-etherscan {
                        background-color: transparent;
                        color: white;
                        margin-top: -0.5rem;
                        // margin-right: 37rem;
                        font-size: 1.5rem;
                      }
                      .btn-etherscan:hover {
                        background-color: transparent;
                        color: #00a8ff;
                      }
                      .btn-etherscan:focus {
                        background-color: transparent;
                      }
                      .btn-etherscan:active {
                        background-color: transparent;
                        border: transparent;
                      }

                      .btn-assetDashboard {
                        background-color: transparent;
                        color: white;
                        margin-top: -0.5rem;
                        // margin-right: 37rem;
                        font-size: 1.6rem;
                        width: 5rem;
                      }
                      .btn-assetDashboard:hover {
                        background-color: transparent;
                        color: #00a8ff;
                      }
                      .btn-assetDashboard:focus {
                        background-color: transparent;
                      }
                      .btn-assetDashboard:active {
                        background-color: transparent;
                        border: transparent;
                      }

                      .btn {
                        color: white;
                      }

                      .btn-toggle {
                        background: #002a40;
                        color: #fff;
                        height: 3rem;
                        width: 17.3rem;
                        margin-top: -0.2rem;
                        border-radius: 0;
                        font-weight: bold;
                        font-size: 1.4rem;
                      }
                      btn-toggle:hover {
                        background: #23b6ff;
                        color: #fff;
                      }
                      .btn-toggle:focus {
                        background: #23b6ff;
                        color: #fff;
                      }
                      .btn-toggle:active {
                        background: #23b6ff;
                        color: #fff;
                      }
                   `}
              </style>
              <div key={this.state.menuInfo.route + "_desktop"}>
                <Route exact path="/" component={Home} />
                {Router(this.state.menuInfo.route)}
              </div>
            </div>
            <NavLink to="/">
            </NavLink>
          </HashRouter>
        </div >
      );
    }

    this.toggleMenu = (menuChoice) => {

      switch(menuChoice){

        case 'ACAdmin' : {
          this.props.setMenuInfo({
            assetClassHolderMenuBool: true,
            assetHolderMenuBool: false,
            assetHolderUserMenuBool: false,
            basicMenuBool: false,
            noAddrMenuBool: false,
            authorizedUserMenuBool: false,      
          }, "ACAdmin")
          return this.setState({ settingsMenu: undefined });
        }
  
        case 'basic' : {
          this.props.setMenuInfo({
            assetClassHolderMenuBool: false,
            assetHolderMenuBool: false,
            assetHolderUserMenuBool: false,
            basicMenuBool: true,
            noAddrMenuBool: false,
            authorizedUserMenuBool: false,      
          }, "basic")
           return this.setState({ settingsMenu: undefined });
        }
  
        case 'NC' : {
          this.props.setMenuInfo({
            assetClassHolderMenuBool: false,
            assetHolderMenuBool: true,
            assetHolderUserMenuBool: false,
            basicMenuBool: false,
            noAddrMenuBool: false,
            authorizedUserMenuBool: false,      
          }, "NCAdmin")
          return this.setState({ settingsMenu: undefined });
        }
  
        case 'NCUser' : {
          this.props.setMenuInfo({
            assetClassHolderMenuBool: false,
            assetHolderMenuBool: false,
            assetHolderUserMenuBool: true,
            basicMenuBool: false,
            noAddrMenuBool: false,
            authorizedUserMenuBool: false,      
          }, "NCUser")
          return this.setState({ settingsMenu: undefined });
        }
  
        case 'authUser' : {
          this.props.setMenuInfo({
            assetClassHolderMenuBool: false,
            assetHolderMenuBool: false,
            assetHolderUserMenuBool: false,
            basicMenuBool: false,
            noAddrMenuBool: false,
            authorizedUserMenuBool: true,      
          }, "authUser")
          return this.setState({ settingsMenu: undefined });
        }
  
      }

      
    }

    this.updateWatchDog = setInterval(() => {


      if (this.state.additionalTokenInfo !== undefined) {
        if (this.state.additionalTokenInfo.ids.length > 0 && this.state.buildReady === true && this.props.globalBalances.assetBalance > 0) {
          if (window.ipfsCounter === Number(this.props.globalBalances.assetBalance) && window.resetInfo === false) {
            console.log("WD: rebuilding assets (Last Step)") 
            this.buildAssets()
          }
        }
      }

      if (window.resetInfo === true) {
        this.props.setHasLoadedAssets(false);
        this.setState({ buildReady: false, runWatchDog: false })
        console.log("WD: setting up assets (Step one)")
        this.setUpAssets()
        window.resetInfo = false
      }

      if (this.props.assetTokenIDs !== undefined && this.state.buildReady === false) {
        if (window.ipfsCounter >= this.props.assetTokenIDs.length && this.state.runWatchDog === true && this.props.assetTokenIDs.length > 0) {
          console.log("turning on buildready... Window IPFS operation count: ", window.ipfsCounter)
          this.setState({ buildReady: true })
        }
      }

      else if ((this.state.buildReady === true && window.ipfsCounter < this.props.assetTokenIDs.length) ||
        (this.state.buildReady === true && this.state.runWatchDog === false)) {
        console.log("Setting buildready to false in watchdog")
        this.setState({ buildReady: false })
      }
    }, 100)

    this.setUpAssets = async () => {

      console.log(this.props.globalBalances)

      await this.props.setHasAssets(true);
      window.ipfsCounter = 0;
      await this.props.setIPFSHashArray([]);
      await this.props.setHasFetchedBals(false);
      await this.props.setAssetsToDefault();        
      await this.props.setAssetTokenInfo({
        assetClass: undefined,
        idxHash: undefined,
        name: undefined,
        photos: undefined,
        text: undefined,
        status: undefined,
      })

      if (window.recount === true) {
        window.recount = false
        await this.props.setBalances({})
        let tempETHBal = await window.utils.getETHBalance(this.props.globalAddr, this.props.web3)
        await this.props.setEthBalance(tempETHBal);
        return this.setUpTokenVals(true)
      }

      if (this.props.globalBalances !== undefined) {

        this.setState({
          assetClassBalance: this.props.globalBalances.assetClassBalance,
          assetBalance: this.props.globalBalances.assetBalance,
          IDTokenBalance: this.props.globalBalances.IDTokenBalance,
          assetHolderBool: this.props.assetHolderBool,
          assetClassHolderBool: this.props.assetClassHolderBool,
          IDHolderBool: this.props.IDHolderBool,
          custodyType: this.props.custodyType,
          hasFetchedBalances: this.props.hasFetchedBalances
        })

      }

      if (this.props.globalBalances === {}) {
        console.log("balances undefined, trying to get them...");
        if (this.props.globalAddr === "undefined") { return this.forceUpdate }
        return this.setUpTokenVals(true);
      }

      console.log("SA: In setUpAssets")

      let tempDescObj = {}
      let tempDescriptionsArray = [];
      let tempNamesArray = [];

      let additionalInfo = await window.utils.getAssetTokenInfo(this.props.globalBalances.assetBalance, this.props.contracts, this.props.globalAddr, this.props.web3) 

      await this.setState({additionalTokenInfo: additionalInfo})

      console.log(additionalInfo)

      if (additionalInfo === undefined) { return }
      console.log(additionalInfo.ids)
      for (let i = 0; i < additionalInfo.ids.length; i++) {
        tempDescObj["desc" + i] = []
        await this.getIPFSJSONObject(additionalInfo.ipfsHashArray[i], tempDescObj["desc" + i])
      }

      console.log("Temp description obj: ", tempDescObj)

      for (let x = 0; x < additionalInfo.ids.length; x++) {
        let tempArray = tempDescObj["desc" + x]
        await tempDescriptionsArray.push(tempArray)
      }

      this.props.setAssetTokenIds(additionalInfo.ids)

      console.log(tempDescriptionsArray)

      this.setState({
        descriptions: tempDescriptionsArray,
        names: tempNamesArray,
        ids: additionalInfo.ids
      })

      console.log("Asset setUp Complete. Turning on watchDog.")
      this.setState({ runWatchDog: true })
      console.log("window IPFS operation count: ", window.ipfsCounter)
      console.log("Bools...", this.props.holderBools.assetHolderBool, this.props.holderBools.assetClassHolderBool, this.props.holderBools.IDHolderBool)

    }

    this.buildAssets = () => {
      console.log("BA: In buildAssets. Window IPFS operation count: ", window.ipfsCounter)
      let tempDescArray = [];
      let emptyDesc = { photo: {}, text: {}, name: "" }

      this.setState({buildReady: false})

      for (let i = 0; i < this.state.ids.length; i++) {
        if (this.state.descriptions[i][0] !== undefined) {
          tempDescArray.push(JSON.parse(this.state.descriptions[i][0]))
        }
        else {
          tempDescArray.push(emptyDesc)
        }
      }

      let tempNameArray = [];
      for (let x = 0; x < this.state.ids.length; x++) {
        if (tempDescArray[x].name === "" || tempDescArray[x].name === undefined) {
          tempNameArray.push("Not Available")
        }
        else {
          tempNameArray.push(tempDescArray[x].name)
        }

      }

      let tempDisplayArray = [];
      for (let j = 0; j < this.state.ids.length; j++) {
        if (tempDescArray[j].photo.DisplayImage === undefined && Object.values(tempDescArray[j].photo).length === 0) {
          tempDisplayArray.push("https://pruf.io/assets/images/pruf-u-logo-192x255.png")
        }
        else if(tempDescArray[j].photo.DisplayImage === undefined && Object.values(tempDescArray[j].photo).length > 0){
          tempDisplayArray.push(Object.values(tempDescArray[j].photo)[0])
        }
        else {
          tempDisplayArray.push(tempDescArray[j].photo.DisplayImage)
        }
      }

      let assetInfo = this.state.additionalTokenInfo;

      window.hasLoadedAssets = true;

      this.props.setAssets({
        descriptions: tempDescArray, 
        names: tempNameArray, 
        displayImages: tempDisplayArray, 
        statuses: assetInfo.statuses,
        countPairs: assetInfo.countPairs,
        assetClasses: assetInfo.assetClasses,
        ids: assetInfo.ids,
        assetClassNames: assetInfo.ACNames
      });

      console.log({
        descriptions: tempDescArray, 
        names: tempNameArray, 
        displayImages: tempDisplayArray, 
        statuses: assetInfo.statuses,
        countPairs: assetInfo.countPairs,
        assetClasses: assetInfo.assetClasses,
        ids: assetInfo.ids,
        assetClassNames: assetInfo.ACNames
      })

      this.setState({additionalTokenInfo: undefined})


    }

    this.setUpTokenVals = async (willSetup) => {
      
      console.log("STV: Setting up balances")
      console.log(this.props.contracts)
      const balsObject = await window.utils.determineTokenBalance(this.props.globalAddr, this.props.contracts)
      await this.props.setBalances(balsObject.bals)
      await this.props.setHolderBools(balsObject.bools)

      await this.props.setHasFetchedBals(true)
      
      if (willSetup) {
        return this.setUpAssets()
      }

    }

    this.getIPFSJSONObject = (lookup, descElement) => {
      //console.log(lookup)
      this.props.ipfs.cat(lookup, async (error, result) => {
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
          if (self.props.globalAddr !== e[0]) {

            self.props.setMenuInfo({
              basicMenuBool: true,
              assetHolderMenuBool: false,
              assetHolderUserMenuBool: false,
              assetClassHolderMenuBool: false,
              noAddrMenuBool: false,
              authorizedUserMenuBool: false,
              settingsMenu: undefined
            },"basic");

            if (window.location.href !== "/#/asset-dashboard") { window.location.href = "/#" }

            self.props.setGlobalAddr(e[0]);
            self.props.setGlobalAssetClass(null);
            self.props.setIsAuthUser(false);
            self.props.setIsACAdmin(false);
            self.setState({ addr: e[0] });
            window.recount = true;
            window.resetInfo = true;

            console.log("///////in acctChanger////////");
          }
          else { console.log("Something bit in the acct listener, but no changes made.") }
        });
      });
    };



    this.setUpContractEnvironment = async (_web3) => {
      if (window.isSettingUpContracts) { return (console.log("Already in the middle of setUp...")) }
      window.isSettingUpContracts = true;

      const self = this;

      console.log("Setting up contracts")

      if (window.ethereum !== undefined) {
        if (this.props.globalAddr !== undefined) {
          await this.props.setMenuInfo({
            noAddrMenuBool: false,
            assetHolderMenuBool: false,
            assetClassHolderMenuBool: false,
            basicMenuBool: true,
            authorizedUserMenuBool: false,
            hasFetchedBalances: false,
          }, 'basic')
        }

        else if (this.props.globalAddr === "") {
          await this.params.setMenuInfo({
            noAddrMenuBool: true,
            assetHolderMenuBool: false,
            assetClassHolderMenuBool: false,
            basicMenuBool: false,
            authorizedUserMenuBool: false,
            hasFetchedBalances: false,
          }, 'noAddr')
        }

        let tempContracts = await buildContracts(_web3)
        await this.props.setContracts(tempContracts)

        if (this.props.globalAddr !== "") {
          let tempETHBal = await window.utils.getETHBalance(this.props.globalAddr, this.props.web3)
          this.props.setEthBalance(tempETHBal);
          this.setUpTokenVals(true)
        }


        console.log("bools...", this.props.holderBools.assetHolderBool, this.props.holderBools.assetClassHolderBool, this.props.holderBools.IDHolderBool)
        window.isSettingUpContracts = false;
        return this.setState({ runWatchDog: true })
      }

      else {
        window.isSettingUpContracts = true;
        await this.props.setContracts(buildContracts(_web3))
        window.isSettingUpContracts = false;
        return this.setState({ runWatchDog: true })
      }

    }

    //Component state declaration

    this.state = {
      IPFS: require("ipfs-mini"),
      addr: undefined,
      web3: null,
      menuInfo: { bools: {
        assetHolderMenuBool: false,
        assetHolderUserMenuBool: false,
        basicMenuBool: true,
        assetClassHolderMenuBool: false,
        noAddrMenuBool: false,
        authorizedUserMenuBool: false,
      }, route: "basic" },
      holderBools: {},
      nameArray: [],
      notAvailable: "N/A",
      assetClass: undefined,
      contractArray: [],
      isAuthUser: undefined,
      assetHolderBool: false,
      IDHolderBool: false,
      assetClassHolderBool: false,
      assetHolderMenuBool: false,
      assetHolderUserMenuBool: false,
      assetClassHolderMenuBool: false,
      basicMenuBool: false,
      authorizedUserMenuBool: false,
      hasFetchedBalances: false,
      isACAdmin: undefined,
      runWatchDog: false,
      buildReady: false,
      hasMounted: false,
      routeRequest: "basic",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    console.log(this.props.menuInfo);
    this.toggleMenu('basic')

    buildWindowUtils()
    window.isSettingUpContracts = false;
    window.hasLoadedAssets = false;
    window.location.href = '/#/';
    window.resetInfo = false;

    window.additionalElementArrays = {
      photo: [],
      text: [],
      name: ""
    }

    if (window.ethereum !== undefined) {
      
      this.props.setAssetTokenInfo({
        assetClass: null,
        idxHash: null,
        name: null,
        photos: null,
        text: null,
        status: null,
      })
      
      const ethereum = window.ethereum;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      this.setUpContractEnvironment(_web3)
      this.setState({ web3: _web3 });
      this.props.setGlobalWeb3(_web3);

      ethereum.enable()

      var _ipfs = new this.state.IPFS({
        host: "ipfs.infura.io",
        port: 5001,
        protocol: "https",
      });

      this.props.setIPFS(_ipfs);

      _web3.eth.getAccounts().then((e) => { this.setState({ addr: e[0] }); this.props.setGlobalAddr(e[0]) });
      window.addEventListener("accountListener", this.acctChanger());
      this.setState({ hasMounted: true })
    }
    else {

      var _web3 = require("web3");
      _web3 = new Web3("https://api.infura.io/v1/jsonrpc/kovan");
      this.setUpContractEnvironment(_web3)
      this.props.setGlobalWeb3(_web3);

      this.props.setMenuInfo({
        noAddrMenuBool: true,
        assetHolderMenuBool: false,
        assetClassHolderMenuBool: false,
        basicMenuBool: false,
        authorizedUserMenuBool: false,
        hasFetchedBalances: false,
      }, "noAddr")

      var _ipfs = new this.state.IPFS({
        host: "ipfs.infura.io",
        port: 5001,
        protocol: "https",
      });

      this.props.setIPFS(_ipfs);

      this.setState({ hasMounted: true })
    }

    this.hamburgerMenu = async () => {
      if (this.state.hamburgerMenu === undefined) {
        this.setState({
          hamburgerMenu: true,
          userMenu: undefined,
          settingsMenu: undefined

        })
      }
      else {
        this.setState({ hamburgerMenu: undefined })
      }
    }

    this.userMenu = async () => {
      if (this.state.userMenu === undefined) {
        this.setState({
          userMenu: true,
          settingsMenu: undefined
        })
      }
      else {
        this.setState({ userMenu: undefined })
      }
    }

    this.settingsMenu = async () => {
      if (this.state.settingsMenu === undefined) {
        this.setState({
          settingsMenu: true,
          userMenu: undefined
        })
      }
      else {
        this.setState({ settingsMenu: undefined })
      }
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

    if (this.state.menuInfo !== this.props.menuInfo || this.state.holderBools !== this.props.holderBools) { 
      this.setState({ menuInfo: this.props.menuInfo, holderBools: this.props.holderBools})
    } 

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    console.log("unmounting component");
    window.removeEventListener("accountListener", this.acctChanger());
  }

  render(

  ) {//render continuously produces an up-to-date stateful webpage  

    if (this.state.hasError === true) {
      return (<div><h1>)-:</h1><h2> An error occoured. Ensure you are connected to metamask and reload the page. Mobile support coming soon.</h2></div>)
    }

    return this.renderContent();
  }
}

const mapStateToProps = (state) => {

  return{
    globalAddr: state.globalAddr,
    web3: state.web3,
    assetClass: state.globalAssetClass,
    assets: state.globalAssets,
    assetTokenIDs: state.globalAssetTokenIDs,
    assetTokenInfo: state.globalAssetTokenInfo,
    globalBalances: state.globalBalances,
    contracts: state.globalContracts,
    costs: state.globalCosts,
    custodyType: state.globalCustodyType,
    ETHBalance: state.globalETHBalance,
    hasFetchedBalances: state.hasFetchedBalances,
    ipfs: state.globalIPFS,
    ipfsHashArray: state.globalIPFSHashArray,
    isACAdmin: state.isACAdmin,
    isAuthUser: state.isAuthUser,
    menuInfo: state.menuInfo,
    holderBools: state.holderBools
  }

}

const mapDispatchToProps = () => {
  return {
    setHasLoadedAssets,
    setHolderBools,
    setGlobalAddr,
    setGlobalWeb3,
    setIPFS,
    setContracts,
    setIsAdmin,
    setBalances,
    setMenuInfo,
    setIsACAdmin,
    setCustodyType,
    setEthBalance,
    setAssets,
    setAssetsToDefault,
    setAssetTokenIds,
    setIPFSHashArray,
    setHasAssets,
    setHasFetchedBals,
    setIPFS,
    setGlobalAssetClass,
    setAssetTokenInfo,
    setIsAuthUser,
    setCosts
  }
}



export default connect(mapStateToProps, mapDispatchToProps())(Main);
