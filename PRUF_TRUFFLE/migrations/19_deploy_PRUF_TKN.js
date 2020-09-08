const UTIL_TKN = artifacts.require('./UTIL_TKN');

module.exports = function(deployer){
    deployer.deploy(UTIL_TKN);
};