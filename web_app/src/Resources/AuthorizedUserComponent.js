import React, { Component } from "react";
import { NavLink, } from "react-router-dom";

class AuthorizedUserComponent extends Component {
    render() {
        return (
            <>
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
                    <NavLink to="/export-asset">Export</NavLink>
                </li>
                <li>
                    <NavLink to="/force-transfer-asset">Force Transfer</NavLink>
                </li>
                <li>
                    <NavLink to="/import-asset">Import</NavLink>
                </li>
                <li>
                    <NavLink to="/manage-escrow">Escrow</NavLink>
                </li>
            </>
        )
    }
}

export default AuthorizedUserComponent;