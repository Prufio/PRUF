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
const PRUF_APP = artifacts.require("APP");
const PRUF_NODE_MGR = artifacts.require("NODE_MGR");
const PRUF_NODE_STOR = artifacts.require("NODE_STOR");
const PRUF_NODE_TKN = artifacts.require("NODE_TKN");
const PRUF_A_TKN = artifacts.require("A_TKN");
const PRUF_UD_NODE_BLDR = artifacts.require("UD_721");
const PRUF_NODE_BLDR = artifacts.require("NODE_BLDR");
const PRUF_STAKE_TKN = artifacts.require("STAKE_TKN");
const PRUF_STAKE_VAULT = artifacts.require("STAKE_VAULT");
const PRUF_REWARD_VAULT = artifacts.require("REWARDS_VAULT");
const PRUF_EO_STAKING = artifacts.require("EO_STAKING");
const PRUF_ECR_MGR = artifacts.require("ECR_MGR");
const PRUF_ECR = artifacts.require("ECR");
const PRUF_ECR2 = artifacts.require("ECR2");
const PRUF_APP_NC = artifacts.require("APP_NC");
const PRUF_ECR_NC = artifacts.require("ECR_NC");
const PRUF_RCLR = artifacts.require("RCLR");
const PRUF_HELPER = artifacts.require("Helper");
const PRUF_MAL_APP = artifacts.require("MAL_APP");
const PRUF_UTIL_TKN = artifacts.require("UTIL_TKN");
const PRUF_DECORATE = artifacts.require("DECORATE");
const PRUF_WRAP = artifacts.require("WRAP");
const PRUF_DAO_STOR = artifacts.require("DAO_STOR");
const PRUF_DAO = artifacts.require("DAO");
const PRUF_DAO_A = artifacts.require("DAO_LAYER_A");
const PRUF_DAO_B = artifacts.require("DAO_LAYER_B");
const PRUF_CLOCK = artifacts.require("FAKE_CLOCK");

let STOR;
let APP;
let NODE_MGR;
let NODE_STOR;
let NODE_TKN;
let A_TKN;
let NODE_BLDR;
let ECR_MGR;
let ECR;
let ECR2;
let ECR_NC;
let APP_NC;
let RCLR;
let Helper;
let MAL_APP;
let UTIL_TKN;
let UD_721;
let DAO_A;
let DAO_B;
let DAO_STOR;
let DAO;
let CLOCK;

let string1Hash;
let string2Hash;
let string3Hash;
let string4Hash;
let string5Hash;
let string14Hash;

let ECR_MGRHASH;

let asset1;
let asset2;
let asset3;
let asset4;
let asset5;
let asset6;
let asset7;
let asset8;
let asset9;
let asset10;
let asset11;
let asset12;
let asset13;
let asset14;

let rgt1;
let rgt2;
let rgt3;
let rgt4;
let rgt5;
let rgt6;
let rgt7;
let rgt8;
let rgt12;
let rgt13;
let rgt14;
let rgt000 =
  "0x0000000000000000000000000000000000000000000000000000000000000000";
let rgtFFF =
  "0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF";

let account1Hash;
let account2Hash;
let account3Hash;
let account4Hash;
let account5Hash;
let account6Hash;
let account7Hash;
let account8Hash;
let account9Hash;
let account10Hash;

let account000 = "0x0000000000000000000000000000000000000000";

let nakedAuthCode1;
let nakedAuthCode3;
let nakedAuthCode7;

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
let daoVetoRoleB32;

let grantRoleSig;
let grantRoleSigComplete;
let revokeRoleSig;
let revokeRoleSigComplete;
let renounceRoleSig;
let renounceRoleSigComplete;

let result;

