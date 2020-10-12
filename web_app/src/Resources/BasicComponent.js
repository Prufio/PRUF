import React, { Component } from "react";
import { NavLink, } from "react-router-dom";
import Nav from 'react-bootstrap/Nav'
import "../index.css";

class BasicComponent extends Component {
    render() {
        return (
        <Nav className="header">
        <li>
                    <NavLink exact to="/">Home</NavLink>
                </li>
                <li>
                    <NavLink exact to="asset-dashboard">Asset Dashboard</NavLink>
                </li>
                <li>
                    <NavLink to="/verify-lite">Verify Lite</NavLink>
                </li>
                <li>
                    <NavLink to="/verify-rights-holder">Deep Verify</NavLink>
                </li>
                <li>
                    <NavLink to="/retrieve-record">Search</NavLink>
                </li>
                </Nav>
        )
    }
}

export default BasicComponent;