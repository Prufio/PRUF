const PRUF_STAKE_VAULT = artifacts.require('STAKE_VAULT');

module.exports = function(deployer){
    deployer.deploy(PRUF_STAKE_VAULT);
};