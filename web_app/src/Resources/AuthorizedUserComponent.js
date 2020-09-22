import React, { Component } from "react";
import { NavLink } from "react-router-dom";
import NavDropdown from 'react-bootstrap/NavDropdown';
import Nav from 'react-bootstrap/Nav'
import "../index.css";

class AuthorizedUserComponent extends Component {
    render() {
        return (
            <Nav className="header">
            <li>
                <NavLink exact to="/">Home</NavLink>
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
                <NavLink to="/import-asset">Import</NavLink>
            </li>
            <li>
                <NavLink to="/export-asset">Export</NavLink>
            </li>
            <li>
                <NavLink to="/manage-escrow">Escrow</NavLink>
            </li>
            <li>
                <NavDropdown title="Modify">
                    <NavDropdown.Item id="header-dropdown" as={NavLink} to="/modify-record-status">Modify Status</NavDropdown.Item>
                    <NavDropdown.Item id="header-dropdown" as={NavLink} to="/decrement-counter">Decrement Counter</NavDropdown.Item>
                    <NavDropdown.Item id="header-dropdown" as={NavLink} to="/modify-description">Modify Description</NavDropdown.Item>
                    <NavDropdown.Item id="header-dropdown" as={NavLink} to="/add-note">Add Note</NavDropdown.Item>
                    <NavDropdown.Item id="header-dropdown" as={NavLink} to="/force-modify-record">Modify Rightsholder</NavDropdown.Item>
                </NavDropdown>
            </li>
        </Nav>
        )
    }
}

export default AuthorizedUserComponent;