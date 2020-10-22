import React, { Component } from "react";
import { Route, NavLink, HashRouter } from "react-router-dom";
import Web3 from "web3";
import Home from "./Home";
import returnABI from "./returnABI";

class Main extends Component {
  constructor(props) {
    super(props);

    this.setUpUtilTkn = async (_web3) => {
      const abi = returnABI();
      const address = "0xbFd6B74D48BA9E7038eF7AC0DCf01F57fd38D65B";
      const UTIL_TKN = new _web3.eth.Contract(abi, address);
      window.UTIL_TKN = UTIL_TKN;
    }

    this.renderContent = () => {
      return (
        <div>
          <HashRouter>
          

            <div className="imageForm">
              <button
                className="imageButton"
                title="Back to Home!"
              >
                <img
                  className="downSizeLogo"
                  src={require("./Resources/pruf ar long.png")}
                  alt="Pruf Logo" />
              </button>
            </div>
            <div>
              <div className="BannerForm">
                <div className="currentMenuOption">
                  <div>
                  </div>
                </div>
                <ul className="header">
                  {window._contracts !== undefined && (
                    <nav>

                    </nav>
                  )}
                </ul>
              </div>
            </div>
            <div className="pageForm">
              <style type="text/css">
                {`
                      .btn-primary {
                        background-color: #00a8ff;
                        color: white;
                      }
                      .btn-primary:hover {
                        background-color: #23b6ff;
                        color: white;
                      }
                      .btn-primary:focus {
                        background: #00a8ff;
                      }
                      .btn-primary:active {
                        background: #00a8ff;
                      }

                      .btn-etherscan {
                        background-color: transparent;
                        color: white;
                        margin-top: -0.5rem;
                        // margin-right: 37rem;
                        font-size: 1.5rem;
                      }
                      .btn-etherscan:hover {
                        background-color: transparent;
                        color: #00a8ff;
                      }
                      .btn-etherscan:focus {
                        background-color: transparent;
                      }
                      .btn-etherscan:active {
                        background-color: transparent;
                        border: transparent;
                      }

                      .btn-assetDashboard {
                        background-color: transparent;
                        color: white;
                        margin-top: -0.5rem;
                        // margin-right: 37rem;
                        font-size: 1.6rem;
                        width: 5rem;
                      }
                      .btn-assetDashboard:hover {
                        background-color: transparent;
                        color: #00a8ff;
                      }
                      .btn-assetDashboard:focus {
                        background-color: transparent;
                      }
                      .btn-assetDashboard:active {
                        background-color: transparent;
                        border: transparent;
                      }

                      .btn {
                        color: white;
                      }

                      .btn-toggle {
                        background: #002a40;
                        color: #fff;
                        height: 3rem;
                        width: 17.3rem;
                        margin-top: -0.2rem;
                        border-radius: 0;
                        font-weight: bold;
                        font-size: 1.4rem;
                      }
                      btn-toggle:hover {
                        background: #23b6ff;
                        color: #fff;
                      }
                      .btn-toggle:focus {
                        background: #23b6ff;
                        color: #fff;
                      }
                      .btn-toggle:active {
                        background: #23b6ff;
                        color: #fff;
                      }
                   `}
              </style>
              <div>
                <Route exact path="/" component={Home} />
              </div>
            </div>
            <NavLink to="/">
            </NavLink>
          </HashRouter>
        

        </div >
      );
    }

    this.acctChanger = async () => {//Handle an address change, update state accordingly
      const ethereum = window.ethereum;
      const self = this;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      window.web3 = _web3;
      ethereum.on("accountsChanged", function (accounts) {
        _web3.eth.getAccounts().then((e) => {
          if (window.addr !== e[0]) {
            window.addr = e[0];
            self.setState({ addr: e[0] });
            console.log("///////in acctChanger////////");
          }
          else { console.log("Something bit in the acct listener, but no changes made.") }
        });
      });
    };
  

    //Component state declaration

    this.state = {
      addr: "",
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
      const ethereum = window.ethereum;
      var _web3 = require("web3");
      _web3 = new Web3(_web3.givenProvider);
      this.setUpUtilTkn(_web3)
      ethereum.enable();

      _web3.eth.getAccounts().then((e) => { this.setState({ addr: e[0] }); window.addr = e[0] });
      window.addEventListener("accountListener", this.acctChanger());
  }

  componentDidCatch(error, info) {
    console.log(info.componentStack)
  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  componentDidUpdate() {//stuff to do when state updates

  }

  componentWillUnmount() {//stuff do do when component unmounts from the window
    console.log("unmounting component");
    window.removeEventListener("accountListener", this.acctChanger());
    //window.removeEventListener("authLevelListener", this.updateAuthLevel());
    //window.removeEventListener("ownerGetter", this.getOwner());
  }

  render(

  ) {//render continuously produces an up-to-date stateful webpage  

    if (this.state.hasError === true) {
      return (<div><h1>)-:</h1><h2> An error occoured. Ensure you are connected to metamask and reload the page. Mobile support coming soon.</h2></div>)
    }

    return this.renderContent();
  }
}

export default Main;
