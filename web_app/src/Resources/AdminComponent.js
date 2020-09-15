import React, { Component } from "react";
import { NavLink, } from "react-router-dom";

class AdminComponent extends Component {
    render() {
        return (<>
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
        </>
        )
    }
}

export default AdminComponent;