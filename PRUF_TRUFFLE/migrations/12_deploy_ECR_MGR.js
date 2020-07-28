const ECR_MGR = artifacts.require('./ECR_MGR');

module.exports = function(deployer){
    deployer.deploy(ECR_MGR);
};