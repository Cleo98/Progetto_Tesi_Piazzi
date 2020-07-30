const minigames = artifacts.require("MiniGames");

module.exports = function(deployer) {
  deployer.deploy(minigames);
};
