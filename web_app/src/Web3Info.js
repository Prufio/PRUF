import React from "react";
import Web3 from "web3";
import Inject from "./InjectWeb3";

class Web3Listener extends React.Component {

  constructor(props){
      super(props);

    this.state = {
      bulletproof_frontend_addr:
      "0x755414B4137F418810bd399E22da19ec9ddfdEaE",
      bulletproof_storage_addr:
      "0xC600741749E4c90Ad553E31DF5f2EA9fe51aB4e0",
      addr: "",
      frontend: 0,
      storage: 0

    }

  }

  render(){return(null)}

  componentDidMount() {
    let _addr = Inject('addr')
    this.setState({addr: _addr});
    this.setState({frontend: Inject('frontend')});
    this.setState({storage: Inject('storage')});
    console.log("vars: ", this.acct, this.bulletproof_storage_addr)
  }

}

export default Web3Listener;
