const Characters = artifacts.require("C:/Users/giovanna/Desktop/UNIBG/Tesi_Progetto/TruffleProject/contracts/Characters.sol");
const Breeding = artifacts.require("C:/Users/giovanna/Desktop/UNIBG/Tesi_Progetto/TruffleProject/contracts/Breeding.sol");

/*module.exports = function(deployer) {
	deployer.deploy(Characters);
	deployer.deploy(Breeding);
}*/

/*module.exports = function(deployer) {
	deployer.deploy(Characters)
		.then(function() {
  			return deployer.deploy(Breeding, Characters.address);
	});
}*/

module.exports = function(deployer, network, accounts) {

    deployer.then(async () => {
        await deployer.deploy(Characters);
        await deployer.deploy(Breeding, Characters.address);
    });
};


/*module.exports = async function(deployer) {
	let char = await deployer.deploy(Characters);
	
	deployer.deploy(Breeding, char);
	
};*/
