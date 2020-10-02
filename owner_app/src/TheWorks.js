import React, { Component } from "react";
import Form from "react-bootstrap/Form";
import Col from "react-bootstrap/Col";
import Button from "react-bootstrap/Button";


class THEWORKS extends Component {
  constructor(props) {
    super(props);

    //State declaration.....................................................................................................

    this.state = {
      addr: "",
      lookupIPFS1: "",
      lookupIPFS2: "",
      hashPath: "",
      error: undefined,
      NRerror: undefined,
      result: null,
      RRresult: [0],
      
      costResult: {},
      costArray: [0],
      assetClass: undefined,
      countDownStart: "6000",
      countDown:"555",
      ipfs1: "a",
      txHash: "",

      status: "1",
      boolBuddy: false,

      type: "",
      manufacturer: "",
      model: "",
      serial: "",

      first: "a",
      middle: "a",
      surname: "a",
      id: "a",
      secret: "a",

      newFirst: "b",
      newMiddle: "b",
      newSurname: "b",
      newId: "b",
      newSecret: "b",

      txStatus: null,
    };
  }

  //component state-change events......................................................................................................

  componentDidMount() {//stuff to do when component mounts in window
    let idxSeed = String(Math.round(Math.random()*100000000));

    console.log("asset idx info: ", idxSeed);

    this.setState({type: idxSeed})
    this.setState({manufacturer: idxSeed})
    this.setState({model: idxSeed})
    this.setState({serial: idxSeed})

    
  }

  componentWillUnmount() {//stuff do do when component unmounts from the window

  }

