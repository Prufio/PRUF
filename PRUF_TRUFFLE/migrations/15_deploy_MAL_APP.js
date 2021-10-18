const PRUF_MAL_APP = artifacts.require('../Test/MAL_APP');

module.exports = function(deployer){
    deployer.deploy(PRUF_MAL_APP);
};