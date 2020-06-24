function returnAddresses() {
  var addrArray = [];
  const storageAddress = "0xd20812d1B3B4Ee1fFdB1830579484A5dD08f5C5A";
  const BPFreeAddress = "0xc2C6Bc205Aa7cbd399d50e156935A40579aF3E3E";
  const BPPayableAddress = "0x7e1A8891A7173c6fe0b5295878b0723E50bd2dAC";
  
  addrArray[0] = storageAddress;
  addrArray[1] = BPFreeAddress;
  addrArray[2] = BPPayableAddress;
  
  return addrArray;
}

export default returnAddresses;
