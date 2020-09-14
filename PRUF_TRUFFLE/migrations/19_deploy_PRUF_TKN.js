const PRUF_TKN = artifacts.require('./UTIL_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_TKN);
};