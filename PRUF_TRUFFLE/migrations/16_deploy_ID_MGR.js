const PRUF_ID_MGR = artifacts.require('ID_MGR');

module.exports = function(deployer){
    deployer.deploy(PRUF_ID_MGR);
};