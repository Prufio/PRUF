const PRUF_APP = artifacts.require('../ReleaseCandidates/APP');

module.exports = function(deployer){
    deployer.deploy(PRUF_APP);
};