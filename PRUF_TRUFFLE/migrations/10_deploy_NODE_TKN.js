const PRUF_NODE_TKN = artifacts.require('NODE_TKN');

module.exports = function(deployer){
    deployer.deploy(PRUF_NODE_TKN);
};