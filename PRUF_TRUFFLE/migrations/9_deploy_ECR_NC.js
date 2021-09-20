const PRUF_ECR_NC = artifacts.require('../InProgress/ECR_NC');

module.exports = function(deployer){
    deployer.deploy(PRUF_ECR_NC);
};