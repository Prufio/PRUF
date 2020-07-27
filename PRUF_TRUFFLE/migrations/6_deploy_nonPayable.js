const PRUF_NP = artifacts.require('./PRUF_NP');

module.exports = function(deployer){
    deployer.deploy(PRUF_NP);
};