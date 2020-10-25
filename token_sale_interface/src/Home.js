import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import "./index.css";
import { ArrowRightCircle } from 'react-feather'
import { connect } from 'react-redux';

class Home extends Component {
  constructor(props) {
    super(props);

     

    this.getParticipants = async (file) => {
        const self = this;
        let participants = {addresses: [], numberOf: 0, referrals: {}};

        file.preventDefault()

        const reader = new FileReader(  )

        reader.onload = async (file) => { 
          const text = (file.target.result);
          const participantsRaw = JSON.parse(text);

          participants = participantsRaw;
          participants.numberOf = participants.addresses.length;

          console.log(text);
          console.log(participantsRaw);
          console.log("Participants: ", participants.addresses, " totaling at ", participants.numberOf, "participants.");
          console.log("Referrals: ", participants.referrals)
          console.log("Each will recieve ", this.state.airdropAmount, " tokens");
          this.setState({participants: participants, successfullyReadFile: true});
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
              console.log("Balance of address", participants.addresses[i],":",self.props.web3.utils.fromWei(_result))
            }
        });
      }
    }

    this.payAirdropParticipants = async () => {

      const self = this;
      const participants = this.state.participants;

      for(let i = 0; i < participants.addresses.length; i++){
        let airdropAmount;
        let referral = participants.referrals[participants.addresses[i]]

        if(referral > 0){airdropAmount = (this.state.airdropAmount + (1000*referral))}
        else{airdropAmount = this.state.airdropAmount}

        console.log(this.props.web3.utils.toWei(String(airdropAmount), 'ether'))
        //console.log("Sent address ", participants.addresses[i], this.state.airdropAmount, " tokens.")
        await window.UTIL_TKN.methods
        .mint(participants.addresses[i], this.props.web3.utils.toWei(String(airdropAmount), 'ether'))
        .send({ from: this.props.globalAddr })
        .on("error", function (_error) {
        console.log(_error)
        })
        .on("receipt", (receipt) => {
          console.log("dropped", airdropAmount, "tokens to address:", participants.addresses[i]);
          console.log("Which had",referral,"referrals");
          console.log("tx receipt: ", receipt);
        }); 
      }
      
    }
    
    this.state = {

      roundBalance: 0,
      participants: {},
      authAddr: undefined,
      addr: undefined,
      airdropAmount: 20000,
      successfullyReadFile: false

    };
  }

  componentDidMount() {

    if (this.props.globalAddr !== undefined) {
      console.log(this.props.globalAddr)
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
                  Choose Address File
                </Form.Label><br></br>
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

const mapStateToProps = (state) => {
  return{
    globalAddr: state.globalAddr,
    web3: state.web3
  }
}

const mapDispatchToProps = () => {
  return {

  }
}



export default connect(mapStateToProps, mapDispatchToProps())(Home);
