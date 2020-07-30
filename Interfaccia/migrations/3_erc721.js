const token = artifacts.require("ERC721");

module.exports = function(deployer) {
  deployer.deploy(token);
};
