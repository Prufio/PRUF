const PRUF_A_TKN = artifacts.require('../ReleaseCandidates/A_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_A_TKN);
};