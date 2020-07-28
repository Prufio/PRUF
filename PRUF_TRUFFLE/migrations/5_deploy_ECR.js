const ECR = artifacts.require('./ECR');

module.exports = function(deployer){
    deployer.deploy(ECR);
};