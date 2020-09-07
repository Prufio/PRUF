const PRUF_SRV_TKN = artifacts.require('./PRUF_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_SRV_TKN);
};