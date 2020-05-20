import React, { useState } from "react";
import { keccak256 } from "js-sha3";
import Web3Listener from "./Web3Listener";

function DecrementCounter() {
  let addr = Web3Listener("addr");
  let bulletproof = Web3Listener("bulletproof");
  let web3 = Web3Listener("web3");

  var [idxHash, setidxHash] = useState("");
  var [rgtHash, setrgtHash] = useState("");
  var [countdownAmount, setCountdownAmount] = useState("");
  var [txHash, setTxHash] = useState("");
  const _decrementCounter = () => {
    console.log(
      //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      rgtHash,
      countdownAmount
    );
  
  let _rgtHash = web3.utils.soliditySha3(idxHash, rgtHash);
    console.log("NewHash", _rgtHash);
    console.log("idxHash", idxHash);

    bulletproof.methods
      ._decCounter(idxHash, _rgtHash, countdownAmount)
      .send({ from: addr })
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="DCform" onSubmit={_decrementCounter}>
      <h2>Countdown</h2>
      Asset ID:
      <input
        type="text"
        name="idxHashField"
        placeholder="Asset ID"
        required
        onChange={(e) => setidxHash("0x" + keccak256(e.target.value))}
      />
      <br></br>
      Rights Holder:
      <input
        type="text"
        name="rgtHashField"
        placeholder="Rights Holder"
        required
        onChange={(e) => setrgtHash("0x" + keccak256(e.target.value))}
      />
      <br></br>
      Countdown Amount
      <input
        type="text"
        name="CountdownAmountForm"
        placeholder="Countdown Amount"
        required
        onChange={(e) => setCountdownAmount(e.target.value)}
      />
      <input type="submit" value="Countdown" />
    </form>
  );
}

export default DecrementCounter;
