const PRUF_CLOCK = artifacts.require('../ReleaseCandidates/FAKE_CLOCK');

module.exports = function(deployer){
    deployer.deploy(PRUF_CLOCK);
};