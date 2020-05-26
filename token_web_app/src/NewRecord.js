import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function NewRecordToken() {
  var web3 = Web3Listener('web3');
  web3.eth.getAccounts().then((e) => setAddr(e[0]));
  var storage = Web3Listener('storage');

  var [addr, setAddr] = useState("");
  var [error, setError] = useState(null);

  var [assetClass, setAssetClass] = useState("");
  var [countDownStart, setCountDownStart] = useState("");
  var [iPfs1, setIPFS1] = useState("");
  var [txHash, setTxHash] = useState("");

  var [manufacturer, setManufacturer] = useState("");
  var [model, setModel] = useState("");
  var [serial, setSerial] = useState("");

  var [id, setID] = useState("");

  const resetWeb3 = () => {
    web3.eth.getAccounts().then((e) => setAddr(e[0]));
  }

  const _newRecord = () => {
    var idxHash = web3.utils.soliditySha3(manufacturer, model, serial);
    var userHash = web3.utils.soliditySha3(addr);
    console.log("idxHash", idxHash);
    console.log("Token ID", id);
    console.log("addr: ", addr);
    console.log('userHash:', userHash);

    storage.methods
      .newRecord(userHash, idxHash, id, assetClass, countDownStart, iPfs1)
      .send({ from: addr, value: web3.utils.toWei("0.00") }).on("error", function(error){setError(error);setTxHash(error.transactionHash);})
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
        Asset Manufacturer:
        <input
          type="text"
          name="manufacturer"
          placeholder="Manufacturer"
          required
          onChange={(e) => setManufacturer(e.target.value)}
        />
        <br></br>
        Asset Model:
        <input
          type="text"
          name="model"
          placeholder="Model Designation"
          required
          onChange={(e) => setModel(e.target.value)}
        />
        <br></br>
        Asset Serial:
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
