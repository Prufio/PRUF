const PRUF_AC_MGR = artifacts.require('./PRUF_AC_MGR');

module.exports = function(deployer){
    deployer.deploy(PRUF_AC_MGR);
};