import React, {Component } from "react";
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

class Main extends Component {

  constructor(props){
    super(props);

    this.acctChanger = async () => {
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
        ethereum.on("accountsChanged", function(accounts) {
        _web3.eth.getAccounts().then((e) => self.setState({addr: e[0]}));
      });
      }
  
      //Component state declaration
  
      this.state = {
        addr: undefined,
        web3: null,
      }
  
    }

    componentDidMount() {
      console.log("component mounted")
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      this.setState({web3: _web3});
      _web3.eth.getAccounts().then((e) => this.setState({addr: e[0]}));
      document.addEventListener("accountListener", this.acctChanger());
    }

    componentWillUnmount() { 
      console.log("unmounting component")
      document.removeEventListener("accountListener", this.acctChanger())
  }

    render(){
      return (
        <HashRouter>
          <div>
            <img src={require("./BP Logo.png")} alt="Bulletproof Logo" />
            <br></br>
            <div>
                {this.state.addr > 0 && (<div className="banner">Currently serving: {this.state.addr}</div> )}
                {this.state.addr === undefined && (<div className="banner">Currently serving: NOBODY! Log into web3 provider!</div>)}
            </div>
            <br></br>
            <div className="page">
              <ul className="header">
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
              </ul>
              <div className="content">
                <Route exact path="/" component={Home} />
                <Route path="/new-record" component={NewRecord} />
                <Route path="/retrieve-record" component={RetrieveRecord} />
                <Route path="/force-modify-record" component={ForceModifyRecord} />
                <Route path="/transfer-asset" component={TransferAsset} />
                <Route
                  path="/modify-record-status"
                  component={ModifyRecordStatus}
                />
                <Route path="/decrement-counter" component={DecrementCounter} />
                <Route path="/modify-description" component={ModifyDescription} />
                <Route path="/add-note" component={AddNote} />
                <Route
                  path="/verify-rights-holder"
                  component={VerifyRightsholder}
                />
              </div>
            </div>
          </div>
        </HashRouter>
      )}
}

export default Main;
