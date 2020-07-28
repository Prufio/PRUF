const PRUF_ECR_MGR = artifacts.require('./ECR_MGR');

module.exports = function(deployer){
    deployer.deploy(PRUF_ECR_MGR);
};