contract("DAO_STOR", (accounts) => {
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

  function timeout(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  it("Should deploy PRUF_HELPER", async () => {
    const PRUF_HELPER_TEST = await PRUF_HELPER.deployed({ from: account1 });
    console.log(PRUF_HELPER_TEST.address);
    assert(PRUF_HELPER_TEST.address !== "");
    Helper = PRUF_HELPER_TEST;
  });

  it("Should build variables", async () => {
    asset1raw = await Helper.getIdxHashRaw("aaa", "aaa", "aaa", "aaa");

    asset2raw = await Helper.getIdxHashRaw("bbb", "bbb", "bbb", "bbb");

    asset3raw = await Helper.getIdxHashRaw("ccc", "ccc", "ccc", "ccc");

    asset4raw = await Helper.getIdxHashRaw("ddd", "ddd", "ddd", "ddd");

    asset5raw = await Helper.getIdxHashRaw("eee", "eee", "eee", "eee");

    asset6raw = await Helper.getIdxHashRaw("fff", "fff", "fff", "fff");

    asset7raw = await Helper.getIdxHashRaw("ggg", "ggg", "ggg", "ggg");

    asset8raw = await Helper.getIdxHashRaw("hhh", "hhh", "hhh", "hhh");

    asset9raw = await Helper.getIdxHashRaw("iii", "iii", "iii", "iii");

    asset10raw = await Helper.getIdxHashRaw("jjj", "jjj", "jjj", "jjj");

    asset11raw = await Helper.getIdxHashRaw("kkk", "kkk", "kkk", "kkk");

    asset12raw = await Helper.getIdxHashRaw("lll", "lll", "lll", "lll");

    asset13raw = await Helper.getIdxHashRaw("mmm", "mmm", "mmm", "mmm");

    asset14raw = await Helper.getIdxHashRaw("nnn", "nnn", "nnn", "nnn");

    asset1 = await Helper.getIdxHash(asset1raw, "1000003");

    asset2 = await Helper.getIdxHash(asset2raw, "1000001");

    asset3 = await Helper.getIdxHash(asset3raw, "1000001");

    asset4 = await Helper.getIdxHash(asset4raw, "1000001");

    asset5 = await Helper.getIdxHash(asset5raw, "1000001");

    asset6 = await Helper.getIdxHash(asset6raw, "1000003");

    asset7 = await Helper.getIdxHash(asset7raw, "1000001");

    asset8 = await Helper.getIdxHash(asset8raw, "1000001");

    asset9 = await Helper.getIdxHash(asset9raw, "1000001");

    asset10 = await Helper.getIdxHash(asset10raw, "1000001");

    asset11 = await Helper.getIdxHash(asset11raw, "1000003");

    asset12 = await Helper.getIdxHash(asset12raw, "1000001");

    asset13 = await Helper.getIdxHash(asset13raw, "1000003");

    asset14 = await Helper.getIdxHash(asset14raw, "1000001");

    rgt1 = await Helper.getJustRgtHash(
      asset1,
      "aaa",
      "aaa",
      "aaa",
      "aaa",
      "aaa"
    );

    rgt2 = await Helper.getJustRgtHash(
      asset2,
      "bbb",
      "bbb",
      "bbb",
      "bbb",
      "bbb"
    );

    rgt3 = await Helper.getJustRgtHash(
      asset3,
      "ccc",
      "ccc",
      "ccc",
      "ccc",
      "ccc"
    );

    rgt4 = await Helper.getJustRgtHash(
      asset4,
      "ddd",
      "ddd",
      "ddd",
      "ddd",
      "ddd"
    );

    rgt5 = await Helper.getJustRgtHash(
      asset5,
      "eee",
      "eee",
      "eee",
      "eee",
      "eee"
    );

    rgt6 = await Helper.getJustRgtHash(
      asset6,
      "fff",
      "fff",
      "fff",
      "fff",
      "fff"
    );

    rgt7 = await Helper.getJustRgtHash(
      asset7,
      "ggg",
      "ggg",
      "ggg",
      "ggg",
      "ggg"
    );

    rgt8 = await Helper.getJustRgtHash(
      asset7,
      "hhh",
      "hhh",
      "hhh",
      "hhh",
      "hhh"
    );

    rgt12 = await Helper.getJustRgtHash(asset12, "a", "a", "a", "a", "a");

    rgt13 = await Helper.getJustRgtHash(asset13, "a", "a", "a", "a", "a");

    rgt14 = await Helper.getJustRgtHash(asset14, "a", "a", "a", "a", "a");

    account1Hash = await Helper.getAddrHash(account1);

    account2Hash = await Helper.getAddrHash(account2);

    account3Hash = await Helper.getAddrHash(account3);

    account4Hash = await Helper.getAddrHash(account4);

    account5Hash = await Helper.getAddrHash(account5);

    account6Hash = await Helper.getAddrHash(account6);

    account7Hash = await Helper.getAddrHash(account7);

    account8Hash = await Helper.getAddrHash(account8);

    account9Hash = await Helper.getAddrHash(account9);

    account10Hash = await Helper.getAddrHash(account10);

    nakedAuthCode1 = await Helper.getURIb32fromAuthcode("1000005", "1");

    nakedAuthCode3 = await Helper.getURIb32fromAuthcode("1000005", "3");

    nakedAuthCode7 = await Helper.getURIb32fromAuthcode("1000005", "7");

    string1Hash = await Helper.getStringHash("1");

    string2Hash = await Helper.getStringHash("2");

    string3Hash = await Helper.getStringHash("3");

    string4Hash = await Helper.getStringHash("4");

    string5Hash = await Helper.getStringHash("5");

    string14Hash = await Helper.getStringHash("1000004");

    ECR_MGRHASH = await Helper.getStringHash("ECR_MGR");

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

    daoVetoRoleB32 = await Helper.getStringHash("DAO_VETO_ROLE");

    defaultAdminRoleB32 =
      "0x0000000000000000000000000000000000000000000000000000000000000000";
  });

  it("Should deploy Storage", async () => {
    const PRUF_STOR_TEST = await PRUF_STOR.deployed({ from: account1 });
    console.log(PRUF_STOR_TEST.address);
    assert(PRUF_STOR_TEST.address !== "");
    STOR = PRUF_STOR_TEST;
  });

  it("Should deploy PRUF_APP", async () => {
    const PRUF_APP_TEST = await PRUF_APP.deployed({ from: account1 });
    console.log(PRUF_APP_TEST.address);
    assert(PRUF_APP_TEST.address !== "");
    APP = PRUF_APP_TEST;
  });

  it("Should deploy PRUF_NODE_MGR", async () => {
    const PRUF_NODE_MGR_TEST = await PRUF_NODE_MGR.deployed({ from: account1 });
    console.log(PRUF_NODE_MGR_TEST.address);
    assert(PRUF_NODE_MGR_TEST.address !== "");
    NODE_MGR = PRUF_NODE_MGR_TEST;
  });

  it("Should deploy PRUF_NODE_STOR", async () => {
    const PRUF_NODE_STOR_TEST = await PRUF_NODE_STOR.deployed({
      from: account1,
    });
    console.log(PRUF_NODE_STOR_TEST.address);
    assert(PRUF_NODE_STOR_TEST.address !== "");
    NODE_STOR = PRUF_NODE_STOR_TEST;
  });

  it("Should deploy PRUF_NODE_TKN", async () => {
    const PRUF_NODE_TKN_TEST = await PRUF_NODE_TKN.deployed({ from: account1 });
    console.log(PRUF_NODE_TKN_TEST.address);
    assert(PRUF_NODE_TKN_TEST.address !== "");
    NODE_TKN = PRUF_NODE_TKN_TEST;
  });

  it("Should deploy PRUF_A_TKN", async () => {
    const PRUF_A_TKN_TEST = await PRUF_A_TKN.deployed({ from: account1 });
    console.log(PRUF_A_TKN_TEST.address);
    assert(PRUF_A_TKN_TEST.address !== "");
    A_TKN = PRUF_A_TKN_TEST;
  });

  it("Should deploy PRUF_ECR_MGR", async () => {
    const PRUF_ECR_MGR_TEST = await PRUF_ECR_MGR.deployed({ from: account1 });
    console.log(PRUF_ECR_MGR_TEST.address);
    assert(PRUF_ECR_MGR_TEST.address !== "");
    ECR_MGR = PRUF_ECR_MGR_TEST;
  });

  it("Should deploy PRUF_ECR", async () => {
    const PRUF_ECR_TEST = await PRUF_ECR.deployed({ from: account1 });
    console.log(PRUF_ECR_TEST.address);
    assert(PRUF_ECR_TEST.address !== "");
    ECR = PRUF_ECR_TEST;
  });

  it("Should deploy PRUF_APP_NC", async () => {
    const PRUF_APP_NC_TEST = await PRUF_APP_NC.deployed({ from: account1 });
    console.log(PRUF_APP_NC_TEST.address);
    assert(PRUF_APP_NC_TEST.address !== "");
    APP_NC = PRUF_APP_NC_TEST;
  });

  it("Should deploy PRUF_ECR_NC", async () => {
    const PRUF_ECR_NC_TEST = await PRUF_ECR_NC.deployed({ from: account1 });
    console.log(PRUF_ECR_NC_TEST.address);
    assert(PRUF_ECR_NC_TEST.address !== "");
    ECR_NC = PRUF_ECR_NC_TEST;
  });

  it("Should deploy PRUF_RCLR", async () => {
    const PRUF_RCLR_TEST = await PRUF_RCLR.deployed({ from: account1 });
    console.log(PRUF_RCLR_TEST.address);
    assert(PRUF_RCLR_TEST.address !== "");
    RCLR = PRUF_RCLR_TEST;
  });

  it("Should deploy PRUF_NODE_BLDR", async () => {
    const PRUF_NODE_BLDR_TEST = await PRUF_NODE_BLDR.deployed({
      from: account1,
    });
    console.log(PRUF_NODE_BLDR_TEST.address);
    assert(PRUF_NODE_BLDR_TEST.address !== "");
    NODE_BLDR = PRUF_NODE_BLDR_TEST;
  });

  it("Should deploy PRUF_ECR2", async () => {
    const PRUF_ECR2_TEST = await PRUF_ECR2.deployed({ from: account1 });
    console.log(PRUF_ECR2_TEST.address);
    assert(PRUF_ECR2_TEST.address !== "");
    ECR2 = PRUF_ECR2_TEST;
  });

  it("Should deploy PRUF_MAL_APP", async () => {
    const PRUF_MAL_APP_TEST = await PRUF_MAL_APP.deployed({ from: account1 });
    console.log(PRUF_MAL_APP_TEST.address);
    assert(PRUF_MAL_APP_TEST.address !== "");
    MAL_APP = PRUF_MAL_APP_TEST;
  });

  it("Should deploy UTIL_TKN", async () => {
    const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: account1 });
    console.log(PRUF_UTIL_TKN_TEST.address);
    assert(PRUF_UTIL_TKN_TEST.address !== "");
    UTIL_TKN = PRUF_UTIL_TKN_TEST;
  });

  it("Should deploy DECORATE", async () => {
    const PRUF_DECORATE_TEST = await PRUF_DECORATE.deployed({ from: account1 });
    console.log(PRUF_DECORATE_TEST.address);
    assert(PRUF_DECORATE_TEST.address !== "");
    DECORATE = PRUF_DECORATE_TEST;
  });

  it("Should deploy WRAP", async () => {
    const PRUF_WRAP_TEST = await PRUF_WRAP.deployed({ from: account1 });
    console.log(PRUF_WRAP_TEST.address);
    assert(PRUF_WRAP_TEST.address !== "");
    WRAP = PRUF_WRAP_TEST;
  });

  it("Should deploy PRUF_DAO_STOR", async () => {
    const PRUF_DAO_STOR_TEST = await PRUF_DAO_STOR.deployed({ from: account1 });
    console.log(PRUF_DAO_STOR_TEST.address);
    assert(PRUF_DAO_STOR_TEST.address !== "");
    DAO_STOR = PRUF_DAO_STOR_TEST;
  });

  it("Should deploy PRUF_DAO_A", async () => {
    const PRUF_DAO_A_TEST = await PRUF_DAO_A.deployed({ from: account1 });
    console.log(PRUF_DAO_A_TEST.address);
    assert(PRUF_DAO_A_TEST.address !== "");
    DAO_A = PRUF_DAO_A_TEST;
  });

  it("Should deploy PRUF_DAO_B", async () => {
    const PRUF_DAO_B_TEST = await PRUF_DAO_B.deployed({ from: account1 });
    console.log(PRUF_DAO_B_TEST.address);
    assert(PRUF_DAO_B_TEST.address !== "");
    DAO_B = PRUF_DAO_B_TEST;
  });

  it("Should deploy PRUF_DAO", async () => {
    const PRUF_DAO_TEST = await PRUF_DAO.deployed({ from: account1 });
    console.log(PRUF_DAO_TEST.address);
    assert(PRUF_DAO_TEST.address !== "");
    DAO = PRUF_DAO_TEST;
  });

  it("Should deploy UD_721", async () => {
    PRUF_UD_NODE_BLDR_TEST = await PRUF_UD_NODE_BLDR.deployed({
      from: account1,
    });
    console.log(PRUF_UD_NODE_BLDR_TEST.address);
    assert(PRUF_UD_NODE_BLDR_TEST.address !== "");
    UD_721 = PRUF_UD_NODE_BLDR_TEST;
  });

  it("Should deploy PRUF_STAKE_TKN", async () => {
    const PRUF_STAKE_TKN_TEST = await PRUF_STAKE_TKN.deployed({
      from: account1,
    });
    console.log(PRUF_STAKE_TKN_TEST.address);
    assert(PRUF_STAKE_TKN_TEST.address !== "");
    STAKE_TKN = PRUF_STAKE_TKN_TEST;
  });

  it("Should deploy PRUF_STAKE_VAULT", async () => {
    const PRUF_STAKE_VAULT_TEST = await PRUF_STAKE_VAULT.deployed({
      from: account1,
    });
    console.log(PRUF_STAKE_VAULT_TEST.address);
    assert(PRUF_STAKE_VAULT_TEST.address !== "");
    STAKE_VAULT = PRUF_STAKE_VAULT_TEST;
  });

  it("Should deploy PRUF_REWARD_VAULT", async () => {
    const PRUF_REWARD_VAULT_TEST = await PRUF_REWARD_VAULT.deployed({
      from: account1,
    });
    console.log(PRUF_REWARD_VAULT_TEST.address);
    assert(PRUF_REWARD_VAULT_TEST.address !== "");
    REWARDS_VAULT = PRUF_REWARD_VAULT_TEST;
  });

  it("Should deploy PRUF_EO_STAKING", async () => {
    const PRUF_EO_STAKING_TEST = await PRUF_EO_STAKING.deployed({
      from: account1,
    });
    console.log(PRUF_EO_STAKING_TEST.address);
    assert(PRUF_EO_STAKING_TEST.address !== "");
    EO_STAKING = PRUF_EO_STAKING_TEST;
  });

  it("Should deploy PRUF_EO_STAKING", async () => {
    const PRUF_CLOCK_TEST = await PRUF_CLOCK.deployed({
      from: account1,
    });
    console.log(PRUF_CLOCK_TEST.address);
    assert(PRUF_CLOCK_TEST.address !== "");
    CLOCK = PRUF_CLOCK_TEST;
  });

  it("Should authorize account1 as DAOveto in DAO", () => {
    return DAO.grantRole(daoVetoRoleB32, account1, { from: account1 });
  });

  it("Should authorize account1 as DAOadmin in DAO_A", () => {
    console.log("Authorizing account1");
    return DAO_A.grantRole(DAOcontrollerRoleB32, account1, { from: account1 });
  });

  it("Should authorize account1 as DAOadmin in DAO_A", () => {
    console.log("Authorizing account1");
    return DAO_B.grantRole(DAOcontrollerRoleB32, account1, { from: account1 });
  });

  it("Should authorize account1 as DAOadmin in DAO_A", () => {
    console.log("Authorizing account1");
    return DAO_STOR.grantRole(DAOlayerRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize account1 as DAOadmin in DAO_A", () => {
    console.log("Authorizing account1");
    return DAO_STOR.grantRole(DAOlayerRoleB32, account1, {
      from: account1,
    });
  });

  it("Should authorize account1 as DAOadmin in DAO_STOR", () => {
    console.log("Authorizing account1");
    return DAO_STOR.grantRole(DAOadminRoleB32, DAO.address, { from: account1 });
  });

  it("Should authorize account1 as DAOadmin in DAO_STOR", () => {
    console.log("Authorizing account1");
    return DAO_STOR.grantRole(DAOadminRoleB32, account1, { from: account1 });
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

  it("Should add storage to DAO_A", () => {
    console.log("Adding in DAO_A");
    return DAO_A.setStorageContract(STOR.address, { from: account1 });
  });

  it("Should add storage to DAO_B", () => {
    console.log("Adding in DAO_B");
    return DAO_B.setStorageContract(STOR.address, { from: account1 });
  });

  it("Should add default contracts to storage", () => {
    console.log("Adding NODE_MGR to default contract list");
    return STOR.addDefaultContracts("0", "NODE_MGR", "1", { from: account1 })

      .then(() => {
        console.log("Adding NODE_TKN to default contract list");
        return STOR.addDefaultContracts("1", "NODE_TKN", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding A_TKN to default contract list");
        return STOR.addDefaultContracts("2", "A_TKN", "1", { from: account1 });
      })

      .then(() => {
        console.log("Adding ECR_MGR to default contract list");
        return STOR.addDefaultContracts("3", "ECR_MGR", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding APP_NC to default contract list");
        return STOR.addDefaultContracts("4", "APP_NC", "2", { from: account1 });
      })

      .then(() => {
        console.log("Adding APP_NC to default contract list");
        return STOR.addDefaultContracts("5", "APP_NC", "2", { from: account1 });
      })

      .then(() => {
        console.log("Adding RCLR to default contract list");
        return STOR.addDefaultContracts("6", "RCLR", "3", { from: account1 });
      })

      .then(() => {
        console.log("Adding NODE_STOR to default contract list");
        return STOR.addDefaultContracts("8", "NODE_STOR", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding DECORATE to default contract list");
        return STOR.addDefaultContracts("9", "DECORATE", "2", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding WRAP to default contract list");
        return STOR.addDefaultContracts("10", "WRAP", "2", { from: account1 });
      });
  });

  it("Should add Storage to each contract", () => {
    console.log("Adding in APP");
    return APP.setStorageContract(STOR.address, { from: account1 })

      .then(() => {
        console.log("Adding in MAL_APP");
        return MAL_APP.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in NODE_MGR");
        return NODE_MGR.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in NODE_STOR");
        return NODE_STOR.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in A_TKN");
        return A_TKN.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in ECR_MGR");
        return ECR_MGR.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in ECR");
        return ECR.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in ECR2");
        return ECR2.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in APP_NC");
        return APP_NC.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in ECR_NC");
        return ECR_NC.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in RCLR");
        return RCLR.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in NODE_BLDR");
        return NODE_BLDR.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in DECORATE");
        return DECORATE.setStorageContract(STOR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding in WRAP");
        return WRAP.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in DAO_A");
        return DAO_A.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in DAO_B");
        return DAO_B.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in DAO");
        return DAO.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in DAO_STOR");
        return DAO_STOR.setStorageContract(STOR.address, { from: account1 });
      })

      .then(() => {
        console.log("Adding in UD_721");
        return UD_721.setStorageContract(STOR.address, {
          from: account1,
        });
      });
  });

  it("Should add contract addresses to storage", () => {
    console.log("Adding APP to storage for use in Node 0");
    return STOR.authorizeContract("APP", APP.address, "0", "1", {
      from: account1,
    })

      .then(() => {
        console.log("Adding NODE_MGR to storage for use in Node 0");
        return STOR.authorizeContract("NODE_MGR", NODE_MGR.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding NODE_STOR to storage for use in Node 0");
        return STOR.authorizeContract(
          "NODE_STOR",
          NODE_STOR.address,
          "0",
          "1",
          {
            from: account1,
          }
        );
      })

      .then(() => {
        console.log("Adding NODE_TKN to storage for use in Node 0");
        return STOR.authorizeContract("NODE_TKN", NODE_TKN.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding A_TKN to storage for use in Node 0");
        return STOR.authorizeContract("A_TKN", A_TKN.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding ECR_MGR to storage for use in Node 0");
        return STOR.authorizeContract("ECR_MGR", ECR_MGR.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding ECR to storage for use in Node 0");
        return STOR.authorizeContract("ECR", ECR.address, "0", "3", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding ECR2 to storage for use in Node 0");
        return STOR.authorizeContract("ECR2", ECR2.address, "0", "3", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding APP_NC to storage for use in Node 0");
        return STOR.authorizeContract("APP_NC", APP_NC.address, "0", "2", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding ECR_NC to storage for use in Node 0");
        return STOR.authorizeContract("ECR_NC", ECR_NC.address, "0", "3", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding RCLR to storage for use in Node 0");
        return STOR.authorizeContract("RCLR", RCLR.address, "0", "3", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding MAL_APP to storage for use in Node 0");
        return STOR.authorizeContract("MAL_APP", MAL_APP.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding UTIL_TKN to storage for use in Node 0");
        return STOR.authorizeContract("UTIL_TKN", UTIL_TKN.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding DECORATE to storage for use in Node 0");
        return STOR.authorizeContract("DECORATE", DECORATE.address, "0", "2", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding DECORATE to storage for use in Node 0");
        return STOR.authorizeContract("DAO_STOR", DAO_STOR.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding DECORATE to storage for use in Node 0");
        return STOR.authorizeContract("CLOCK", CLOCK.address, "0", "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Adding WRAP to storage for use in Node 0");
        return STOR.authorizeContract("WRAP", WRAP.address, "0", "2", {
          from: account1,
        });
      });
  });

  it("Should resolve contract addresses", () => {
    console.log("Resolving in APP");
    return APP.resolveContractAddresses({ from: account1 })

      .then(() => {
        console.log("Resolving in MAL_APP");
        return MAL_APP.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in NODE_MGR");
        return NODE_MGR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in NODE_STOR");
        return NODE_STOR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in A_TKN");
        return A_TKN.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in ECR_MGR");
        return ECR_MGR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in ECR");
        return ECR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in ECR2");
        return ECR2.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in APP_NC");
        return APP_NC.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in ECR_NC");
        return ECR_NC.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in RCLR");
        return RCLR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in NODE_BLDR");
        return NODE_BLDR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DECORATE");
        return DECORATE.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in WRAP");
        return WRAP.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO_A");
        return DAO_A.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO_B");
        return DAO_B.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO");
        return DAO.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in DAO_STOR");
        return DAO_STOR.resolveContractAddresses({ from: account1 });
      })

      .then(() => {
        console.log("Resolving in UD_721");
        return UD_721.resolveContractAddresses({ from: account1 });
      });
  });

  it("Should give DAO_A assetTransferRole for APP_NC", () => {
    console.log("Authorizing account1");
    return UD_721.grantRole(contractAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should give DAO_A assetTransferRole for APP_NC", () => {
    console.log("Authorizing account1");
    return APP_NC.grantRole(assetTransferRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should give DAO_B assetTransferRole for APP_NC", () => {
    console.log("Authorizing account1");
    return UD_721.grantRole(contractAdminRoleB32, DAO_B.address, {
      from: account1,
    });
  });

  it("Should give DAO_B assetTransferRole for APP_NC", () => {
    console.log("Authorizing account1");
    return APP_NC.grantRole(assetTransferRoleB32, DAO_B.address, {
      from: account1,
    });
  });

  it("Should authorize STAKE_VAULT for trusted agent functions in UTIL_TKN", async () => {
    return UTIL_TKN.grantRole(trustedAgentRoleB32, STAKE_VAULT.address, {
      from: account1,
    });
  });

  it("Should authorize EO_STAKING to mint STAKE_TKNs", async () => {
    return STAKE_TKN.grantRole(minterRoleB32, EO_STAKING.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A for EO_STAKING", async () => {
    return EO_STAKING.grantRole(contractAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A as contractAdmin in RV", async () => {
    return REWARDS_VAULT.grantRole(contractAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize DAO_A as contractAdmin in SV", async () => {
    return STAKE_VAULT.grantRole(contractAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize EO_STAKING to pay rewards", async () => {
    return REWARDS_VAULT.grantRole(stakePayerRoleB32, EO_STAKING.address, {
      from: account1,
    });
  });

  it("Should authorize EO_STAKING to take stakes out of the STAKE_VAULT", async () => {
    return STAKE_VAULT.grantRole(stakeRoleB32, EO_STAKING.address, {
      from: account1,
    });
  });

  it("Should authorize EO_STAKING as stake admin in stake_vault", async () => {
    return STAKE_VAULT.grantRole(stakeAdminRoleB32, EO_STAKING.address, {
      from: account1,
    });
  });

  it("Should authorize all minter contracts for minting A_TKN(s)", () => {
    console.log("Authorizing account1");
    return A_TKN.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    });
  });

  it("Should authorize all minter contracts for minting A_TKN(s)", () => {
    console.log("Authorizing APP_NC");
    return A_TKN.grantRole(minterRoleB32, APP_NC.address, {
      from: account1,
    });
  });

  it("Should authorize all minter contracts for minting A_TKN(s)", () => {
    console.log("Authorizing APP");
    return A_TKN.grantRole(minterRoleB32, APP.address, {
      from: account1,
      // });
    })

      .then(() => {
        console.log("Authorizing RCLR");
        return A_TKN.grantRole(minterRoleB32, RCLR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing RCLR");
        return A_TKN.grantRole(minterRoleB32, account1, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return A_TKN.grantRole(DAOroleB32, DAO_A.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return A_TKN.grantRole(pauserRoleB32, DAO_A.address, {
          from: account1,
        });
      });
  });

  it("Should authorize all payable contracts for transactions", () => {
    console.log("Authorizing NODE_MGR");
    return UTIL_TKN.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    })

      .then(() => {
        console.log("Authorizing NODE_MGR");
        return UTIL_TKN.grantRole(payableRoleB32, NODE_MGR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing APP_NC");
        return UTIL_TKN.grantRole(payableRoleB32, APP_NC.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing APP");
        return UTIL_TKN.grantRole(payableRoleB32, APP.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing RCLR");
        return UTIL_TKN.grantRole(payableRoleB32, RCLR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing NODE_MGR");
        return UTIL_TKN.grantRole(trustedAgentRoleB32, NODE_MGR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return UTIL_TKN.grantRole(pauserRoleB32, DAO_A.address, {
          from: account1,
        });
      });
  });

  it("Should authorize all minter contracts for minting NODE_TKN(s)", () => {
    console.log("Authorizing NODE_MGR");
    return NODE_TKN.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    })

      .then(() => {
        console.log("Authorizing NODE_MGR");
        return NODE_TKN.grantRole(minterRoleB32, NODE_MGR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return NODE_TKN.grantRole(contractAdminRoleB32, DAO_A.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return NODE_TKN.grantRole(pauserRoleB32, DAO_A.address, {
          from: account1,
        });
      });
  });

  it("Should authorize NODE_BLDR", () => {
    console.log("Authorizing NODE_BLDR");
    return NODE_MGR.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    })

      .then(() => {
        console.log("Authorizing account1");
        return NODE_MGR.grantRole(IDverifierRoleB32, account1, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing account1");
        return NODE_MGR.grantRole(IDverifierRoleB32, account10, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing NODE_BLDR");
        return NODE_MGR.grantRole(IDproviderRoleB32, NODE_BLDR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing NODE_BLDR");
        return NODE_MGR.grantRole(IDverifierRoleB32, NODE_BLDR.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing account1");
        return NODE_MGR.grantRole(DAOroleB32, DAO_A.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return NODE_MGR.grantRole(pauserRoleB32, DAO_A.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing account1");
        return NODE_MGR.grantRole(IDverifierRoleB32, UD_721.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing NODE_MGR");
        return NODE_MGR.grantRole(nodeAdminRoleB32, UD_721.address, {
          from: account1,
        });
      });
  });

  it("Should authorize all minter contracts for minting NODE_TKN(s)", () => {
    console.log("Authorizing NODE_MGR");
    return APP.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    })

      .then(() => {
        console.log("Authorizing NODE_MGR");
        return APP.grantRole(assetTransferRoleB32, APP.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return APP.grantRole(pauserRoleB32, DAO_A.address, {
          from: account1,
        });
      });
  });

  it("Should authorize A_TKN to discard", () => {
    console.log("Authorizing A_TKN");
    return RCLR.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    })

      .then(() => {
        console.log("Authorizing A_TKN");
        return RCLR.grantRole(discardRoleB32, A_TKN.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return RCLR.grantRole(pauserRoleB32, DAO_A.address, {
          from: account1,
        });
      });
  });

  it("Should authorize NODE_MGR for NODE_STOR", () => {
    console.log("Authorizing NODE_MGR");
    return NODE_STOR.grantRole(defaultAdminRoleB32, DAO_A.address, {
      from: account1,
    })

      .then(() => {
        console.log("Authorizing NODE_MGR");
        return NODE_STOR.grantRole(nodeAdminRoleB32, NODE_MGR.address, {
          from: account1,
        })

          .then(() => {
            console.log("Authorizing NODE_MGR");
            return NODE_STOR.grantRole(nodeAdminRoleB32, account1, {
              from: account1,
            });
          })

          .then(() => {
            console.log("Authorizing  DAO_A.address");
            return NODE_STOR.grantRole(DAOroleB32, DAO_A.address, {
              from: account1,
            });
          });
      })

      .then(() => {
        console.log("Authorizing DAO_A");
        return NODE_STOR.grantRole(pauserRoleB32, DAO_A.address, {
          from: account1,
        });
      })

      .then(() => {
        console.log("Authorizing  DAO_A.address");
        return NODE_STOR.grantRole(contractAdminRoleB32, DAO_A.address, {
          from: account1,
        });
      });
  });

  it("Should authorize account10 for nodeMinterRoleB32", () => {
    console.log("Authorizing NODE_MGR");
    return NODE_BLDR.grantRole(nodeMinterRoleB32, account10, {
      from: account1,
    });
  });

  it("Should authorize account10 for nodeMinterRoleB32", () => {
    console.log("Authorizing NODE_MGR");
    return NODE_STOR.grantRole(DAOroleB32, account1, {
      from: account1,
    });
  });

  it("Should authorize account10 for nodeMinterRoleB32", () => {
    console.log("Authorizing NODE_MGR");
    return A_TKN.grantRole(DAOroleB32, account1, {
      from: account1,
    });
  });

  it("Should set all permitted storage providers", () => {
    console.log("Authorizing UNCONFIGURED");
    return NODE_STOR.setStorageProviders("0", "1", { from: account1 })

      .then(() => {
        console.log("Authorizing Mutable");
        return NODE_STOR.setStorageProviders("1", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing ARWEAVE");
        return NODE_STOR.setStorageProviders("2", "1", { from: account1 });
      });
  });

  it("Should set all baseURI(s) for storage providers", () => {
    console.log("TEST0 == UNCONFIGURED");
    return A_TKN.setBaseURIforStorageType("0", "TEST0", { from: account1 })

      .then(() => {
        console.log("TEST1 == Mutable");
        return A_TKN.setBaseURIforStorageType("1", "TEST1", { from: account1 });
      })

      .then(() => {
        console.log("TEST2 == ARWEAVE");
        return A_TKN.setBaseURIforStorageType("2", "TEST2", { from: account1 });
      });
  });

  it("Should set all permitted management types", () => {
    console.log("Authorizing Unrestricted");
    return NODE_STOR.setManagementTypes("0", "1", { from: account1 })

      .then(() => {
        console.log("Authorizing Restricted");
        return NODE_STOR.setManagementTypes("1", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Less Restricted");
        return NODE_STOR.setManagementTypes("2", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Authorized");
        return NODE_STOR.setManagementTypes("3", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Trusted");
        return NODE_STOR.setManagementTypes("4", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Remotely Managed");
        return NODE_STOR.setManagementTypes("5", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Unconfigured");
        return NODE_STOR.setManagementTypes("255", "1", { from: account1 });
      });
  });

  it("Should set all permitted custody types", () => {
    console.log("Authorizing NONE");
    return NODE_STOR.setCustodyTypes("0", "1", { from: account1 })

      .then(() => {
        console.log("Authorizing Custodial");
        return NODE_STOR.setCustodyTypes("1", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Non-Custodial");
        return NODE_STOR.setCustodyTypes("2", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing ROOT");
        return NODE_STOR.setCustodyTypes("3", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Verify-Non-Custodial");
        return NODE_STOR.setCustodyTypes("4", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Wrapped or decorated ERC721");
        return NODE_STOR.setCustodyTypes("5", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Free Custodial");
        return NODE_STOR.setCustodyTypes("11", "1", { from: account1 });
      })

      .then(() => {
        console.log("Authorizing Free Non-Custodial");
        return NODE_STOR.setCustodyTypes("12", "1", { from: account1 });
      });
  });

  it("Should mint a couple of asset root tokens", () => {
    console.log("Minting root token 1 -C");
    return NODE_MGR.createNode(
      "1",
      "CUSTODIAL_ROOT",
      "1",
      "3",
      "0",
      "0",
      "9500",
      rgt000,
      rgt000,
      account1,
      { from: account1 }
    ).then(() => {
      console.log("Minting root token 2 -NC");
      return NODE_MGR.createNode(
        "2",
        "NON-CUSTODIAL_ROOT",
        "2",
        "3",
        "0",
        "0",
        "9500",
        rgt000,
        rgt000,
        account1,
        { from: account1 }
      );
    });
  });

  it("Should set costs in minted roots", () => {
    console.log("Setting costs in Node 1");

    return NODE_MGR.setOperationCosts("1", "1", "10000000000000000", account1, {
      from: account1,
    })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "1",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        console.log("Setting base costs in Node 2");
        return NODE_MGR.setOperationCosts(
          "2",
          "1",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "2",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "3",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "4",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "5",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "6",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "7",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      })

      .then(() => {
        return NODE_MGR.setOperationCosts(
          "2",
          "8",
          "10000000000000000",
          account1,
          {
            from: account1,
          }
        );
      });
  });

  it("Should Mint 2 cust and 2 non-cust Node tokens in AC_ROOT 1", () => {
    console.log("Minting PRUF to account1");
    return UTIL_TKN.mint(account1, "8000000000000000000000000", {
      from: account1,
    })

      .then(() => {
        console.log("Minting PRUF to account10");
        return UTIL_TKN.mint(account10, "4000000000000000000000000", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Minting Node 1000001 -C");
        return NODE_BLDR.purchaseNode(
          "Custodial_AC1",
          "1",
          "1",
          rgt000,
          rgt000,
          account1,
          { from: account1 }
        );
      })

      .then(() => {
        console.log("Minting Node 1000002 -NC");
        return NODE_BLDR.purchaseNode(
          "Non_Custodial_AC2",
          "1",
          "2",
          rgt000,
          rgt000,
          account1,
          { from: account1 }
        );
      })

      .then(() => {
        console.log("Minting Node 1000003 -NC");
        return NODE_BLDR.purchaseNode(
          "Non_Custodial_AC3",
          "1",
          "2",
          rgt000,
          rgt000,
          account1,
          { from: account1 }
        );
      })

      .then(() => {
        console.log("Minting Node 1000004 -NC");
        return NODE_BLDR.purchaseNode(
          "Non_Custodial_AC4",
          "1",
          "2",
          rgt000,
          rgt000,
          account10,
          { from: account10 }
        );
      });
  });

  it("Should Mint 2 non-cust Node tokens in AC_ROOT 2", () => {
    console.log("Minting Node 1000005 -NC");
    return NODE_BLDR.purchaseNode(
      "Non-Custodial_AC5",
      "2",
      "2",
      rgt000,
      rgt000,
      account1,
      { from: account1 }
    ).then(() => {
      console.log("Minting Node 1000006 -NC");
      return NODE_BLDR.purchaseNode(
        "Non_Custodial_AC6",
        "2",
        "2",
        rgt000,
        rgt000,
        account10,
        { from: account10 }
      );
    });
  });

  it("Should finalize all ACs", () => {
    console.log("Updating Node Immutables");
    return NODE_MGR.setNonMutableData(
      "1000001",
      "3",
      "1",
      "0x0000000000000000000000000000000000000000",
      "66",
      { from: account1 }
    )

      .then(() => {
        return NODE_MGR.setNonMutableData(
          "1000002",
          "2",
          "1",
          "0x0000000000000000000000000000000000000000",
          "66",
          { from: account1 }
        );
      })

      .then(() => {
        return NODE_MGR.setNonMutableData(
          "1000003",
          "2",
          "1",
          "0x0000000000000000000000000000000000000000",
          "66",
          { from: account1 }
        );
      })

      .then(() => {
        return NODE_MGR.setNonMutableData(
          "1000004",
          "2",
          "1",
          "0x0000000000000000000000000000000000000000",
          "66",
          { from: account10 }
        );
      })

      .then(() => {
        return NODE_MGR.setNonMutableData(
          "1000005",
          "2",
          "1",
          "0x0000000000000000000000000000000000000000",
          "66",
          { from: account1 }
        );
      })

      .then(() => {
        return NODE_MGR.setNonMutableData(
          "1000006",
          "2",
          "1",
          "0x0000000000000000000000000000000000000000",
          "66",
          { from: account10 }
        );
      });
  });

  it("Should finalize all ACs", () => {
    console.log("Authorizing Node Switch 1");
    return NODE_STOR.modifyNodeSwitches("1000001", "1", "0", {
      from: account1,
    })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000001", "7", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000002", "7", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000003", "7", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000004", "7", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000005", "7", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000006", "7", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000001", "8", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000002", "8", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000003", "8", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000004", "8", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000005", "8", "1", {
          from: account1,
        });
      })

      .then(() => {
        return NODE_STOR.modifyNodeSwitches("1000006", "8", "1", {
          from: account1,
        });
      });
  });

  it("Should authorize APP in all relevant nodes", () => {
    console.log("Authorizing APP");
    return STOR.enableContractForNode("APP", "1000001", "1", {
      from: account1,
    }).then(() => {
      return STOR.enableContractForNode("APP", "1000002", "1", {
        from: account1,
      });
    });
  });

  it("Should authorize APP_NC in all relevant nodes", () => {
    console.log("Authorizing APP_NC");
    return STOR.enableContractForNode("APP_NC", "1000003", "2", {
      from: account1,
    })

      .then(() => {
        return STOR.enableContractForNode("APP_NC", "1000003", "2", {
          from: account1,
        });
      })

      .then(() => {
        return STOR.enableContractForNode("APP_NC", "1000004", "2", {
          from: account10,
        });
      })

      .then(() => {
        return STOR.enableContractForNode("APP_NC", "1000006", "2", {
          from: account10,
        });
      });
  });

  it("Should authorize APP in all relevant nodes", () => {
    console.log("Authorizing APP");
    return STOR.enableContractForNode("APP", "1000001", "1", {
      from: account1,
    }).then(() => {
      return STOR.enableContractForNode("APP", "1000002", "1", {
        from: account1,
      });
    });
  });

  it("Should authorize MAL_APP in all relevant nodes", () => {
    console.log("Authorizing MAL_APP");
    return STOR.enableContractForNode("MAL_APP", "1000001", "1", {
      from: account1,
    }).then(() => {
      return STOR.enableContractForNode("MAL_APP", "1000002", "1", {
        from: account1,
      });
    });
  });

  it("Should authorize ECR in all relevant nodes", () => {
    console.log("Authorizing ECR");
    return STOR.enableContractForNode("ECR", "1000001", "3", {
      from: account1,
    }).then(() => {
      return STOR.enableContractForNode("ECR", "1000002", "3", {
        from: account1,
      });
    });
  });

  it("Should authorize ECR_NC in all relevant nodes", () => {
    console.log("Authorizing ECR_NC");
    return STOR.enableContractForNode("ECR_NC", "1000003", "3", {
      from: account1,
    })

      .then(() => {
        return STOR.enableContractForNode("ECR_NC", "1000004", "3", {
          from: account10,
        });
      })

      .then(() => {
        return STOR.enableContractForNode("ECR_NC", "1000005", "3", {
          from: account1,
        });
      })

      .then(() => {
        return STOR.enableContractForNode("ECR_NC", "1000006", "3", {
          from: account10,
        });
      });
  });

  it("Should authorize ECR2 in all relevant nodes", () => {
    console.log("Authorizing ECR2");
    return STOR.enableContractForNode("ECR2", "1000001", "3", {
      from: account1,
    }).then(() => {
      return STOR.enableContractForNode("ECR2", "1000002", "3", {
        from: account1,
      });
    });
  });

  it("Should authorize A_TKN in all relevant nodes", () => {
    console.log("Authorizing A_TKN");
    return STOR.enableContractForNode("A_TKN", "1", "1", { from: account1 })

      .then(() => {
        return STOR.enableContractForNode("A_TKN", "2", "1", {
          from: account1,
        });
      })

      .then(() => {
        return STOR.enableContractForNode("A_TKN", "1000001", "1", {
          from: account1,
        });
      })

      .then(() => {
        return STOR.enableContractForNode("A_TKN", "1000002", "1", {
          from: account1,
        });
      });
  });

  it("Should add users to Node 1000001-1000006 in AC_Manager", () => {
    console.log(
      "//**************************************END BOOTSTRAP**********************************************/"
    );
    console.log("Account2 => 1000001");
    return NODE_MGR.addUser("1000001", account4Hash, "1", { from: account1 })

      .then(() => {
        console.log("Account2 => 1000001");
        return NODE_MGR.addUser("1000001", account2Hash, "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Account2 => 1000001");
        return NODE_MGR.addUser("1000001", account1Hash, "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Account1 => 1000003");
        return NODE_MGR.addUser("1000003", account1Hash, "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Account2 => 1000003");
        return NODE_MGR.addUser("1000003", account2Hash, "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Account4 => 1000003");
        return NODE_MGR.addUser("1000003", account4Hash, "1", {
          from: account1,
        });
      })

      .then(() => {
        console.log("Account4 => 1000004");
        return NODE_MGR.addUser("1000004", account4Hash, "1", {
          from: account10,
        });
      })

      .then(() => {
        console.log("Account4 => 1000006");
        return NODE_MGR.addUser("1000006", account4Hash, "1", {
          from: account10,
        });
      })

      .then(() => {
        console.log("Account10 => 1000001");
        return NODE_MGR.addUser("1000001", account10Hash, "1", {
          from: account1,
        });
      });
  });

  it("Should mint 30000 tokens to account2", async () => {
    return UTIL_TKN.mint(account2, "30000000000000000000000", {
      from: account1,
    });
  });

  //1
  it("Should fail because caller !DAO_LAYER", () => {
    console.log(
      "//**************************************END DAO_STOR SETUP**********************************************/"
    );
    console.log(
      "//**************************************BEGIN DAO_STOR FAIL BATCH (48)**********************************************/"
    );
    console.log(
      "//**************************************BEGIN setQuorum FAIL BATCH**********************************************/"
    );
    return DAO_STOR.setQuorum("2", { from: account2 });
  });

  //2
  it("Should fail because quorum is too high", () => {
    return DAO_STOR.setQuorum("15", { from: account1 });
  });

  //3
  it("Should fail because caller !DAO_LAYER", () => {
    console.log(
      "//**************************************END setQuorum FAIL BATCH**********************************************/"
    );
    console.log(
      "//**************************************BEGIN setPassingMargin FAIL BATCH**********************************************/"
    );
    return DAO_STOR.setPassingMargin('51', {
      from: account2,
    });
  });

  //4
  it("Should fail because passing margin is under 50", () => {
    return DAO_STOR.setPassingMargin('49', {
      from: account1,
    });
  });

  //5
  it("Should fail because caller !DAO_LAYER", () => {
    console.log(
      "//**************************************END setPassingMargin FAIL BATCH**********************************************/"
    );
    console.log(
      "//**************************************BEGIN setMaxVote FAIL BATCH**********************************************/"
    );
    return DAO_STOR.setMaxVote('99999999', {
      from: account2,
    });
  });

  //6
  it("Should fail because MaxVote is too high", () => {
    return DAO_STOR.setMaxVote('100000001', {
      from: account1,
    });
  });

  //7
  it("Should fail because caller !CONTRACT_ADMIN", () => {
    console.log(
      "//**************************************END setMaxVote FAIL BATCH**********************************************/"
    );
    console.log(
      "//**************************************BEGIN resolveContractAddresses FAIL BATCH**********************************************/"
    );
    return DAO_STOR.resolveContractAddresses({
      from: account2,
    });
  });

  //8
  it("Should fail because caller !DAO_ADMIN", () => {
    console.log(
      "//**************************************END resolveContractAddresses FAIL BATCH**********************************************/"
    );
    console.log(
      "//**************************************BEGIN adminCreateMotion FAIL BATCH**********************************************/"
    );
    return DAO_STOR.adminCreateMotion(rgt1, account1, {
      from: account9,
    });
  });

  it("Should set grantRoleSig", () => {
    grantRoleSig = web3.utils.keccak256(web3.eth.abi.encodeParameters(
      ['string', 'address', 'bytes32', 'address', 'string'],
      ['DAO_grantRole', DAO_A.address, minterRoleB32, APP_NC.address, 'A_TKN']
      )
    );
    return console.log(grantRoleSig);
  });

  it("Should createMotion", () => {
    return DAO_STOR.adminCreateMotion(grantRoleSig, account1, {
      from: account1,
    });
  });

  //9
  it("Should fail because motion already exists", () => {
    return DAO_STOR.adminCreateMotion(grantRoleSig, account1, {
      from: account1,
    });
  });

  it("Should set grantRoleSigComplete", async () => {
    grantRoleSigComplete = await DAO_STOR.getMotionByIndex("0", {
      from: account1,
    });
    return console.log(grantRoleSigComplete);
  });

  //10
  it("Should fail because caller !DAO_ADMIN", () => {
    console.log(
      "//**************************************END adminCreateMotion FAIL BATCH**********************************************/"
    );
    console.log(
      "//**************************************BEGIN adminVote FAIL BATCH**********************************************/"
    );
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000001", "10000", "1", account1, {
      from: account9,
    });
  });

  //11
  it("Should fail because motion not in proposed status", () => {
    return DAO_STOR.adminVote(grantRoleSig, "1000001", "10000", "1", account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("1", "10", { from: account1 });
  });

  it("Should vote on motion", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000001", "10000", "1", account1, {
      from: account1,
    });
  });

  it("Should vote on motion", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000002", "10000", "1", account1, {
      from: account1,
    });
  });

  it("Should vote on motion", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000003", "10000", "1", account1, {
      from: account1,
    });
  });

  it("Should vote on motion", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000004", "10000", "1", account1, {
      from: account1,
    });
  });

  it("Should vote on motion", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000005", "10000", "1", account1, {
      from: account1,
    });
  });

  //12
  it("Should fail because node has already voted", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000001", "10000", "1", account1, {
      from: account1,
    });
  });

  //13
  it("Should fail because y/n !1||0", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000006", "10000", "2", account1, {
      from: account1,
    });
  });

  //14
  it("Should fail because caller !DAO_LAYER", () => {
    console.log(
      "//**************************************END adminVote FAIL BATCH**********************************************/"
    );
    console.log(
      "//**************************************BEGIN verifyResolution FAIL BATCH**********************************************/"
    );
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account1, {
      from: account9,
    });
  });

  //15
  it("Should fail because motion is not valid in this epoch", () => {
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("2", "10", { from: account1 });
  });

  it("Should resolve motion", () => {
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account1, {
      from: account1,
    });
  });

  //16
  it("Should fail because motion already resolved", () => {
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account1, {
      from: account1,
    });
  });

  it("Should createMotion(1)", () => {
    return DAO_STOR.adminCreateMotion(grantRoleSig, account1, {
      from: account1,
    });
  });

  it("Should set grantRoleSigComplete", async () => {
    grantRoleSigComplete = await DAO_STOR.getMotionByIndex("1", {
      from: account1,
    });
    return console.log(grantRoleSigComplete);
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("3", "10", { from: account1 });
  });

  it("Should vote no on motion(1)", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000001", "10000", "0", account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("4", "10", { from: account1 });
  });

  //17
  it("Should fail because motion was rejected by majority", () => {
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("3", "10", { from: account1 });
  });

  it("Should vote yes on motion(1)", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000002", "10000", "1", account1, {
      from: account1,
    });
  });

  it("Should vote yes on motion(1)", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000003", "20000", "1", account1, {
      from: account1,
    });
  });

  it("Should vote no on motion(1)", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000004", "10000", "0", account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("4", "10", { from: account1 });
  });

  // it("Should return motionData", async () => {
  //   // console.log({ grantRoleSigComplete });
  //   result = await DAO_STOR.getMotionData(grantRoleSigComplete, {
  //     from: account1,
  //   });
  //   return console.log(Object.values({result}));
  // });

  it("Should return motionData", async () => {
    var Record = [];

    return await DAO_STOR.getMotionData(
      grantRoleSigComplete,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  //18
  it("Should fail because does not meet quorum", () => {
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("3", "10", { from: account1 });
  });

  it("Should vote yes on motion(1)", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000005", "1000", "0", account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("4", "10", { from: account1 });
  });

  it("Should return motionData", async () => {
    var Record = [];

    return await DAO_STOR.getMotionData(
      grantRoleSigComplete,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  //19
  it("Should fail because vote does not pass due to majority", () => {
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("3", "10", { from: account1 });
  });

  it("Should vote no on motion(1)", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000006", "1000000", "1", account1, {
      from: account1,
    });
  });

  it("Should vote no on motion(1)", () => {
    return DAO_STOR.adminVote(grantRoleSigComplete, "1000007", "1000000", "1", account1, {
      from: account1,
    });
  });

  it("Should setEpoch", async () => {
    return CLOCK.setClock("4", "10", { from: account1 });
  });

  it("Should return motionData", async () => {
    var Record = [];

    return await DAO_STOR.getMotionData(
      grantRoleSigComplete,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  //20
  it("Should fail because caller not authorized to execute resolution", () => {
    return DAO_STOR.verifyResolution(grantRoleSigComplete, account2, {
      from: account1,
    });
  });

  it("Should set SharesAddress", async () => {
    console.log(
      "//**************************************END DAO_STOR TEST**********************************************/"
    );
    console.log(
      "//**************************************BEGIN THE WORKS CUSTODIAL**********************************************/"
    );
    return UTIL_TKN.AdminSetSharesAddress(account1, { from: account1 });
  });

  it("Should mint 30000 tokens to account2", async () => {
    return UTIL_TKN.mint(account2, "30000000000000000000000", {
      from: account1,
    });
  });

  it("Should mint 30000 tokens to account4", async () => {
    return UTIL_TKN.mint(account4, "30000000000000000000000", {
      from: account1,
    });
  });

  it("Should write asset12 in Node 1000001", async () => {
    return APP.newRecord(asset12raw, rgt12, "1000001", "100", asset12raw, {
      from: account2,
    });
  });

  it("Should retrieve show clean asset 12", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of new asset12 to status(1)", async () => {
    return APP.modifyStatus(asset12, rgt12, "1", { from: account2 });
  });

  it("Should retrieve asset12 @stat(1)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should Transfer asset12 RGT(12) to RGT(2)", async () => {
    return APP.transferAsset(asset12, rgt12, rgt2, { from: account2 });
  });

  it("Should retrieve asset12 @newRgt(rgt2) && +1 N.O.T", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should force modify asset12 RGT(2) to RGT(12)", async () => {
    return APP.forceModifyRecord(asset12, rgt12, { from: account2 });
  });

  it("Should retrieve asset12 @newStat(0) && @newRgt(rgt12) && +1 FMR count && +1 N.O.T", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should decrement asset12 amount from (100) to (85)", async () => {
    return APP.decrementCounter(asset12, rgt12, "15", { from: account2 });
  });

  it("Should retrieve asset12 @newDecCount(85)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should modify Mutable note @asset12 to (asset12)", async () => {
    return APP.modifyMutableStorage(asset12, rgt12, asset12, rgt000, {
      from: account2,
    });
  });

  it("Should retrieve asset12 with newMutable(asset12)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of new asset12 to status(51)", async () => {
    return APP.modifyStatus(asset12, rgt12, "51", { from: account2 });
  });

  it("Should retrieve asset12 @newStatus(51)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should set NonMutable note to (asset12)", async () => {
    return APP.addNonMutableStorage(asset12, rgt12, asset12, rgt000, {
      from: account2,
    });
  });

  it("Should retrieve asset12 with newNonMutable(asset12)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of asset12 to status(1)", async () => {
    return APP.modifyStatus(asset12, rgt12, "1", { from: account2 });
  });

  it("Should retrieve asset12 @newStatus(1)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should set asset12 into locked escrow for 3 minutes", async () => {
    return ECR.setEscrow(asset12, account2Hash, "180", "50", {
      from: account2,
    });
  });

  it("Should retrieve asset12 @newStatus((50)ECR)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should take asset12 out of escrow", async () => {
    return ECR.endEscrow(asset12, { from: account2 });
  });

  it("Should retrieve asset12 @newStatus(58)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of asset12 to status(1)", async () => {
    return APP.modifyStatus(asset12, rgt12, "1", { from: account2 });
  });

  it("Should retrieve asset12 @newStatus(1)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should set asset12 to stolen(3) status", async () => {
    return APP.setLostOrStolen(asset12, rgt12, "3", { from: account2 });
  });

  it("Should retrieve asset12 @newStatus(3)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of asset12 to status(51)", async () => {
    return APP.modifyStatus(asset12, rgt12, "51", { from: account2 });
  });

  it("Should retrieve asset12 @newStaus(51)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset12,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should write asset13 in Node 1000003", async () => {
    console.log(
      "//**************************************BEGIN THE WORKS NON CUSTODIAL**********************************************/"
    );
    return APP_NC.newRecord(asset13raw, rgt13, "1000003", "100", asset13raw, {
      from: account1,
    });
  });

  it("Should retrieve show clean asset 13", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should decrement asset13 amount from (100) to (85)", async () => {
    return APP_NC.decrementCounter(asset13, "15", { from: account1 });
  });

  it("Should retrieve asset13 @newDecCount(85)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should modify Mutable note @asset13 to (asset13)", async () => {
    return APP_NC.modifyMutableStorage(asset13, asset13, rgt000, {
      from: account1,
    });
  });

  it("Should retrieve asset13 with newMutable(asset13)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should set NonMutable note to (asset13)", async () => {
    return APP_NC.addNonMutableStorage(asset13, asset13, rgt000, {
      from: account1,
    });
  });

  it("Should retrieve asset13 with newNonMutable(asset13)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account1 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should force modify asset13 rgt13 to RGT(2)", async () => {
    return APP_NC.changeRgt(asset13, rgt2, { from: account1 });
  });

  it("Should retrieve asset13 @newRgt(2)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should set asset13 to stolen(53) status", async () => {
    return APP_NC.setLostOrStolen(asset13, "53", { from: account1 });
  });

  it("Should retrieve asset13 @newStatus(53)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of new asset12 to status(51)", async () => {
    return APP_NC.modifyStatus(asset13, "51", { from: account1 });
  });

  it("Should retrieve asset13 @stat(51)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should set asset12 into escrow for 3 minutes", async () => {
    return ECR_NC.setEscrow(asset13, account1Hash, "180", "56", {
      from: account1,
    });
  });

  it("Should retrieve asset13 @newStatus((56)(ECR))", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should take asset12 out of escrow", async () => {
    return ECR_NC.endEscrow(asset13, { from: account1 });
  });

  it("Should retrieve asset13  @newStatus(57)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of asset13 to status(59)", async () => {
    return APP_NC.modifyStatus(asset13, "59", { from: account1 });
  });

  it("Should retrieve asset13 @newStaus(59)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should discard asset13", async () => {
    return A_TKN.discard(asset13, { from: account1 });
  });

  it("Should retrieve asset13 @newStaus((60)discarded)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should recycle asset13", async () => {
    return RCLR.recycle(asset13, rgt13, { from: account1 });
  });

  it("Should retrieve asset13  @newRgt(13) && @newAC(1000003) && +1 N.O.T && @newStatus(58)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account4 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });

  it("Should change status of asset12 to status(51)", async () => {
    return APP_NC.modifyStatus(asset13, "51", { from: account1 });
  });

  it("Should retrieve asset12 @newStaus(51)", async () => {
    var Record = [];

    return await STOR.retrieveShortRecord(
      asset13,
      { from: account2 },
      function (_err, _result) {
        if (_err) {
        } else {
          Record = Object.values(_result);
          console.log(Record);
        }
      }
    );
  });
});