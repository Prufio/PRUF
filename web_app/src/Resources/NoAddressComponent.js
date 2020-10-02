import React, { Component } from "react";
import { NavLink } from "react-router-dom";
import NavDropdown from 'react-bootstrap/NavDropdown';
import Nav from 'react-bootstrap/Nav'
import "../index.css";

class NoAddressComponent extends Component {
    render() {
        return (
            <Nav className="header">
                <li>
                    <NavLink exact to="/">Home</NavLink>
                </li>
                <li>
                    <NavLink to="/retrieve-record">Search</NavLink>
                </li>
                <li>
                    <NavLink to="/verify-lite">Verify</NavLink>
                </li>
            </Nav>
        )
    }
}

export default NoAddressComponent; 