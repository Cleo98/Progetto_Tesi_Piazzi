const time = require("./Tools/time");
const laboratory = artifacts.require("Laboratory.sol");
const charactersNames = ["Character #1"];

contract("Laboratory", (accounts) => {
	let [owner, alice] = accounts;
	let contractInstance;
	let firstCharacter;

	beforeEach(async () => {
		contractInstance = await laboratory.new();
		firstCharacter = await contractInstance.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
		assert.strictEqual(firstCharacter.receipt.status, true); 
        assert.strictEqual(firstCharacter.logs[0].args.name, charactersNames[0]);
	})

	afterEach(async () => {
		await contractInstance.kill();
	})

	it("should not be able to upgrade a character - character is not ready", async () => {
		try {
    	   	await contractInstance.upgradeCharacter(firstCharacter.logs[0].args.id.words[0], {from: alice});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
  		assert(false, "The contract did not throw an error");

	})

	it("should not be able to upgrade a character - character has not enough xp", async () => {
		await time.advanceTime(360);
		await time.advanceBlock();

		try {
    	   	await contractInstance.upgradeCharacter(firstCharacter.logs[0].args.id.words[0], {from: alice});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
  		assert(false, "The contract did not throw an error");

	})

	it("should be able to upgrade a character", async () => {
		const setup = contractInstance.changeXp(firstCharacter.logs[0].args.id.words[0], 1500, {from: owner});

		await time.advanceTime(360);
		await time.advanceBlock();

		const result = await contractInstance.upgradeCharacter(firstCharacter.logs[0].args.id.words[0], {from: alice});
    	assert.strictEqual(result.receipt.status, true);
	})

})