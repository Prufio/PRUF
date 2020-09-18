import React, { Component } from "react";
import { NavLink, } from "react-router-dom";

class BasicComponent extends Component {
    render() {
        return (<>
                <li>
                    <NavLink to="/verify-lite">Verify</NavLink>
                </li>
                <li>
                    <NavLink to="/verify-rights-holder">Deep Verify</NavLink>
                </li>
                <li>
                    <NavLink to="/retrieve-record">Search</NavLink>
                </li>
                </>
        )
    }
}

export default BasicComponent;