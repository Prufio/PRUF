import returnABIs from "./returnABIs";

async function returnContracts(_web3) {
  const abis = returnABIs();
  var addr;
  var contracts = {storage: null,
                  nonPayable: null,
                  payable: null,
                  simpleEscrow: null,
                  };

  _web3.eth.getAccounts().then((e) => addr = e[0]);
  const STORAGE_ABI = abis.storage;
  const PRUF_NP_ABI = abis.nonPayable;
  const PRUF_APP_ABI = abis.payable;
  const PRUF_simpleEscrow_ABI = abis.simpleEscrow;
  const storage_Address = "0xb350Ee967437E27F8E811D950d08bCdc4014C14f";
  const Storage = new _web3.eth.Contract(STORAGE_ABI, storage_Address);
  var PRUF_NP = null;
  var PRUF_APP = null;
  var PRUF_simpleEscrow = null;

      await Storage.methods
        .resolveContractAddress("PRUF_NP")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          PRUF_NP = new _web3.eth.Contract(PRUF_NP_ABI, _result);}
          }
        );

        await Storage.methods
        .resolveContractAddress("PRUF_APP")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          PRUF_APP = new _web3.eth.Contract(PRUF_APP_ABI, _result);}
          }
        );

      await Storage.methods
        .resolveContractAddress("PRUF_simpleEscrow")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
            PRUF_simpleEscrow = new _web3.eth.Contract(PRUF_simpleEscrow_ABI, _result);}
          }
        );

  contracts.storage = Storage;
  contracts.nonPayable = PRUF_NP;
  contracts.payable = PRUF_APP;
  contracts.simpleEscrow = PRUF_simpleEscrow;

  return contracts;
}

export default returnContracts;
