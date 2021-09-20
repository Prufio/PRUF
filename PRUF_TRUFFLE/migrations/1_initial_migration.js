const Migrations = artifacts.require("../Test/Migrations");

module.exports = function (deployer) {
  deployer.deploy(Migrations);
};
