const PRUF_AC_TKN = artifacts.require('./AC_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_AC_TKN);
};