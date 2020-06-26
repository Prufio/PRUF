function returnAddresses() {
  var addrArray = [];
  const storageAddress = "0x315432483985FF59eC70B13ed27538B26C8ed410";
  const BPappNonPayableAddress = "0xdAabF3a9eef7C8f9446607D3C4dEbC490dC07beb";
  const BPappPayableAddress = "0x3069595d91bd026ef713183ca65229b2883817Dd";
  
  addrArray[0] = storageAddress;
  addrArray[1] = BPappNonPayableAddress;
  addrArray[2] = BPappPayableAddress;
  
  return addrArray;
}

export default returnAddresses;
