import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function VerifyRightsholder() {
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");
  let web3 = Web3Listener("web3");

  var [idxHash, setidxHash] = useState("");
  var [rgtHash, setrgtHash] = useState("");
  var [newIpfs1, setNewIpfs1] = useState("");
  var [txHash, setTxHash] = useState("");
  const _modifyDescription = () => {
    console.log(   //------------------------------------------remove ------security
      "Sending data: ",
      idxHash,
      rgtHash,
      newIpfs1
    );

  let _rgtHash = (web3.utils.soliditySha3(idxHash, rgtHash));
    console.log('NewHash', _rgtHash);
    console.log('idxHash', idxHash);

    frontend.methods
      ._modIpfs1(idxHash, _rgtHash, newIpfs1)
      .send({ from: addr})
      .on("receipt", (receipt) => {
        setTxHash(receipt.transactionHash);
      });
    console.log(txHash);
  };

  return (
    <form className="VRform" onSubmit={_modifyDescription}>
      <h2>Verify</h2>
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
      <input type="radio" value="true" name="verify"/> on blockchain
      <br></br>
      <input type="submit" value="Verify" />
    </form>
  );
}

export default VerifyRightsholder;
