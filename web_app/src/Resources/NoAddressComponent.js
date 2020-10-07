import React, { Component } from "react";
import { NavLink } from "react-router-dom";
import NavDropdown from 'react-bootstrap/NavDropdown';
import Nav from 'react-bootstrap/Nav'
import "../index.css";
import {
    BrowserView,
    MobileView,
    isBrowser,
    isMobile
} from "react-device-detect";

class NoAddressComponent extends Component {
    render() {

        if (isMobile) {
            return (
                <Nav className="header">
                    <li>
                        <NavLink exact to="/">Home</NavLink>
                    </li>
                    <li>
                        <NavLink to="/retrieve-record-mobile">Search</NavLink>
                    </li>
                    <li>
                        <NavLink to="/verify-lite-mobile">Verify</NavLink>
                    </li>
                </Nav>
            )
        }
        else {
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
}

export default NoAddressComponent; 