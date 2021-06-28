/*--------------------------------------------------------PRuF0.8.0
__/\\\\\\\\\\\\\ _____/\\\\\\\\\ _______/\\__/\\ ___/\\\\\\\\\\\\\\\        
 _\/\\\/////////\\\ _/\\\///////\\\ ____\//__\//____\/\\\///////////__       
  _\/\\\_______\/\\\_\/\\\_____\/\\\ ________________\/\\\ ____________      
   _\/\\\\\\\\\\\\\/__\/\\\\\\\\\\\/_____/\\\____/\\\_\/\\\\\\\\\\\ ____     
    _\/\\\/////////____\/\\\//////\\\ ___\/\\\___\/\\\_\/\\\///////______    
     _\/\\\ ____________\/\\\ ___\//\\\ __\/\\\___\/\\\_\/\\\ ____________   
      _\/\\\ ____________\/\\\ ____\//\\\ _\/\\\___\/\\\_\/\\\ ____________  
       _\/\\\ ____________\/\\\ _____\//\\\_\//\\\\\\\\\ _\/\\\ ____________ 
        _\/// _____________\/// _______\/// __\///////// __\/// _____________
         *-------------------------------------------------------------------*/

const PRUF_UTIL_TKN = artifacts.require("UTIL_TKN");
const PRUF_STAKE_TKN = artifacts.require("STAKE_TKN");
const PRUF_STAKE_VAULT = artifacts.require("STAKE_VAULT");
const PRUF_REWARD_VAULT = artifacts.require("REWARDS_VAULT");
const PRUF_EO_STAKING = artifacts.require("EO_STAKING");
const PRUF_HELPER = artifacts.require('Helper');

let UTIL_TKN;
let STAKE_TKN;
let STAKE_VAULT;
let REWARDS_VAULT;
let EO_STAKING;
let Helper;

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

let payableRoleB32;
let minterRoleB32;
let trustedAgentRoleB32;
let assetTransferRoleB32;
let discardRoleB32;

contract("REWARDS_VAULT", (accounts) => {
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

  it("Should deploy PRUF_UTIL_TKN", async () => {
    const PRUF_UTIL_TKN_TEST = await PRUF_UTIL_TKN.deployed({ from: account1 });
    console.log(PRUF_UTIL_TKN_TEST.address);
    assert(PRUF_UTIL_TKN_TEST.address !== "");
    UTIL_TKN = PRUF_UTIL_TKN_TEST;
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

  it("Should build variables", async () => {
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

    ECR_MGRHASH = await Helper.getStringHash("ECR_MGR");

    payableRoleB32 = await Helper.getStringHash("PAYABLE_ROLE");

    minterRoleB32 = await Helper.getStringHash("MINTER_ROLE");

    trustedAgentRoleB32 = await Helper.getStringHash("TRUSTED_AGENT_ROLE");

    assetTransferRoleB32 = await Helper.getStringHash("ASSET_TXFR_ROLE");

    discardRoleB32 = await Helper.getStringHash("DISCARD_ROLE");
  });

  //1
  it("Should fail because caller !contractAdmin", async () => {
    console.log("//**************************************END BOOTSTRAP**********************************************/");
    console.log("//**************************************BEGIN REWARDS_VAULT TEST**********************************************/");
    console.log("//**************************************BEGIN REWARDS_VAULT Fail Batch**********************************************/");
    console.log("//**************************************BEGIN Admin_setTokenContracts Fail Batch**********************************************/");
    return REWARDS_VAULT.Admin_setTokenContracts(UTIL_TKN.address, STAKE_TKN.address, { from: account2 });
  });


  it("Should pause stake_vault", async () => {
    return REWARDS_VAULT.pause({ from: account1 });
  });

  //2
  it("Should fail because contract is paused and caller !have pauser_role", async () => {
    console.log("//**************************************END Admin_setTokenContracts Fail Batch**********************************************/");
    console.log("//**************************************BEGIN payRewards Fail Batch**********************************************/");
    return REWARDS_VAULT.payRewards('1', "10000000000000000000000", { from: account2 });
  });
  

  it("Should unpause stake_vault", async () => {
    return REWARDS_VAULT.unpause({ from: account1 });
  });
  
  //3
  it("Should fail because caller !stakePayer", async () => {
    console.log("//**************************************END Admin_setTokenContracts Fail Batch**********************************************/");
    console.log("//**************************************BEGIN payRewards Fail Batch**********************************************/");
    return REWARDS_VAULT.payRewards('1', "10000000000000000000000", { from: account1 });
  });

  //4
  it("Should fail because caller !have ASSET_TXFR_ROLE", async () => {
    console.log("//**************************************END payRewards Fail Batch**********************************************/");
    console.log("//**************************************BEGIN transferERC721Token Fail Batch**********************************************/");
    return REWARDS_VAULT.transferERC721Token(account2, '1', STAKE_TKN.address, { from: account1 });
  });

});
