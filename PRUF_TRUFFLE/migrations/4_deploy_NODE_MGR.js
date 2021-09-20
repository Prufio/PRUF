const PRUF_NODE_MGR = artifacts.require('../ReleaseCandidates/NODE_MGR');

module.exports = function(deployer){
    deployer.deploy(PRUF_NODE_MGR);
};