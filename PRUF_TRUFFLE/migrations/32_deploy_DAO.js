const PRUF_DAO = artifacts.require('../InProgress/DAO');

module.exports = function(deployer){
    deployer.deploy(PRUF_DAO);
};