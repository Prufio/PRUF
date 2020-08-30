import React, { Component } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";

class NonCustodialComponent extends Component {
    render() {
        return (
            <>
                <li>
                    <NavLink to="/new-record-NC">New</NavLink>
                </li>
                <li>
                    <NavLink to="/verify-rights-holder-NC">Verify</NavLink>
                </li>
                <li>
                    <NavLink to="/retrieve-record-NC">Search</NavLink>
                </li>
                <li>
                    <NavLink to="/transfer-asset-NC">Transfer</NavLink>
                </li>
                <li>
                    <NavLink to="/modify-record-status-NC">Status</NavLink>
                </li>
                <li>
                    <NavLink to="/decrement-counter-NC">Countdown</NavLink>
                </li>
                <li>
                    <NavLink to="/modify-description-NC">Description</NavLink>
                </li>
                <li>
                    <NavLink to="/add-note-NC">Add Note</NavLink>
                </li>
                <li>
                    <NavLink to="/export-asset-NC">Export</NavLink>
                </li>
                <li>
                    <NavLink to="/manage-escrow-NC">Escrow</NavLink>
                </li>
            </>
        )
    }
}

export default NonCustodialComponent; 