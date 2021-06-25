const PRUF_REWARDS_VAULT = artifacts.require('REWARDS_VAULT');

module.exports = function(deployer){
    deployer.deploy(PRUF_REWARDS_VAULT);
};