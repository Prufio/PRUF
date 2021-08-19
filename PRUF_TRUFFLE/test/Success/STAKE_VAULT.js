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
        let stakePayerRoleB32;
        
        contract("STAKE_VAULT", (accounts) => {
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
        
            stakeRoleB32 = await Helper.getStringHash("STAKE_ROLE");
        
            stakePayerRoleB32 = await Helper.getStringHash("STAKE_PAYER_ROLE");

            stakeAdminRoleB32 = await Helper.getStringHash("STAKE_ADMIN_ROLE");
          });
        
          it("Should authorize STAKE_VAULT for trusted agent functions in UTIL_TKN", async () => {
            console.log(
              "//**************************************END BOOTSTRAP**********************************************/"
            );
            console.log(
              "//**************************************BEGIN STAKE_VAULT TEST**********************************************/"
            );
            console.log(
              "//**************************************BEGIN STAKE_VAULT SETUP**********************************************/"
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


          it("Should authorize EO_STAKING as stake admin in stake_vault", async () => {
            return STAKE_VAULT.grantRole(stakeAdminRoleB32, account1, {
              from: account1,
            });
          });


          it("Should authorize EO_STAKING as stake admin in stake_vault", async () => {
            return STAKE_VAULT.grantRole(stakeAdminRoleB32, EO_STAKING.address, {
              from: account1,
            });
          });
        
          it("Should authorize EO_STAKING to take stakes out of the STAKE_VAULT", async () => {
            return STAKE_VAULT.grantRole(stakeRoleB32, EO_STAKING.address, {
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
        
          it("Should mint 300000 tokens to account2", async () => {
            return UTIL_TKN.mint(account2, "300000000000000000000000", {
              from: account1,
            });
          });
        
          it("Should retrieve balanceOf(300000) Pruf tokens @account2", async () => {
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
            console.log(
              "//**************************************END STAKE_VAULT SETUP**********************************************/"
            );
            return new Promise((resolve) => setTimeout(resolve, ms));
          }

          it("Should set stake level1", async () => {
            console.log("//**************************************BEGIN STAKE_VAULT TEST**********************************************/");
            return EO_STAKING.setStakeLevels(
              "1",
              "1000000000000000000000",
              "100000000000000000000000",
              "10",
              "50",
              {
                from: account1,
              }
            );
          });
        
          it("Should stake 100000ü on account2", async () => {
            return EO_STAKING.stakeMyTokens("100000000000000000000000", "1", {
              from: account2,
            });
          });
        
          it("Should retrieve balanceOf(100000) Pruf tokens @stake_tkn(2)", async () => {
            var Balance = [];
        
            return await STAKE_VAULT.stakeOfToken(
              '1',
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
        
          it("Should retrieve balanceOf(200000) Pruf tokens @account2", async () => {
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
        
          it("Should authorize account1 as STAKE_ADMIN", async () => {
            return STAKE_VAULT.grantRole(stakeRoleB32, account1, {
              from: account1,
            });
          });
          
          it("Should release stake", async () => {
            return STAKE_VAULT.releaseStake(
                '1',
              { from: account1 }
            );
          });
        
          it("Should retrieve balanceOf(300000) Pruf tokens @account2", async () => {
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
        
          it("Should unauthorize account1 as STAKE_ADMIN", async () => {
            return STAKE_VAULT.revokeRole(stakeRoleB32, account1, {
              from: account1,
            });
          });
        
          it("Should stake 100000ü on account2", async () => {
            return EO_STAKING.stakeMyTokens("100000000000000000000000", "1", {
              from: account2,
            });
          });
          
          it("Should transfer stake_tkn(1) to STAKE_VAULT", async () => {
            return STAKE_TKN.transferFrom(
                account2,
                STAKE_VAULT.address,
                '2',
              { from: account2 }
            );
          });
        
          it("Should authorize account1 to transfer ERC721s", async () => {
            return STAKE_VAULT.grantRole(assetTransferRoleB32, account1, {
              from: account1,
            });
          });
          
          it("Should transfer stake_tkn(2) back to account2", async () => {
            return STAKE_VAULT.transferERC721Token(
                account2,
                '2',
                STAKE_TKN.address,
              { from: account1 }
            );
          });
        
          it("Should authorize account1 as STAKE_ADMIN", async () => {
            return STAKE_VAULT.grantRole(stakeRoleB32, account1, {
              from: account1,
            });
          });
          
          it("Should give STAKE_VAULT 100000 tokens", async () => {
            return STAKE_VAULT.takeStake(
                '2',
                '100000000000000000000000',
              { from: account1 }
            );
          });
        
          it("Should retrieve balanceOf(100000) Pruf tokens @STAKE_VAULT", async () => {
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
        
          it("Should retrieve balanceOf(100000) Pruf tokens @account2", async () => {
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
        
          it("Should unauthorize account1 as STAKE_ADMIN", async () => {
            return STAKE_VAULT.revokeRole(stakeRoleB32, account1, {
              from: account1,
            });
          });
          
          it("Should pause STAKE_VAULT", async () => {
            return STAKE_VAULT.pause(
              { from: account1 }
            );
          });
          
          it("Should unpause STAKE_VAULT", async () => {
            return STAKE_VAULT.unpause(
              { from: account1 }
            );
          });
        });
        