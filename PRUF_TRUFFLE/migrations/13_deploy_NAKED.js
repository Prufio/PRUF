const PRUF_NAKED = artifacts.require('./NAKED');

module.exports = function(deployer){
    deployer.deploy(PRUF_NAKED);
};