  componentDidUpdate() {//stuff to do when state updates

  }
  render() {//render continuously produces an up-to-date stateful document  
    const self = this;

    const _retrieveRecord = () => {
        const self = this;
        var idxHash;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        console.log("idxHash", idxHash);
        console.log("addr: ", window.addr);
  
        window.contracts.STOR.methods
          .retrieveShortRecord(idxHash)
          .call({ from: window.addr }, function (_error, _result) {
            if (_error) { console.log(_error)
              self.setState({ error: _error });
              self.setState({ RRresult: 0 });
            } else {
              if (Object.values(_result)[2] === '0'){  self.setState({ status: 'No status set' });}
              else if (Object.values(_result)[2] === '1'){  self.setState({ status: 'Transferrable' });}
              else if (Object.values(_result)[2] === '2'){  self.setState({ status: 'Non-transferrable' });}
              else if (Object.values(_result)[2] === '3'){  self.setState({ status: 'ASSET REPORTED STOLEN' });}
              else if (Object.values(_result)[2] === '4'){  self.setState({ status: 'ASSET REPRTED LOST' });}
              else if (Object.values(_result)[2] === '5'){  self.setState({ status: 'Asset in transfer' });}
              else if (Object.values(_result)[2] === '6'){  self.setState({ status: 'In escrow (block.number locked)' });}
              else if (Object.values(_result)[2] === '7'){  self.setState({ status: 'P2P Transferrable' });}
              else if (Object.values(_result)[2] === '8'){  self.setState({ status: 'P2P Non-transferrable' });}
              else if (Object.values(_result)[2] === '9'){  self.setState({ status: 'ASSET REPORTED STOLEN (P2P)' });}
              else if (Object.values(_result)[2] === '10'){  self.setState({ status: 'ASSET REPORTED LOST (P2P)' });}
              else if (Object.values(_result)[2] === '11'){  self.setState({ status: 'In P2P transfer' });}
              else if (Object.values(_result)[2] === '12'){  self.setState({ status: 'In escrow (block.time locked)' });}
              else if (Object.values(_result)[2] === '20'){  self.setState({ status: 'Cusdodial escrow ended' });}
              else if (Object.values(_result)[2] === '21'){  self.setState({ status: 'P2P escrow ended' });}
              self.setState({ RRresult: Object.values(_result)})
              self.setState({ error: undefined });
          }});
      };

    const _setIPFS2 = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = window.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
  
        var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("addr: ", window.addr);
  
        window.contracts.APP.methods
          .$addIpfs2Note(idxHash, rgtHash, window.web3.utils.soliditySha3(this.state.ipfs1))
          .send({ from: window.addr, value: window.costs.createNoteCost })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ ANstats: "AN failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ ANstats: "AN success" });
            _retrieveRecord()
          });
  
        console.log(this.state.txHash);
      };

    const _updateDescription = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = window.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
        var _ipfs1 = window.web3.utils.soliditySha3("LETS GOOOOOOOO");
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", window.addr);
        console.log("new desc: ", _ipfs1);
  
        window.contracts.NP.methods
          ._modIpfs1(idxHash, rgtHash, _ipfs1)
          .send({ from: window.addr })
          .on("error", function (_error) {
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ UDstats: "UD failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ UDstats: "UD success" });
            _setIPFS2()
          });
  
        console.log(this.state.txHash);
      };

    const _decrementCounter = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = window.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", window.addr);
        console.log("CountDown amt: ", this.state.countDown);
  
        window.contracts.NP.methods
          ._decCounter(idxHash, rgtHash, this.state.countDown)
          .send({ from: window.addr })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ CDstats: "CD failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ CDstats: "CD success" });
            _updateDescription()
          });
  
        console.log(this.state.txHash);
      };

    const _forceModifyRecord = () => {
        var idxHash;
        var newRgtRaw;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        newRgtRaw = window.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var newRgtHash = window.web3.utils.soliditySha3(idxHash, newRgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", newRgtRaw);
        console.log("New rgtHash", newRgtHash);
        console.log("addr: ", window.addr);
  
        window.contracts.APP.methods
          .$forceModRecord(idxHash, newRgtHash)
          .send({ from: window.addr, value: window.costs.forceTransferCost })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ FMRstats: "FMR failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ FMRstats: "FMR success" });
            _decrementCounter()
          });
  
        console.log(this.state.txHash);
      };

    const _transferAsset = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = window.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        var newRgtRaw = window.web3.utils.soliditySha3(
          this.state.newFirst,
          this.state.newMiddle,
          this.state.newSurname,
          this.state.newId,
          this.state.newSecret
        );
        var newRgtHash = window.web3.utils.soliditySha3(idxHash, newRgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", window.addr);
  
        window.contracts.APP.methods
          .$transferAsset(idxHash, rgtHash, newRgtHash)
          .send({ from: window.addr, value: window.costs.transferAssetCost })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ TAstats: "TA failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ TAstats: "TA success" });
            _forceModifyRecord()
          });
        console.log(this.state.txHash);
      };

    const _modifyStatus = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = window.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("New rgtRaw", rgtRaw);
        console.log("New rgtHash", rgtHash);
        console.log("addr: ", window.addr);
  

        window.contracts.NP.methods
          ._modStatus(idxHash, rgtHash, this.state.status)
          .send({ from: window.addr })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ MSstats: "MS failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            this.setState({ txStatus: receipt.status });
            console.log(receipt.status);
            this.setState({ MSstats: "MS success" });
            _transferAsset()
          });
  
        console.log(this.state.txHash);
      };

    const _verify = () => {
        var idxHash;
        var rgtRaw;
        
        idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );
  
        rgtRaw = window.web3.utils.soliditySha3(
          this.state.first,
          this.state.middle,
          this.state.surname,
          this.state.id,
          this.state.secret
        );
        var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);
  
        console.log("idxHash", idxHash);
        console.log("addr: ", window.addr);
  
        window.contracts.STOR.methods
          ._verifyRightsHolder(idxHash, rgtHash)
          .call({ from: window.addr }, function (_error, _result) {
            if (_error) {
              self.setState({ error: _error });
              self.setState({ result: 0 });
            } else {
              self.setState({ result: _result });
              console.log("verify.call result: ", _result);
              self.setState({ error: undefined });
            }
          });
  
          window.contracts.STOR.methods
          .blockchainVerifyRightsHolder(idxHash, rgtHash)
          .send({ from: window.addr })
          .on("error", function (_error) {
            // self.setState({ NRerror: _error });
            self.setState({ txHash: Object.values(_error)[0].transactionHash });
            self.setState({ txStatus: false });
            self.setState({ VRHstats: "VRH failure" });
            console.log(Object.values(_error)[0].transactionHash);
          })
          .on("receipt", (receipt) => {
            this.setState({ txHash: receipt.transactionHash });
            console.log(this.state.txHash);
            this.setState({ VRHstats: "VRH success" });
            _modifyStatus()
          });
  
        console.log(this.state.result);
      };

    const _newRecord = () => {
      var idxHash;
      var rgtRaw;
      
      idxHash = window.web3.utils.soliditySha3(
          this.state.type,
          this.state.manufacturer,
          this.state.model,
          this.state.serial,
      );


      rgtRaw = window.web3.utils.soliditySha3(
        this.state.first,
        this.state.middle,
        this.state.surname,
        this.state.id,
        this.state.secret
      );

      var rgtHash = window.web3.utils.soliditySha3(idxHash, rgtRaw);

      console.log("idxHash", idxHash);
      console.log("New rgtRaw", rgtRaw);
      console.log("New rgtHash", rgtHash);
      console.log("addr: ", window.addr);
      console.log(window.assetClass);

      window.contracts.APP.methods
        .$newRecord(
          idxHash,
          rgtHash,
          window.assetClass,
          this.state.countDownStart,
          window.web3.utils.soliditySha3(this.state.ipfs1)
        )
        .send({ from: window.addr, value: window.costs.newRecordCost})
        .on("error", function (_error) {
          // self.setState({ NRerror: _error });
          self.setState({ txHash: Object.values(_error)[0].transactionHash });
          self.setState({ txStatus: false });
          self.setState({ NRstats: "NR failure" });
          console.log(Object.values(_error)[0].transactionHash);
        })
        .on("receipt", (receipt) => {
          this.setState({ txHash: receipt.transactionHash });
          this.setState({ txStatus: receipt.status });
          this.setState({ NRstats: "NR success" });

          _verify()
        });
    };

    const batchTest = () => {
        if(window.contracts.APP !== ""){
            _newRecord();
        }
        else{
        this.forceUpdate()}
    }

    return (
      <div>
          {window.addr === undefined && (
            <div className="Results">
              <h2>User address unreachable</h2>
              <h3>Please connect web3 provider.</h3>
            </div>
          )}{window.assetClass === undefined && (
            <div className="Results">
              <h2>No asset class selected.</h2>
              <h3>Please select asset class in home page to use forms.</h3>
            </div>
          )}
          {window.addr > 0 && window.assetClass > 0 &&(
            <div>
                
            <Form className="TWform">
                

                <div className="Results">
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.NRstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.VRHstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.MSstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.TAstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.FMRstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.CDstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.UDstats}
                    </Form.Group>
                </Form.Row>
                <Form.Row>
                <Form.Group as={Col} controlId="formGridType">
                    {this.state.ANstats}
                </Form.Group>
                </Form.Row>
                </div>
                <Form.Row>
                  <Form.Group >
                    <Button className="buttonDisplay"
                      variant="primary"
                      type="button"
                      size="lg"
                      onClick={batchTest}>
                      LETS GOOOOO
                    </Button>
                  </Form.Group>
                </Form.Row>
            </Form>
            

        </div>)}

        {this.state.RRresult[4] === "0" && (
          <div className="Results">No Asset Found for Given Data</div>
        )}

        {this.state.RRresult[4] > 0 && ( //conditional rendering
          <div className="Results">
            Asset Found!
            <br></br>
            Status:{this.state.status}
            <br></br>
            Mod Count:{this.state.RRresult[3]}
            <br></br>
            Asset Class :{this.state.RRresult[4]}
            <br></br>
            Count :{this.state.RRresult[5]} of {this.state.RRresult[6]}
            <br></br>
            IPFS Description :{this.state.RRresult[7]}
            <br></br>
            IPFS Note {this.state.RRresult[8]}
          </div>
        )}
        </div>
        
    )
  }
}

export default THEWORKS;
