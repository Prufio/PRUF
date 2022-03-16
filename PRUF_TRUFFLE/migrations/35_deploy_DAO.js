const PRUF_DAO = artifacts.require('../ReleaseCandidates/DAO');

module.exports = function(deployer){
    deployer.deploy(PRUF_DAO);
};