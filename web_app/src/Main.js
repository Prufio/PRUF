import React, { useState } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from 'web3';

import Home from "./Home";
import AddNote from "./AddNote";
import DecrementCounter from "./DecrementCounter";
import ForceModifyRecord from "./ForceModifyRecord";
import ModifyDescription from "./ModifyDescription";
import ModifyRecordStatus from "./ModifyRecordStatus";
import NewRecord from "./NewRecord";
import RetrieveRecord from "./RetrieveRecord";
import TransferAsset from "./TransferAsset";
import returnAbi from './abi';
import returnSAbi from './sAbi';
import Web3 from 'web3';


function testLog(toLog){
  console.log(toLog);
}

var senderAddress;

// class Main extends Component {
//   render() {
  function Main(){

    let web3 = require('web3');
      const ethereum = window.ethereum;
      web3 = new Web3(web3.givenProvider);
      var [addr, setAddr] = useState('');

    window.addEventListener('load', async () => {
      await ethereum.enable();
      web3.eth.getAccounts().then(e => setAddr(e[0]));
    
      if (web3.eth.getAccounts().then(e => e === addr)) {
        console.log("Serving current metamask address at accounts[0]");
        senderAddress = addr;
      }
    
      ethereum.on('accountsChanged', function (accounts) {
        console.log('trying to change active address');
        web3.eth.getAccounts().then(e => setAddr(e[0]));
      })
    })

    testLog ("hello");
    return (
      <HashRouter>
        <div>
            <img src={require("./BP Logo.png")} alt="Bulletproof Logo" />
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
              <Route path="/modify-description" component={ModifyDescription} />
              <Route path="/add-note" component={AddNote} />
            </div>
          </div>
        </div>
      </HashRouter>
    );
  }
//}
export {senderAddress};
export {testLog};
export default Main;
export default App;
