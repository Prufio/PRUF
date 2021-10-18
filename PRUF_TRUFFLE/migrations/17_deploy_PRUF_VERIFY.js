const PRUF_VERIFY = artifacts.require('../InProgress/VERIFY');

module.exports = function(deployer){
    deployer.deploy(PRUF_VERIFY);
};