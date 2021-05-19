const PRUF_PIP = artifacts.require('PIP');

module.exports = function(deployer){
    deployer.deploy(PRUF_PIP);
};