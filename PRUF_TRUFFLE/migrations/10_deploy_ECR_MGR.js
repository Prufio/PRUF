const PRUF_ECR_MGR = artifacts.require('../InProgress/ECR_MGR');

module.exports = function(deployer){
    deployer.deploy(PRUF_ECR_MGR);
};