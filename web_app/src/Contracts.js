import returnABIs from "./returnABIs";

async function returnContracts(_web3) {
  const abis = returnABIs();
  var contracts = {STOR: null,
                  NP: null,
                  APP: null,
                  ECR: null,
                  };
  const STOR_ABI = abis.STOR;
  const NP_ABI = abis.NP;
  const APP_ABI = abis.APP;
  const AC_MGR_ABI = abis.AC_MGR;
  const ECR_ABI = abis.ECR;
  const STOR_Address = "0xae0A1529F0FA3Ed53490cE1Dc0E30c5cEa45791d";
  const STOR = new _web3.eth.Contract(STOR_ABI, STOR_Address);
  var NP = null;
  var APP = null;
  var AC_MGR = null;
  var ECR = null;

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
        .resolveContractAddress("AC_MGR")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          AC_MGR = new _web3.eth.Contract(AC_MGR_ABI, _result);}
          }
        );

      await STOR.methods
        .resolveContractAddress("ECR")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
            ECR = new _web3.eth.Contract(ECR_ABI, _result);}
          }
        );

  contracts.STOR = STOR;
  contracts.NP = NP;
  contracts.APP = APP;
  contracts.ECR = ECR;
  contracts.AC_MGR = AC_MGR;

  return contracts;
}

export default returnContracts;
