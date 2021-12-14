const PRUF_UD_NODE_BLDR = artifacts.require('../ReleaseCandidates/UD_721');

module.exports = function(deployer){
    deployer.deploy(PRUF_UD_NODE_BLDR);
};