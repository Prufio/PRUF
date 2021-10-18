const PRUF_UTIL_TKN = artifacts.require('../Released/UTIL_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_UTIL_TKN);
};