const PRUF_APP_NC = artifacts.require('../InProgress/APP_NC');

module.exports = function(deployer){
    deployer.deploy(PRUF_APP_NC);
};