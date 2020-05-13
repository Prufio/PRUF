import React, { Component } from "react";
import {
  Route,
  NavLink,
  HashRouter
} from "react-router-dom";
import Home from "./Home";
import AddNote from "./AddNote";
import DecrementCounter from "./DecrementCounter";
import ForceModifyRecord from "./ForceModifyRecord";
import ModifyNote from "./ModifyNote";
import ModifyRecordStatus from "./ModifyRecordStatus";
import NewRecord from "./NewRecord";
import RetrieveRecord from "./RetrieveRecord";
import TransferAsset from "./TransferAsset";
 
class Main extends Component {
  render() {
    return (
    <HashRouter>
        <div>
          <h1><img src={require('./BP Logo.png')} /></h1>
          <ul className="header">
            <li><NavLink exact to="/">Home</NavLink></li>
            <li><NavLink to="/new-record">New Record</NavLink></li>
            <li><NavLink to="/retrieve-record">Retrieve Record</NavLink></li>
            <li><NavLink to="/force-modify-record">Force Modify Record</NavLink></li>
            <li><NavLink to="/transfer-asset">Transfer Asset</NavLink></li>
            <li><NavLink to="/modify-record-status">Modify Record Status</NavLink></li>
            <li><NavLink to="/decrement-counter">Dec Counter</NavLink></li>
            <li><NavLink to="/modify-note">Modify Note</NavLink></li>
            <li><NavLink to="/add-note">Add Note</NavLink></li>
          </ul>
          <div className="content">
            <Route exact path="/" component={Home}/>
            <Route path="/new-record" component={NewRecord}/>
            <Route path="/retrieve-record" component={RetrieveRecord}/>
            <Route path="/force-modify-record" component={ForceModifyRecord}/>
            <Route path="/transfer-asset" component={TransferAsset}/>
            <Route path="/modify-record-status" component={ModifyRecordStatus}/>
            <Route path="/decrement-counter" component={DecrementCounter}/>
            <Route path="/modify-note" component={ModifyNote}/>
            <Route path="/add-note" component={AddNote}/>
          </div>
        </div>
    </HashRouter>
    );
  }
}
 
export default Main;