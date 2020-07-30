const laboratory = artifacts.require("Laboratory");

module.exports = function(deployer) {
  deployer.deploy(laboratory);
};
