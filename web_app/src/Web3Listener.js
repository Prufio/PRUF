import { useState } from "react";
import Web3 from "web3";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";

function Web3Listener(request) {
  const bulletproof_frontend_addr =
    "0x4126B47eC123B211Bc8E8A4d1336FCA75aE3894B";
  const bulletproof_storage_addr =
   "0xCE08A984217CC11472f11d67faA7846ce33aEfc1";

  let web3 = require("web3");
  const ethereum = window.ethereum;
  web3 = new Web3(web3.givenProvider);
  var [addr, setAddr] = useState("");
  var _addr;
  const frontEnd_abi = returnFrontEndAbi();
  const storage_abi = returnStorageAbi();
  const frontend = new web3.eth.Contract(
    frontEnd_abi,
    bulletproof_frontend_addr
  );
  const storage = new web3.eth.Contract(
    storage_abi, 
    bulletproof_storage_addr
  );

  window.addEventListener("load", async () => {
    web3.eth.getAccounts().then((e) => setAddr(e[0]));

    if (web3.eth.getAccounts().then((e) => e === addr)) {
      console.log("Serving current metamask address at accounts[0]");
    }

    ethereum.on("accountsChanged", function(accounts) {
      console.log("trying to change active address");
      web3.eth.getAccounts().then((e) => setAddr(e[0]));
    });
  });

  if (request === "addr") {
    if(addr > 0){
      console.log("Value from addr request:", addr);
      return (addr);
    }

    else{
      console.log("Null value from addr request");
      return (null);
    }
    
  } else if (request === "web3") {
    return web3;
  } else if (request === "frontend") {
    return frontend;
  } else if (request === "storage") {
    return storage;
  }
}

export default Web3Listener;
