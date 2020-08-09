const PRUF_APP_NC = artifacts.require('./APP_NC');

module.exports = function(deployer){
    deployer.deploy(PRUF_APP_NC);
};