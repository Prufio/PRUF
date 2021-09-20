const PRUF_PIP = artifacts.require('../InProgress/PIP');

module.exports = function(deployer){
    deployer.deploy(PRUF_PIP);
};