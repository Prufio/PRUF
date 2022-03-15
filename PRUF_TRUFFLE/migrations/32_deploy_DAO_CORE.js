const PRUF_DAO_CORE = artifacts.require('../ReleaseCandidates/DAO_CORE');

module.exports = function(deployer){
    deployer.deploy(PRUF_DAO_CORE);
};