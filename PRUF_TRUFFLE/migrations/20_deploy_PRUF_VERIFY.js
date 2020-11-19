const PRUF_VERIFY = artifacts.require('./VERIFY');

module.exports = function(deployer){
    deployer.deploy(PRUF_VERIFY);
};