/*--------------------------------------------------------PRüF0.8.6
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

const PRUF_UTIL_TKN = artifacts.require("UTIL_TKN");
const PRUF_STAKE_TKN = artifacts.require("STAKE_TKN");
const PRUF_STAKE_VAULT = artifacts.require("STAKE_VAULT");
const PRUF_REWARD_VAULT = artifacts.require("REWARDS_VAULT");
const PRUF_EO_STAKING = artifacts.require("EO_STAKING");
const PRUF_HELPER = artifacts.require("Helper");

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
let stakeRoleB32;
let stakeAdminRoleB32;
let stakePayerRoleB32;
let pauserRoleB32;

contract("EO_STAKING", (accounts) => {
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

    nodeAdminRoleB32 = await Helper.getStringHash("NODE_ADMIN_ROLE");

    stakeRoleB32 = await Helper.getStringHash("STAKE_ROLE");

    stakeAdminRoleB32 = await Helper.getStringHash("STAKE_ADMIN_ROLE");

    stakePayerRoleB32 = await Helper.getStringHash("STAKE_PAYER_ROLE");

    pauserRoleB32 = await Helper.getStringHash("PAUSER_ROLE");
  });

  it("Should authorize STAKE_VAULT for trusted agent functions in UTIL_TKN", async () => {
    console.log(
      "//**************************************END BOOTSTRAP**********************************************/"
    );
    console.log(
      "//**************************************BEGIN REWARDS_VAULT TEST**********************************************/"
    );
    console.log(
      "//**************************************BEGIN REWARDS_VAULT SETUP**********************************************/"
    );
    return UTIL_TKN.grantRole(trustedAgentRoleB32, STAKE_VAULT.address, {
      from: account1,
    });
  });

  it("Should authorize EO_STAKING to mint STAKE_TKNs", async () => {
    return STAKE_TKN.grantRole(minterRoleB32, EO_STAKING.address, {
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

  it("Should authorize EO_STAKING to take stakes out of the STAKE_VAULT", async () => {
    return STAKE_VAULT.grantRole(stakeAdminRoleB32, EO_STAKING.address, {
      from: account1,
    });
  });

  it("Should authorize EO_STAKING to take stakes out of the STAKE_VAULT", async () => {
    return UTIL_TKN.grantRole(pauserRoleB32, STAKE_VAULT.address, {
      from: account1,
    });
  });

  it("Should authorize EO_STAKING to take stakes out of the STAKE_VAULT", async () => {
    return UTIL_TKN.grantRole(pauserRoleB32, REWARDS_VAULT.address, {
      from: account1,
    });
  });

  it("Should mint 300000000 tokens to REWARDS_VAULT", async () => {
    return UTIL_TKN.mint(REWARDS_VAULT.address, "300000000000000000000000000", {
      from: account1,
    });
  });

  it("Should retrieve balanceOf(300000000) Pruf tokens REWARDS_VAULT", async () => {
    var Balance = [];

    return await UTIL_TKN.balanceOf(
      REWARDS_VAULT.address,
      { from: account1 },
      function (_err, _result) {
        if (_err) {
        } else {
          Balance = Object.values(_result);
          console.log(Balance);
        }
      }
    );
  });

  it("Should mint 50000 tokens to account2", async () => {
    return UTIL_TKN.mint(account2, "50000000000000000000000", {
      from: account1,
    });
  });

  it("Should mint 300000 tokens to account2", async () => {
    return UTIL_TKN.mint(account3, "300000000000000000000000", {
      from: account1,
    });
  });

  it("Should retrieve balanceOf(50000) Pruf tokens @account2", async () => {
    var Balance = [];

    return await UTIL_TKN.balanceOf(
      account2,
      { from: account1 },
      function (_err, _result) {
        if (_err) {
        } else {
          Balance = Object.values(_result);
          console.log(Balance);
        }
      }
    );
  });

  it("Should set token contracts in REWARDS_VAULT", async () => {
    return REWARDS_VAULT.setTokenContracts(
      UTIL_TKN.address,
      STAKE_TKN.address,
      { from: account1 }
    );
  });

  it("Should set token contracts in STAKE_VAULT", async () => {
    return STAKE_VAULT.setTokenContracts(
      UTIL_TKN.address,
      STAKE_TKN.address,
      { from: account1 }
    );
  });

  it("Should set token contracts in EO_STAKING", async () => {
    return EO_STAKING.setTokenContracts(
      UTIL_TKN.address,
      STAKE_TKN.address,
      STAKE_VAULT.address,
      REWARDS_VAULT.address,
      { from: account1 }
    );
  });

  function timeout(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }

  it("Should pause UTIL_TKN", async () => {
    return UTIL_TKN.pause({ from: account1 });
  });

  //1
  it("Should fail because caller !have ASSET_TXFR_ROLE", async () => {
    console.log(
      "//**************************************END REWARDS_VAULT SETUP**********************************************/"
    );
    console.log(
      "//**************************************BEGIN EO_STAKING Fail Batch(21)**********************************************/"
    );
    console.log(
      "//**************************************BEGIN transferERC721Token Fail Batch**********************************************/"
    );
    return EO_STAKING.transferERC721Token(account2, "1", STAKE_TKN.address, {
      from: account1,
    });
  });

  //2
  it("Should fail because caller !contractAdmin", async () => {
    console.log(
      "//**************************************END transferERC721Token Fail Batch**********************************************/"
    );
    console.log(
      "//**************************************BEGIN setTokenContracts Fail Batch**********************************************/"
    );
    return EO_STAKING.setTokenContracts(
      UTIL_TKN.address,
      STAKE_TKN.address,
      STAKE_VAULT.address,
      REWARDS_VAULT.address,
      { from: account2 }
    );
  });

  //3
  it("Should fail because caller !contractAdmin", async () => {
    console.log(
      "//**************************************END setTokenContracts Fail Batch**********************************************/"
    );
    console.log(
      "//**************************************BEGIN setStakeLevels Fail Batch**********************************************/"
    );
    return EO_STAKING.setStakeLevels(
      "1",
      "1000000000000000000000",
      "100000000000000000000000",
      "1",
      "50",
      {
        from: account2,
      }
    );
  });

  //4
  it("Should fail because interval !>=2", async () => {
    return EO_STAKING.setStakeLevels(
      "2",
      "1000000000000000000000",
      "100000000000000000000000",
      "0",
      "50",
      {
        from: account1,
      }
    );
  });

  //5
  it("Should fail because min < ü100", async () => {
    return EO_STAKING.setStakeLevels(
      "2",
      "99999999999999999999",
      "100000000000000000000000",
      "2",
      "50",
      {
        from: account1,
      }
    );
  });

  //6
  it("Should fail because staking tier is inactive", async () => {
    console.log(
      "//**************************************END setStakeLevels Fail Batch**********************************************/"
    );
    console.log(
      "//**************************************BEGIN stakeMyTokens Fail Batch**********************************************/"
    );
    return EO_STAKING.stakeMyTokens("100000000000000000000000", "1", {
      from: account2,
    });
  });

  it("Should create staking tier 1", async () => {
    return EO_STAKING.setStakeLevels(
      "1",
      "1000000000000000000000",
      "1000000000000000000000000",
      "2",
      "50",
      {
        from: account1,
      }
    );
  });

  //7
  it("Should fail because stake above maximum for this tier", async () => {
    return EO_STAKING.stakeMyTokens("100000000000000000000001", "1", {
      from: account3,
    });
  });

  //8
  it("Should fail because stake below minimum for this tier", async () => {
    return EO_STAKING.stakeMyTokens("990000000000000000000", "1", {
      from: account2,
    });
  });

  it("Should stake 10000 tokens from account2", async () => {
    return EO_STAKING.stakeMyTokens("10000000000000000000000", "1", {
      from: account2,
    });
  });

  //9
  it("Should fail because caller !stakeHolder", async () => {
    console.log(
      "//**************************************END stakeMyTokens Fail Batch**********************************************/"
    );
    console.log(
      "//**************************************BEGIN increaseMyStake Fail Batch**********************************************/"
    );
    return EO_STAKING.increaseMyStake("1", "10000000000", {
      from: account1,
    });
  });

  it("Should pause EO_STAKING", async () => {
    return EO_STAKING.pause({ from: account1 });
  });

  //10
  it("Should fail because contract is paused and caller !have pauser_role", async () => {
    return EO_STAKING.increaseMyStake("1", "10000000000", {
      from: account2,
    });
  });

  it("Should unpause EO_STAKING", async () => {
    return EO_STAKING.unpause({ from: account1 });
  });

  it("should end staking", async () => {
    return EO_STAKING.endStaking(0, { from: account1});
  })

  //11
  it("Should fail because new stakes cannot be created", async () => {
    return EO_STAKING.increaseMyStake("1", "10000000000", {
      from: account2,
    });
  });

  it("should resume staking", async () => {
    return EO_STAKING.endStaking(100000000, { from: account1});
  })

  //12
  it("Should fail because caller has not waited 24h since stake", async () => {
    return EO_STAKING.increaseMyStake("1", "10000000000", {
      from: account2,
    });
  });

  //13
  it("Should fail because caller cannot increase stake > maximum", async () => {
    await timeout(2000).then(() => {
    return EO_STAKING.increaseMyStake("1", "1000000000000000000000000", {
      from: account2,
    });
  })
  });

  //14
  it("Should fail because caller does not hold sufficient tokens", async () => {
    return EO_STAKING.increaseMyStake("1", "95000000000000000000000", {
      from: account2,
    });
  });

  it("Should mint 300000 tokens to account2", async () => {
    return UTIL_TKN.mint(account2, "300000000000000000000000", {
      from: account1,
    });
  });

  //15
  it("Should fail because caller !stakeHolder", async () => {
    console.log(
      "//**************************************END increaseMyStake Fail Batch**********************************************/"
    );
    console.log(
      "//**************************************BEGIN claimBonus Fail Batch**********************************************/"
    );
    return EO_STAKING.claimBonus("1", {
      from: account1,
    });
  });

  it("Should pause stake_vault", async () => {
    return EO_STAKING.pause({ from: account1 });
  });

  //16
  it("Should fail because contract is paused and caller !have pauser_role", async () => {
    return EO_STAKING.claimBonus("1", { from: account2 });
  });

  it("Should unpause stake_vault", async () => {
    return EO_STAKING.unpause({ from: account1 });
  });

  it("Should create staking tier 2", async () => {
    return EO_STAKING.setStakeLevels(
      "2",
      "1000000000000000000000",
      "100000000000000000000000",
      "10",
      "50",
      {
        from: account1,
      }
    );
  });

  it("Should stake 10000 more tokens from account2", async () => {
    return EO_STAKING.stakeMyTokens("10000000000000000000000", "2", {
      from: account2,
    });
  });

  //17
  it("Should fail because caller has not waited 24h since staking", async () => {
    return EO_STAKING.claimBonus("2", { from: account2 });
  });

  //18
  it("Should fail because caller !stakeHolder", async () => {
    console.log(
      "//**************************************END stakeMyTokens Fail Batch**********************************************/"
    );
    console.log(
      "//**************************************BEGIN breakStake Fail Batch**********************************************/"
    );
    return EO_STAKING.breakStake("1", { from: account1 });
  });

  it("Should pause stake_vault", async () => {
    return EO_STAKING.pause({ from: account1 });
  });

  //19
  it("Should fail because contract is paused and caller !have pauser_role", async () => {
    return EO_STAKING.breakStake("1", { from: account2 });
  });

  it("Should unpause stake_vault", async () => {
    return EO_STAKING.unpause({ from: account1 });
  });

  //20
  it("Should fail because stake period has not elapsed", async () => {
    return EO_STAKING.breakStake("2", { from: account2 });
  });

  it("Should claim bonus from stake 1", async () => {
    await timeout(1000);
    return EO_STAKING.claimBonus("1", { from: account2 });
  });

  //21
  it("Should fail because must wait full iteration before breaking stake", async () => {
    return EO_STAKING.breakStake("1", { from: account2 });
  });

  it("Should create staking tier 3", async () => {
    console.log(
      "//**************************************END breakStake Fail Batch**********************************************/"
    );
    console.log(
      "//**************************************BEGIN newStake(internal) Fail Batch**********************************************/"
    );
    return EO_STAKING.setStakeLevels(
      "3",
      "100000000000000000000",
      "100000000000000000000000",
      "10",
      "50",
      {
        from: account1,
      }
    );
  });
});
