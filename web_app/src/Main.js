import React, { Component } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Home from "./Home";
import AddNote from "./AddNote";
import DecrementCounter from "./DecrementCounter";
import ForceModifyRecord from "./ForceModifyRecord";
import ModifyDescription from "./ModifyDescription";
import ModifyRecordStatus from "./ModifyRecordStatus";
import NewRecord from "./NewRecord";
import RetrieveRecord from "./RetrieveRecord";
import TransferAsset from "./TransferAsset";

class Main extends Component {
  render() {
    return (
      <HashRouter>
        <div>
          <h1>
            <img src={require("./BP Logo.png") } alt="Bulletproof Logo"/>
          </h1>
          <ul className="header">
            <li>
              <NavLink exact to="/">
                Home
              </NavLink>
            </li>
            <li>
              <NavLink to="/new-record">New Asset</NavLink>
            </li>
            <li>
              <NavLink to="/retrieve-record">Look-up Asset</NavLink>
            </li>
            <li>
              <NavLink to="/transfer-asset">Transfer Asset</NavLink>
            </li>
            <li>
              <NavLink to="/modify-record-status">Asset Status</NavLink>
            </li>
            <li>
              <NavLink to="/decrement-counter">Countdown</NavLink>
            </li>
            <li>
              <NavLink to="/modify-description">Description</NavLink>
            </li>
            <li>
              <NavLink to="/add-note">Note</NavLink>
            </li>
            <li>
              <NavLink to="/force-modify-record">Force Modify Asset</NavLink>
            </li>
          </ul>
          <div className="content">
            <Route exact path="/" component={Home} />
            <Route path="/new-record" component={NewRecord} />
            <Route path="/retrieve-record" component={RetrieveRecord} />
            <Route path="/force-modify-record" component={ForceModifyRecord} />
            <Route path="/transfer-asset" component={TransferAsset} />
            <Route
              path="/modify-record-status" component={ModifyRecordStatus}
            />
            <Route path="/decrement-counter" component={DecrementCounter} />
            <Route path="/modify-description" component={ModifyDescription} />
            <Route path="/add-note" component={AddNote} />
          </div>
        </div>
      </HashRouter>
    );
  }
}

export default Main;
