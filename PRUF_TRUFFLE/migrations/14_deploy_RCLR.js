const PRUF_RCLR = artifacts.require('./RCLR');

module.exports = function(deployer){
    deployer.deploy(PRUF_RCLR);
};