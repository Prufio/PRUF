const PRUF_EO_STAKING = artifacts.require('../Released/EO_STAKING');

module.exports = function(deployer){
    deployer.deploy(PRUF_EO_STAKING);
};