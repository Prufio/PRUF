const PRUF_ID_MGR = artifacts.require('../ReleaseCandidates/ID_MGR');

module.exports = function(deployer){
    deployer.deploy(PRUF_ID_MGR);
};