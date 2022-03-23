const PRUF_DAO_STOR = artifacts.require('../ReleaseCandidates/DAO_STOR');

module.exports = function(deployer){
    deployer.deploy(PRUF_DAO_STOR);
};