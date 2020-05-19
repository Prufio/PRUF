import React from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3Listener from './Web3Listener';
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

function Main () {
    return (
      <HashRouter>
        <div>
            <img src={require("./BP Logo.png")} alt="Bulletproof Logo"/>
            Currently serving: {Web3Listener('addr')}
                {/* {ethereum && <p>currently serving: {addr} </p>}
                {!ethereum && <p>Metamask not currently installed</p>} */}
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
              <Route path="/verify-rights-holder" component={VerifyRightsholder} />
            </div>
          </div>
        </div>
      </HashRouter>
    );
}

export default Main;
