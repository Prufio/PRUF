const PRUF_PRESALE = artifacts.require('PRESALE');

module.exports = function(deployer){
    deployer.deploy(PRUF_PRESALE);
};