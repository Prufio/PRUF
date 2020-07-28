const STOR = artifacts.require('./STOR');

module.exports = function(deployer){
    deployer.deploy(STOR);
};