import returnABIs from "./returnABIs";

async function returnContracts(_web3) {
  const abis = returnABIs();
  var contracts = {storage: null,
                  nonPayable: null,
                  payable: null,
                  simpleEscrow: null,
                  };
  const STORAGE_ABI = abis.storage;
  const PRUF_NP_ABI = abis.nonPayable;
  const PRUF_APP_ABI = abis.payable;
  const PRUF_AC_manager_ABI = abis.actManager;
  const PRUF_simpleEscrow_ABI = abis.simpleEscrow;
  const storage_Address = "0xae0A1529F0FA3Ed53490cE1Dc0E30c5cEa45791d";
  const Storage = new _web3.eth.Contract(STORAGE_ABI, storage_Address);
  var PRUF_NP = null;
  var PRUF_APP = null;
  var PRUF_AC_manager = null;
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
        .resolveContractAddress("PRUF_AC_manager")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          PRUF_AC_manager = new _web3.eth.Contract(PRUF_AC_manager_ABI, _result);}
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
  contracts.actManager = PRUF_AC_manager;

  return contracts;
}

export default returnContracts;
