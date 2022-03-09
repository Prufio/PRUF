const PRUF_DAO_A = artifacts.require('../ReleaseCandidates/DAO_LAYER_A');

module.exports = function(deployer){
    deployer.deploy(PRUF_DAO_A);
};