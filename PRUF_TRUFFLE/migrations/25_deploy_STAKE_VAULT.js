const PRUF_STAKE_VAULT = artifacts.require('../Released/STAKE_VAULT');

module.exports = function(deployer){
    deployer.deploy(PRUF_STAKE_VAULT);
};