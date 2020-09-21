import React, { Component } from "react";
import { NavLink, } from "react-router-dom";
import NavDropdown from 'react-bootstrap/NavDropdown';
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
                    <NavDropdown title="AC Data">
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/update-ac-name">Update AC Name</NavDropdown.Item>
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/get-ac-data">Retrieve AC Data</NavDropdown.Item>
                        <NavDropdown.Item id="header-dropdown" as={NavLink} to="/increase-ac-share">Increase Price Share</NavDropdown.Item>
                    </NavDropdown>
                </li>
            </Nav>
        )
    }
}

export default AdminComponent;