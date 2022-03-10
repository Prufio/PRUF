const PRUF_CLOCK = artifacts.require('../ReleaseCandidates/CLOCK');

module.exports = function(deployer){
    deployer.deploy(PRUF_CLOCK);
};