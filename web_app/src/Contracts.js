function returnAddresses() {
  var addrArray = [];
  const storageAddress = "0x44f5F3191169E5F5D6643c46545d0e1ED7c1Da02";
  const BPappNonPayableAddress = "0x1F12c9980AF01fF9bd50d7928CcA481E51a9fe33";
  const BPappPayableAddress = "0x6B62596C6502ba74f0562BB841770CA305aB9538";
  
  addrArray[0] = storageAddress;
  addrArray[1] = BPappNonPayableAddress;
  addrArray[2] = BPappPayableAddress;
  
  return addrArray;
}

export default returnAddresses;
