const PRUF_AC_MGR = artifacts.require('./AC_MGR');

module.exports = function(deployer){
    deployer.deploy(PRUF_AC_MGR);
};