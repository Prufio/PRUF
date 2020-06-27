import returnStorageAbi from "./Storage_ABI";
import returnBPappNonPayableAbi from "./BPappNonPayable_ABI";
import returnBPappPayableAbi from "./BPappPayable_ABI";

async function returnContracts(_web3) {
  var addr;
  var contractArray = [];
  _web3.eth.getAccounts().then((e) => addr = e[0]);
  const storage_abi = returnStorageAbi();
  const BPappNonPayableAbi = returnBPappNonPayableAbi();
  const BPappPayableAbi = returnBPappPayableAbi();
  const storageAddress = "0x315432483985FF59eC70B13ed27538B26C8ed410";
  const Storage = new _web3.eth.Contract(storage_abi, storageAddress);
  var BPappNonPayable = null;
  var BPappPayable = null;

      await Storage.methods
        .resolveContractAddress("BPappNonPayable")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
          BPappNonPayable = new _web3.eth.Contract(BPappNonPayableAbi, _result);}
          }
        );

      await Storage.methods
        .resolveContractAddress("BPappPayable")
        .call(function (_error, _result) {
          if (_error) { console.log(_error);
          } else { 
            BPappPayable = new _web3.eth.Contract(BPappPayableAbi, _result);}
          }
        );

  contractArray[0] = Storage;
  contractArray[1] = BPappNonPayable;
  contractArray[2] = BPappPayable;


  return contractArray;
}

export default returnContracts;
