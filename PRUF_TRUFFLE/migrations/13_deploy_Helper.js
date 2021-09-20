const PRUF_Helper = artifacts.require('../Test/Helper');

module.exports = function(deployer){
    deployer.deploy(PRUF_Helper);
};