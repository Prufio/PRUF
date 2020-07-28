const AC_MGR = artifacts.require('./AC_MGR');

module.exports = function(deployer){
    deployer.deploy(AC_MGR);
};