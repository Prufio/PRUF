function returnAddresses() {
  var addrArray = [];
  const storageAddress = "0x9c5910f6B29d3563217395D7259875eF8E540Ef0";
  const BPFreeAddress = "0x2dA766ACD51b0a420713764B3CB4c632c609eB63";
  const BPPayableAddress = "";
  
  addrArray[0] = storageAddress;
  addrArray[1] = BPFreeAddress;
  addrArray[2] = BPPayableAddress;
  
  return addrArray;
}

export default returnAddresses;
