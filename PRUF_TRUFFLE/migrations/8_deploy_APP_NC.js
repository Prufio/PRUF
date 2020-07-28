const APP_NC = artifacts.require('./APP_NC');

module.exports = function(deployer){
    deployer.deploy(APP_NC);
};