const PRUF_NODE_BLDR = artifacts.require('../ReleaseCandidates/NODE_BLDR');

module.exports = function(deployer){
    deployer.deploy(PRUF_NODE_BLDR);
};