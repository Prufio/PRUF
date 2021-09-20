const PRUF_STOR = artifacts.require('../ReleaseCandidates/STOR');

module.exports = function(deployer){
    deployer.deploy(PRUF_STOR);
};