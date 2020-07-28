const PRUF_APP = artifacts.require('./APP');

module.exports = function(deployer){
    deployer.deploy(PRUF_APP);
};