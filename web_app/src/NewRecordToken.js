import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function NewRecordToken() {
  var web3 = Web3Listener('web3');
  web3.eth.getAccounts().then((e) => setAddr(e[0]));
  var frontend = Web3Listener('frontend');

  var [addr, setAddr] = useState("");
  var [error, setError] = useState(null);
  
  var [AssetClass, setAssetClass] = useState("");
  var [CountDownStart, setCountDownStart] = useState("");
  var [Ipfs1, setIPFS1] = useState("");
  var [txHash, setTxHash] = useState("");

  var [type, setType] = useState("");
  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");

  var [id, setID] = useState("");

  const resetWeb3 = () => {
    web3.eth.getAccounts().then((e) => setAddr(e[0]));
  }

  const _newRecord = () => {
    var idxHash = web3.utils.soliditySha3(type, manufacturer, model, serial);
    
    console.log("idxHash", idxHash);
    console.log("Token ID", id);
    console.log("addr: ", addr);

    frontend.methods
      .$newRecord(idxHash, id, AssetClass, CountDownStart, Ipfs1)
      .send({ from: addr, value: web3.utils.toWei("0.01") }).on("error", function(error){setError(error);setTxHash(error.transactionHash);})
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
        //Stuff to do when tx confirms
      });
    console.log(txHash);
  };

  return (
    <div>
      {addr === undefined && (
          <div className="VRresults">
            <h2>WARNING!</h2>
            Injected web3 not connected to form!
          </div>
        )}
      {addr > 0 && (
        <form className="NRform">
        <h2>New Tokenized Asset</h2>
        Type:
        <input
          type="text"
          name="type"
          placeholder="Type"
          required
          onChange={(e) => setType(e.target.value)}
        />
        <br></br>
        Manufacturer:
        <input
          type="text"
          name="manufacturer"
          placeholder="Manufacturer"
          required
          onChange={(e) => setManufacturer(e.target.value)}
        />
        <br></br>
        Model:
        <input
          type="text"
          name="model"
          placeholder="Model"
          required
          onChange={(e) => setModel(e.target.value)}
        />
        <br></br>
        Serial:
        <input
          type="text"
          name="serial"
          placeholder="Serial Number"
          required
          onChange={(e) => setSerial(e.target.value)}
        />
        Token ID:
        <input
          type="text"
          name="id"
          placeholder="Token ID"
          required
          onChange={(e) => setID(e.target.value)}
        />
        <br></br>
        Asset Class:
        <input
          type="text"
          name="AssetClassField"
          placeholder="Asset Class"
          required
          onChange={(e) => setAssetClass(e.target.value)}
        />
        <br></br>
        Log Start Value:
        <input
          type="text"
          name="CountDownStartField"
          placeholder="Countdown Start"
          required
          onChange={(e) => setCountDownStart(e.target.value)}
        />
        <br></br>
        Description:
        <input
          type="text"
          name="IPFS1Field"
          placeholder="Description IPFS hash"
          required
          onChange={(e) => setIPFS1(web3.utils.soliditySha3(e.target.value))}
        />
        <br />
        <input type="button" value="New Token Record" onClick={_newRecord} />
        <br></br>
      </form>
      )}
      {txHash > 0 && ( //conditional rendering
        <div className="VRresults">
          {error != null && (
            <div>
              ERROR! Please check etherscan
            </div>
            )}
            {error === null && (<div> No Errors Reported </div>)}
          <br></br>
          <br></br>
          <a
            href={"https://kovan.etherscan.io/tx/" + txHash}
            target="_blank"
            rel="noopener noreferrer"
          >
            KOVAN Etherscan:{txHash}
          </a>
        </div>
      )}
    </div>
  );
}

export default NewRecordToken;
