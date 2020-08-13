import returnABIs from "./returnABIs";

async function returnContracts(_web3) {
  const abis = returnABIs();
  var contracts = {STOR: null,
                  NP: null,
                  payable: null,
                  simpleEscrow: null,
                  };
  const STOR_ABI = abis.STOR;
  const NP_ABI = abis.NP;
  const APP_ABI = abis.payable;
  const PRUF_AC_manager_ABI = abis.actManager;
  const PRUF_simpleEscrow_ABI = abis.simpleEscrow;
  const STOR_Address = "0xae0A1529F0FA3Ed53490cE1Dc0E30c5cEa45791d";
  const STOR = new _web3.eth.Contract(STOR_ABI, STOR_Address);
  var NP = null;
  var APP = null;
  var PRUF_AC_manager = null;
  var PRUF_simpleEscrow = null;

      await STOR.methods
        .resolveContractAddress("NP")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          NP = new _web3.eth.Contract(NP_ABI, _result);}
          }
        );

        await STOR.methods
        .resolveContractAddress("APP")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          APP = new _web3.eth.Contract(APP_ABI, _result);}
          }
        );

        await STOR.methods
        .resolveContractAddress("PRUF_AC_manager")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          PRUF_AC_manager = new _web3.eth.Contract(PRUF_AC_manager_ABI, _result);}
          }
        );

      await STOR.methods
        .resolveContractAddress("PRUF_simpleEscrow")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
            PRUF_simpleEscrow = new _web3.eth.Contract(PRUF_simpleEscrow_ABI, _result);}
          }
        );

  contracts.STOR = STOR;
  contracts.NP = NP;
  contracts.payable = APP;
  contracts.simpleEscrow = PRUF_simpleEscrow;
  contracts.actManager = PRUF_AC_manager;

  return contracts;
}

export default returnContracts;
