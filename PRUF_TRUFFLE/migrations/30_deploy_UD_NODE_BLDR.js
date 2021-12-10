const PRUF_UD_NODE_BLDR = artifacts.require('../ReleaseCandidates/PRUF_UD-NODE_BLDR');

module.exports = function(deployer){
    deployer.deploy(PRUF_UD_NODE_BLDR);
};