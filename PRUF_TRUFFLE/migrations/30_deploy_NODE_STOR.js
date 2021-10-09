const PRUF_NODE_STOR = artifacts.require('../ReleaseCandidates/NODE_STOR');

module.exports = function(deployer){
    deployer.deploy(PRUF_NODE_STOR);
};