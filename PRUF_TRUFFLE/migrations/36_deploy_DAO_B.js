const PRUF_DAO_B = artifacts.require('../ReleaseCandidates/DAO_LAYER_B');

module.exports = function(deployer){
    deployer.deploy(PRUF_DAO_B);
};