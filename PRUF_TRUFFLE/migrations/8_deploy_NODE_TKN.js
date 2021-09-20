const PRUF_NODE_TKN = artifacts.require('../ReleaseCandidates/NODE_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_NODE_TKN);
};