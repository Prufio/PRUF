const PRUF_ECR = artifacts.require('../InProgress/ECR');

module.exports = function(deployer){
    deployer.deploy(PRUF_ECR);
};