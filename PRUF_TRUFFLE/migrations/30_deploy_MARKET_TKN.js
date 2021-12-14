const PRUF_MARKET_TKN = artifacts.require('../inProgress/MARKET_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_MARKET_TKN);
};