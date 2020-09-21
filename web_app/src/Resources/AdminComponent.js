import React, { Component } from "react";
import { NavLink, } from "react-router-dom";
import Nav from 'react-bootstrap/Nav'
import "../index.css";

class AdminComponent extends Component {
    render() {
        return (
        <Nav className="header">
        <li>
                <NavLink exact to="/">Home</NavLink>
            </li>
            <li>
                <NavLink to="/add-user">Add User</NavLink>
            </li>
            <li>
                <NavLink to="/set-costs">Set Costs</NavLink>
            </li>
            <li>
                <NavLink to="/enable-contract">Enable Contract</NavLink>
            </li>
            <li>
                <NavLink to="/update-ac-name">Update Name</NavLink>
            </li>
            <li>
                <NavLink to="/get-ac-data">Get AC Data</NavLink>
            </li>
        </Nav>
        )
    }
}

export default AdminComponent;