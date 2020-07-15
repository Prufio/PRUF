const Migrations = artifacts.require("Migrations");

module.exports = function (deployer) {
  deployer.deploy(PRUF_AC_manager_065);
  deployer.deploy(PRUF_ACToken);
  deployer.deploy(PRUF_app_065);
  deployer.deploy(PRUF_AssetToken);
  deployer.deploy(PRUF_NP_065);
  deployer.deploy(PRUF_simpleEscrow_065);
  deployer.deploy(PRUF_storage_065);
};
