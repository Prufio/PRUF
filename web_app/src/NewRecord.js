import React, { useState } from "react";
import Web3Listener from "./Web3Listener";

function NewRecord() {
  let web3 = Web3Listener("web3");
  let addr = Web3Listener("addr");
  let frontend = Web3Listener("frontend");

  var [idxHash, setIdxHash] = useState("");
  var [rgtHash, setRgtHash] = useState("");
  var [AssetClass, setAssetClass] = useState("");
  var [CountDownStart, setCountDownStart] = useState("");
  var [Ipfs1, setIPFS1] = useState("");
  var [txHash, setTxHash] = useState("");

    const [_index, _setIndex] = useState({
      type:'',
      manufacturer:'',
      model:'',
      serial:''
    })
    
    const [_rights, _setRights] = useState({
      first:'',
      middle:'',
      surname:'',
      id:'',
      password:''
    })

  const indexDoctor = (e) => {
      _setIndex({
        ..._index,
        [e.target.name]: e.target.value
      });
      console.log(_index.type, _index.manufacturer, _index.model, _index.serial);
      setIdxHash(web3.utils.soliditySha3(_index.type, _index.manufacturer, _index.model, _index.serial))
  }

  const rightsDoctor = (e) => {
      _setRights({
        ..._rights,
        [e.target.name]: e.target.value
      });
      console.log(_rights.first, _rights.middle, _rights.surname, _rights.id, _rights.password);
      setRgtHash(web3.utils.soliditySha3(_rights.first, _rights.middle, _rights.surname, _rights.id, _rights.password));
  }

  const _newRecord = () => {
    setRgtHash(web3.utils.soliditySha3(idxHash, rgtHash));
    console.log(_index.type, _index.manufacturer, _index.model, _index.serial);
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
    <form className="NRform">
      <h2>New Asset</h2>
      Type:
      <input
        type="text"
        name="type"
        placeholder="Type"
        required
<<<<<<< Updated upstream
        onChange={(e) => setidxHash(web3.utils.keccak256(e.target.value))}
=======
        onChange={(e) => indexDoctor(e)}
>>>>>>> Stashed changes
      />
      <br></br>
      Manufacturer:
      <input
        type="text"
        name="manufacturer"
        placeholder="Manufacturer"
        required
<<<<<<< Updated upstream
        onChange={(e) => setrgtHash(web3.utils.keccak256(e.target.value))}
=======
        onChange={(e) => indexDoctor(e)}
      />
      <br></br>
      Model:
      <input
        type="text"
        name="model"
        placeholder="Model"
        required
        onChange={(e) => indexDoctor(e)}
      />
      <br></br>
      Serial:
      <input
        type="text"
        name="serial"
        placeholder="Serial Number"
        required
        onChange={(e) => indexDoctor(e)}
      />
      <br></br>
      First Name:
      <input
        type="text"
        name="first"
        placeholder="first name"
        required
        onChange={(e) => rightsDoctor(e)}
      />
      <br></br>
      Middle Name:
      <input
        type="text"
        name="middle"
        placeholder="middle name"
        required
        onChange={(e) => rightsDoctor(e)}
      />
      <br></br>
      Surname:
      <input
        type="text"
        name="surname"
        placeholder="surname"
        required
        onChange={(e) => rightsDoctor(e)}
      />
      <br></br>
      ID:
      <input
        type="text"
        name="id"
        placeholder="id"
        required
        onChange={(e) => rightsDoctor(e)}
      />
      <br></br>
      Password:
      <input
        type="text"
        name="passkey"
        placeholder="Password"
        required
        onChange={(e) => rightsDoctor(e)}
>>>>>>> Stashed changes
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
      {idxHash}
      <input type="button" value="New Record" onClick={_newRecord} />
    </form>
  );
}

export default NewRecord;

