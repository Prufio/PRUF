import React, { Component } from "react";
import { NavLink, } from "react-router-dom";

class BasicComponent extends Component {
    render() {
        return (<>
                <li>
                    <NavLink to="/verify-rights-holder">Verify</NavLink>
                </li>
                <li>
                    <NavLink to="/retrieve-record">Search</NavLink>
                </li>
                </>
        )
    }
}

export default BasicComponent;