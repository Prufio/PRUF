const APP = artifacts.require('./APP');

module.exports = function(deployer){
    deployer.deploy(APP);
};