import { useState } from "react";
import Web3 from "web3";
import returnStorageAbi from "./stor_abi";
import returnFrontEndAbi from "./front_abi";

function Web3Listener(request) {
  const bulletproof_frontend_addr =
    "0x2E70fB5908C6541d13Ac356D0C1AEc4C59fb6F75";
  const bulletproof_storage_addr =
   "0x37259b5A5FbAC8D855d1283a7F5D542208Bd9412";

  let web3 = require("web3");
  const ethereum = window.ethereum;
  web3 = new Web3(web3.givenProvider);
  var [addr, setAddr] = useState("");
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
    //web3.eth.getAccounts().then((e) => setAddr(e[0]));

    if (web3.eth.getAccounts().then((e) => e === addr)) {
      //console.log("Serving current metamask address at accounts[0]");
    }

    ethereum.on("accountsChanged", function(accounts) {
      //console.log("trying to change active address");
      web3.eth.getAccounts().then((e) => setAddr(e[0]));
    });
  });


  if (request === "frontend") {
    return frontend;
  } else if (request === "storage") {
    return storage;
  } else if (request === 'web3') {
    return (web3);
  }
}
export default Web3Listener;
