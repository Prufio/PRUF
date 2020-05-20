import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function NewRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");

  var [idxHash, setidxHash] = useState("");
  var [rgtHash, setrgtHash] = useState("");
  var [AssetClass, setAssetClass] = useState("");
  var [CountDownStart, setCountDownStart] = useState("");
  var [Ipfs1, setIPFS1] = useState("");
  var [txHash, setTxHash] = useState("");

  const _newRecord = () => {
    console.log(
      //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      rgtHash,
      AssetClass,
      CountDownStart,
      Ipfs1
    );
    
  let _rgtHash = (web3.utils.soliditySha3(idxHash, rgtHash));
    console.log('NewHash', _rgtHash);
    console.log('idxHash', idxHash);

    frontend.methods
      .$newRecord(idxHash, _rgtHash, AssetClass, CountDownStart, Ipfs1)
      .send({ from: addr, value: web3.utils.toWei("0.01") })

      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="NRform" onSubmit={_newRecord}>
      <h2>New Asset</h2>
      Asset ID:
      <input
        type="text"
        name="idxHashField"
        placeholder="Asset ID"
        required
        onChange={(e) => setidxHash(web3.utils.keccak256(e.target.value))}
      />
      <br></br>
      Rights Holder:
      <input
        type="text"
        name="rgtHashField"
        placeholder="Rights Holder"
        required
        onChange={(e) => setrgtHash(web3.utils.keccak256(e.target.value))}
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
      <input type="submit" value="New Record" />
    </form>
  );
}

export default NewRecord;
