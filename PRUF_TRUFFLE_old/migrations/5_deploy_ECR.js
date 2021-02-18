const PRUF_ECR = artifacts.require('./ECR');

module.exports = function(deployer){
    deployer.deploy(PRUF_ECR);
};