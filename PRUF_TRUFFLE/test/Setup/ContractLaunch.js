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

const PRUF_STOR = artifacts.require("STOR");
const PRUF_UTIL_TKN = artifacts.require("UTIL_TKN");
const PRUF_A_TKN = artifacts.require("A_TKN");
const PRUF_NODE_TKN = artifacts.require("NODE_TKN");
const PRUF_NODE_MGR = artifacts.require("NODE_MGR");
const PRUF_NODE_BLDR = artifacts.require("NODE_BLDR");
const PRUF_NODE_STOR = artifacts.require("NODE_STOR");
const PRUF_APP_NC = artifacts.require("APP_NC");
const PRUF_DAO = artifacts.require("DAO");
const PRUF_DAO_A = artifacts.require("DAO_A");
const PRUF_HELPER = artifacts.require("Helper");

let STOR;
let UTIL_TKN;
let A_TKN;
let NODE_TKN;
let NODE_MGR;
let NODE_BLDR;
let NODE_STOR;
let APP_NC;
let DAO;
let DAO_A;
let Helper;

let payableRoleB32;
let minterRoleB32;
let trustedAgentRoleB32;
let IDminterRoleB32;
let IDverifierRoleB32;
let assetTransferRoleB32;
let discardRoleB32;
let DAOroleB32;
let DAOcontrollerRoleB32;
let DAOlayerRoleB32;
let DAOadminRoleB32;
let contractAdminRoleB32;
let defaultAdminRoleB32;
let pauserRoleB32;
let roleMemberCount;
let stakeRoleB32;
let stakePayerRoleB32;
let stakeAdminRoleB32;

contract("Launch", (accounts) => {
  console.log(
    "//**************************BEGIN Launch**************************//"
  );

  const account1 = accounts[0];

  it("Should deploy Storage", async () => {
    const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: account1 });
    console.log(PRUF_STOR_TEST.address);
    assert(PRUF_STOR_TEST.address !== "");
    STOR = PRUF_STOR_TEST;
  });

  it("Should deploy UTIL_TKN", async () => {
    const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: account1 });
    console.log(PRUF_UTIL_TKN_TEST.address);
    assert(PRUF_UTIL_TKN_TEST.address !== "");
    UTIL_TKN = PRUF_UTIL_TKN_TEST;
  });

  it("Should deploy PRUF_A_TKN", async () => {
    const PRUF_A_TKN_TEST = await PRUF_A_TKN.deployed({ from: account1 });
    console.log(PRUF_A_TKN_TEST.address);
    assert(PRUF_A_TKN_TEST.address !== "");
    A_TKN = PRUF_A_TKN_TEST;
  });

  it("Should deploy PRUF_NODE_TKN", async () => {
    const PRUF_NODE_TKN_TEST = await PRUF_NODE_TKN.deployed({ from: account1 });
    console.log(PRUF_NODE_TKN_TEST.address);
    assert(PRUF_NODE_TKN_TEST.address !== "");
    NODE_TKN = PRUF_NODE_TKN_TEST;
  });

  it("Should deploy PRUF_NODE_MGR", async () => {
    const PRUF_NODE_MGR_TEST = await PRUF_NODE_MGR.deployed({ from: account1 });
    console.log(PRUF_NODE_MGR_TEST.address);
    assert(PRUF_NODE_MGR_TEST.address !== "");
    NODE_MGR = PRUF_NODE_MGR_TEST;
  });

  it("Should deploy PRUF_APP_NC", async () => {
    const PRUF_APP_NC_TEST = await PRUF_APP_NC.deployed({ from: account1 });
    console.log(PRUF_APP_NC_TEST.address);
    assert(PRUF_APP_NC_TEST.address !== "");
    APP_NC = PRUF_APP_NC_TEST;
  });

  it("Should deploy PRUF_HELPER", async () => {
    const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: account1 });
    console.log(PRUF_HELPER_TEST.address);
    assert(PRUF_HELPER_TEST.address !== "");
    Helper = PRUF_HELPER_TEST;
  });

  it("Should build Roles", () => {
    payableRoleB32 = await Helper.getStringHash("PAYABLE_ROLE");

    minterRoleB32 = await Helper.getStringHash("MINTER_ROLE");

    IDproviderRoleB32 = await Helper.getStringHash("ID_PROVIDER_ROLE");

    trustedAgentRoleB32 = await Helper.getStringHash("TRUSTED_AGENT_ROLE");

    assetTransferRoleB32 = await Helper.getStringHash("ASSET_TXFR_ROLE");

    IDminterRoleB32 = await Helper.getStringHash("ID_MINTER_ROLE");

    IDverifierRoleB32 = await Helper.getStringHash("ID_VERIFIER_ROLE");

    discardRoleB32 = await Helper.getStringHash("DISCARD_ROLE");

    DAOroleB32 = await Helper.getStringHash("DAO_ROLE");

    nodeAdminRoleB32 = await Helper.getStringHash("NODE_ADMIN_ROLE");

    nodeMinterRoleB32 = await Helper.getStringHash("NODE_MINTER_ROLE");

    contractAdminRoleB32 = await Helper.getStringHash("CONTRACT_ADMIN_ROLE");

    DAOcontrollerRoleB32 = await Helper.getStringHash("DAO_CONTROLLER_ROLE");

    DAOlayerRoleB32 = await Helper.getStringHash("DAO_LAYER_ROLE");

    DAOadminRoleB32 = await Helper.getStringHash("DAO_ADMIN_ROLE");

    pauserRoleB32 = await Helper.getStringHash("PAUSER_ROLE");

    stakeRoleB32 = await Helper.getStringHash("STAKE_ROLE");

    stakePayerRoleB32 = await Helper.getStringHash("STAKE_PAYER_ROLE");

    stakeAdminRoleB32 = await Helper.getStringHash("STAKE_ADMIN_ROLE");

    defaultAdminRoleB32 =
      "0x0000000000000000000000000000000000000000000000000000000000000000";
  });

  it("Should authorize account1 as DAOveto in DAO", () => {
    return DAO.grantRole(daoVetoRoleB32, account1, { from: account1 });
  });

  it("Should authorize account1 as DAOcontroller in DAO_A", () => {
    console.log("Authorizing account1");
    return DAO_A.grantRole(DAOcontrollerRoleB32, account1, { from: account1 });
  });

  it("Should authorize account1 as DAOcontroller in DAO_B", () => {
    console.log("Authorizing account1");
    return DAO_B.grantRole(DAOcontrollerRoleB32, account1, { from: account1 });
  });

  it("Should authorize account1 as DAOadmin in DAO_A", () => {
    console.log("Authorizing account1");
    return DAO_STOR.grantRole(DAOlayerRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize account1 as DAOadmin in DAO_STOR", () => {
    console.log("Authorizing account1");
    return DAO_STOR.grantRole(DAOadminRoleB32, DAO.address, { from: account1 });
  });

  // it("Should authorize account1 as DAOadmin in DAO_A", () => {
  //   console.log("Authorizing account1");
  //   return DAO_STOR.grantRole(DAO_A, DAO_A.address, { from: account1 });
  // });

  it("Should authorize DAO_A as DAO_A in STOR", () => {
    console.log("Authorizing account1");
    return STOR.grantRole(DAOroleB32, DAO_A.address, {
      from: account1,
    });
  });
  it("Should authorize DAO_B as DAO_B in STOR", () => {
    console.log("Authorizing account1");
    return STOR.grantRole(DAOroleB32, DAO_B.address, {
      from: account1,
    });
  });
});
