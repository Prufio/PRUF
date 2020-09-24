import returnABIs from "./returnABIs";

async function buildContracts(_web3) {


  const abis = returnABIs();

  const ID_TKN_ABI = abis.ID_TKN;
  const STOR_ABI = abis.STOR;
  const NP_ABI = abis.NP;
  const APP_ABI = abis.APP;
  const AC_MGR_ABI = abis.AC_MGR;
  const ECR_ABI = abis.ECR;
  const VERIFY_ABI = abis.VERIFY;
  const ECR_MGR_ABI = abis.ECR_MGR;
  const ECR_NC_ABI = abis.ECR_NC;
  const A_TKN_ABI = abis.A_TKN;
  const AC_TKN_ABI = abis.AC_TKN;
  const APP_NC_ABI = abis.APP_NC;
  const NP_NC_ABI = abis.NP_NC;
  const PIP_ABI = abis.PIP;
  const RCLR_ABI = abis.RCLR;
  const UTIL_TKN_ABI = abis.UTIL_TKN;

  const STOR_Address = "0x630A1e0059BC7b14EDd6ad116Ea31420E96c3BbE";

  const STOR = new _web3.eth.Contract(STOR_ABI, STOR_Address);

  let APP = null;
  let NP = null;
  let AC_MGR = null;
  let AC_TKN = null;
  let A_TKN = null;
  let ECR_MGR = null;
  let ECR = null;
  let VERIFY = null;
  let ECR_NC = null;
  let APP_NC = null;
  let NP_NC = null;
  let RCLR = null;
  let PIP = null;
  let ID_TKN = null;
  let UTIL_TKN = null;

  var _contracts = {
    content: []
  };

  await STOR.methods
    .resolveContractAddress("NP")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        NP = new _web3.eth.Contract(NP_ABI, _result);
      }
    }
    ).then(async () => {
      await STOR.methods
        .resolveContractAddress("NP_NC")
        .call(function (_error, _result) {
          if (_error) {
            console.log(_error);
          } else {
            console.log(_result);
            NP_NC = new _web3.eth.Contract(NP_NC_ABI, _result);
          }
        }
        );
    });

  await STOR.methods
    .resolveContractAddress("APP")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        APP = new _web3.eth.Contract(APP_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("APP_NC")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        APP_NC = new _web3.eth.Contract(APP_NC_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("AC_MGR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result)
        AC_MGR = new _web3.eth.Contract(AC_MGR_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("AC_TKN")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        AC_TKN = new _web3.eth.Contract(AC_TKN_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ECR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        ECR = new _web3.eth.Contract(ECR_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ECR_NC")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        ECR_NC = new _web3.eth.Contract(ECR_NC_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ECR_MGR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        ECR_MGR = new _web3.eth.Contract(ECR_MGR_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("A_TKN")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        A_TKN = new _web3.eth.Contract(A_TKN_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("RCLR")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        RCLR = new _web3.eth.Contract(RCLR_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("ID_TKN")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        ID_TKN = new _web3.eth.Contract(ID_TKN_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("UTIL_TKN")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        UTIL_TKN = new _web3.eth.Contract(UTIL_TKN_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("PIP")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        PIP = new _web3.eth.Contract(PIP_ABI, _result);
      }
    }
    );

  await STOR.methods
    .resolveContractAddress("VERIFY")
    .call(function (_error, _result) {
      if (_error) {
        console.log(_error);
      } else {
        console.log(_result);
        VERIFY = new _web3.eth.Contract(VERIFY_ABI, _result);
      }
    }
    );

/*   await _contracts.content.push(STOR);     //0
  await _contracts.content.push(APP);      //1
  await _contracts.content.push(NP);       //2
  await _contracts.content.push(AC_MGR);   //3
  await _contracts.content.push(AC_TKN);   //4
  await _contracts.content.push(A_TKN);    //5
  await _contracts.content.push(ECR_MGR);  //6
  await _contracts.content.push(ECR);      //7
  await _contracts.content.push(VERIFY);   //8
  await _contracts.content.push(ECR_NC);   //9
  await _contracts.content.push(APP_NC);   //10
  await _contracts.content.push(NP_NC);    //11
  await _contracts.content.push(RCLR);     //12
  await _contracts.content.push(ID_TKN);   //14
  await _contracts.content.push(UTIL_TKN); //15
  await _contracts.content.push(PIP);    //16 */

  

  //console.log(_contracts)
  return window.contracts = {
    STOR: STOR,
    APP: APP,
    NP: NP,
    AC_MGR: AC_MGR,
    AC_TKN: AC_TKN,
    A_TKN: A_TKN,
    ECR_MGR: ECR_MGR,
    ECR: ECR,
    VERIFY: VERIFY,
    ECR_NC: ECR_NC,
    APP_NC: APP_NC,
    NP_NC: NP_NC,
    RCLR: RCLR,
    PIP: PIP,
    ID_TKN: ID_TKN,
    UTIL_TKN: UTIL_TKN
  }
}

export default buildContracts;
