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
import returnAbi from "./abi";
import returnSAbi from "./sAbi";
var address;


function testLog(toLog){
  console.log(toLog);
}

function newRecordPack(_asset_id, _rights_holder, _asset_class, _count_down, _asset_IPFS1, _cost){
  
  let web3 = require('web3');
  const ethereum = window.ethereum;
  web3 = new Web3(web3.givenProvider);
  var [addr, setAddr] = useState('');

  window.addEventListener('load', async () => {
  await ethereum.enable();
  web3.eth.getAccounts().then(e => setAddr(e[0]));
  address = addr;
  console.log("Serving address: ", addr)

  if (web3.eth.getAccounts().then(e => e === addr)) {
    console.log("Serving current metamask address at accounts[0]");
  }

  ethereum.on('accountsChanged', function (accounts) {
    console.log('trying to change active address');
    web3.eth.getAccounts().then(e => setAddr(e[0]));
  })
})

  let _addr = address;
  let web3 = require("web3");

  const bulletproof_frontend_addr =
    "0xD097ce9cC3f8402a7311c576c60f7CeE44baf711";

  const bulletproof_storage_addr = 
    "0x124B7F075b9b18aCd8Fb1C7C4c14A5EA959dDB82";

  web3 = new Web3(web3.givenProvider);
  var txHash;

  const myAbi = returnAbi();
  const sAbi = returnSAbi();
  const bulletproof = new web3.eth.Contract(myAbi, bulletproof_frontend_addr);
  const storage = new web3.eth.Contract(sAbi, bulletproof_storage_addr);

  console.log("Adding new asset...");
  console.log("Using data: ", _asset_id, _rights_holder, _asset_class, _count_down, _asset_IPFS1, _cost, _addr);
  
  if (_addr != "") {
  bulletproof.methods
    .$newRecord(_asset_id, _rights_holder, _asset_class, _count_down, _asset_IPFS1)
    .send({ from: _addr, value: web3.utils.toWei(_cost) })
    .then((_txHash) => txHash = _txHash).then(console.log(txHash));
  }

  else{
    alert("Invalid sender address... Check that MetaMask is connected");
  }

}

  function Main(){

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

export {newRecordPack};
export {testLog};
export default Main;

