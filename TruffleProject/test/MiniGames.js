const time = require("./Tools/time");
const minigames = artifacts.require("MiniGames.sol");
const charactersNames = ["Character #1", "Character #2"];

contract("MiniGames", (accounts) => {
	let [owner, alice, bob] = accounts;
	let contractInstance;
	let firstCharacter;
	let secondCharacter;

	beforeEach(async () => {
		contractInstance = await minigames.new();
		firstCharacter = await contractInstance.createRandomCharacter(charactersNames[0], {from: alice, value: 5000000000000000});
		secondCharacter = await contractInstance.createRandomCharacter(charactersNames[1], {from: bob, value: 5000000000000000});
	})

	afterEach(async () => {
		await contractInstance.kill();
	})

	it("owner should be able to set randomNumber", async() => {
		const setup = await contractInstance._setRandomNumber(15, {from: owner});
		assert.strictEqual(setup.receipt.status, true);
	})

	it("should not be able to set randomNumber if not the owner", async() => {
		try {
    	   	await contractInstance._setRandomNumber(15, {from: alice});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
  		assert(false, "The contract did not throw an error");
	})

	//Test effettuati su un solo gioco: per gli altri è analogo
	it("should be able to play sumDice", async() => {
		const setup = await contractInstance._setRandomNumber(17, {from: owner});

		await time.advanceTime(360);
		await time.advanceBlock();

		const play = await contractInstance.sumDice(firstCharacter.logs[0].args.id.words[0], 7, 1, {from: alice});
		assert.strictEqual(play.receipt.status, true);
	})

	it("should not be able to play sumDice with someone else's character", async() => {
		const setup = await contractInstance._setRandomNumber(17, {from: owner});

		await time.advanceTime(360);
		await time.advanceBlock();

		try {
    	   	await contractInstance.sumDice(firstCharacter.logs[0].args.id.words[0], 7, 1, {from: bob});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
  		assert(false, "The contract did not throw an error");
	})

	it("should not be able to play sumDice - incorrect amount of xp", async() => {
		const setup = await contractInstance._setRandomNumber(17, {from: owner});

		await time.advanceTime(360);
		await time.advanceBlock();

		try {
    	   	await contractInstance.sumDice(firstCharacter.logs[0].args.id.words[0], 7, 30, {from: alice});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
  		assert(false, "The contract did not throw an error");
	})

	it("should not be able to play sumDice - character is not ready", async() => {
		const setup = await contractInstance._setRandomNumber(17, {from: owner});

		try {
    	   	await contractInstance.sumDice(firstCharacter.logs[0].args.id.words[0], 7, 20, {from: alice});
    		assert(true);
  		}
  		catch (err) {
    		return;
  		}
  		assert(false, "The contract did not throw an error");
	})
})