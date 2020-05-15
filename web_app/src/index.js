import React from "react";
import ReactDOM from "react-dom";
import Main, {testLog} from "./Main";
import "./index.css";

testLog("first");
ReactDOM.render(
  <Main/>, 
  document.getElementById("root")
);