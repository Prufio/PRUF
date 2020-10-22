import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import "./index.css";
import { ArrowRightCircle } from 'react-feather'

class Home extends Component {
  constructor(props) {
    super(props);

    this.getParticipants = async (file) => {
        const self = this;
        let participants = {addresses: [], numberOf: 0};

        file.preventDefault()

        const reader = new FileReader(  )

        reader.onload = async (file) => { 
          const text = (file.target.result)
          const participantsRaw = JSON.parse(text)
          for(let i = 0; i < Object.values(participantsRaw).length; i++){
            participants.numberOf++;
            participants.addresses.push(Object.values(participantsRaw)[i])
          }
          console.log(text)
          console.log(participantsRaw)
          console.log("Participants: ", participants.addresses, " totaling at ", participants.numberOf, "participants.")
          const airdropAmount = this.state.roundBalance/participants.numberOf;
          console.log("Each will recieve ", airdropAmount, " tokens")
          this.setState({airdropAmount: airdropAmount, participants: participants, successfullyReadFile: true})
        };

        if(file.target.files[0] !== undefined){
          reader.readAsText(file.target.files[0])
        }


        
    }

    this.getTokenBalances = async () => {
      const self = this;
      const participants = this.state.participants;
      for(let i = 0; i < participants.addresses.length; i++){
        //console.log("Sent address ", participants.addresses[i], this.state.airdropAmount, " tokens.")
        await window.UTIL_TKN.methods
        .balanceOf(participants.addresses[i])
          .call((_error, _result) => {
            if (_error) { console.log("Error: ", _error) }
            else {
              console.log("Balance of address", participants.addresses[i],":",window.web3.utils.fromWei(_result))
            }
        }); 
      }
    }

    this.payAirdropParticipants = async () => {
      const self = this;
      const participants = this.state.participants;

      for(let i = 0; i < participants.addresses.length; i++){
        console.log(window.web3.utils.toWei(String(this.state.airdropAmount), 'ether'))
        //console.log("Sent address ", participants.addresses[i], this.state.airdropAmount, " tokens.")
        await window.UTIL_TKN.methods
        .mint(participants.addresses[i], window.web3.utils.toWei(String(this.state.airdropAmount), 'ether'))
        .send({ from: window.addr })
        .on("error", function (_error) {
          self.setState({ error: _error });
          self.setState({ result: _error.transactionHash });
        })
        .on("receipt", (receipt) => {
          console.log("dropped", this.state.airdropAmount, "tokens to address:", participants.addresses[i]);
          console.log("tx receipt: ", receipt);
        }); 
      }
      
    }
    
    this.state = {
      roundBalance: 20000000,
      participants: {},
      authAddr: undefined,
      addr: undefined,
      airdropAmount: 0,
      successfullyReadFile: false
    };
  }

  componentDidMount() {
    if (window.addr !== undefined) {
      this.setState({ addr: window.addr })
    }
    
    

  }

  componentDidUpdate() {

  }

  static getDerivedStateFromError(error) {
    // Update state so the next render will show the fallback UI.
    return { hasError: true };
  }

  render() {

    return (
      <div>
        <div className="home">
          <img className="prufARCroppedForm" src={require("./Resources/Pruf AR (2).png")} alt="Pruf Logo Home" />
          <br></br>
            <div>
            {!this.state.successfullyReadFile && (
              <Form.Group as={Col} controlId="formGridContractName">
                <Form.Label className="formFont">
                  Choose Address File :
                </Form.Label>
                <input type="file" onChange={(e) => this.getParticipants(e)} />
              </Form.Group>
            )}
              
              {this.state.successfullyReadFile && (
                <>
                <Form.Row>
                <div> <h4>Get balances</h4>
                  <div className="submitButton-content">
                    <ArrowRightCircle
                      onClick={() => { this.getTokenBalances() }}
                    />
                  </div>
                </div>
              </Form.Row>
              <Form.Row>
              <div> <h4>Airdrop Tokens</h4> 
                <div className="submitButton-content">
                  <ArrowRightCircle
                    onClick={() => { this.payAirdropParticipants() }}
                  />
                </div>
              </div>
            </Form.Row>
            </>
              )}
              
            </div>
        </div>
      </div>
    );
  }
}

export default Home;
