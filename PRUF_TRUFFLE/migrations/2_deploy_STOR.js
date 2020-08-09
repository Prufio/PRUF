const PRUF_STOR = artifacts.require('./STOR');

module.exports = function(deployer){
    deployer.deploy(PRUF_STOR);
};