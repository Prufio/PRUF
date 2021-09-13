const PRUF_STAKE_TKN = artifacts.require('STAKE_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_STAKE_TKN);
};