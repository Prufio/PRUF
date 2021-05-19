const PRUF_PURCHASE = artifacts.require('PURCHASE');

module.exports = function(deployer){
    deployer.deploy(PRUF_PURCHASE);
};