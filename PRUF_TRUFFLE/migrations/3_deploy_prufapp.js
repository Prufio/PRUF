const PRUF_app = artifacts.require('./PRUF_APP');

module.exports = function(deployer){
    deployer.deploy(PRUF_app);
};