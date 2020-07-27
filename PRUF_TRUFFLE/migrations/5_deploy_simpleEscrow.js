const PRUF_simpleEscrow = artifacts.require('./PRUF_simpleEscrow');

module.exports = function(deployer){
    deployer.deploy(PRUF_simpleEscrow);
};