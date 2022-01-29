/*--------------------------------------------------------PRüF0.9.0
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
__\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
___\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
____\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
_____\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______
______\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________
_______\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________
________\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________
_________\/// _____________\/// _______\/// __\///////// __\/// _____________
*---------------------------------------------------------------------------*/

const PRUF_DAO = artifacts.require("DAO");
const PRUF_A_TKN = artifacts.require("A_TKN");
const PRUF_STOR = artifacts.require("STOR");
const PRUF_HELPER = artifacts.require("Helper");

let DAO;
let A_TKN;
let DAO_ADMIN_roleB32;
let CONTRACTADMINROLE;
let DAOroleB32;
let Helper;
let STOR;

contract("DAO", (accounts) => {
  console.log(
    "//**************************BEGIN BOOTSTRAP**************************//"
  );

  const account1 = accounts[0];
  const account2 = accounts[1];
  const account3 = accounts[2];
  const account4 = accounts[3];
  const account5 = accounts[4];
  const account6 = accounts[5];
  const account7 = accounts[6];
  const account8 = accounts[7];
  const account9 = accounts[8];
  const account10 = accounts[9];

  it("Should deploy PRUF_HELPER", async () => {
    const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: account1 });
    console.log(PRUF_HELPER_TEST.address);
    assert(PRUF_HELPER_TEST.address !== "");
    Helper = PRUF_HELPER_TEST;
  });

  it("Should deploy PRUF_DAO", async () => {
    const PRUF_DAO_TEST = await PRUF_DAO.deployed({ from: account1 });
    console.log(PRUF_DAO_TEST.address);
    assert(PRUF_DAO_TEST.address !== "");
    DAO = PRUF_DAO_TEST;
  });

  it("Should deploy Storage", async () => {
    const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: account1 });
    console.log(PRUF_STOR_TEST.address);
    assert(PRUF_STOR_TEST.address !== "");
    STOR = PRUF_STOR_TEST;
  });

  it("Should deploy PRUF_A_TKN", async () => {
    const PRUF_A_TKN_TEST = await PRUF_A_TKN.deployed({ from: account1 });
    console.log(PRUF_A_TKN_TEST.address);
    assert(PRUF_A_TKN_TEST.address !== "");
    A_TKN = PRUF_A_TKN_TEST;
  });

  it("Should fill out all helper variables", async () => {
    CONTRACTADMINROLE = await Helper.getStringHash("CONTRACT_ADMIN_ROLE");
    DAO_ADMIN_roleB32 = await Helper.getStringHash("DAO_ADMIN_ROLE");
    DAOroleB32 = await Helper.getStringHash("DAO_ROLE");
  });

  it("Should authorize account1 for NODE_STOR", () => {
    console.log("Authorizing account1");
    return DAO.grantRole(DAO_ADMIN_roleB32, account1, { from: account1 });
  });

  it("Should authorize account1 for NODE_STOR", () => {
    console.log("Authorizing account1");
    return A_TKN.grantRole(DAOroleB32, DAO.address, { from: account1 });
  });

  it("Should authorize account1 for NODE_STOR", () => {
    console.log("Authorizing account1");
    return A_TKN.grantRole(CONTRACTADMINROLE, DAO.address, { from: account1 });
  });

  it("Should authorize account1 for NODE_STOR", () => {
    console.log("Authorizing account1");
    return STOR.grantRole(DAOroleB32, DAO.address, { from: account1 });
  });

  it("Should add contract addresses to storage", () => {
    console.log("Adding APP to storage for use in Node 0");
    return STOR.authorizeContract("A_TKN", A_TKN.address, "0", "1", {
      from: account1,
    });
  });

  it("Should authorize account1 for NODE_STOR", () => {
    console.log("Authorizing account1");
    return A_TKN.setStorageContract(STOR.address, { from: account1 });
  });

  it("Should authorize account1 for NODE_STOR", () => {
    console.log("Authorizing account1");
    return DAO.setStorageContract(STOR.address, { from: account1 });
  });

  it("Should resolve contract addresses", () => {
    console.log("Resolving in APP");
    return DAO.resolveContractAddresses({ from: account1 })
  });

  it("Should resolve contract addresses", () => {
    console.log("Resolving in APP");
    return DAO.setBaseURIforStorageType("1", "test", { from: account1 })
  });

  it("Should authorize account1 for NODE_STOR", () => {
    console.log("Authorizing account1");
    return DAO.DAOsetStorageContract(STOR.address, A_TKN.address, { from: account1 });
  });
});
