import React, { Component } from "react";
import { NavLink } from "react-router-dom";
import NavDropdown from 'react-bootstrap/NavDropdown';
import Nav from 'react-bootstrap/Nav'
import "../index.css";

class NonCustodialUserComponent extends Component {
    render() {
        return (
            <Nav className="header">
                <li>
                    <NavLink exact to="/">Home</NavLink>
                </li>
                <li>
                    <NavLink exact to="check-in">Asset Dashboard</NavLink>
                </li>
                <li>
                    <NavLink to="/verify-rights-holder">Verify</NavLink>
                </li>
                <li>
                    <NavLink to="/retrieve-record">Search</NavLink>
                </li>
                <li>
                    <NavLink to="/transfer-asset-NC">Transfer</NavLink>
                </li>
                <li>
                    <NavLink to="/import-asset-NC">Import</NavLink>
                </li>
                <li>
                    <NavLink to="/export-asset-NC">Export</NavLink>
                </li>
                <li>
                    <NavLink to="/manage-escrow-NC">Escrow</NavLink>
                </li>
                <li>
                    <NavDropdown title="Modify">
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/modify-record-status-NC">Modify Status</NavDropdown.Item>
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/decrement-counter-NC">Decrement Counter</NavDropdown.Item>
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/modify-description-NC">Modify Description</NavDropdown.Item>
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/add-note-NC">Add Note</NavDropdown.Item>
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/force-modify-record-NC">Modify Rightsholder</NavDropdown.Item>
                    </NavDropdown>
                </li>
            </Nav>
        )
    }
}

export default NonCustodialUserComponent; 