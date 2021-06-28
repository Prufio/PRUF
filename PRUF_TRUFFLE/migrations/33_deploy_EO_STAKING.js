const PRUF_EO_STAKING = artifacts.require('EO_STAKING');

module.exports = function(deployer){
    deployer.deploy(PRUF_EO_STAKING);
};