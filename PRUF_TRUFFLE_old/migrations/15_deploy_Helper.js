const PRUF_Helper = artifacts.require('./Helper');

module.exports = function(deployer){
    deployer.deploy(PRUF_Helper);
};