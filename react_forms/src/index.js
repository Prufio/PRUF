import React, {useState} from "react";
import ReactDOM from "react-dom";
import "./index.css";

import Transfer from "./transfer";
import NewRecord from "./new_record";


function MyForm() {
    return (
      <NewRecord/>
    );
}

ReactDOM.render(<MyForm />, document.getElementById('root'));
